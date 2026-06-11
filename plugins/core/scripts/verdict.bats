#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/verdict.sh"
}

@test "deny: emits hook JSON and exits zero" {
	run deny "nope"
	[ "$status" -eq 0 ]
	[[ "$output" == *'"permissionDecision": "deny"'* || "$output" == *'"permissionDecision":"deny"'* ]]
	[[ "$output" == *"nope"* ]]
}

@test "warn: emits additionalContext" {
	run warn "careful"
	[ "$status" -eq 0 ]
	[[ "$output" == *"additionalContext"* ]]
	[[ "$output" == *"careful"* ]]
}

@test "verdict_prefix: prepended when set" {
	verdict_prefix="Blocked:"
	run deny "reason"
	[[ "$output" == *"Blocked: reason"* ]]
}

@test "verdict_prefix: absent when unset" {
	run deny "reason"
	[[ "$output" != *"Blocked"* ]]
}
