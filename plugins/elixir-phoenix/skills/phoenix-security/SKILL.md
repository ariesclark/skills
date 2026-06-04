---
name: phoenix-security
description: >-
  Security essentials for Elixir/Phoenix apps — atom exhaustion, SQL injection, XSS, open redirects, password hashing, constant-time token comparison, sensitive-data logging, CSRF, and dependency auditing. Use when writing or reviewing auth, input handling, queries, redirects, token/password code, or doing a security pass. Triggers: security, atom exhaustion, SQL injection, XSS, open redirect, password hashing, secure_compare, timing attack.
---

# Phoenix / Elixir security essentials

Pairs with `phoenix-authorization` (access control) and `elixir-conventions` (assertive parsing). These are the BEAM- and web-specific footguns.

## RULES
1. **Never `String.to_atom/1` on user input.** Atoms aren't garbage-collected — unbounded creation crashes the VM. Use `String.to_existing_atom/1` *only* when the full set is known and pre-created; otherwise keep it a string.
2. **Never interpolate user input into raw SQL.** Use parameterized Ecto queries; if you must use `fragment`, pass values as `?` parameters, never string-built.
3. **Hash passwords with a slow KDF** — Argon2 (`argon2_elixir`) or bcrypt/pbkdf2. Never SHA/MD5, never unsalted. Run the hash even on unknown users to avoid user-enumeration timing.
4. **Compare secrets in constant time** with `Plug.Crypto.secure_compare/2` (tokens, signatures, HMACs) — never `==`.
5. **Validate redirect targets.** Only redirect to allowlisted internal paths; reject absolute/external URLs from params (open-redirect → phishing).
6. **Don't log secrets/PII.** Scrub passwords, tokens, and `Authorization` headers; use Phoenix param filtering and a logger scrubber.
7. **Escape output / trust HEEx.** Don't build HTML by string concatenation or mark untrusted input `raw/1`.
8. **Audit dependencies** (`mix deps.audit` / `mix hex.audit`) in CI.

## Atom exhaustion

```elixir
# Don't — unbounded atom creation from input
role = String.to_atom(params["role"])

# Do — keep it a string, or convert against a known set
role = params["role"]
valid = String.to_existing_atom(role)   # only if every valid atom already exists
```

## SQL — parameterize

```elixir
# Don't
Repo.query!("select * from users where email = '#{email}'")

# Do
from(u in User, where: u.email == ^email) |> Repo.all()
```

## Passwords & token comparison

```elixir
# verify; constant-time, and still hash on a missing user
def authenticate(email, password) do
  user = Accounts.get_user_by_email(email)
  if Argon2.verify_pass(password, user && user.password_hash) do
    {:ok, user}
  else
    Argon2.no_user_verify()          # equalize timing
    {:error, :invalid_credentials}
  end
end

Plug.Crypto.secure_compare(provided_token, stored_token)   # never ==
```

## Open redirect

```elixir
# Don't
redirect(conn, external: params["return_to"])

# Do — only internal, allowlisted paths
case safe_path(params["return_to"]) do
  {:ok, path} -> redirect(conn, to: path)
  :error      -> redirect(conn, to: ~p"/")
end
```

## Sensitive logging
- `config :phoenix, :filter_parameters, ["password", "token", "secret"]`.
- Scrub `Authorization`/`Cookie` headers before they reach logs or your error reporter's request context.

---
*Adapted and expanded from [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide) (MIT, © 2026 Joseph Morgan).*
