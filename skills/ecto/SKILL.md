---
name: ecto
description: Ecto patterns for Postgres-backed Elixir/Phoenix apps — schemas, changesets (per-operation, composition, validations), associations, cast_assoc/cast_embed, Ecto.Multi, transactions, migrations, and query performance (N+1, indexes). Use when writing or reviewing schemas, changesets, migrations, or Repo/query code. Triggers: Ecto, changeset, cast_assoc, Repo, migration, Ecto.Multi, preload, N+1.
---

# Ecto patterns

Pairs with `elixir-conventions`. Database errors a caller can act on (validation, conflict) are values; anything that "can't happen" should crash.

## RULES
1. **One changeset per operation**, not one mega-changeset. `registration_changeset`, `profile_changeset`, `admin_changeset` — each casts only its own fields. Don't toggle behavior with option flags.
2. **`cast` the fields you accept; never `cast` everything.** The cast allowlist is your mass-assignment boundary.
3. **Pair `unsafe_validate_unique` with a DB `unique_constraint`.** The first gives a friendly form error; the second is the source of truth that catches the concurrent insert the validation can't see.
4. **`cast_assoc`/`cast_embed` require the association preloaded** on the struct you're updating, and a changeset on the child that casts its **own** fields (including any required FKs). Set `on_replace:` explicitly.
5. **Multi-step writes go in `Ecto.Multi`,** not nested `Repo` calls — you get one transaction and a `{:error, failed_step, value, changes_so_far}` you can branch on.
6. **Index every foreign key and every column you filter/sort by.** Postgres does not auto-index FKs.
7. **Preload deliberately.** N+1s come from accessing associations in a loop; preload up front or join.
8. **Raise on unrecoverable DB state.** Use `Repo.insert!`/`Repo.get!` etc. when a failure means a bug, not a user-facing error (see `elixir-conventions` §7–§8).

## Changesets — assertive, not defensive

```elixir
# Don't — defensive option-juggling inside one changeset
def changeset(user, attrs, opts \\ []) do
  user
  |> cast(attrs, [:email, :password])
  |> then(fn cs -> if Keyword.get(opts, :validate_unique, true), do: unsafe_validate_unique(cs, :email, Repo), else: cs end)
end

# Do — one changeset per operation; the caller picks
def registration_changeset(user, attrs) do
  user
  |> cast(attrs, [:email, :password])
  |> validate_required([:email, :password])
  |> validate_format(:email, ~r/@/)
  |> unsafe_validate_unique(:email, Repo)
  |> unique_constraint(:email)
end
```

Compose shared validation as plain changeset->changeset functions and pipe them; don't reach for `with`/`else` inside changesets.

## Associations & nested data

```elixir
order
|> Repo.preload(:line_items)                 # required before cast_assoc
|> Ecto.Changeset.cast(attrs, [:status])
|> Ecto.Changeset.cast_assoc(:line_items,
     with: &LineItem.changeset/2,
     on_replace: :delete)                     # be explicit: :delete | :nilify | :raise
```

- `cast_assoc` when parent and children share a lifecycle and arrive in one payload. When they have **independent** lifecycles, manage them separately with `Ecto.Multi` instead.
- `cast_embed` for embedded schemas (no separate table); same preload/`on_replace` discipline.

## Ecto.Multi

```elixir
Ecto.Multi.new()
|> Ecto.Multi.insert(:order, Order.changeset(%Order{}, attrs))
|> Ecto.Multi.insert_all(:items, LineItem, &build_items(&1.order, attrs))
|> Ecto.Multi.run(:charge, fn _repo, %{order: order} -> Billing.charge(order) end)
|> Repo.transaction()
|> case do
  {:ok, %{order: order}} -> {:ok, order}
  {:error, :charge, reason, _changes} -> {:error, reason}   # branch only on steps you can act on
end
```

Don't write a generic catch-all `else` over every step — match the steps whose failure the caller can handle; let genuinely unexpected failures raise.

## Migrations & performance
- Reversible migrations; `create index(...)` on FKs and filter/sort columns. Consider `concurrently: true` (with `@disable_ddl_transaction true`) for large tables.
- `Repo.all(from u in User, where: ..., preload: [:posts])` over looping `Repo.preload` per row.
- Use `select:` to avoid loading whole rows when you need a few fields; `Repo.aggregate/3` for counts/sums.

## Before you finish
Run `mix format`, `mix compile --warnings-as-errors`, and your migrations against a scratch DB (`mix ecto.migrate` / `ecto.rollback`) so reversibility is real, not assumed.

---
*Adapted and expanded from [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide) (MIT, © 2026 Joseph Morgan).*
