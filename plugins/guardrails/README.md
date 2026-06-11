# Guardrails

Rule-based PreToolUse hooks that block noisy Bash habits before they run:
decorative banners (`echo "==="`), status narration (`echo done`), and
shelling out to `grep`/`find`/`cat`/`sed` where a dedicated tool fits.
Banners are denied outright; the rest surface as context the agent can
override when the shell is genuinely needed.

Routing lives in the manifest's `hooks` key (`matcher` picks the tool, `if`
rules pick the calls worth inspecting); `scripts/bash.sh` holds the checks
as flat guard blocks. Requires `jq`.

## Install

```
/plugin install guardrails@ariesclark
```
