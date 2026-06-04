# ariesclark — Claude Code skills

A Claude Code plugin of idiomatic **Elixir & Phoenix** skills (plus a Fly.io ops skill), packaged as a plugin and a single-plugin marketplace.

## Install

```text
/plugin marketplace add ariesclark/skills
/plugin install ariesclark@ariesclark
```

Or, for local development, drop this repo under a skills directory (`~/.claude/skills/` or a project's `.claude/skills/`) — the `.claude-plugin/plugin.json` makes it load in place as `ariesclark@skills-dir`.

## Skills

### Elixir & Phoenix
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

### Infrastructure
| Skill | What it covers |
| --- | --- |
| `fly` | Fly.io ops — Prometheus/VictoriaLogs queries, `fly ssh`, production Postgres |

## Credits

- The Elixir & Phoenix skills are adapted and expanded from **[elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide)** by Joseph Morgan (MIT).
- `elixir-conventions` is based on Chris Keathley's **[Good and Bad Elixir](https://keathley.io/blog/good-and-bad-elixir.html)**.

## License

MIT — see [LICENSE](LICENSE).
