# Papercuts

Log the small frictions you hit while working — a tool call that missed and had
to be retried, a confusing or undocumented setup step, instructions that didn't
work as written (a skill, a doc, CLAUDE.md), a flaky command, a stale cache, a
misleading error, a non-obvious gotcha — to `PAPERCUTS.jsonl`, in the moment. None of them block the work, so they never get written down; logged
together they show where the repo needs sanding down. This is distinct from a
work log (what you accomplished) and from an issue tracker (real bugs and
tracked work).

The CLI lives in `bin/`, which Claude Code adds to the Bash tool's PATH while the
plugin is enabled, so it is a bare `papercuts` command with two subcommands. A
`SessionStart` hook (`scripts/session-start`) primes the agent to log
proactively, one at a time:

```
papercuts add "<what you were doing>, <what got in the way>"
papercuts list [--json]
```

`add` timestamps the entry and appends it as one JSON object to
`PAPERCUTS.jsonl` in the working directory (one line per papercut), tagged with
the model that hit it, the session, the active skill and plugin, and the Claude
Code version. All of those come from the session transcript, read by the bundled
`core` helpers (`scripts/core`, a symlink); `-m` overrides the model, and any
field the transcript cannot supply is left out of the entry.

`-t` attaches the tool call behind the papercut as a `tool` object — its `name`,
the full `input`, the `output`, and whether it failed (`error`) — so the evidence
lands with the entry instead of being described in prose. Bare, it takes the most
recent call, which is the one that just ran, since the transcript records the
`papercuts` invocation itself only after it finishes. With a name (`-t Bash`) it
takes the most recent call of that tool; `--tool=Bash` says the same thing with no
ambiguity. Without `-t` no tool is recorded. A name is read off `-t` only when it
looks like a tool (`Bash`, `mcp__server__tool`), so an unquoted message survives,
but quoting it is safer. When nothing matches, `add` warns on stderr and logs the
papercut anyway. Output over 2000 characters is cut with an ellipsis;
`PAPERCUTS_OUTPUT_LIMIT` changes the cap. `list` prints the logged entries as readable lines, or a JSON array
with `--json`. `PAPERCUTS_FILE` or `-f` overrides the path; the file and any
parent directory are created on first use.

## Reviewing a whole session

`/papercut` mines the whole session at once instead of relying on in-the-moment
logging. It delegates to a [fork](https://code.claude.com/docs/en/sub-agents#fork-the-current-conversation):
a subagent that inherits the entire conversation, so it needs no transcript or
session id. The fork extracts the papercuts and appends each with `papercuts add`,
and only its final count returns to the main context — its tool calls stay out of
the way. It is user-triggered only; the primer tells
the agent never to run the review itself.

A fork was chosen over shelling out to `claude --print` so the review shows up in
the agents panel, where it can be watched and steered, and over a named subagent
so it gets the real conversation instead of a re-parsed transcript. The tradeoff:
a fork runs on the main session's model, not a cheaper one. Forks need fork mode,
on by default in recent Claude Code; set `CLAUDE_CODE_FORK_SUBAGENT=1` otherwise.

## Install

```
/plugin install papercuts@ariesclark
```
