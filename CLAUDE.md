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

## Writing ast-grep hook rules

ast-grep rules surfaced as PreToolUse verdicts (see `plugins/guardrails`) are read
by an agent whose call was just blocked. Each `message`/`note` is an error-recovery
prompt: get it to a compliant call on the next try.

- **Name the offender, lead with the fix.** Capture the node with `pattern: $CMD`
  and interpolate it (`` `$CMD` is entirely noise ``), like `$TOOL` in
  `shelling-out`. Don't restate the abstract rule.
- **Match copy to severity.** `error` denies and the agent resubmits, so write a
  retry ("Try again without it"); `warning` doesn't block, so write "prefer Y".
- **Be assertive.** It's rejected until fixed: "Delete it", not "Usually the fix is
  to delete it". No hedging, no em dashes.
- **Message vs note.** Message names the offender, the verdict, and the retry
  (`` `$CMD` is entirely noise. Try again without it. ``). The note teaches the rule
  itself, in a fixed shape: a lead line of `directive + why-as-cost` ("Don't print
  fixed text; it wastes context and repeats what each command's output and exit status
  already show"), then, only if the rule has several recognizable forms, a
  `Common gotchas (blocked):` list of `category: example` entries picked for structural
  range (bare, `&&`, `||`), not reworded duplicates. The shared domain ("When running
  bash commands") is stated once by whatever wraps the notes (the SessionStart primer,
  or the PreToolUse message), not repeated in every note.
- **Keep `$NAME` out of prose.** ast-grep interpolates metavariables into the
  message, so a literal `$VAR` gets eaten; use words or non-metavariable forms
  (`$(cmd)` is safe).
- **Backtick literal tokens.** Tool names, flags, arguments, and operators go in
  backticks (`` `run_in_background` ``, `` `&&` ``, `` `sleep` ``) so they read as
  code, not prose. Wrap long copy in a block scalar to keep source lines short:
  notes use literal (`|-`) so the wrapping and the gotchas list show as written; a
  message can fold (`>-`) back to one line.
- **Scope precisely.** A rule that overreaches gets ignored. Carve out the fine
  lookalikes (guardrails' noise rules exempt redirects:
  `not: { inside: { kind: redirected_statement } }`) and keep siblings consistent.
- **Prove it.** Cover real and edge cases in `valid:`/`invalid:`, render the copy
  through the hook (interpolation only appears at runtime), and run the plugin's
  tests. If rules are config-toggled, add the `userConfig` entry.

## References

- [Skills](https://code.claude.com/docs/en/skills): `SKILL.md` structure,
  frontmatter, and supported features.
- [Plugins](https://code.claude.com/docs/en/plugins): authoring plugins and their
  components.
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces):
  `.claude-plugin/marketplace.json` and distribution.
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference): full
  manifest and directory-layout reference.
