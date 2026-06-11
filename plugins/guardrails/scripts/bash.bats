#!/usr/bin/env bats

hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/bash.sh"
}

@test "denies a banner echo" {
	run hook '{"tool_input":{"command":"echo \"=== step 1 ===\""}}'
	[ "$status" -eq 0 ]
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "denies a divider echo" {
	run hook '{"tool_input":{"command":"echo \"---\""}}'
	[[ "$output" == *"decorative divider"* ]]
}

@test "warns on status narration" {
	run hook '{"tool_input":{"command":"make build && echo done"}}'
	[[ "$output" == *"additionalContext"* ]]
	[[ "$output" == *"status word"* ]]
}

@test "warns on shelling out to grep" {
	run hook '{"tool_input":{"command":"grep -r foo ."}}'
	[[ "$output" == *"additionalContext"* ]]
	[[ "$output" == *"dedicated tool"* ]]
}

@test "warns on sed after a separator" {
	run hook '{"tool_input":{"command":"ls && sed -i s/a/b/ file"}}'
	[[ "$output" == *"dedicated tool"* ]]
}

@test "silent on a clean command" {
	run hook '{"tool_input":{"command":"ls -la"}}'
	[ -z "$output" ]
}

@test "silent on a plain labelled echo" {
	run hook '{"tool_input":{"command":"echo before && diff a b"}}'
	[ -z "$output" ]
}

@test "silent on empty input" {
	run hook '{"tool_input":{}}'
	[ -z "$output" ]
}
