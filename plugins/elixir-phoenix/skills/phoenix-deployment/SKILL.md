---
name: phoenix-deployment
description: >-
  Deploying Phoenix/Elixir releases to production — runtime.exs vs config.exs, release migrations, runtime env (PHX_HOST/PHX_SERVER/SECRET_KEY_BASE), assets, health checks, and log levels.
when_to_use: >-
  Use when configuring releases, deploys, or runtime config — `runtime.exs` vs compile-time config, `mix release`, migrations in prod, env like `PHX_HOST`/`SECRET_KEY_BASE`, and health checks — or debugging "works locally, breaks in prod".
---

# Phoenix deployment

The gotchas that pass in dev and fail (or leak) in a release. Pairs with `observability` (prod logging) and `phoenix-security` (secrets).

## RULES
1. **Runtime config goes in `config/runtime.exs`, not `config.exs`.** `config.exs`/`prod.exs` are evaluated at *compile* time and baked into the release — env vars read there are frozen at build. Read `System.get_env`/`fetch_env!` in `runtime.exs`.
2. **`System.fetch_env!/1` for required secrets** (crash on boot if missing) — don't default them to empty strings.
3. **Run migrations explicitly in releases.** No Mix in a release; use a release command / migration module (`MyApp.Release.migrate/0` calling `Ecto.Migrator`). Don't auto-migrate inside `start/2` without care for multi-node startup races.
4. **Set the runtime essentials:** `SECRET_KEY_BASE`, `PHX_HOST` (URL config), `PHX_SERVER=true` (so the endpoint actually serves in a release), `DATABASE_URL`, pool size.
5. **Compile/digest assets at build time;** serve them from the release. Don't run a JS toolchain in the runtime container.
6. **Expose a real health check** that verifies dependencies (DB reachable), not just `200 OK` from the web layer — and distinguish liveness from readiness if your platform uses both.
7. **Prod log level `:info`+ and structured** (see `observability`); `:debug` in prod is a performance and PII risk.

## runtime.exs essentials

```elixir
# config/runtime.exs — evaluated at boot, not build
import Config

if config_env() == :prod do
  config :my_app, MyApp.Repo,
    url: System.fetch_env!("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

  config :my_app, MyAppWeb.Endpoint,
    server: System.get_env("PHX_SERVER") == "true",
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    url: [host: System.fetch_env!("PHX_HOST"), port: 443, scheme: "https"]
end
```

## Release migrations

```elixir
defmodule MyApp.Release do
  @app :my_app
  def migrate do
    Application.load(@app)
    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end
end
# deploy step: bin/my_app eval "MyApp.Release.migrate()"
```

Run migrations as a discrete deploy step **before** the new code starts taking traffic; gate destructive migrations behind expand/contract.

## Common prod-only failures
- Env var read in `config.exs` → baked at build, ignored at runtime. (→ move to `runtime.exs`.)
- Endpoint not serving → forgot `PHX_SERVER=true` / `server: true`.
- Missing `SECRET_KEY_BASE`/`PHX_HOST` → boot crash or wrong URLs in emails/redirects.
- Auto-migrate on boot racing across multiple nodes → run as an explicit, single step.

## Before shipping
`mix compile --warnings-as-errors`, `mix test`, build the release, and dry-run the migration path (`migrate` then `rollback`) against a staging DB.
