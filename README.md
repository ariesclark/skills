# ariesclark agent skills

A marketplace catalog of agent skills, organized as domain plugins you
install independently. Three plugins so far: idiomatic Elixir & Phoenix
backend skills, Fly.io infrastructure ops, and a prior-art workflow skill.

## Install

Add the marketplace once, then install the plugins you want:

```text
/plugin marketplace add ariesclark/skills
/plugin install elixir-phoenix@ariesclark
/plugin install fly@ariesclark
/plugin install prior-art@ariesclark
```

## Plugins

Each plugin has its own README with the full skill list and details.

### [`elixir-phoenix`](plugins/elixir-phoenix/README.md)

Idiomatic Elixir & Phoenix backend skills: conventions, OTP, Ecto, JSON APIs, authorization, security, Oban, observability, deployment, and testing.

### [`fly`](plugins/fly/README.md)

Fly.io infrastructure ops: Prometheus/VictoriaLogs queries, `fly ssh`, production Postgres.

### [`prior-art`](plugins/prior-art/README.md)

Find and reuse existing prior art (libraries, established methodology, official docs, upstream patterns) before hand-rolling or reimplementing what's already solved.

## Local development

Add this repo as a local marketplace and install from it. Changes to a skill's
`SKILL.md` take effect immediately; other changes need `/reload-plugins`:

```text
/plugin marketplace add ./
/plugin install <name>@ariesclark
```

Validate a plugin's structure and manifest before publishing:

```bash
claude plugin validate ./ --strict
claude plugin validate ./plugins/<name> --strict
```

## References

- [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide): Joseph Morgan (MIT); foundation for the Elixir & Phoenix skills.
- Chris Keathley, [Good and Bad Elixir](https://keathley.io/blog/good-and-bad-elixir) ([source](https://github.com/keathley/keathley.github.io/blob/master/_posts/2021/2021-05-14-good-and-bad-elixir.md)); foundation for `elixir-conventions`.

## License

MIT. See [LICENSE](LICENSE).
