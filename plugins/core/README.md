# Core

Shared library for the other plugins in this marketplace — not useful to
install on its own.

`scripts/` holds the sources with colocated bats tests:

- `verdict.sh` — `deny`/`warn` emit a PreToolUse hook verdict as JSON and
  exit; an optional `verdict_prefix` is prepended to every message.
- `url.sh` — `url_host`, `url_path`, `url_host_is`, `url_segment`: URL
  parsing that survives ports, userinfo, mixed case, query strings, and
  lookalike hosts.

Consumer plugins symlink this directory (for example
`plugins/github/scripts/core → ../../core/scripts`). Plugin installation
dereferences symlinks, so installed plugins ship their own copies and never
depend on core at runtime.

Run the tests with:

```
bats plugins/core/scripts/
```
