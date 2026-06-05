---
name: fly
description: >-
  Operate Fly.io infrastructure — query the org's hosted Prometheus and VictoriaLogs, run commands on live app machines via SSH, and connect to the production database.
when_to_use: >-
  Use when a task touches the `fly` CLI, the Fly Prometheus or VictoriaLogs API, a live app release, or the production database — e.g. running `fly ssh console`, an RPC into prod, `psql` against prod, a Prometheus query, searching the logs, or checking what's on the production node.
allowed-tools: Bash(fly tokens create readonly:*) Bash(fly tokens list:*) Bash(fly machine list:*) Bash(fly pg db list:*) Bash(fly pg config show:*) Bash(fly pg events list:*) Bash(curl -sG https://api.fly.io/prometheus/:*) Bash(curl -sG https://api.fly.io/victorialogs/:*) Bash(date:*) Bash(jq:*) Bash(git remote -v:*) Bash(find . -name fly.toml:*) WebFetch(domain:fly.io)
disallowed-tools: Bash(fly auth token:*)
---

# Fly.io operations

`fly` and `flyctl` are aliases — prefer `fly`.

## Workspace

Resolve the **organization** and **application** before acting:

1. Nearest `fly.toml` (`app = "..."`) — `find . -name fly.toml`.
2. Repo's `git remote` or project name — `git remote -v`.
3. Ask the user.

Substitute resolved values into `<organization>`, `<app>`, `<db-app>`, `<db-name>` below.
`<model>` (used in token `--name` for the audit log) is your own model name.

## Authentication

For `fly` CLI subcommands, don't pass `-t` — the CLI reads OAuth from `~/.fly/config.yml` automatically (set up via `fly auth login`), and OAuth covers every subcommand, including `ssh console`. Don't reuse the `readonly` token minted below (it authorizes the HTTPS API only) for SSH — its scope doesn't cover it. A purpose-built scoped SSH credential does exist if you ever need one (`fly tokens create ssh -a <app>`), but OAuth is simplest here.

For direct API calls (curl), mint a short-lived `readonly` token per call:

```bash
curl -H "Authorization: $(fly tokens create readonly \
  --name '<model>: <≤32-char description>' \
  --expiry 30s --org <organization>)" \
  https://...
```

The output already carries the `FlyV1 ` prefix.

### Rules

- **Inline only.** Never `echo` / `cat` / redirect a token, or assign to a variable that survives across commands. If a macaroon appears in chat, treat as compromised and rotate.
- **`--name`** = `"<model>: <≤32-char reason>"` — lands in Fly's audit log.
- **`--expiry 30s`** — long enough for one API call, short enough to die fast.
- **`readonly` is the only scope to mint.** Org-wide read covers everything curl-style here.
- **Never use `fly auth token`** — it's deprecated and prints the OAuth token the CLI is currently using; leave that credential to the CLI's implicit lookup.
- **No mutations from this skill.** Deploys, secrets, machine destroys, DDL, DB writes — ask the user.
- If a token leaks: `fly tokens list --scope org --org <organization>` → `fly tokens revoke <id>`.

## Observability

Metrics (Prometheus) and logs (VictoriaLogs) are queried over HTTPS with an inline `readonly`
token. Reach for **Prometheus** for machine/app time series (CPU, memory, load), and
**VictoriaLogs** for queryable, historical log search and aggregation (`fly logs` only tails the
live buffer).

→ Endpoints, query syntax, and worked examples: `references/observability.md`

## Remote execution

`fly ssh console -a <app> -qC "<command>"` runs a command on a live machine (add `--machine <id>`
to target one; list with `fly machine list -q -a <app>`).

A common pattern is invoking the app's own release/console binary to evaluate code on the
**already-running** node (full app state) rather than a fresh, stateless process.

→ Shell patterns and examples: `references/remote-execution.md`
→ Elixir/Phoenix release RPC (an instance of that pattern): `references/elixir-rpc.md`

## Database (Postgres)

Two ways in: `fly pg <subcommand> -a <db-app>` (`db list` / `config show` / `events list` — no SSH,
hits the Fly API), and psql over SSH on the DB machine — the container holds the password in
`$OPERATOR_PASSWORD`, and SQL streams via stdin so there's no argv escaping. Reads only — mutations
(writes, DDL, migrations) are for the user to run.

→ psql here-string/heredoc patterns and `fly pg` recipes: `references/database.md`
