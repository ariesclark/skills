#!/usr/bin/env bats

clone_temporarily() {
	CLAUDE_CODE_SESSION_ID=session-bats bash "$BATS_TEST_DIRNAME/clone-temporarily" "$@"
}

teardown() {
	rm -rf "${TMPDIR:-/tmp}/sessionbats"-*
}

@test "fails with usage without a repository" {
	run clone_temporarily
	[ "$status" -ne 0 ]
	[[ "$output" == *"usage:"* ]]
}

@test "clones into a session-prefixed path and prints it" {
	run clone_temporarily yarlson/lnk
	[ "$status" -eq 0 ]
	[[ "$output" == *"/sessionbats-github-yarlson-lnk-"* ]]
	[ -d "$output/.git" ]
}

@test "rejects urls with usage" {
	run clone_temporarily https://github.com/yarlson/lnk
	[ "$status" -eq 1 ]
	[[ "$output" == *"usage:"* ]]

	run clone_temporarily https://gist.github.com/4917aeecf7e6ccba14995a4a9e604f9b
	[ "$status" -eq 1 ]
	[[ "$output" == *"usage:"* ]]
}

@test "failed clones exit 2 and leave nothing behind" {
	run clone_temporarily features/nope-not-a-repo
	[ "$status" -eq 2 ]
	[[ "$output" == *"could not be cloned"* ]]

	leftovers=("${TMPDIR:-/tmp}/sessionbats-github-features-nope-not-a-repo"-*)
	[ ! -e "${leftovers[0]}" ]
}

@test "clones a gist by id" {
	run clone_temporarily 4917aeecf7e6ccba14995a4a9e604f9b
	[ "$status" -eq 0 ]
	[[ "$output" == *"/sessionbats-github-4917aeecf7e6ccba14995a4a9e604f9b-"* ]]
	[ -d "$output/.git" ]
}

@test "failed gist clones exit 2" {
	run clone_temporarily 00000000000000000000000000000dead
	[ "$status" -eq 2 ]
	[[ "$output" == *"could not be cloned"* ]]
}

@test "fails loudly without a session id" {
	run env -u CLAUDE_CODE_SESSION_ID bash "$BATS_TEST_DIRNAME/clone-temporarily" yarlson/lnk
	[ "$status" -eq 1 ]
	[[ "$output" == *"session_id is empty"* ]]
}
