---
name: phoenix-json-api
description: >-
  Building JSON APIs with Phoenix: the :api pipeline, controllers + action_fallback, a unified error type, error rendering, pagination, versioning, and token auth.
when_to_use: >-
  Use when writing or reviewing JSON controllers, routers, or API error handling: the `:api` pipeline, `action_fallback`/`FallbackController`, error shapes, pagination, versioning, and Bearer-token auth.
---

# Phoenix JSON APIs

Pairs with `elixir-conventions` (especially §5 unified error struct, §7 and §8 raise vs return) and `phoenix-authorization`.

## RULES

1. **`:api` pipeline does `plug :accepts, ["json"]`** and token/session auth, with no CSRF/session/flash plumbing meant for HTML.
2. **Controllers return either a `%Plug.Conn{}` or `{:error, _}`.** Use `action_fallback` to render the error shapes.
3. **The FallbackController matches ONLY known error shapes. No catch-all.** An action that returns anything else is a bug; let it raise so your error reporter captures it with a stacktrace.
4. **Use one unified error type** (a `defexception` struct) that the controller renders consistently and that callers can also `raise`.
5. **Return `{:error, _}` only for failures the client can act on** (validation, not-found, auth, rate-limit). Dependency/invariant failures raise → 500 (see `elixir-conventions` §7).
6. **Stable response envelope and status codes.** Decide your error body shape once and keep it.
7. **Paginate every unbounded collection** (clamp page size); never return an unbounded list.

## FallbackController: match known, let the rest raise

```elixir
defmodule MyAppWeb.FallbackController do
  use Phoenix.Controller
  import MyAppWeb.ErrorRenderer   # render_error/2 below

  def call(conn, {:error, %Ecto.Changeset{} = cs}), do: conn |> render_error(:unprocessable_entity, cs) |> halt()
  def call(conn, {:error, %MyApp.Error{} = e}),       do: conn |> render_error(e.status, e) |> halt()
  def call(conn, {:error, :not_found}),               do: conn |> render_error(:not_found, :not_found) |> halt()
  def call(conn, {:error, :unauthorized}),            do: conn |> render_error(:unauthorized, :unauthorized) |> halt()
  # NO `def call(conn, other)` catch-all: an unmatched return raises FunctionClauseError,
  # which Sentry.PlugCapture (or your reporter) captures WITH a stacktrace and renders as a 500.
end
```

> A catch-all that turns any unmatched value into a generic 400/500 is the single most common reason API errors show up in Sentry with no stacktrace and one giant over-grouped issue. Don't add it.

## Unified error type

```elixir
defmodule MyApp.Error do
  defexception [:code, :status, :message, :details]

  def message(%__MODULE__{code: code, status: status}), do: "#{code} (#{status})"

  def not_found(msg, details \\ %{}), do: %__MODULE__{code: :not_found, status: :not_found, message: msg, details: details}
  def conflict(msg, details \\ %{}),  do: %__MODULE__{code: :conflict, status: :conflict, message: msg, details: details}
end
```

Because it's an exception, contexts can **return** `{:error, %MyApp.Error{}}` for expected failures or **raise** it for unrecoverable ones; the web layer handles both. Construct it at the source (where the code knows what went wrong) rather than guessing a status at the boundary.

## Controllers

```elixir
def show(conn, %{"id" => id}) do
  with {:ok, post} <- Blog.fetch_post(id) do   # {:error, :not_found} falls through to fallback
    render(conn, :show, post: post)
  end
end
```

Use `with` for the happy path; don't add `else` clauses that rewrap errors (`elixir-conventions` §5). Assert (`{:ok, x} = ...`) on things the client can't act on.

## Pagination / versioning / auth

- Clamp page size server-side: `limit = attrs |> get_int("limit", 25) |> min(100)`. Return `data` + `meta` (cursor or page/total).
- Version via path (`/api/v1`) or an `Accept` header; pick one and route pipelines accordingly.
- Bearer tokens: a `plug` reads `authorization`, verifies, assigns the current identity, and halts with `{:error, :unauthorized}` on failure. Compare tokens with `Plug.Crypto.secure_compare/2` (see `phoenix-security`).
