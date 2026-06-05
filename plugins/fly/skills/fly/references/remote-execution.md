# Remote execution: shell commands

`fly ssh console -C` runs commands on a live machine. Payload goes inline as the `-C` value. Add `--machine <id>` to target one specifically (list with `fly machine list -q -a <app>`).

```bash
fly ssh console -a <app> -qC "<command>"
```

**Example: print uptime:**

```bash
fly ssh console -a <app> -qC "cat /proc/uptime"
```

**Example: hostname on a specific machine:**

```bash
fly ssh console -a <app> --machine <machine-id> -qC "hostname"
```

## Common pattern: the app's own remote console

Many runtimes ship a binary that evaluates code on the running node. Prefer the form that attaches
to the **already-running** process (full app state) over one that boots a fresh, stateless instance,
e.g. an Elixir/Phoenix release's `bin/<app> rpc` (not `eval`), a Rails `bin/rails runner`, a
Node REPL over the app socket. For the Elixir/Phoenix specifics, see `references/elixir-rpc.md`.
