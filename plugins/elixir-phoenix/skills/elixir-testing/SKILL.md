---
name: elixir-testing
description: >-
  Testing Elixir/Phoenix backends with ExUnit — DataCase/ConnCase setup, the Ecto SQL sandbox, fixtures, JSON API tests, changeset/context tests, and assertive test style.
when_to_use: >-
  Use when writing or reviewing ExUnit tests, fixtures, or test setup. Triggers: ExUnit, test, DataCase, ConnCase, Ecto sandbox, fixtures, assert, JSON API test.
---

# Elixir/Phoenix testing (ExUnit)

Pairs with `elixir-conventions`. Tests should be assertive: state the exact expected shape so a failure points at the problem.

## RULES
1. **Use the case templates:** `DataCase` for context/DB tests, `ConnCase` for controller/API tests. They wire the Ecto SQL sandbox and helpers.
2. **`async: true` only when the test owns its data via the sandbox** and touches no shared global state (named processes, ETS, external services). Otherwise `async: false`.
3. **Assertive assertions over `Enum.all?`.** A `for`-comprehension of asserts (or per-element asserts) tells you *which* element failed; `assert Enum.all?(...)` just says `false`.
4. **Match the exact result,** don't assert truthiness. `assert {:ok, %User{email: "a@b.c"}} = create_user(attrs)` beats `assert create_user(attrs)`.
5. **Test changesets via `errors_on/1`** — assert specific field errors, not just `refute changeset.valid?`.
6. **Fixtures build valid baseline data;** override per test. Keep them small and composable.
7. **Don't sleep to wait.** Use `assert_receive`, `Oban.Testing`, or sandbox-aware sync points.

## Assertive collection checks

```elixir
# Don't — failure is a useless `false`
assert Enum.all?(users, & &1.active)

# Do — failure names the offending element
for user <- users, do: assert user.active
```

## Context / changeset test

```elixir
defmodule MyApp.AccountsTest do
  use MyApp.DataCase, async: true

  test "create_user/1 requires an email" do
    assert {:error, changeset} = Accounts.create_user(%{})
    assert %{email: ["can't be blank"]} = errors_on(changeset)
  end

  test "create_user/1 inserts a user" do
    assert {:ok, %User{email: "a@b.c"}} = Accounts.create_user(%{email: "a@b.c", password: "secret123"})
  end
end
```

## JSON API test (ConnCase)

```elixir
defmodule MyAppWeb.PostControllerTest do
  use MyAppWeb.ConnCase, async: true

  setup :register_and_authenticate   # assigns a token-authed conn

  test "GET /api/posts/:id returns the post", %{conn: conn} do
    post = post_fixture()
    conn = get(conn, ~p"/api/posts/#{post.id}")
    assert %{"data" => %{"id" => id}} = json_response(conn, 200)
    assert id == post.id
  end

  test "GET /api/posts/:id is 404 for a stranger's post", %{conn: conn} do
    other = post_fixture(user: user_fixture())
    assert json_response(get(conn, ~p"/api/posts/#{other.id}"), 404)
  end
end
```

## Fixtures

```elixir
def user_fixture(attrs \\ %{}) do
  {:ok, user} =
    attrs
    |> Enum.into(%{email: "user#{System.unique_integer([:positive])}@test.dev", password: "secret123"})
    |> Accounts.create_user()
  user
end
```

## The Ecto sandbox
- `DataCase`/`ConnCase` check out a sandboxed connection per test and roll it back after — tests don't see each other's writes.
- For code under test that runs in **another process** (Task/GenServer/Oban), grant it sandbox access (`Ecto.Adapters.SQL.Sandbox.allow/3`) or use shared mode with `async: false`.

## Before you finish
Run `mix test`, `mix format --check-formatted`, and `mix compile --warnings-as-errors`. These belong in CI; run them locally before pushing.
