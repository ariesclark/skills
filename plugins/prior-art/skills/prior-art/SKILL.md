---
name: prior-art
description: Find and reuse an existing solution before deriving your own, whether building a feature, fixing a bug, researching an approach, or configuring a tool. Covers libraries and dependencies, prior fixes and known issues, established methodology, official docs and specs, upstream repos, and reusable CI and tooling.
when_to_use: >-
  Invoke when about to build, fix, research, or configure something that probably already has a solution, before doing it fresh. Tripwires: debugging an error (search the exact message: often a known, fixed issue); writing a common helper; adding or reimplementing a dependency; hand-rolling CI, tooling, or scaffolding; tuning config or defaults; calling an unfamiliar API. The tell: any impulse to derive from memory instead of reusing a library, prior fix, standard, or upstream pattern.
---

# Prior art first

Most work isn't new. Whatever you are about to build, fix, research, or configure, someone has likely already solved or documented it: the maintainers, an upstream repo, a widely-used library, a published spec, or someone who hit the same bug and wrote down the fix. Deriving it yourself re-does careful decisions other people already made, and the result is usually worse: missing edge cases, nothing to maintain it, behavior that surprises the next person. Searching first costs minutes; rebuilding costs far more.

This applies as much to fixing and understanding as to building. A bug is often a known issue, already fixed in a newer version, or answered word for word in the tracker. Find that before you debug from scratch.

## The four principles

Everything below follows from four ideas:

1. **Assume it already exists.** Whether building, fixing, or deciding, search for the solution before you produce one.
2. **Reuse beats rebuild.** A maintained solution carries its fixed edge cases and keeps getting fixes; yours carries neither. Adopt before you author.
3. **Your memory is not a source.** What you recall about an API, default, config, or fix is a version-blind reconstruction that is subtly wrong. Truth is the real source or the official docs at the version that runs.
4. **Surface the choice; deviate only with a reason.** Present what you found and let the user pick adopt, adapt, or hand-roll. Building from scratch is right when nothing fits, it is unmaintained, too heavy, or genuinely novel: say which.

## How to find it

Two moves: discover that a solution exists, then read the exact one that applies. Skipping discovery is why prior art gets missed; skipping verification is why the fix you found turns out wrong.

**Discover it.**

- **Check what is already here.** Read the manifest and lockfile (the capability may already be a dependency you can call) and `grep` the repo for the helper, pattern, or config before adding anything.
- **Search by the problem, in plain words.** For a bug, the exact error message or symptom plus the version; a closed issue or a release note often is the answer. For a capability, "<problem> <language> library". For a method, the named spec or algorithm. `gh search issues`, `gh search code`, the package registry, and `CHANGELOG`s all surface it.
- **Read first-hand accounts as leads.** Blog posts, issues, discussions, and forum threads where someone hit the same thing name the gotcha and the fixing version fast.

**Verify it.**

1. **Pin the version.** Read the lockfile or manifest (`pnpm-lock.yaml`, `Cargo.lock`, `go.mod`, `poetry.lock`, `Gemfile.lock`, `mix.lock`) for the exact installed version. Defaults and options drift, so "latest" docs are often wrong for this repo.
2. **Read the real source at that version.** The dependency vendored locally (`node_modules/`, `.venv/.../site-packages/`, `vendor/`, `deps/`) is the exact code running, so read it directly. Otherwise clone upstream and `git checkout` the matching tag. Use `gh` for files, releases, and the issue/PR history behind a behavior.
3. **Read the official docs, not a summary.** The project's `README`, in-repo `docs/`, and `CHANGELOG`/`UPGRADING` (version-specific behavior lives there); doc hosts hexdocs.pm, docs.rs, pkg.go.dev, readthedocs. When you need exact wording or defaults, `curl` the page and read it in full: WebFetch returns a summary that drops the detail that matters.
4. **Confirm every specific against the source.** A blog post or issue is a lead, not truth. Check the API, default, config, and version behavior it claims before acting, and never stop at memory.
5. **Cite what you found** with `file:line` or the doc URL and the version it applies to, so the recommendation can be checked.

## Anti-patterns

- Debugging from scratch without searching the exact error, which is often a known, already-fixed issue.
- Reimplementing what a maintained library provides (date math, parsing, validation, crypto, retries).
- Hand-rolling a patch, workaround, or fork for what an upgrade, a config option, or a maintained plugin already fixes.
- Inventing a bespoke approach to a problem that has an established, documented methodology.
- Guessing an API, signature, config, or default from memory instead of reading the source at the running version.
- Writing a bespoke CI workflow when the platform ships a reusable action or starter.
- Adopting prior art blindly, without checking maintenance, fit, or what it drags in.
