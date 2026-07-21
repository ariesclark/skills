---
name: prior-art
description: Find and reuse existing prior art (libraries and dependencies, established methodology and reference patterns, official documentation, upstream repos, reusable CI and tooling) before hand-rolling or reimplementing something that has already been solved.
when_to_use: >-
  Use before adding a dependency, reimplementing functionality a library already provides, designing an approach to a common problem, hand-rolling CI, tooling, infra, or scaffolding, or recommending or changing the configuration, tuning, or operational settings of a dependency you already run. Also when you would otherwise guess at an API, format, config, or default instead of reading the official docs or spec: read the upstream docs and real source before advising a change rather than reasoning from memory. Anytime the impulse is to build from scratch, or to tune an existing tool from memory, rather than reuse an existing library, established methodology, documented standard, or upstream pattern.
---

# Prior art first

Most "new" work isn't new. The library you need, the approach to the problem, the config, the algorithm, the API you are about to call: usually someone has already built, solved, or documented it, whether the project's own maintainers, an official or upstream repo, a widely-used library, or a published spec. Hand-rolling re-derives decisions other people already made carefully, and the result is usually worse: missing edge cases, nothing to maintain it, and behavior that surprises the next person. Searching first costs a few minutes; rewriting a bespoke version later costs far more.

## RULES

1. **Search before you build.** Before adding a dependency, reimplementing a capability, designing an approach, or writing CI/tooling/infra, spend the first few minutes finding how it is already done or documented.
2. **Look in priority order:** (a) this repo and sibling repos for an existing pattern or an already-listed dependency, (b) the official or upstream project's own repo and docs, (c) the broader ecosystem of well-known libraries, packages, reusable actions, and reference implementations.
3. **Present the prior art before implementing.** Tell the user what you found and propose adopting it; let them pick adopt vs. adapt vs. hand-roll. This is the core of the skill: don't silently build past a solution that already exists.
4. **Prefer a maintained dependency over a reimplementation.** Date math, parsing, validation, auth, retries, format handling: a maintained library keeps getting fixes and edge cases; your reimplementation does not. Reach for the library before writing the logic yourself.
5. **Upgrade or adopt before you patch.** When a dependency has a bug or is missing a feature, first check whether a newer version, a maintained plugin or extension, or a built-in option already fixes or provides it. Prefer bumping the version or installing the addition over hand-rolling a patch, monkeypatch, workaround, or vendored fork. Reserve a local patch for when upstream genuinely has no fix, and say so.
6. **Follow established methodology, don't invent one.** For a common problem there is usually a documented pattern, reference architecture, or standard algorithm. Adopt the well-trodden approach rather than a novel one, unless the novelty is the point.
7. **Read the docs and the real source, don't reconstruct from memory.** For an unfamiliar API, format, config, or protocol, fetch the official documentation, spec, or source (web search, `gh`, WebFetch) and follow it. Memory-reconstructed signatures and config are subtly wrong.
8. **Deviate only with a stated reason.** Building from scratch is right when the prior art doesn't fit, is unmaintained, pulls in too much, or the need is genuinely novel; say which.

## Where to look

- **In-repo / org first.** Existing patterns, configs, and the dependencies already in the manifest. `grep`/`find` for the pattern and match the conventions already in use before adding anything new.
- **Official / upstream.** The tool, library, or platform's own repo, docs, and spec. These often ship a reference implementation, a worked example, or a reusable action. A plugin marketplace, for instance, can mirror its ecosystem's official starter repo and delegate validation to a _reusable action_ rather than hand-rolling the steps.
- **Ecosystem.** The package registry (for a library that already solves it), `awesome-*` lists, reference architectures, and `starter`/`template` repos.
- **First-hand accounts.** Blog posts, `CHANGELOG` notes, GitHub issues and discussions, forum threads, and conference talks where someone hit the same problem. These often name the exact gotcha, workaround, or the version that fixes it faster than reconstructing it from reference docs. Search for the specific error message, symptom, or "how to X with <tool>". Treat them as leads and verify the specifics against the primary source before acting.

## How to find and fetch it

Reading "the docs" only helps if you read the ones that match what actually runs. A reliable path:

1. **Pin the version first.** Read the lockfile or manifest (`mix.lock`, `package-lock.json`/`pnpm-lock.yaml`, `Cargo.lock`, `go.mod`, `poetry.lock`, `requirements.txt`, `Gemfile.lock`) to get the exact installed version. Defaults, option names, and behavior drift between versions, so docs for "latest" are often wrong for the version in the repo.
2. **Read the real source at that version.** In priority order: the dependency already vendored locally (`node_modules/`, `deps/`, `.venv/.../site-packages/`, `vendor/`) is the exact code running, so read it directly; otherwise clone the upstream repo and `git checkout` the matching tag, then open the actual modules to confirm defaults and signatures. Use `gh` for files, releases, the `CHANGELOG`, and the issue/PR history behind a behavior.
3. **Read the official docs, not a summary of them.** Start with the project's own `README`, its in-repo `docs/` or `guides/` directory, and the `CHANGELOG`/`UPGRADING` notes (the last two carry version-specific behavior). Language doc hosts: hexdocs.pm, docs.rs, pkg.go.dev, readthedocs, rubydoc.info. When you need exact wording, defaults, or config, fetch the page and read it in full rather than trusting a summarizer that can drop the detail that matters.
4. **Secondary sources as leads, primary sources as truth.** Blog posts, issues, and first-hand write-ups often surface the exact problem and fix fastest, so search them early. But verify the specifics they claim (APIs, defaults, config, version behavior) against the official docs or source before acting, and never stop at memory.
5. **If a direct fetch is blocked,** fall back to the local dependency copy or a repo clone; the running code is the most authoritative source anyway.
6. **Cite what you found** with `file:line` or the doc URL, and note the version it applies to, so the recommendation can be checked.

## What to evaluate before adopting

Weigh, briefly: Is it **maintained** (recent commits, not abandoned)? Does it **fit** this repo's structure and constraints? What does it **pull in**, and is that acceptable? Is the source **trustworthy** (official or well-known)? If it clears that bar on balance, adopt and adapt it. If it doesn't, that gap _is_ your reason to deviate: name it so the choice is legible.

## Anti-patterns

- Reimplementing what a well-maintained library already provides (date math, parsing, validation, crypto, retries).
- Inventing a bespoke approach to a problem that has an established, documented methodology.
- Guessing an API, signature, or format from memory instead of reading the official docs or spec.
- Writing a bespoke CI workflow when the platform already ships a reusable action or starter.
- Pasting a snippet from memory instead of reading the maintained source.
- Hand-rolling a patch, workaround, or fork for something a dependency upgrade, a config option, or a maintained plugin already fixes.
- Skipping blog posts, issues, and first-hand write-ups that describe the exact problem, then re-deriving the fix from scratch.
- Adopting prior art blindly, without checking maintenance, fit, or what it drags in.
