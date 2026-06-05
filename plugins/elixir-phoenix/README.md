# Elixir & Phoenix skills

Idiomatic Elixir & Phoenix backend skills: conventions, error handling, Ecto,
OTP, Oban, JSON APIs, authorization, security, observability, deployment, and
testing.

## Install

```text
/plugin marketplace add ariesclark/skills
/plugin install elixir-phoenix@ariesclark
```

## Skills

| Skill | What it covers |
| --- | --- |
| `elixir-conventions` | The "Good and Bad Elixir" rules: error tuples vs. raising, `with`/`case`, assertive matching, pipelines |
| `otp` | GenServer, Supervisor/DynamicSupervisor, Task, Registry, ETS, process lifecycle |
| `ecto` | Schemas, per-operation changesets, `cast_assoc`/`cast_embed`, `Ecto.Multi`, migrations, N+1/indexes |
| `phoenix-json-api` | `:api` pipeline, `action_fallback` with no catch-all, a unified error type, pagination, token auth |
| `phoenix-authorization` | Server-side checks, scope-over-filter (IDOR-proof), policy modules |
| `phoenix-security` | Atom exhaustion, SQL injection, XSS, open redirects, password hashing, constant-time comparison |
| `oban` | Worker return semantics (`:ok`/`:cancel`/`:discard`/`{:error}`), idempotency, unique jobs, testing |
| `observability` | Structured JSON logging, `:telemetry`, OpenTelemetry, error reporting, metrics |
| `phoenix-deployment` | `runtime.exs` vs compile-time config, release migrations, runtime env, health checks |
| `elixir-testing` | ExUnit, DataCase/ConnCase, the Ecto sandbox, fixtures, assertive tests |

The skills cross-reference each other (for example, `phoenix-json-api` builds on
the unified error type from `elixir-conventions`), so installing the whole plugin
gives the most coherent guidance.

## References

- [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide): Joseph Morgan (MIT); foundation for these skills.
- Chris Keathley, [Good and Bad Elixir](https://keathley.io/blog/good-and-bad-elixir.html) ([source](https://github.com/keathley/keathley.github.io/blob/master/_posts/2021/2021-05-14-good-and-bad-elixir.md)); foundation for `elixir-conventions`.

## License

MIT. See [LICENSE](../../LICENSE).
