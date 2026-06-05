# Prior Art

Search for and mirror existing prior art (official/upstream repos, reusable
actions, in-repo patterns) before hand-rolling CI, tooling, infra, or
reimplementing functionality.

## Install

```text
/plugin marketplace add ariesclark/skills
/plugin install prior-art@ariesclark
```

## The `prior-art` skill

Before building CI, tooling, infra, or reimplementing a capability, the skill
prompts a search for how it has already been solved: first this repo and its
org, then the official or upstream project, then the wider ecosystem (reusable
actions, libraries, template repos). It presents what it finds and proposes
adopting it, pins any third-party source to an immutable ref, and hand-rolls
only with a stated reason.

## License

MIT. See [LICENSE](../../LICENSE).
