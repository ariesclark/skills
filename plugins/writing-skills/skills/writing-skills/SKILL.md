---
name: writing-skills
description: The vocabulary and principles for writing and editing skills that behave predictably — how a skill is invoked, how its content is ranked on the information hierarchy, how leading words and completion criteria steer the agent, and how pruning keeps it lean.
when_to_use: >-
  Use when writing, editing, reviewing, or shortening a skill, deciding whether a
  skill should be model- or user-invoked, choosing what belongs in SKILL.md versus
  a linked reference file, or diagnosing why a skill fires unreliably or behaves
  inconsistently across runs.
---

# Writing skills

A skill exists to wring determinism out of a stochastic agent. **Predictability** — the agent taking the same _process_ every run, not producing the same _output_ — is the root virtue, and every lever below serves it. A brainstorming skill still diverges every run; what stays constant is how it goes about it.

**Bold terms** have full definitions in [`GLOSSARY.md`](GLOSSARY.md); reach for it when a term needs its edges.

## Invocation

Every skill pays one of two costs, and the choice is which:

- **Model-invoked** keeps a `description`, so the agent can fire the skill on its own and other skills can reach it. The description sits in the context window every turn, so it spends **context load**. Use it only when the agent must reach the skill unprompted, or another skill must.
- **User-invoked** strips the description (`disable-model-invocation: true`): only the human, typing its name, can invoke it. Zero context load, but it spends **cognitive load** — the human becomes the index that has to remember it exists.

When user-invoked skills outrun what you can hold in your head, a **router skill** — one user-invoked skill that names the others and when to reach for each — pays that cognitive load down.

## Information hierarchy

A skill's content is either a **step** (an ordered action the agent performs) or **reference** (a fact, rule, or definition it consults on demand). Rank each piece by how immediately the agent needs it, on a ladder:

1. **In-skill step** — in `SKILL.md`, the primary tier. Each step ends on a **completion criterion**.
2. **In-skill reference** — in `SKILL.md`, read on demand. A flat peer-set (every rule on one rung) is a fine shape, not a smell.
3. **Disclosed reference** — pushed into a linked file, reached by a **context pointer** that loads it only when needed.

**Progressive disclosure** is the move down that ladder: keep the core workflow in `SKILL.md`, push long examples, deep-dive patterns, and reference tables into a linked file the body points at. A pointer's _wording_, not its target, decides how reliably the agent follows it — so sharpen the wording before you inline must-have material. **Co-location** is the companion move: keep a concept's definition, rules, and caveats under one heading so reading one part brings its neighbours along.

The tension is the whole job: push too little down and the top bloats; push too much and you bury what the agent actually needs.

## Steering

- A **leading word** is a compact concept already in the model's pretraining — _lesson_, _fog of war_, _tracer bullet_ — that the agent thinks with while running the skill. Repeated as a token (never restated as a sentence), it anchors a whole region of behaviour in the fewest tokens by recruiting priors the model already holds. Prefer an existing word; a coined one recruits nothing until you spend tokens defining it.
- A **completion criterion** has two independent axes. Its _clarity_ (can the agent tell done from not-done?) resists **premature completion**. Its _demand_ (how much it requires — "every modified model accounted for", not "produce a change list") sets how much **legwork** the agent does. The strongest criteria are both checkable and exhaustive.
- **Premature completion** is ending a step while attention slips to _being done_. Sharpen the criterion first — it is local and cheap. Only when the bound is irreducibly fuzzy _and_ you see the rush, hide the later steps by splitting the sequence across a real context boundary.

## Pruning

Keep each meaning in a **single source of truth**: one authoritative place, so a behaviour change is a one-place edit. Check every line for **relevance** — does it still bear on what the skill does? Then run the **no-op** test sentence by sentence: does this change behaviour versus the model's default? A line can be perfectly relevant and still be a no-op. Delete whole sentences that fail; be aggressive.

The failure modes to diagnose against: **sprawl** (too long even when every line is live — cured by the ladder), **sediment** (stale layers that accrete because adding feels safe and removing feels risky), **duplication** (one meaning in two places, which also inflates its rank on the ladder), and **no-op** (load spent saying what the agent already does). See `GLOSSARY.md` for each and its cure.

## Why lean

Every token spends a finite attention budget, and accuracy drops as context grows (context rot), so a lean skill buys reliability, not just space.

- Chroma, "Context Rot: How Increasing Input Tokens Impacts LLM Performance": https://trychroma.com/research/context-rot
- Anthropic, "Effective context engineering for AI agents": https://anthropic.com/engineering/effective-context-engineering-for-ai-agents
