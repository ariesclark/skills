# Elixir / Phoenix release RPC

A concrete instance of the "run the app's own remote console" pattern (see
`references/remote-execution.md`), for Mix releases. Adapt the binary/idiom for other runtimes.

| Subcommand | What it does |
|---|---|
| `bin/<app> eval 'code'` | Fresh mini-VM (`:nonode@nohost`), no supervision tree, no Repo. One-off code only. |
| `bin/<app> rpc 'code'` | Runs on the **already-running** release. Full app state. **Use this.** |
| `bin/<app> remote` | Interactive IEx on the running release. |

`rpc` takes the Elixir as argv.

```bash
fly ssh console -a <app> -qC \
  "/app/bin/<app> rpc '<expression>'"
```

**Example — print the running app version** (substitute `<otp_app>`, the OTP atom):

```bash
fly ssh console -a <app> -qC \
  "/app/bin/<app> rpc 'Application.spec(:<otp_app>, :vsn) |> IO.inspect()'"
```

**Example — confirm `rpc` not `eval`** (eval would return `:nonode@nohost`):

```bash
fly ssh console -a <app> -qC \
  "/app/bin/<app> rpc 'Node.self() |> IO.inspect()'"
```

**Don't dump the whole environment.** Introspection like `System.get_env()` returns secrets too
(the Erlang `RELEASE_COOKIE`, DB URLs, API keys). Select only the keys you need, and redact
sensitive values before saving or sharing the output.

Quoting: outer `"..."`, inner `'...'` around the Elixir. Escape inner `'` as `'\''` or use `~s|...|` / `~S|...|` sigils.
