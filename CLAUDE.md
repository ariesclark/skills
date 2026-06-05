# Repository guide

A Claude Code plugin **marketplace** (`.claude-plugin/marketplace.json`). Plugins
live under `plugins/<name>/`, each with its own `.claude-plugin/plugin.json` and
skills under `skills/<skill>/SKILL.md`.

## Validate before committing

Run these on every plugin you touched, plus the marketplace and the skill linter:

```bash
claude plugin validate . --strict                 # marketplace manifest
claude plugin validate ./plugins/<name> --strict  # a plugin + its skills' frontmatter
ast-grep scan                                      # SKILL.md frontmatter lint rules
```

## Editing skills

Changes to a `SKILL.md` body take effect immediately in a running session; changes
to `plugin.json`, hooks, or MCP config need `/reload-plugins` or a restart.

## References

- [Skills](https://code.claude.com/docs/en/skills) — `SKILL.md` structure,
  frontmatter, and supported features.
- [Plugins](https://code.claude.com/docs/en/plugins) — authoring plugins and their
  components.
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) —
  `.claude-plugin/marketplace.json` and distribution.
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) — full
  manifest and directory-layout reference.
