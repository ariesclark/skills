# Core

Shared library for the other plugins in this marketplace — not useful to
install on its own.

`scripts/` holds the sources with colocated bats tests:

- `hook` — `deny`/`warn` emit a PreToolUse hook decision as JSON and exit;
  `deny` takes an optional second argument emitted as `additionalContext`
  (seen by the model but not the user). Both delegate to `hook.jq`, so the
  JSON shape lives in one place.
- `hook.jq` — the same decision shapes for jq-based hooks (loaded with
  `jq -L <this directory>` and `include "hook";`): `deny($reason)` /
  `deny($reason; $context)` and `warn($context)` build the decision object.
  A hook that builds its decision in jq can emit it straight to stdout
  instead of shelling back out to `hook`.
- `rule` — scans code against ast-grep rule files for PreToolUse hooks
  (sources `hook`). `rule_inline <rule.yml...>` joins rule files into one
  `--inline-rules` document; `rule_scan <rule.yml...>` reads code on stdin and
  prints the matches as JSON; `rule_pick` selects the most-severe match from a
  match array; `apply_rules <rule.yml...>` ties them together and emits the
  verdict (`error` denies, anything else warns).
- `mktemp` — session-scoped temporary directories named
  `<session_id>-<template>-XXXXXX` under `$TMPDIR`, reading the
  `session_id` global with `$CLAUDE_CODE_SESSION_ID` as the fallback, so
  hooks set the global from their input and plain scripts need nothing
  (dashes stripped, so the id never collides with the separators). `session_mktemp <template>` creates one, failing when
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
