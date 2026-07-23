---
description: Fork this conversation and mine it for papercuts, appending each to PAPERCUTS.jsonl.
---

Delegate a papercut review of this conversation to a fork, so the review stays
out of the main context. Use the Agent tool with `subagent_type: "fork"` — a fork
inherits the whole conversation so far, so it needs no transcript or session id.
Hand the fork exactly this task:

> Review the entire conversation so far for "papercuts": small frictions hit
> while working — a tool call that missed and had to be retried, a confusing or
> undocumented setup step, instructions that didn't work as written (a skill, a
> doc, CLAUDE.md), a flaky command, a stale cache, a misleading error, a
> non-obvious gotcha. These are not accomplishments and not tracked bugs. For
> each distinct papercut, run:
>
>     papercuts add "<what was being done>, <what got in the way>"
>
> The `papercuts` command is on PATH. When done, report how many you appended, and
> nothing else.

Do not review the conversation yourself in the main thread — the fork does the
whole review. (Forks require Claude Code with fork mode enabled, on by default in
recent versions; set `CLAUDE_CODE_FORK_SUBAGENT=1` if the fork type is rejected.)
