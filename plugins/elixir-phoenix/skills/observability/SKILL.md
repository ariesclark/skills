---
name: observability
description: >-
  Observability for Elixir/Phoenix — structured (JSON) logging, :telemetry events/handlers, OpenTelemetry tracing, error reporting (e.g. Sentry), and metrics/LiveDashboard. Use when adding logging, instrumentation, traces, or metrics, or reviewing how an app reports what it's doing in production. Triggers: logging, structured logs, logger_json, telemetry, OpenTelemetry, traces, metrics, LiveDashboard, Sentry.
---

# Observability

Three distinct pillars — don't conflate them: **logs** (what happened), **traces** (how a request flowed), **metrics** (aggregate rates/latencies). Pairs with `elixir-conventions`.

## RULES
1. **Log structured, not interpolated.** `Logger.error("charge failed", order_id: id, reason: inspect(reason))` — pass metadata, don't bake values into the message string (so logs stay queryable and group well).
2. **JSON logs in production.** Use a JSON formatter (e.g. `logger_json`) so a log pipeline can index fields. **No ANSI color codes in prod** — they corrupt JSON and log parsers (colors are for dev consoles only).
3. **Attach `:telemetry` handlers in `Application.start/2`,** once, not per-request. Handler functions must be fast and must not crash (a raising handler gets detached).
4. **Errors/crashes go to an error reporter** (e.g. Sentry) with a stacktrace — that's separate from logs. A logged string is not an exception report (see `elixir-conventions`: raise the unexpected so it's captured with a trace).
5. **Trace with OpenTelemetry** for cross-service request flow; propagate context across process/HTTP boundaries. Correlate logs to traces by injecting `trace_id`/`span_id` into logger metadata.
6. **Don't log secrets/PII** (see `phoenix-security`); filter params and scrub headers.
7. **Set log level by env** (`:info`+ in prod, `:debug` in dev) and rate-limit noisy error reporting.

## Structured logging

```elixir
# Don't — values trapped in the message; ANSI colors in prod
Logger.info("user #{id} did #{action}")

# Do — message is the event, data is metadata
Logger.info("user.action", user_id: id, action: action)
```

```elixir
# prod: JSON formatter, metadata allowlist, no colors
config :logger, :default_handler,
  formatter: {LoggerJSON.Formatters.Basic, metadata: [:request_id, :trace_id, :span_id, :user_id]}
```

## :telemetry

```elixir
# Application.start/2
:telemetry.attach_many(
  "obs-handlers",
  [[:my_app, :repo, :query], [:phoenix, :endpoint, :stop]],
  &MyApp.Telemetry.handle_event/4,
  nil
)

def handle_event([:my_app, :repo, :query], %{total_time: t}, meta, _) do
  if System.convert_time_unit(t, :native, :millisecond) > 500,
    do: Logger.warning("slow query", source: meta.source, ms: ...)
end
```

Use `Telemetry.Metrics` + a reporter (Prometheus, or `Phoenix.LiveDashboard` for a live view) to turn events into metrics. Don't hand-roll counters.

## Tracing (OpenTelemetry)
- Set up the OTel SDK + auto-instrumentation libs (`opentelemetry_phoenix`, `opentelemetry_ecto`, `opentelemetry_bandit`/cowboy, `opentelemetry_oban`).
- Propagate context across HTTP and into spawned processes/jobs; without propagation a "trace" is a single orphaned span.
- Add a logger-metadata bridge so each log line carries the active `trace_id`/`span_id`.

## Error reporting vs logs
Errors and logs are different pipelines. Crashes/exceptions should reach an error reporter (Sentry et al.) **with a stacktrace**; structured logs are for expected, queryable events. If something interesting is also a bug, raise it — don't just log a string.

---
*Adapted and expanded from [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide) (MIT, © 2026 Joseph Morgan).*
