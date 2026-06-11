deny() {
	jq -n --arg reason "${verdict_prefix:+$verdict_prefix }$1" \
		'{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
	exit 0
}

warn() {
	jq -n --arg context "${verdict_prefix:+$verdict_prefix }$1" \
		'{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$context}}'
	exit 0
}
