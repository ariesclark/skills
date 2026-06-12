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

@test "accepts a full url and strips .git" {
	run clone_temporarily https://github.com/yarlson/lnk.git
	[ "$status" -eq 0 ]
	[[ "$output" == *"/sessionbats-github-yarlson-lnk-"* ]]
}

@test "failed clones exit nonzero and leave nothing behind" {
	run clone_temporarily features/nope-not-a-repo
	[ "$status" -eq 1 ]
	[[ "$output" == *"could not be cloned"* ]]

	leftovers=("${TMPDIR:-/tmp}/sessionbats-github-features-nope-not-a-repo"-*)
	[ ! -e "${leftovers[0]}" ]
}

@test "fails loudly without a session id" {
	run env -u CLAUDE_CODE_SESSION_ID bash "$BATS_TEST_DIRNAME/clone-temporarily" yarlson/lnk
	[ "$status" -eq 1 ]
	[[ "$output" == *"session_id is empty"* ]]
}
