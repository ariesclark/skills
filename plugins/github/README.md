# GitHub

PreToolUse hooks that stop lossy GitHub page fetches and hand back something
better: repository and gist URLs are shallow-cloned into `/tmp/github/...`
(via `gh`, so private repos work) and the deny message points at the clone
and its SHA; PR and issue URLs are redirected to the matching `gh pr view` /
`gh issue view` invocation. Covers WebFetch plus `curl`/`wget` in Bash
commands, with quote-aware command parsing.

Requires `gh` (authenticated), `git`, `jq`, and `python3`.

## Install

```
/plugin install github@ariesclark
```
