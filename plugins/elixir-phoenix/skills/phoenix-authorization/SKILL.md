---
name: phoenix-authorization
description: >-
  Authorization / access control for Phoenix apps: server-side checks, ownership verification, scope-based queries to prevent IDOR, and policy modules.
when_to_use: >-
  Use when writing or reviewing any code that decides whether the current user may see or change a resource: authorization and access control, ownership checks, IDOR-proof scoped queries, and policy modules (`can?`).
---

# Phoenix authorization

Authentication answers "who are you"; authorization answers "may you do this". Pairs with `phoenix-security` and `phoenix-json-api`.

## RULES

1. **Authorize on the server, every time.** Hiding a button or omitting a field in the UI is not access control.
2. **Prefer scope over filter.** Constrain the query by the current user so unauthorized rows are _unreachable_, rather than fetching by id and checking ownership after.
3. **Never trust an id from the request** as proof of access. An authenticated user supplying someone else's id is the canonical IDOR.
4. **Centralize non-trivial rules in policy modules** (`can?/3`), not scattered `if` checks across controllers.
5. **Default deny.** Unknown action/role/resource → unauthorized, not allowed.
6. **Return `{:error, :unauthorized}` (or a 404 to avoid leaking existence)** consistently; let it render via the fallback.

## Scope, don't fetch-then-check (prevents IDOR)

```elixir
# Don't: fetch by id, then check ownership (one slip = IDOR)
post = Repo.get!(Post, id)
if post.user_id == user.id, do: ..., else: {:error, :unauthorized}

# Do: scope the query to the user; other users' rows simply don't exist
def fetch_post(%User{id: uid}, id) do
  case Repo.get_by(Post, id: id, user_id: uid) do
    nil  -> {:error, :not_found}
    post -> {:ok, post}
  end
end
```

Thread the current scope (user / org / tenant) into your context functions so authorization is _implicit in the query_ and hard to bypass.

## Policy modules for richer rules

```elixir
defmodule MyApp.Policy do
  # default-deny: anything not explicitly allowed falls through to false
  def can?(%User{role: :admin}, _action, _resource), do: true
  def can?(%User{id: uid}, :edit, %Post{user_id: uid}), do: true
  def can?(%User{id: uid}, :delete, %Comment{user_id: uid}), do: true
  def can?(_user, _action, _resource), do: false
end

with true <- MyApp.Policy.can?(user, :edit, post) do
  Blog.update_post(post, attrs)
else
  false -> {:error, :unauthorized}
end
```

Keep policy functions total and assertive: match the allowed cases, let the final clause deny.

## Controllers / plugs

- A `require_authenticated` plug assigns the current identity and halts with `{:error, :unauthorized}` if absent.
- Per-resource authorization happens in the context (via scope) or an explicit policy check in the action, not only in a plug, which can't see the specific resource.

## Common mistakes

- Authorizing in a plug by route but not re-checking the specific record the action loads.
- Returning `403` where existence itself is sensitive; prefer `404`.
- Role checks sprinkled in templates/serializers instead of gating the data access.
