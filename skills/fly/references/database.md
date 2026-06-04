# Database — Postgres access & cluster inspection

Unlike Observability (which authenticates HTTPS API calls with a minted `readonly` token), DB
access goes through `fly` itself — the CLI's implicit OAuth handles SSH, and the Postgres password
is read from `$OPERATOR_PASSWORD` inside the container. No `readonly` token is involved here.

## Postgres access

SSH onto the DB machine and connect psql via a Postgres URL with the password baked in — the container has the password in `$OPERATOR_PASSWORD`, no local secrets needed. SQL streams via stdin (here-string), so no SQL-in-argv escaping. The `<<<` is a redirection, not a pipe — the top-level command is still `fly`.

```bash
<<< "<sql>" \
fly ssh console -a <db-app> \
  -qC 'sh -c "psql postgres://postgres:$OPERATOR_PASSWORD@localhost/<db-name>"'
```

`flyio/postgres-flex`: password in `$OPERATOR_PASSWORD`, TCP on `localhost`, superuser `postgres`. Substitute `<db-app>` / `<db-name>` from `fly.toml` or ask the user.

## Cluster inspection

`fly pg <subcommand> -a <db-app>` hits the Fly API directly — no SSH, no psql. Use these to discover `<db-name>`, audit config, or check recent cluster events before reaching for psql.

**Example — list databases and their users** (use to discover `<db-name>`):

```bash
fly pg db list -a <db-app>
```

**Example — show Postgres config** (WAL level, connection limits, `shared_preload_libraries`, pending-restart flags):

```bash
fly pg config show -a <db-app>
```

**Example — recent cluster events** (failovers, restarts, role changes — useful when something looks off):

```bash
fly pg events list -a <db-app>
```

**Example — count users:**

```bash
<<< "select count(*) from users;" \
fly ssh console -a <db-app> \
  -qC 'sh -c "psql postgres://postgres:$OPERATOR_PASSWORD@localhost/<db-name>"'
```

For multi-line SQL, replace `<<<` with a trailing heredoc:

```bash
fly ssh console -a <db-app> \
  -qC 'sh -c "psql postgres://postgres:$OPERATOR_PASSWORD@localhost/<db-name>"' \
<<SQL
select ...;
select ...;
SQL
```

Mutations (writes, DDL, migrations) — ask the user to run psql themselves.
