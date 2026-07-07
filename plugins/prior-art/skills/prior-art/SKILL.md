---
name: prior-art
description: Find and reuse existing prior art (libraries and dependencies, established methodology and reference patterns, official documentation, upstream repos, reusable CI and tooling) before hand-rolling or reimplementing something that has already been solved.
when_to_use: >-
  Use before adding a dependency, reimplementing functionality a library already provides, designing an approach to a common problem, or hand-rolling CI, tooling, infra, or scaffolding. Also when you would otherwise guess at an API or format instead of reading the official docs or spec. Anytime the impulse is to build from scratch rather than reuse an existing library, established methodology, documented standard, or upstream pattern.
---

# Prior art first

Most "new" work isn't new. The library you need, the approach to the problem, the config, the algorithm, the API you are about to call: usually someone has already built, solved, or documented it, whether the project's own maintainers, an official or upstream repo, a widely-used library, or a published spec. Hand-rolling re-derives decisions other people already made carefully, and the result is usually worse: missing edge cases, nothing to maintain it, and behavior that surprises the next person. Searching first costs a few minutes; rewriting a bespoke version later costs far more.

## RULES

1. **Search before you build.** Before adding a dependency, reimplementing a capability, designing an approach, or writing CI/tooling/infra, spend the first few minutes finding how it is already done or documented.
2. **Look in priority order:** (a) this repo and sibling repos for an existing pattern or an already-listed dependency, (b) the official or upstream project's own repo and docs, (c) the broader ecosystem of well-known libraries, packages, reusable actions, and reference implementations.
3. **Present the prior art before implementing.** Tell the user what you found and propose adopting it; let them pick adopt vs. adapt vs. hand-roll. This is the core of the skill: don't silently build past a solution that already exists.
4. **Prefer a maintained dependency over a reimplementation.** Date math, parsing, validation, auth, retries, format handling: a maintained library keeps getting fixes and edge cases; your reimplementation does not. Reach for the library before writing the logic yourself.
5. **Follow established methodology, don't invent one.** For a common problem there is usually a documented pattern, reference architecture, or standard algorithm. Adopt the well-trodden approach rather than a novel one, unless the novelty is the point.
6. **Read the docs and the real source, don't reconstruct from memory.** For an unfamiliar API, format, config, or protocol, fetch the official documentation, spec, or source (web search, `gh`, WebFetch) and follow it. Memory-reconstructed signatures and config are subtly wrong.
7. **Deviate only with a stated reason.** Building from scratch is right when the prior art doesn't fit, is unmaintained, pulls in too much, or the need is genuinely novel; say which.

## Where to look

- **In-repo / org first.** Existing patterns, configs, and the dependencies already in the manifest. `grep`/`find` for the pattern and match the conventions already in use before adding anything new.
- **Official / upstream.** The tool, library, or platform's own repo, docs, and spec. These often ship a reference implementation, a worked example, or a reusable action. A plugin marketplace, for instance, can mirror its ecosystem's official starter repo and delegate validation to a _reusable action_ rather than hand-rolling the steps.
- **Ecosystem.** The package registry (for a library that already solves it), `awesome-*` lists, reference architectures, and `starter`/`template` repos.

## What to evaluate before adopting

Weigh, briefly: Is it **maintained** (recent commits, not abandoned)? Does it **fit** this repo's structure and constraints? What does it **pull in**, and is that acceptable? Is the source **trustworthy** (official or well-known)? If it clears that bar on balance, adopt and adapt it. If it doesn't, that gap _is_ your reason to deviate: name it so the choice is legible.

## Anti-patterns

- Reimplementing what a well-maintained library already provides (date math, parsing, validation, crypto, retries).
- Inventing a bespoke approach to a problem that has an established, documented methodology.
- Guessing an API, signature, or format from memory instead of reading the official docs or spec.
- Writing a bespoke CI workflow when the platform already ships a reusable action or starter.
- Pasting a snippet from memory instead of reading the maintained source.
- Adopting prior art blindly, without checking maintenance, fit, or what it drags in.
