---
name: oban
description: >-
  Background jobs with Oban: worker design, return-value semantics (:ok / :cancel / :discard / {:error}), idempotency, unique jobs, queues, cron, and testing.
when_to_use: >-
  Use when writing or reviewing Oban workers and their `perform/1` return values, enqueuing background jobs, unique jobs, or cron, and when reasoning about job error/retry/backoff behavior or testing with `Oban.Testing`.
---

# Oban background jobs

Pairs with `elixir-conventions`. The worker's **return value is its control flow**. Getting it right is the difference between a self-healing queue and a retry-storm that pages you.

## RULES
1. **Return values mean things; pick deliberately:**
   - `:ok` / `{:ok, _}` → success.
   - `{:error, reason}` → **transient** failure worth retrying (timeout, network, rate-limit, 5xx). Counts an attempt, backs off, and (with error reporting on) pages.
   - `{:cancel, reason}` → expected, **non-retryable** condition the job can't fix (record gone, invalid state, 4xx). Stops retrying; not an error.
   - `{:discard, reason}` → drop this job without retrying (e.g. now irrelevant).
   - **raise** → genuinely unexpected bug. Gets a real stacktrace + your error reporter; retries per backoff.
2. **Don't return `{:error, _}` for things retrying won't fix.** "User not found" is `:cancel`/`:discard`, not `:error`; otherwise you retry six times and report each one (this is a top source of noisy, traceless job issues).
3. **Make `perform/1` idempotent.** Jobs run at least once; a retry must not double-charge/double-send. Guard with a unique key or an upsert.
4. **Use unique jobs** (`unique: [period: ..., fields: ..., keys: ...]`) to dedupe enqueues.
5. **Set `max_attempts` and a sane `backoff/1`** per worker; don't leave a poison job retrying forever.
6. **Keep args small and serializable** (ids, not whole structs); reload inside the job.
7. **Test with `Oban.Testing`** (`perform_job/2` / `assert_enqueued`), not by sleeping.

## Return-value mapping

```elixir
defmodule MyApp.Workers.SyncCustomer do
  use Oban.Worker, queue: :default, max_attempts: 6

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    case Billing.sync(id) do
      :ok                       -> :ok
      {:error, :not_found}      -> {:cancel, :not_found}      # expected, won't fix on retry
      {:error, :rate_limited}   -> {:error, :rate_limited}    # transient: retry with backoff
      {:error, reason}          -> {:error, reason}
    end
    # an unexpected crash in Billing.sync raises → stacktrace + reporter, no manual rewrap
  end

  @impl Oban.Worker
  def backoff(%Oban.Job{attempt: attempt}), do: trunc(:math.pow(2, attempt))
end
```

## Idempotency

```elixir
# unique enqueue (dedupe at insert time)
%{id: id}
|> MyApp.Workers.SyncCustomer.new(unique: [period: 60, keys: [:id]])
|> Oban.insert()

# idempotent effect (safe under at-least-once delivery)
Repo.insert(%Receipt{job_id: job.id}, on_conflict: :nothing, conflict_target: :job_id)
```

## Testing

```elixir
test "cancels when the customer is gone" do
  assert {:cancel, :not_found} = perform_job(SyncCustomer, %{"id" => "missing"})
end

test "enqueues on signup" do
  Accounts.create_user(attrs)
  assert_enqueued worker: SyncCustomer
end
```

## Anti-patterns
- A worker that catches every error and returns `{:error, inspect(e)}` → erases the stacktrace and retries bugs.
- Passing whole Ecto structs in args (stale data, bloated payloads).
- No `max_attempts` ceiling / no backoff → retry storms.
