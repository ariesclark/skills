#!/usr/bin/env bats

hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/bash.sh"
}

@test "silent on a command without curl or wget" {
	run hook '{"tool_input":{"command":"git clone https://github.com/x/y"}}'
	[ -z "$output" ]
}

@test "silent on curl of a non-github url" {
	run hook '{"tool_input":{"command":"curl -fsSL https://example.com/x"}}'
	[ -z "$output" ]
}

@test "silent when the url only appears in a quoted string" {
	run hook '{"tool_input":{"command":"echo \"curl https://github.com/x/y\" >> notes.md"}}'
	[ -z "$output" ]
}

@test "curl of a pull request delegates to the gh redirect" {
	run hook '{"tool_input":{"command":"curl https://github.com/anthropics/claude-code/pull/9"}}'
	[[ "$output" == *"gh pr view"* ]]
}

@test "wget after a separator with env prefix still matches" {
	run hook '{"tool_input":{"command":"ls && DEBUG=1 wget https://github.com/anthropics/claude-code/issues/4"}}'
	[[ "$output" == *"gh issue view"* ]]
}

@test "sudo curl is unwrapped" {
	run hook '{"tool_input":{"command":"sudo curl -o /tmp/x https://github.com/anthropics/claude-code/pull/2"}}'
	[[ "$output" == *"gh pr view"* ]]
}

@test "first github url wins over earlier non-github urls" {
	run hook '{"tool_input":{"command":"curl https://example.com/a && curl https://github.com/anthropics/claude-code/pull/3"}}'
	[[ "$output" == *"gh pr view"* ]]
}

@test "clones a repository fetched by curl" {
	[ -n "${NETWORK_TESTS:-}" ] || skip "set NETWORK_TESTS=1 to run network tests"
	run hook '{"tool_input":{"command":"curl -fsSL https://github.com/yarlson/lnk"}}'
	[[ "$output" == *"was cloned for you at"* ]]
}
