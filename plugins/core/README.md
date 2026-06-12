# Core

Shared library for the other plugins in this marketplace — not useful to
install on its own.

`scripts/` holds the sources with colocated bats tests:

- `verdict` — `deny`/`warn` emit a PreToolUse hook verdict as JSON and
  exit; an optional `verdict_prefix` is prepended to every message, and
  `deny` takes an optional second argument emitted as `additionalContext`
  (seen by the model but not the user).
- `mktemp` — session-scoped temporary directories named
  `<session_id>-<template>-XXXXXX` under `$TMPDIR`, reading the
  `session_id` global (dashes stripped, so the id never collides with the
  separators). `session_mktemp <template>` creates one, failing when
  `session_id` is empty; `session_cleanup <prefix>` (from a SessionEnd
  hook) removes the session's directories whose template starts with the
  prefix.
- `url` — `parse_url <name> <url>` explodes a URL into `<name>_host`,
  `<name>_pathname`, `<name>_search`, and a `<name>_segments` array,
  surviving ports, userinfo, and mixed case; `host_is <host>
  <domain...>` matches exactly or by subdomain, rejecting lookalikes;
  `parse_search_params <array> <string>` fills a declared associative
  array with decoded parameters from a query string, when a consumer
  actually needs them; `url_decode` reverses query-string encoding.
- `shell.jq` — a jq module (loaded with `jq -L <this directory>` and
  `include "shell";`) for walking `shfmt --to-json` syntax trees:
  `word_text` rebuilds an argument word from its literal parts only, so
  variable expansions contribute nothing; `strip_wrappers` drops leading
  wrapper commands (`sudo`, `env`, …) and `VAR=value` assignments from a
  word array, leaving the real command first.

Consumer plugins symlink this directory (for example
`plugins/github/scripts/core → ../../core/scripts`). Plugin installation
dereferences symlinks, so installed plugins ship their own copies and never
depend on core at runtime.

Run the tests with:

```
bats plugins/core/scripts/
```
