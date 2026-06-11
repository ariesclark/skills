#!/usr/bin/env bash

directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$directory/core/url.sh"

command=$(jq -r '.tool_input.command // empty')

[[ "$command" == *curl* || "$command" == *wget* ]] || exit 0

urls=$(python3 - "$command" 2>/dev/null <<'PY'
import shlex
import sys

lexer = shlex.shlex(sys.argv[1], posix=True, punctuation_chars=True)
lexer.whitespace_split = True

try:
    tokens = list(lexer)
except ValueError:
    sys.exit(0)

expecting_command = True
fetching = False

for token in tokens:
    if not token.strip("();<>|&"):
        expecting_command = True
        fetching = False
        continue

    if expecting_command:
        if token in {"sudo", "env", "command", "exec", "time", "nohup"}:
            continue
        if "=" in token and "://" not in token:
            continue
        fetching = token in {"curl", "wget"}
        expecting_command = False
    elif fetching and "://" in token:
        print(token)
PY
)

[[ -n "$urls" ]] || exit 0

while IFS= read -r candidate; do
	url_host_is "$candidate" github.com githubusercontent.com || continue
	exec "$directory/webfetch.sh" "$candidate"
done <<< "$urls"

exit 0
