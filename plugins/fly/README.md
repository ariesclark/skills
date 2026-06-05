# Fly.io Ops

Operate Fly.io infrastructure: query the org's hosted Prometheus and
VictoriaLogs, run commands on live app machines via SSH, and connect to the
production database.

## Install

```text
/plugin marketplace add ariesclark/skills
/plugin install fly@ariesclark
```

## The `fly` skill

A single skill for Fly.io operations, scoped to read-only tools so it can
investigate production without mutating it:

- **Metrics:** query the org's hosted Prometheus over HTTPS with a short-lived, minted read-only token.
- **Logs:** search historical, queryable logs in VictoriaLogs, not just the live `fly logs` tail.
- **Remote execution:** run commands on a live machine via `fly ssh console`, including the app's own release console (for example, an Elixir/Phoenix `rpc`).
- **Database:** connect psql over SSH on the DB machine, plus `fly pg` cluster inspection. Reads only; mutations are left to the user.

Query syntax and worked examples live in `skills/fly/references/`.

## License

MIT. See [LICENSE](../../LICENSE).
