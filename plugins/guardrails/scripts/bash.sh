#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/core/verdict.sh"

command=$(jq -r '.tool_input.command // empty')

if printf '%s' "$command" | grep -Eq 'echo[[:space:]]+["'\'' ]*[-=*#_]{2,}'; then
	deny 'This command prints a decorative divider (echo "---", echo "=== step ==="). Dividers add noise without information; re-run the command without it.'
fi

if printf '%s' "$command" | grep -Eiq 'echo[[:space:]]+["'\'']?(done|ok|okay|success|succeeded|completed?|finished|all good|fully identical)["'\'' .!]*$'; then
	warn 'This command echoes a status word like done or ok. Success is implied by a clean exit and failure prints its own error, so drop it. Echo only a short label when output would otherwise be ambiguous, like a silent diff that exits clean.'
fi

if printf '%s' "$command" | grep -Eq '(^|;|&&|\|\|)[[:space:]]*(grep|sed|find|cat|head|tail)[[:space:]]'; then
	warn 'This command shells out where a dedicated tool fits: Grep to search, Glob to find files, Read to view one, Edit to change one. Keep the shell version only when it genuinely needs a shell, like a multi-stage pipeline; in that case, ignore this.'
fi

exit 0
