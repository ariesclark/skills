# Elixir / Phoenix release RPC

A concrete instance of the "run the app's own remote console" pattern (see
`references/remote-execution.md`), for Mix releases. Adapt the binary/idiom for other runtimes.

| Subcommand              | What it does                                                                       |
| ----------------------- | ---------------------------------------------------------------------------------- |
| `bin/<app> eval 'code'` | Fresh mini-VM (`:nonode@nohost`), no supervision tree, no Repo. One-off code only. |
| `bin/<app> rpc 'code'`  | Runs on the **already-running** release. Full app state. **Use this.**             |
| `bin/<app> remote`      | Interactive IEx on the running release.                                            |

`rpc` takes the Elixir as argv.

```bash
fly ssh console -a <app> -qC \
  "/app/bin/<app> rpc '<expression>'"
```

**Example: print the running app version** (substitute `<otp_app>`, the OTP atom):

```bash
fly ssh console -a <app> -qC \
  "/app/bin/<app> rpc 'Application.spec(:<otp_app>, :vsn) |> IO.inspect()'"
```

**Example: confirm `rpc` not `eval`** (eval would return `:nonode@nohost`):

```bash
fly ssh console -a <app> -qC \
  "/app/bin/<app> rpc 'Node.self() |> IO.inspect()'"
```

**Don't dump the whole environment.** Introspection like `System.get_env()` returns secrets too
(the Erlang `RELEASE_COOKIE`, DB URLs, API keys). Select only the keys you need, and redact
sensitive values before saving or sharing the output.

Quoting: outer `"..."`, inner `'...'` around the Elixir. Escape inner `'` as `'\''` or use `~s|...|` / `~S|...|` sigils. Inside single-quoted Elixir, write string literals as `~s|...|` so no `"` appears to close the outer double-quotes.

## Capturing live request state (telemetry handler across nodes)

`rpc` is stateful *within a node*: a `:telemetry` handler you attach in one call keeps firing, and
`:persistent_term` you write survives into later `rpc` calls. That lets you observe a real
in-flight request — e.g. the exact header set a request arrives with **after** any CDN/proxy hops,
which the app sees but you can't reconstruct from the client side.

Pattern: **attach a handler that records only what you need → trigger one tagged request → read it
back → detach.** Two gotchas: handlers are **per-node**, so on a multi-machine app attach on every
machine (`fly machine list -q -a <app>`, loop `--machine`); and **redact** — record header *names*
and counts, never cookie/`authorization`/session *values*.

```bash
# 1. Attach on every machine. Store names+count for requests tagged with a probe header.
for mid in $(fly machine list -q -a <app>); do
  fly ssh console -a <app> --machine "$mid" -qC \
    "/app/bin/<app> rpc ':telemetry.attach(~s|hp|, [:phoenix, :endpoint, :stop], fn _, _, m, _ -> c = m[:conn]; if c && Plug.Conn.get_req_header(c, ~s|x-probe|) != [] do :persistent_term.put(:hp, {length(c.req_headers), Enum.map(c.req_headers, &elem(&1, 0))}) end end, nil)'"
done

# 2. Fire a few tagged requests so they spread across machines.
for i in $(seq 1 8); do curl -sS -o /dev/null -w '%{http_code}\n' https://<host>/<path> -H 'x-probe: 1'; done

# 3. Read back from each machine.
for mid in $(fly machine list -q -a <app>); do
  fly ssh console -a <app> --machine "$mid" -qC \
    "/app/bin/<app> rpc 'case :persistent_term.get(:hp, :none) do {n, names} -> IO.puts(~s|COUNT=| <> Integer.to_string(n)); Enum.each(Enum.sort(names), &IO.puts/1); _ -> IO.puts(~s|none|) end'"
done

# 4. ALWAYS clean up — a stray handler + persistent_term should not outlive the probe.
for mid in $(fly machine list -q -a <app>); do
  fly ssh console -a <app> --machine "$mid" -qC \
    "/app/bin/<app> rpc '{:telemetry.detach(~s|hp|), :persistent_term.erase(:hp)}'"
done
```

`if` must be block form (`if cond do … end`), not `if cond, do: … end`, inside the handler `fn`.
`[:phoenix, :endpoint, :stop]` metadata carries `:conn`; requests rejected by the web server
(Bandit/Cowboy) *before* Plug — oversized/too-many headers, malformed request line — never reach
this event, so probe a request you know succeeds.
