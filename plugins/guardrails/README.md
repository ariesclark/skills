# Guardrails

Rule-based PreToolUse hooks that block noisy Bash habits before they run:
echoing static text (`echo "==="`, `echo done`), re-echoing a command's
output (`echo $(cmd)`, ``echo `cmd` ``), shelling out to
`grep`/`find`/`cat`/`sed` where a dedicated tool fits, stacking independent
commands with `;` instead of running them as parallel tool calls, and
backgrounding with `&` instead of the `run_in_background` parameter. Echoes
and backgrounding are denied outright; the rest surface as context the agent
can override when the shell is genuinely needed. A plain `echo` is left alone
only when it emits dynamic input like `$VAR` (run the command directly rather
than echoing its output).

Detection lives in declarative ast-grep rules under `rules/` (one file per
habit, each with colocated `valid`/`invalid` test cases). On every Bash
command, `scripts/bash` selects the rule files whose `CLAUDE_PLUGIN_OPTION_*`
toggle is on, then pipes the command through `core/scripts/rule`'s
`apply_rules`, which scans it with `ast-grep --inline-rules --stdin` and
emits the most-severe match as a verdict (`error` rules deny, `warning` rules
warn). Because the rules match a real syntax tree, a leading tool feeding a
pipe is flagged while the same tool used as a downstream filter is left
alone, and the stacking rule counts only top-level statements, skipping setup
builtins like `set`/`cd` so `set -euo pipefail; cmd` stays quiet. Each rule
can be toggled at enable time. Requires `jq` and `ast-grep`.

ast-grep parses with tree-sitter, which does not peel wrapper commands, so
`sudo grep …` is not flagged (the bare `grep …` still is). `sgconfig.yml`
wires `rules/` for `ast-grep test`, which runs each rule's colocated cases.

## Install

```
/plugin install guardrails@ariesclark
```
