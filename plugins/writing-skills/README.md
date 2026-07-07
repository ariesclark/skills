# Writing Skills

The vocabulary and principles for writing and editing skills that behave
predictably: how a skill is invoked, how its content is ranked on the information
hierarchy, how leading words and completion criteria steer the agent, and how
pruning keeps it lean.

## Install

```text
/plugin marketplace add ariesclark/skills
/plugin install writing-skills@ariesclark
```

## The `writing-skills` skill

The skill frames a skill as a lever on **predictability** — the agent taking the
same process every run — and hangs the craft on four axes: invocation
(model- vs user-invoked, and the context and cognitive loads each spends), the
information hierarchy (steps vs reference, progressive disclosure, co-location),
steering (leading words, completion criteria, premature completion), and pruning
(single source of truth, relevance, the no-op test, and the failure modes each
cures). `SKILL.md` carries the framework; the full per-term definitions are
disclosed to a colocated `GLOSSARY.md`, which is the same progressive-disclosure
move the skill teaches.

## Credits

The framework and much of its vocabulary — predictability, the information
hierarchy, leading words, and the failure-mode catalog — adapt Matt Pocock's
[`writing-great-skills`](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-great-skills).
The prose here is original; the concepts are his.

## License

MIT. See [LICENSE](../../LICENSE).
