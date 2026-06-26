#!/usr/bin/env bats

hook_jq() {
	jq -c -L "$BATS_TEST_DIRNAME" -n "include \"hook\"; $1"
}

@test "deny: builds a deny decision" {
	run hook_jq 'deny("nope")'
	[[ "$output" == *'"permissionDecision":"deny"'* ]]
	[[ "$output" == *'"permissionDecisionReason":"nope"'* ]]
}

@test "deny: omits additionalContext without one" {
	run hook_jq 'deny("nope")'
	[[ "$output" != *additionalContext* ]]
}

@test "deny: includes additionalContext when given" {
	run hook_jq 'deny("nope"; "the path is /tmp/x")'
	[[ "$output" == *'"additionalContext":"the path is /tmp/x"'* ]]
}

@test "deny: empty context is dropped" {
	run hook_jq 'deny("nope"; "")'
	[[ "$output" != *additionalContext* ]]
}

@test "warn: builds an additionalContext decision" {
	run hook_jq 'warn("careful")'
	[[ "$output" == *'"additionalContext":"careful"'* ]]
	[[ "$output" != *permissionDecision* ]]
}
