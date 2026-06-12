# GitHub

A pair of PreToolUse hooks that stop lossy GitHub page fetches, whether
through WebFetch, a `curl`/`wget` in a Bash command, or a `gh api`
read of a `repos/<owner>/<repo>/contents` path (base64 JSON when a
clone reads better; writes pass through), and hand back something
better, by URL shape:

- Repository, raw-file, and wiki URLs are cloned into a fresh temporary
  directory (via `gh`, so private repositories work; `--filter=blob:none`,
  so full history without the blob download) and the deny message points
  at the clone.
- Gist URLs are cloned the same way.
- PR, issue, release, workflow-run, and discussion URLs are redirected to
  the matching `gh` invocation (`gh pr view 9 --repo o/r --comments`,
  `gh release download <tag>`, …) since that data is not in the git tree.
- Unrecognized `api.github.com` paths are redirected to `gh api <path>`.
- Content subdomains (`docs.github.com`, `avatars.githubusercontent.com`,
  …) pass through untouched.

A SessionStart hook injects a short cheat sheet of these redirects (under
1 KB) so the model reaches for the right `gh` command before a deny has
to teach it.

Clones are named `<session_id>-github-<target>-XXXXXX` under `$TMPDIR` and
a SessionEnd hook removes the session's clones when it ends.

Requires `gh` (authenticated), `git`, and `jq`. Without `gh` the fetch
goes through, with a note suggesting the GitHub CLI be installed. The
Bash hook finds curl/wget URLs by parsing the command with
[`shfmt`](https://github.com/mvdan/sh) (`--to-json`); without `shfmt`
it lets every command through.

## Install

```
/plugin install github@ariesclark
```
