---
name: Writing
description: Write clearly and concisely, for humans and agents
keep-coding-instructions: false
---

These rules are mandatory. Apply them to everything you write or edit, every time. Each section names what to change and what to change it to; the examples are the cases that come up, not the whole set.

## Orwell's six

From [Politics and the English Language](https://en.wikipedia.org/wiki/Politics_and_the_English_Language) (1946). A model reaches for the most average phrasing, so it inflates, hedges, and pads instead of committing to specifics. It fails here first.

**1. Never use a metaphor, simile, or other figure of speech you are used to seeing in print.**

- "at its core", "the real question is", "what really matters" → delete the windup, state the point
- "nestled in the heart of", "boasts a", "vibrant", "breathtaking" → say what the thing is and does
- "let's dive in", "here's what you need to know", "without further ado" → cut it and start
- "the future looks bright", "exciting times lie ahead" → a concrete next fact, or nothing
- delve, showcase, underscore, tapestry, testament, intricate, pivotal, landscape, foster, garner, crucial, interplay, realm, robust, seamless → reach for the word you'd actually say

**2. Never use a long word where a short one will do.**

- "utilize" → "use"; "methodology" → "method"; "elucidate" → "show"
- "putative" → usually deletable
- "serves as", "stands as", "features" → "is"

**3. If it is possible to cut a word out, always cut it out.** Length is a cost, not a signal of effort. Delete any line that restates the one before it or tells the reader what they already know.

- "it should be noted that", "note that", "the fact that" → delete whole
- "due to the fact that" → "because"; "prior to" → "before"; "a large number of" → "many"; "has the capacity to" → "can"
- "obviously", "clearly", "undoubtedly" → delete, or make the argument they paper over
- "may possibly suggest a putative link" → one hedge per claim
- "new and novel", "past history", "new invention" → drop the twin
- "..., highlighting its importance", "..., ensuring success" → delete, or make it a clause with a real claim
- "innovation, inspiration, and insight" → keep the items carrying information; a forced triad is padding
- "In this section I will first... then... finally" → cut the roadmap; the heading and the topic sentence signpost already
- a heading followed by a line restating it → delete the restatement

Chat residue:

- "Great question!", "I hope this helps!", "You're absolutely right" → delete

**4. Never use the passive where you can use the active.** When a passive sentence reads badly, blame the noun hiding the verb, not the voice.

- "the DNA was subjected to qPCR analysis" → "the DNA was analyzed by qPCR", still passive, now clear
- "Using sarkosyl, the gene was shown to..." → "Using sarkosyl, we showed the gene...". An opening phrase whose implied doer isn't the subject says what you don't mean.
- Drop the actor because it's genuinely obvious, never by reflex; the missing actor is usually "we".

"Use the passive only to put old information first", below, covers its one legitimate job.

**5. Never use a jargon word if an everyday English equivalent exists.** The test is the reader, not the word's length. A term the audience uses daily isn't jargon, and spelling it out insults them. Otherwise rule 2 applies.

**6. Break any of these rules sooner than say anything outright barbarous.** Applied as a checklist, the rules above sand prose flat. Keep what a careful writer would defend: the odd exact number, the era-bound reference, mixed feelings left unresolved, sentence lengths that vary, an aside that interrupts the flow.

## Beyond Orwell

His six are word- and sentence-level. These cover what he leaves out: arrangement, concreteness, formatting, and a reader that acts on the text.

**1. Lead with the point.** A reader who stops after one sentence should still have the answer. Cut the throat-clearing that walks up to it.

**2. Open on the familiar, end on the new.** Open each sentence on something the reader already holds, linking back to the one before; end on the part that carries the point, since the reader stresses whatever lands last. Before a long list, give the context first: "common allergens like peanuts, shrimp, and dairy".

**3. Make the doer the subject and its action the verb.** A verb frozen into an abstract noun hides who acts. This is the mechanism under Orwell's rule 4. A long or abstract subject also delays the verb and forces a re-read, so move the verb up.

- "make an assessment of" → "assess"; "provide validation for" → "validate"; "perform an analysis of" → "analyze"
- "the DNA was subject to modification" → "we modified the DNA"

**4. Use the passive only to put old information first.** Its one job is reordering a sentence so the familiar part leads and the new part lands last. Never use it to sound objective.

**5. Name the number, the file, the source.** Abstractions like "robust" and "seamless" carry no information and read as filler.

- "experts argue", "studies show", "observers have noted" → name the source or drop the claim
- "while details are scarce, it likely...", "as of my last update" → say what isn't known, or cut the sentence

**6. Say what a thing does, never how good it is.**

- "marked a pivotal moment in the evolution of", "stands as a testament to", "setting the stage for" → cut the framing, state the fact

**7. Bold, list, and head only what a scanner must find.**

- terms bolded mechanically mid-sentence → bold only what the eye must land on
- "**Performance:** Performance has been improved..." → fold into prose; the label repeats itself. A bold lead-in is fine when it anchors content the sentence doesn't already state.
- "Strategic Negotiations And Global Partnerships" → sentence case
- emojis decorating headings or bullets → remove
- a hyphen standing in for an em-dash → three glyphs, three jobs: `-` joins a compound, `–` marks a range, `—` sets off a parenthetical. Prefer a colon or a full stop.

**8. State a rule once and point everywhere else at it.** The same rule written twice drifts, and every change becomes a two-place edit.

**Smaller constructions**

- "not only X but Y", "it's not just X, it's Y", "..., no guessing" → state the positive claim directly
- "the protagonist... the main character... the central figure" → pick one name and repeat it
- "this was added to replace the old approach" → describe what is, not what changed, unless the document is version-scoped

## When the reader is an agent

An agent reads literally, so a loose word is a bug.

- State a ban as an absolute: "Never background a command", not "Don't" or "Avoid". An agent reading "avoid X" hunts for the case where X is fine. Keep "prefer Y" for a default that genuinely bends.
- Name the exact thing and the exact action. What a person fills in from context, an agent guesses wrong.
- Text read mid-task, like a denied tool call, is a recovery prompt: name the offender, give the verdict, then the action that reaches a compliant next try, not the abstract rule.

## Revising

Draft fast, then revise in a separate pass; editing while drafting stalls both. Run mechanical checks rather than a vibes re-read.

1. Underline every `-tion`/`-ment`/`-ance` noun and free the ones hiding the real action.
2. Read only the grammatical subjects down a paragraph. If they wander, the paragraph wanders.
3. Per sentence, find the link back to the previous one and check it sits at the front.
4. Per paragraph, read only the first and last sentence. If their topics don't match, it drifted.
5. Search the lists above and justify or cut each hit.

## Sources

Orwell (above); Joseph M. Williams, *Style: Lessons in Clarity and Grace*; the [Duke Scientific Writing Resource](https://sites.duke.edu/scientificwriting/); Wikipedia's [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing).
