#!/usr/bin/env bats

@test "emits the redirect guidance" {
	run bash "$BATS_TEST_DIRNAME/context"

	[ "$status" -eq 0 ]
	[[ "$output" == *"gh pr view"* ]]
	[[ "$output" == *"git show <ref>:<path>"* ]]
	[[ "$output" == *"gh search"* ]]
}

@test "stays short enough to load every session" {
	run bash -c "bash '$BATS_TEST_DIRNAME/context' | wc -c"
	[ "$output" -lt 1000 ]
}
