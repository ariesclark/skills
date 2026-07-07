---
name: why
description: Explain exactly why you took a specific action, citing the exact context that drove each part of the decision, separating what your instructions required from what was left to your discretion, then putting the resolution and its in-place fix to the user with AskUserQuestion and acting on their pick.
when_to_use: >-
  Use when the user asks why you did, chose, said, or skipped something ("why did you...", "what made you...", "cite what influenced that"), or wants a past decision audited. Also good right after a surprising or wrong action, to trace it to its source and fix that source so it does not repeat.
---

# Why

Reconstruct a specific decision honestly, then resolve it: name the action, trace each influence to the exact context that caused it, separate what your instructions forced from what was left to your discretion, then land on one distinct result. Accuracy is the whole point. A clean-sounding reason you reverse-engineered to look justified is the failure mode; "nothing drove this, it was my own call, and a rule actually discouraged it" is the success.

**Work only from what is already in context.** The reason lives in the conversation, the instructions and reminders you were given, and the tool results you already saw. Do not read files, grep, or run commands to reconstruct it: investigating after the fact builds a plausible story instead of reporting the real driver. Tools are allowed only for applying the fix, once the reason is already clear. If the reason is not in context and you do not actually know it, reject explicitly: say the reason is not in context and you cannot reconstruct it, and stop. Do not guess, and do not go looking.

## Steps

1. **Pin the action.** State the exact thing in one line, in the user's terms. The action is whatever could have gone another way: a command, a tool choice, an edit, a phrasing, or an omission. If the user did not pin one, take the most recent decision with a real alternative; if two could be meant, ask which before explaining.
2. **Trace each influence to its source, using only context you already have.** For every part of the decision, find the real cause and quote it. Look across: user instructions in this thread, `CLAUDE.md` rules (project and global), recalled memories, `<system-reminder>` blocks, hook messages, tool output you already saw, skill bodies, the environment block. Cite the line, not "my guidelines." Most decisions have several inputs; list them apart. If no cause is in context, do not investigate to find one: reject (see above).
3. **Separate forced from discretionary.** For each part, say whether context required it (quote the driver) or nothing in the available context drove it and it was left to your discretion. "Discretionary" means only that: no driver present, not a positive reason you can introspect. It is not a reject; reject is for when the action or its context is not available to you at all, while a discretionary choice is one you can see had no driver. The split feeds the fix: forced means edit the instruction that caused it, discretionary means add one. If a rule pushed against what you did, lead with that.
4. **Resolve to one result, then put it to the user with `AskUserQuestion`.** Land on one distinct result below (or a reject), then call `AskUserQuestion` presenting that result as the recommended option alongside the real alternatives, and act on the choice. Reject is the only result with no question. Pick the result by whether the user named a better alternative.

## Resolve to one result

Trace the decision first in every case, then land on exactly one of these. Do not blend them.

- **"Why X instead of Y" (alternative named).** Weigh X against Y honestly.
  - **Y is better: correct in place.** Have the concrete fix ready, do not just describe it, then apply it once the user picks it in the question below. The fix has two forms depending on step 3:
    - **X was forced** by an instruction: edit that file (the bad rule, memory, hook, or skill). Changing its text is the correction, plus redoing the work as Y.
    - **X was discretionary** (nothing drove it): there is no file to blame, so introduce the guardrail that was missing. Add a rule, memory, or hook that forces Y next time. Do not reject a discretionary miss when an alternative was named; a named alternative is exactly what the new instruction encodes.
    - Either way the fix changes a file. An already-sent or destructive action that cannot be redone still gets the source fix.
  - **X still stands: hold X.** Keep it and give the reason it wins; do not cave just because an alternative was named. But when the reason X wins is an instruction in context, name that instruction as the lever: X holds only while the rule does, so if the user still disagrees, the rule is what changes, not X. Never close a hold with "no fix needed" while a rule is doing the work; point at the rule so the user can overrule it.
- **"Why X" (no alternative named).** Explain what drove X, then:
  - **Dissatisfaction, but you were not told what to do instead: ask.** Ask what they would have preferred, or whether they want it changed. Do not invent a Y to knock down, and do not rewrite on a guess. Wait for the answer before correcting anything.
  - **Plain question: propose a fix.** If X was discretionary or wrong, prepare the in-place fix and offer it in the question below. If the decision was well-grounded, say so instead of inventing a fix.

### Put it to the user with AskUserQuestion

After you land on a result, call `AskUserQuestion` so the user drives the final action instead of you acting unilaterally. Make the recommended result the first option, labeled `(Recommended)`. Tailor the options to the branch:

- **Correct in place:** "Apply the fix in place (Recommended)", "Show the exact edit first", "Hold X instead". Apply the edit and redo the work on approval.
- **Hold X:** "Keep X (Recommended)", "Override to Y and change the rule that is the lever".
- **Propose a fix:** "Apply the fix (Recommended)", "Just note it, change nothing".
- **Ask:** the question itself is the `AskUserQuestion`; the options are the alternatives you would have chosen, so the user names Y.
- **Reject:** no question. State that the reason is not in context and stop.

## Output shape

Keep it tight. Four labeled parts, plain text, except the cited driver, which goes in a rendered blockquote:

**Action:** the one-line thing you are explaining.

**What drove it:** name each influence, then quote its source verbatim in a blockquote, with the exact span that caused the action in bold. The blockquote is a verbatim copy, never summarized, paraphrased, condensed, or tidied; bolding the operative span is the only change you may make. Cite the specific line, not "my guidelines":

> Bash tool: "**Keep each command simple and legible.** The permission evaluator and the user read every one, so a dense one-liner is harder to approve and harder to follow than a couple of plain steps."

**What was discretionary:** the parts nothing pointed to, named plainly.

**Result:** the outcome you landed on. Corrected in place (the file and what you redid), holding X (with the reason it wins and the rule that is the lever), proposed a source fix (the file and the change), or rejected (the reason is not in context). Then call `AskUserQuestion` to put that result and its alternatives to the user, and act on the pick. Reject is the only result with no question.

## Source-to-fix mapping

Where the fix goes depends on what drove the miss:

- **A rule existed but was easy to miss:** rephrase it, or add the example you got wrong, in that same `CLAUDE.md` or rule file.
- **Nothing drove it and it was wrong:** write a new rule where it belongs (global `CLAUDE.md` for cross-project, the project's own for local), or a memory file for a preference.
- **A memory or instruction was stale or wrong:** update or delete it at the source.
- **A hook message was unclear:** edit the rule's `message`/`note`, not just your behavior.
- **It must run automatically every time:** prose only nudges, so propose a hook in `settings.json`, which the harness enforces.
- **The fix lands in an instruction file** (`CLAUDE.md`, a rule, a memory, a hook): edit it in place. That is what "fix in place" means. Propose-and-wait only when you lack authorization or the right change is genuinely unclear.

## Example

Asked "why did you run `npm test` when this is a pnpm project?" (alternative named, and it wins, so correct in place):

**Action:** ran `npm test`, which failed.

**What drove it:** the project's `CLAUDE.md`, which I followed verbatim:

> Run **`npm test`** to run the test suite.

**What was discretionary:** nothing. The action was forced by the instruction; the instruction itself is wrong for a `pnpm` repo.

**Result (corrected in place):** `pnpm test` was the right call. The fix is to edit that line in the project `CLAUDE.md` from `npm test` to `pnpm test` so it stops entering context next session, and rerun with `pnpm test`.

Then put it to the user with `AskUserQuestion`:

> **Apply the `pnpm test` fix to the project `CLAUDE.md`?**
> - Apply in place and rerun (Recommended)
> - Show the exact edit first
> - Leave it, I was wrong

On "Apply," edit the file and rerun `pnpm test`.

## Rules

- **Do not confabulate.** No cause found means "a discretionary choice," not an invented instruction that makes the decision look justified.
- **No new context.** The reason must be in context already. Never read files, grep, or run commands to find it; tools are for applying the fix, not for reconstructing the why. If it is not there and you do not know it, reject explicitly instead of investigating or guessing.
- **Quote, do not paraphrase.** The exact words are what the user can act on. "The Bash section says 'Keep each command simple and legible'" beats "my instructions favor simplicity." Render the quote in a blockquote and bold the exact span that caused the action, so the driver is unmistakable.
- **Never summarize the blockquote.** It must reproduce the source text exactly, character for character, bolding aside. Do not condense, reword, or tidy it. If the source is long, quote the relevant sentence whole rather than shortening it.
- **Own the misses.** If context discouraged what you did, or a better option was there and you skipped it, lead with that instead of defending the call.
- **Not every why ends in a fix.** A grounded decision needs no change; say why it was right rather than forcing a fix to look responsive.
- **Fix the source, not the symptom.** A promise does not survive a context reset. The durable fix edits the instruction, memory, or hook that is still there next session.
