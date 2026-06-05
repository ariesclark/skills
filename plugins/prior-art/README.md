# Prior Art

Find and reuse existing prior art (libraries, established methodology, official
documentation, upstream repos, reusable CI and tooling) before hand-rolling or
reimplementing something that has already been solved.

## Install

```text
/plugin marketplace add ariesclark/skills
/plugin install prior-art@ariesclark
```

## The `prior-art` skill

Before adding a dependency, reimplementing a capability, designing an approach,
or hand-rolling CI and tooling, the skill prompts a search for how it has already
been solved or documented: first this repo and its org, then the official or
upstream project's repo and docs, then the wider ecosystem (libraries, reusable
actions, reference implementations, template repos). It favors a maintained
library over a reimplementation and an established methodology over a novel one,
reads the real docs or source instead of reconstructing from memory, presents
what it finds and proposes adopting it, and hand-rolls only with a stated
reason.

## License

MIT. See [LICENSE](../../LICENSE).
