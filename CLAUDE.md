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

CI runs all of these on PRs (`.github/workflows/validate-plugins.yml`):
`claude plugin validate` via Anthropic's reusable action, and `ast-grep scan` via
the official ast-grep action.

## Skill frontmatter rules

- **The description budget is a hard limit.** Claude Code truncates the combined
  `description` + `when_to_use` text at **1,536 characters** in the skill listing
  (the `maxSkillDescriptionChars` default); any triggering keywords past the cut
  are silently dropped, so the skill under-triggers. `ast-grep scan` enforces this
  per field (`description` ≤ 1024, `when_to_use` ≤ 512 → combined ≤ 1,536) via the
  rules in `.ast-grep/rules/`. Lead with the key use case, and put trigger phrases
  in `when_to_use` rather than cramming them into `description`.
- **`name`**: lowercase letters, numbers, and hyphens only; ≤ 64 chars; must match
  the skill's directory name.
- **Quote or fold any description containing `: ` (colon-space).** An unquoted YAML
  plain scalar breaks on colon-space (e.g. `Triggers: foo`), and the skill then
  loads with *empty* metadata — no error, it just silently fails to trigger. Use a
  folded block scalar (`>-`) or quotes.
- VS Code's built-in SKILL.md validator warns on `when_to_use` and other
  Claude-specific fields. That's cosmetic — a known allowlist gap in the editor;
  `claude plugin validate` is the source of truth for what actually loads.

## Editing skills

Changes to a `SKILL.md` body take effect immediately in a running session; changes
to `plugin.json`, hooks, or MCP config need `/reload-plugins` or a restart.
