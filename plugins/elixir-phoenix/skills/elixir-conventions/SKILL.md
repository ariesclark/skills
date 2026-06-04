---
name: elixir-conventions
description: >-
  Idiomatic Elixir conventions for control flow, error handling, and code shape.
when_to_use: >-
  Use when writing or reviewing Elixir code — error tuples vs exceptions, raising, `with`/`case`/`else`, pattern-matching assertions, pipelines, and module API design. Triggers: "is this idiomatic Elixir", error handling, `with` statement, let-it-crash, defensive code.
---

# Elixir conventions

Recurring patterns that lead to worse code, and the better alternatives.

## `Map.get/2` and `Keyword.get/2` vs. `Access`

`Map.get/2` and `Keyword.get/2` lock you into one data structure — change the structure later and you have to update every call site. Prefer `Access`:

```elixir
# Don't
opts = %{foo: :bar}
Map.get(opts, :foo)

# Do
opts[:foo]
```

## Don't pipe results into the following function

Side-effecting functions return results like `{:ok, term()} | {:error, term()}`. Don't pipe those results into the next function — handle them directly with `case` or `with`.

```elixir
# Don't
def main do
  data
  |> call_service()
  |> parse_response()
  |> handle_result()
end

# Do
def main do
  with {:ok, response} <- call_service(data),
       {:ok, decoded}  <- parse_response(response) do
    decoded
  end
end
```

Piping forces each function to handle the previous one's results, spreading error handling across the calls. Each function ends up knowing too much about how it's called and composed — and it assumes errors can be handled generically, which is often wrong. The calling function is usually the only one with enough information to decide what to do with an error.

When errors are a vital part of control flow, keep all the handling in the calling function with `case`:

```elixir
def main(id) do
  case :fuse.check(:service) do
    :ok ->
      case call_service(id) do
        {:ok, result} ->
          :ok = Cache.put(id, result)
          {:ok, result}

        {:error, error} ->
          :fuse.melt(:service)
          {:error, error}
      end

    :blown ->
      cached = Cache.get(id)
      if cached, do: {:ok, cached}, else: {:error, :unavailable}
  end
end
```

It makes the calling function bigger, but you can read it top to bottom and understand every control-flow path.

## Don't pipe into case statements

If you find yourself piping into `case`, assign the intermediate steps to a variable instead.

```elixir
# Don't
build_post(attrs)
|> store_post()
|> case do
  {:ok, post} -> ...
  {:error, _} -> ...
end

# Do
changeset = build_post(attrs)

case store_post(changeset) do
  {:ok, post} -> ...
  {:error, _} -> ...
end
```

## Don't hide higher-order functions

When working with collections, write functions that operate on a single entity and use the higher-order function directly in your pipeline.

```elixir
# Don't
def main do
  collection
  |> parse_items()
  |> add_items()
end

def parse_items(list), do: Enum.map(list, &String.to_integer/1)
def add_items(list), do: Enum.reduce(list, 0, &(&1 + &2))

# Do
def main do
  collection
  |> Enum.map(&parse_item/1)
  |> Enum.reduce(0, &add_item/2)
end

defp parse_item(item), do: String.to_integer(item)
defp add_item(num, acc), do: num + acc
```

Single-entity functions are reusable across `Stream`, `Enum`, `Task`, and more, instead of being coupled to one call site. Better solutions also tend to reveal themselves — here the named helpers can collapse entirely:

```elixir
def main do
  collection
  |> Enum.map(&String.to_integer/1)
  |> Enum.sum()
end
```

As a general rule, strive to eliminate functions that have only a single call site.

## Avoid else in with blocks

`else` is fine when you need an operation that's generic across all returned error values. Don't use it to handle every potential error (or even a large number of them).

```elixir
# Don't
with {:ok, response} <- call_service(data),
     {:ok, decoded}  <- Jason.decode(response),
     {:ok, result}   <- store_in_db(decoded) do
  :ok
else
  {:error, %Jason.Error{} = error} -> ...
  {:error, %ServiceError{} = error} -> ...
  {:error, %DBError{}} -> ...
end
```

And never annotate clauses with a name just to tell the errors apart:

```elixir
# Don't
with {:service, {:ok, resp}}   <- {:service, call_service(data)},
     {:decode, {:ok, decoded}} <- {:decode, Jason.decode(resp)},
     {:db, {:ok, result}}      <- {:db, store_in_db(decoded)} do
  :ok
else
  {:service, {:error, error}} -> ...
  {:decode, {:error, error}} -> ...
  {:db, {:error, error}} -> ...
end
```

If you're doing this, the error conditions matter — which means you don't want `with` at all. You want `case`.

`with` is best when you can fall through at any point without caring about the specific error. A good way to get there is a common error type:

```elixir
defmodule MyApp.Error do
  defexception [:code, :msg, :meta]

  def new(code, msg, meta) when is_binary(msg) do
    %__MODULE__{code: code, msg: msg, meta: Map.new(meta)}
  end

  def not_found(msg, meta \\ %{}), do: new(:not_found, msg, meta)
  def internal(msg, meta \\ %{}), do: new(:internal, msg, meta)
end

def main do
  with {:ok, response} <- call_service(data),
       {:ok, decoded}  <- decode(response),
       {:ok, result}   <- store_in_db(decoded) do
    :ok
  end
end

# Wrap a library's error in our own type, near the source
defp decode(resp) do
  with {:error, _} <- Jason.decode(resp) do
    {:error, MyApp.Error.internal("could not decode: #{inspect(resp)}")}
  end
end
```

This gives a unified way to surface every error in the app. The struct can render in a Phoenix controller or be returned from an RPC handler — and because it's an exception, the caller can also choose to raise it and get a well-formatted message:

```elixir
case main() do
  {:ok, _}    -> :ok
  {:error, e} -> raise e
end
```

## State what you want, not what you don't

Be intentional about a function's requirements. Don't check that a value isn't `nil` when what you actually expect is a string:

```elixir
# Don't
def call_service(%{req: req}) when not is_nil(req), do: ...

# Do
def call_service(%{req: req}) when is_binary(req), do: ...
```

The same goes for `case` and `if`. Be explicit about what you expect, and prefer to raise or crash on arguments that violate those expectations.

## Only return error tuples when the caller can do something about it

Only make callers deal with errors they can actually act on. If an API can error and there's nothing the caller can do about it, raise an exception or throw instead of returning a result tuple.

```elixir
# Don't — if the table doesn't exist, catch and return an error tuple
def get(table \\ __MODULE__, id) do
  try do
    :ets.lookup(table, id)
  catch
    _, _ -> {:error, "Table is not available"}
  end
end

# Do — there's nothing the caller can do about it, so just throw
def get(table \\ __MODULE__, id) do
  :ets.lookup(table, id)
end
```

## Raise exceptions if you receive invalid data

Don't be afraid to raise when a return value or piece of data violates your expectations. If you call a downstream service that should always return JSON, use `Jason.decode!` and skip the extra error handling.

```elixir
# Don't
def main do
  {:ok, resp} = call_service(id)

  case Jason.decode(resp) do
    {:ok, decoded} -> decoded
    {:error, e} -> # now what?...
  end
end

# Do
def main do
  {:ok, resp} = call_service(id)
  Jason.decode!(resp)
end
```

This lets the process crash (which is good) and removes the useless error-handling logic.

## Use for when checking collections in tests

A quick one that makes test failures far more helpful:

```elixir
# Don't
assert Enum.all?(posts, fn post -> %Post{} == post end)

# Do
for post <- posts, do: assert %Post{} == post
```

## Before you finish: run the checks

These belong in CI, but run them locally before declaring code done — don't just eyeball it:

- `mix format` (or `--check-formatted`) — formatting is not a matter of taste here.
- `mix compile --warnings-as-errors` — warnings are bugs-in-waiting (unused vars, unreachable clauses, missing `@impl`).
- `mix credo --strict --format=oneline` — style/consistency and common smells, if the project uses it. **Always pass `--format=oneline`.** Credo's default prints a multi-line block per issue, which bloats the context window for no benefit; one greppable line per issue is all you need to act on.
  - Iterating on one file? Scope it: `mix credo suggest --format=oneline lib/my_app/foo.ex` (`suggest` is the default, so `mix credo --format=oneline lib/my_app/foo.ex` works too) — far faster than re-scanning the whole tree.
  - Don't recognize a finding? `mix credo explain lib/my_app/foo.ex:42:7` prints the full rationale with a before/after example — the one place you *want* the detail, so skip `oneline` here. You can also explain a check by name: `mix credo explain Credo.Check.Refactor.Nesting`.
- `mix dialyzer` — typespec/contract violations, if set up.
- `mix test` — and add a failing test first for any bug you fix.

If a check isn't configured, note it rather than skipping silently.
