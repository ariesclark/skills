# Changelog

All notable changes to the `elixir-phoenix` plugin are documented here. This
project follows [Semantic Versioning](https://semver.org).

## [0.2.0]

- `elixir-code-smells`: a review-lens index of Elixir code, design, process, and
  meta-programming anti-patterns (plus the twelve traditional smells), each with
  its own reference file covering the problem, an example, the refactoring that
  fixes it, the matching Credo check, and sources. Mirrors the official Elixir
  anti-pattern guides and the lucasvegi catalog.

## [0.1.0]

Initial release. Ten idiomatic Elixir & Phoenix skills:

- `elixir-conventions`: error tuples vs. raising, `with`/`case`, assertive matching, pipelines
- `otp`: GenServer, Supervisor/DynamicSupervisor, Task, Registry, ETS, process lifecycle
- `ecto`: schemas, per-operation changesets, `cast_assoc`/`cast_embed`, `Ecto.Multi`, migrations, N+1/indexes
- `phoenix-json-api`: `:api` pipeline, `action_fallback`, unified error type, pagination, token auth
- `phoenix-authorization`: server-side checks, scope-over-filter (IDOR-proof), policy modules
- `phoenix-security`: atom exhaustion, SQL injection, XSS, open redirects, password hashing, constant-time comparison
- `oban`: worker return semantics, idempotency, unique jobs, testing
- `observability`: structured JSON logging, `:telemetry`, OpenTelemetry, error reporting, metrics
- `phoenix-deployment`: `runtime.exs` vs compile-time config, release migrations, runtime env, health checks
- `elixir-testing`: ExUnit, DataCase/ConnCase, the Ecto sandbox, fixtures, assertive tests
