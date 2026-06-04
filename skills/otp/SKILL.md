---
name: otp
description: OTP concurrency patterns for Elixir — GenServer, Supervisor/DynamicSupervisor, Task/Task.Supervisor, Agent, Registry, ETS, and process lifecycle. Use when writing or reviewing stateful processes, supervision trees, background concurrency, or anything touching `GenServer`/`Supervisor`/`Task`/`:ets`. Triggers: GenServer, supervisor, handle_call, handle_continue, Task.async, process state, let-it-crash.
---

# OTP patterns

Pairs with `elixir-conventions` (assertive code, let-it-crash). Here: how to structure processes so failures are localized and state is owned by exactly one process.

## RULES
1. **A process's public API and its callbacks live in the same module.** Callers use `MyServer.do_thing(pid, arg)`, never `GenServer.call(pid, ...)` directly.
2. **`init/1` must be fast and must not block.** Do expensive/bootstrapping work in `handle_continue/2`, not `init/1`.
3. **`call` for "I need the result/backpressure"; `cast` for fire-and-forget.** Don't `cast` when the caller depends on the outcome.
4. **One writer per piece of state.** Don't share mutable state across processes; route writes through the owning process (or an ETS table the owner alone writes).
5. **Name dynamic processes via `Registry`/`:via`,** not global atoms (atoms aren't GC'd — see `phoenix-security`).
6. **Supervise everything that holds state or does work.** A bare `spawn`/unsupervised `Task` that crashes is invisible.
7. **Let it crash:** don't `try/rescue` around your own logic to keep a process alive — crash and let the supervisor restart from a known-good state.

## GenServer skeleton

```elixir
defmodule Cache do
  use GenServer

  # Public API — callers never touch GenServer directly
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  def fetch(key), do: GenServer.call(__MODULE__, {:fetch, key})
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})

  @impl true
  def init(opts) do
    # fast: just set up; defer real work
    {:ok, %{table: nil, opts: opts}, {:continue, :warm}}
  end

  @impl true
  def handle_continue(:warm, state), do: {:noreply, %{state | table: load_table(state.opts)}}

  @impl true
  def handle_call({:fetch, key}, _from, state), do: {:reply, Map.fetch(state.table, key), state}

  @impl true
  def handle_cast({:put, key, value}, state), do: {:noreply, put_in(state.table[key], value)}
end
```

## Supervision

- Static children → a `Supervisor` with an explicit `:strategy` (`:one_for_one` is the default choice; `:rest_for_one` when later children depend on earlier ones).
- Runtime-spawned, same-type children → `DynamicSupervisor` + `Registry` for lookup.
- Choose restart type deliberately: `:permanent` (always restart), `:transient` (restart only on abnormal exit), `:temporary` (never).

```elixir
DynamicSupervisor.start_child(MySup, {Worker, id: id})
# look the worker back up by id
[{pid, _}] = Registry.lookup(MyRegistry, id)
```

## Tasks

- `Task.async/await` for a single concurrent computation you'll join — **always pass a timeout**, and supervise long-lived ones with `Task.Supervisor`.
- `Task.async_stream/3` for bounded-concurrency fan-out over a collection (`max_concurrency:`, `on_timeout: :kill_task`) — the idiomatic way to parallelize a batch without spawning unboundedly.

```elixir
items
|> Task.async_stream(&process/1, max_concurrency: 10, timeout: 30_000, on_timeout: :kill_task)
|> Enum.reduce({[], []}, fn
  {:ok, result}, {ok, err} -> {[result | ok], err}
  {:exit, reason}, {ok, err} -> {ok, [reason | err]}
end)
```

## ETS

- Use for read-heavy shared caches. Create the table in the owning process; **only the owner writes.**
- `read_concurrency: true` for read-mostly tables; `write_concurrency: true` for concurrent writers. `:protected` (default) lets any process read; `:public` only when you truly need outside writers (you usually don't).
- The table dies with its owner — own it from a supervised process, not a transient task.

## Anti-patterns
- Blocking `init/1` (delays the whole supervision tree booting).
- A GenServer that's really just a lock around shared data → consider ETS or passing state explicitly.
- Catching exits to "keep the server up" → you're hiding the bug and keeping corrupt state.
- Unsupervised `Task.start/1` for important work → crashes vanish.

---
*Adapted and expanded from [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide) (MIT, © 2026 Joseph Morgan).*
