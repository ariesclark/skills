# Kagi

Routes every web lookup through the [Kagi CLI](https://kagi.com), which runs
signed in to your Kagi account. Searches carry your rankings, lenses, and bangs,
and results come back as structured data instead of a model-written summary.

Requires `kagi` on `PATH`. Every hook exits silently when it is missing, so the
plugin degrades to stock behavior rather than blocking work.

## Hooks

`hooks/session-start` runs at `SessionStart` and names the command per need
(`search`, `quick`, `ask-page`, `extract`, `news`), the output format to return
to context, and `kagi skills get kagi` for everything else. The CLI ships that
guide version-matched to the installed binary, so the text points at it instead
of restating flags that drift on the next release. It loads every session, so
the agent never has to recognize that a lookup is a kagi job first.

The guide emits whether or not `kagi` is installed yet: the plugin ships a `kagi`
shim on `PATH` that installs the CLI on first use, so the guide is valid before
the binary exists. Then it runs `kagi auth status` and, for each of the session
token and the API key that reads `not configured`, appends the line that sets
that one up. It runs the status check as `KAGI_SHIM_AUTO_INSTALL=false kagi auth
status`, so a missing CLI reports nothing and the shim never installs mid-session;
the guide still shows and no setup block does.

The `context` option toggles the whole hook off.

Three `PreToolUse` hooks in `hooks/` deny with the command to run instead. All
four hooks are toggleable in plugin settings. Their shared helpers live in
`scripts/`: `quote` renders an argument as a pasteable shell word, `reachable`
decides which hosts Kagi can serve, `bash.jq` pulls URLs out of a parsed
command, and `core` symlinks the marketplace's shared library.

- `hooks/websearch` — `WebSearch` becomes `kagi search "<query>" --format toon
--limit 5`. A lone `allowed_domains` entry folds into a `site:` filter.
- `hooks/webfetch` — `WebFetch` becomes `kagi ask-page "<url>" "<prompt>"`,
  with `kagi extract` and `kagi summarize` offered as the other readings.
- `hooks/bash` — `curl` or `wget` of a search engine result page becomes
  `kagi search`, carrying the `q` parameter over. Reaching `kagi.com` over HTTP
  redirects to the CLI itself.

The fetch hook stays out of the way where Kagi cannot help or another plugin
already owns the URL: `localhost` and private addresses, `github.com` (the
`github` plugin clones it), and `claude.ai` artifacts (readable only through
WebFetch's own login).

## Tests

```bash
bats plugins/kagi/hooks/
```
