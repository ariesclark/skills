#!/usr/bin/env bats

cleanup() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/cleanup"
}

setup() {
	clone=$(mktemp -d "${TMPDIR:-/tmp}/abc123-github-yarlson-lnk-XXXXXX")
	other=$(mktemp -d "${TMPDIR:-/tmp}/unrelated-github-yarlson-lnk-XXXXXX")
	foreign=$(mktemp -d "${TMPDIR:-/tmp}/abc123-elixir-cache-XXXXXX")
}

teardown() {
	rm -rf "$clone" "$other" "$foreign"
}

@test "removes the session's clones" {
	run cleanup '{"session_id":"abc123"}'

	[ "$status" -eq 0 ]
	[ ! -d "$clone" ]
}

@test "leaves other sessions' clones alone" {
	run cleanup '{"session_id":"abc123"}'

	[ -d "$other" ]
}

@test "leaves the session's other plugins' directories alone" {
	run cleanup '{"session_id":"abc123"}'

	[ -d "$foreign" ]
}

@test "silent without a session id" {
	run cleanup '{}'

	[ "$status" -eq 0 ]
	[ -z "$output" ]
	[ -d "$clone" ]
}
