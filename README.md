# ariesclark — Claude Code skills

A Claude Code **marketplace** catalog of skills, organized as domain plugins you
install independently. Currently: idiomatic **Elixir & Phoenix** skills and a
**Fly.io** ops skill.

## Install

Add the marketplace once, then install the plugins you want:

```text
/plugin marketplace add ariesclark/skills
/plugin install elixir-phoenix@ariesclark
/plugin install fly@ariesclark
```

## Plugins

### `elixir-phoenix`
Idiomatic Elixir & Phoenix backend skills.

| Skill | What it covers |
| --- | --- |
| `elixir-conventions` | The "Good and Bad Elixir" rules — error tuples vs. raising, `with`/`case`, assertive matching, pipelines |
| `otp` | GenServer, Supervisor/DynamicSupervisor, Task, Registry, ETS, process lifecycle |
| `ecto` | Schemas, per-operation changesets, `cast_assoc`/`cast_embed`, `Ecto.Multi`, migrations, N+1/indexes |
| `phoenix-json-api` | `:api` pipeline, `action_fallback` with no catch-all, a unified error type, pagination, token auth |
| `phoenix-authorization` | Server-side checks, scope-over-filter (IDOR-proof), policy modules |
| `phoenix-security` | Atom exhaustion, SQL injection, XSS, open redirects, password hashing, constant-time comparison |
| `oban` | Worker return semantics (`:ok`/`:cancel`/`:discard`/`{:error}`), idempotency, unique jobs, testing |
| `observability` | Structured JSON logging, `:telemetry`, OpenTelemetry, error reporting, metrics |
| `phoenix-deployment` | `runtime.exs` vs compile-time config, release migrations, runtime env, health checks |
| `elixir-testing` | ExUnit, DataCase/ConnCase, the Ecto sandbox, fixtures, assertive tests |

### `fly`
Fly.io infrastructure ops — Prometheus/VictoriaLogs queries, `fly ssh`, production Postgres.

### `prior-art`
Before building CI, tooling, infra, or reimplementing functionality — search for existing prior art (in-repo patterns, official/upstream repos, reusable actions, libraries) and mirror it instead of hand-rolling.

## Repository layout

```text
.
├── .claude-plugin/
│   └── marketplace.json        # the catalog (pluginRoot: ./plugins)
└── plugins/
    ├── elixir-phoenix/
    │   ├── .claude-plugin/plugin.json
    │   ├── CHANGELOG.md
    │   └── skills/             # one directory per skill
    ├── fly/
    │   ├── .claude-plugin/plugin.json
    │   ├── CHANGELOG.md
    │   └── skills/fly/         # SKILL.md + references/
    └── prior-art/
        ├── .claude-plugin/plugin.json
        ├── CHANGELOG.md
        └── skills/prior-art/
```

## Local development

Add this repo as a local marketplace and install from it — changes to a skill's
`SKILL.md` take effect immediately; other changes need `/reload-plugins`:

```text
/plugin marketplace add /path/to/this/repo
/plugin install elixir-phoenix@ariesclark
```

Validate a plugin's structure and manifest before publishing:

```bash
claude plugin validate ./plugins/elixir-phoenix --strict
claude plugin validate ./plugins/fly --strict
```

## References

- [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide) — Joseph Morgan (MIT); foundation for the Elixir & Phoenix skills.
- Chris Keathley, [Good and Bad Elixir](https://keathley.io/blog/good-and-bad-elixir.html) ([source](https://github.com/keathley/keathley.github.io/blob/master/_posts/2021/2021-05-14-good-and-bad-elixir.md)); foundation for `elixir-conventions`.

## License

MIT — see [LICENSE](LICENSE).
