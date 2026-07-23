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
- `path` — `command_elsewhere <name> [<directory>]` is `command -v` with one
  directory cut out of PATH, defaulting to the directory of the script that
  called it. A shim named after the command it wraps (`kagi/bin/kagi`) uses it
  to find the real binary instead of resolving back to itself. It compares
  directories physically, so it drops a symlinked or relative PATH entry
  pointing at the excluded one too, and fails like `command -v` when nothing
  else on PATH matches.
- `url` — `parse_url <name> <url>` explodes a URL into `<name>_host`,
  `<name>_pathname`, `<name>_search`, and a `<name>_segments` array,
  surviving ports, userinfo, and mixed case; `host_is <host>
<domain...>` matches exactly or by subdomain, rejecting lookalikes;
  `parse_search_params <array> <string>` fills a declared associative
  array with decoded parameters from a query string, when a consumer
  actually needs them; `url_decode` reverses query-string encoding.
- `claude` — reads Claude Code's own on-disk state. `claude_config_directory` is
  `${CLAUDE_CONFIG_DIR:-~/.claude}`; `claude_projects_directory` is its `projects`
  subdirectory; `claude_session_id` is the `session_id` global or
  `$CLAUDE_CODE_SESSION_ID` (like `mktemp`). On top of those, a set of model
  helpers report which model answered from a session's transcript. Each takes the
  session id as its argument and reads no globals, failing quietly (non-zero, no
  output) rather than logging: `get_transcript <session_id>` locates the transcript
  JSONL under `claude_projects_directory`; the rest build on it, dropping
  `<synthetic>` entries: `get_models` lists every assistant model in order;
  `get_recent_model` is the last; `get_ranked_models` is the distinct models
  most-used first; `get_top_model` is the busiest; `get_model_counts` prints
  `<count> <model>` per line. A session with no real models is empty (the list
  helpers) or fails (the single-model getters). Two more read the same transcript:
  `get_tool_calls <session_id> [<name>]` emits one JSON object per tool call —
  `{name, input, output, error}`, each joined to its `tool_result` — optionally
  filtered to one tool, and `get_recent_tool_call` is the last of them;
  `get_recent_field <field> <session_id>` is the last non-null value of a
  top-level entry field (`version`, `attributionSkill`, `attributionPlugin`,
  `gitBranch`, …). Each helper has a `get_current_*` wrapper (`get_current_model`,
  `get_current_tool_call`, `get_current_skill`, `get_current_plugin`,
  `get_current_version`, …) that passes `claude_session_id` and delegates.
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
