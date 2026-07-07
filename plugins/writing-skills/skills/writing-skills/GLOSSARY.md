# Glossary — writing skills

The domain model behind [`SKILL.md`](SKILL.md). A skill exists to wring determinism out of a stochastic agent; the root virtue is **predictability**, and every term here is a lever on it. Terms are grouped by axis: invocation (how a skill is reached), information hierarchy (how its content is arranged), steering (how the agent's runtime behaviour is shaped), and pruning (how it is kept lean). Failure modes sit beside the lever that cures them.

## Predictability

How consistently a skill makes the agent behave the same _way_ — same process, not same output. A brainstorming skill should diverge every run; its tokens vary while its behaviour holds. Cost and maintainability are symptoms of predictability, not rivals to it.

## Invocation

### Model-invoked

A skill that keeps its `description`, so the agent can discover and fire it on its own; the human can still type its name too, so model-invocation always _includes_ user reach. It pays a permanent **context load** every turn in exchange for that discoverability, and it is reachable by other skills. A model-invoked skill whose content is all **reference** is one home for reference several skills share.

### User-invoked

A skill with its `description` stripped (`disable-model-invocation: true`): invisible to the agent, reachable only by the human typing its name. It trades agent-discoverability for zero **context load**. Because nothing but the human can reach it, no other skill can fire it.

### Context load

The standing cost a **model-invoked** skill imposes on the context window — its description, always loaded, spending both tokens and attention. What **user-invoked** skills escape, and the brake on splitting into more model-invoked skills.

### Cognitive load

The cost a **user-invoked** skill imposes on the human: remembering it exists and when to reach for it. Not a cost to drive to zero — it is the price of human agency. Spend it where human judgement matters; remove it where it does not.

### Router skill

A **user-invoked** skill whose job is to name your other user-invoked skills and when to reach for each, so the human remembers one skill instead of many. It can only hint, never fire them. The cure for **cognitive load** when user-invoked skills multiply.

### Context pointer

A reference held in context that names out-of-context material and encodes the condition for reaching it. The `description` is the top-level pointer (window → skill); a link to a disclosed file is the same object one level down. Its _wording_, not its target, decides when and how reliably the agent reaches the material. A must-have behind a weak pointer is a variance bug: fix the wording first.

## Information hierarchy

### Step

An ordered action the agent performs — when a skill has steps, the primary tier and the part that earns its place in `SKILL.md`. Not every skill has them: a skill can be all steps, all **reference**, or both. Every step ends on a **completion criterion**.

### Reference

Material the agent consults on demand: definitions, rules, facts, examples. Secondary to **steps** when a skill has them, the whole content when it does not. The prime candidate for **progressive disclosure**.

### Progressive disclosure

Moving **reference** down the ladder — out of `SKILL.md` and behind a **context pointer** — so the top stays legible. Not mainly a token optimisation; it is how the information hierarchy is protected. Licensed by branching: disclose what only some paths need, inline what every path needs. If a pointer fires unreliably on must-have material, sharpen its wording before pulling it back inline.

### Co-location

Keeping the material an agent needs at once in one place — a concept's definition, rules, and caveats under a single heading, not scattered. Where the hierarchy decides _how far down_ a piece sits, co-location decides _what sits beside it_. A skill should read like documentation written for the agent.

## Steering

### Leading word

A compact concept already in the model's pretraining that the agent thinks with while running the skill — _lesson_, _fog of war_, _tracer bullet_. Repeated as a token, never restated as a sentence, it accumulates a distributed definition across the skill and anchors a region of behaviour in the fewest tokens. Coining your own works only if you define it; a made-up word recruits no priors, so you pay in definition tokens what a pretrained word gives free. It serves predictability twice: in the body it anchors execution, and in the description — when the same word lives in your prompts and docs — it anchors invocation.

### Completion criterion

The condition that tells the agent a unit of work is done. Two independent axes make it a lever. _Clarity_ (can it tell done from not-done?) resists **premature completion** and needs steps to bite. _Demand_ (how much it requires) sets **legwork**, and binds flat **reference** too — an exhaustiveness bar like "every rule applied" is how a skill with no steps still drives thorough work. The strongest criteria are both checkable and exhaustive.

### Legwork

The work an agent does within a single step — reading files, exploring the codebase, digging up what it needs rather than offloading to the human. It lives below the step structure, latent in the wording. Raised by a **leading word** (_thorough_, _exhaustive_) or a demanding **completion criterion**; goes thin when that demand is missing or when **premature completion** cuts the step short.

### Premature completion

_Failure mode._ Ending the current step before it is genuinely done, because attention slips to being done rather than to the work. A between-steps failure: it needs **steps** to occur. A tug-of-war between visible later steps (the pull forward) and the **completion criterion**'s clarity (the resistance). Reach for the levers in order: sharpen the bound first, since it is local and cheap; only when the criterion is irreducibly fuzzy _and_ you observe the rush, hide the later steps by splitting across a real context boundary.

## Pruning

### Single source of truth

The state where each meaning lives in exactly one authoritative place, so changing a behaviour is a one-place edit. **Duplication** is its violation.

### Relevance

Whether a line still bears on what the skill does. A line loses it either by never bearing on the task or by going stale as the world it describes changes. Shorter skills are easier to keep relevant, because each line is cheaper to check. Distinct from **no-op**: relevance asks whether a line bears on the task, not whether it changes behaviour.

### No-op

_Failure mode._ An instruction that changes nothing because the model already does it by default — load spent to say what the agent would do anyway. The test: does this line change behaviour versus the default? A line can be perfectly **relevant** and still be a no-op. It is model-relative: settle a disagreement by running the skill, not by debating. A **leading word** too weak to beat the default is a no-op; the fix is a stronger word, not a different technique.

### Sprawl

_Failure mode._ A skill simply too long, even when every line is live and unique. Costs readability, maintainability, and tokens. The cure is the information hierarchy: disclose **reference** behind pointers, and split so each path carries only what it needs. Distinct from **sediment** (length from stale accumulation) and **duplication** (length from repeated meaning).

### Sediment

_Failure mode._ Stale layers that settle because adding feels safe and removing feels risky, so you must core down through them to find what is still live. The default fate of any skill without a pruning discipline — the slow erosion of **relevance**.

### Duplication

_Failure mode._ The same meaning given more than one **single source of truth**. Costs maintenance, costs tokens, and inflates a meaning's rank on the ladder past its worth. The accidental inverse of a **leading word**, which repeats a token on purpose but never the meaning.
