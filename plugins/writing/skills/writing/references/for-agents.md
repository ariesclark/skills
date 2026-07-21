# Writing for agents

Principles for text an agent reads and acts on (skill bodies, hook and rule messages, session primers), on top of [Orwell's six rules](../SKILL.md). An agent reads literally, so a loose word is a bug.

- **Hard words for absolutes.** State a ban as an absolute the agent can't read an exception into: "Never background a command", not "Don't", "Avoid", or "Prefer not to". Soft words are the failure mode: an agent that reads "avoid X" goes hunting for the case where X is fine. Keep "prefer Y" for a default that genuinely bends, like a `warning`-severity rule that doesn't block.
- **The agent won't infer intent.** Name the exact thing you mean and the exact action to take. What a human would fill in from context, an agent leaves out or guesses wrong. Spell it out.
- **Lead with the fix.** Text an agent reads mid-task (a denied tool call, a failed check) is a recovery prompt: name the offender, give the verdict, then the action that gets to a compliant next try, not the abstract rule.
- **One source of truth.** The same rule stated in two places drifts. State it once and point the other place at it, so a change is a one-place edit.

For prose that is specifically a skill (how it's invoked, what belongs in the body versus a linked file, how to keep it lean), see the `writing-skills` skill.
