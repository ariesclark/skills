#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/mktemp"
}

@test "session_mktemp: prefixes the session id, stripping its dashes" {
	session_id=session-bats
	directory=$(session_mktemp example)

	[ -d "$directory" ]
	[[ "$directory" == "${TMPDIR:-/tmp}/sessionbats-example-"* ]]
	rm -r "$directory"
}

@test "session_mktemp: fails without a session" {
	session_id=""
	run session_mktemp example

	[ "$status" -eq 1 ]
	[[ "$output" == *"session_id is empty"* ]]
}

@test "session_cleanup: removes the session's directories" {
	session_id=session-bats
	directory=$(session_mktemp example)

	session_cleanup example

	[ ! -d "$directory" ]
}

@test "session_cleanup: leaves other sessions alone" {
	session_id=session-other
	directory=$(session_mktemp example)

	session_id=session-bats
	session_cleanup example

	[ -d "$directory" ]
	rm -r "$directory"
}

@test "session_cleanup: leaves the session's other prefixes alone" {
	session_id=session-bats
	directory=$(session_mktemp other)

	session_cleanup example

	[ -d "$directory" ]
	rm -r "$directory"
}

@test "session_cleanup: silent without a session" {
	session_id=""
	run session_cleanup example

	[ "$status" -eq 0 ]
	[ -z "$output" ]
}
