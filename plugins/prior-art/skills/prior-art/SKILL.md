---
name: prior-art
description: Find and mirror existing prior art before hand-rolling CI/CD, workflows, build tooling, infrastructure-as-code, scaffolding, or reimplementing functionality a well-known project has already solved.
when_to_use: >-
  Use before setting up CI, writing a workflow or pipeline, adding a linter/formatter/release automation, scaffolding a plugin or package, configuring Docker/Terraform/Kubernetes, or reimplementing standard functionality (algorithms, parsers, format handling) — anytime the impulse is to hand-roll boilerplate, a reusable action, or infra config rather than reuse existing prior art.
---

# Prior art first

Most "new" infrastructure isn't new. CI pipelines, release workflows, linters, scaffolding, Dockerfiles, and common algorithms have already been solved — usually by the project's own maintainers, an official/upstream repo, or a widely-used library. Hand-rolling re-derives decisions other people already made carefully, and the result is usually worse: missing edge cases, nothing to maintain it, and behavior that surprises the next person. Searching first costs a few minutes; rewriting a bespoke version later costs far more.

## RULES
1. **Search before you scaffold.** Before writing CI, tooling, infra config, or reimplementing a capability, spend the first few minutes finding how it's already done.
2. **Look in priority order:** (a) this repo and sibling repos for an existing pattern, (b) the official or upstream project's own repo, (c) the broader ecosystem — well-known libraries, reusable actions, template repos.
3. **Present the prior art before implementing.** Tell the user what you found and propose adopting it; let them pick adopt vs. adapt vs. hand-roll. This is the core of the skill — don't silently hand-roll past a solution that already exists.
4. **Prefer adopting a maintained source over copying a snippet.** A reusable action, a shared config preset, or a library dependency keeps getting fixes; a pasted snippet rots in place.
5. **Read the real source, don't reconstruct from memory.** Use web search, `gh`, or WebFetch to fetch the actual file. Memory-reconstructed config is subtly wrong and unpinnable.
6. **Pin third-party sources to an immutable ref** — a commit SHA for actions, an exact version for dependencies — and note where it came from so it can be bumped deliberately.
7. **Deviate only with a stated reason.** Hand-rolling is right when the prior art doesn't fit, is unmaintained, pulls in too much, or the need is genuinely novel — say which.

## Where to look
- **In-repo / org first.** Existing workflows, `Makefile`/`justfile`, config files, sibling packages. `grep`/`find` for the pattern and match the conventions already in use.
- **Official / upstream.** The tool or platform's own repo and docs often ship a reference workflow or a reusable action. For example, a Claude Code plugin marketplace mirrors `anthropics/claude-plugins-official`, which delegates plugin validation to a *pinned reusable action* rather than hand-rolling the steps.
- **Ecosystem.** `awesome-*` lists, the package registry, `starter`/`template` repos, and the relevant action/extension marketplace.

## What to evaluate before adopting
Weigh, briefly: Is it **maintained** (recent commits, not abandoned)? Does it **fit** this repo's structure with minimal config? What does it **pull in**, and is that acceptable? Is the source **trustworthy and pinnable** (official or well-known, with a stable ref)? If it clears that bar on balance, adopt and adapt it. If it doesn't, that gap *is* your reason to deviate — name it so the choice is legible.

## Anti-patterns
- Writing a bespoke CI workflow when the platform already ships a reusable action or starter.
- Reimplementing a standard algorithm or format parser that a stdlib or popular library already provides.
- Pasting a snippet from memory instead of reading and pinning the maintained source.
- Adopting prior art blindly — without checking maintenance, fit, or what it drags in.
