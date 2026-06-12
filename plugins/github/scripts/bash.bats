#!/usr/bin/env bats

hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/bash"
}

teardown() {
	rm -rf "${TMPDIR:-/tmp}/sessionbats"-*
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

@test "silent on github lookalikes" {
	run hook '{"tool_input":{"command":"curl https://github.com.evil.com/yarlson/lnk"}}'
	[ -z "$output" ]
}

@test "curl of a pull request delegates to the gh redirect" {
	run hook '{"tool_input":{"command":"curl https://github.com/anthropics/claude-code/pull/9"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *'gh pr view 9 --repo anthropics/claude-code --comments'* ]]
}

@test "wget after a separator with env prefix still matches" {
	run hook '{"tool_input":{"command":"ls && DEBUG=1 wget https://github.com/anthropics/claude-code/issues/4"}}'
	[[ "$output" == *"gh issue view 4"* ]]
}

@test "sudo curl is unwrapped" {
	run hook '{"tool_input":{"command":"sudo curl -o /tmp/x https://github.com/anthropics/claude-code/pull/2"}}'
	[[ "$output" == *"gh pr view 2"* ]]
}

@test "first github url wins over earlier non-github urls" {
	run hook '{"tool_input":{"command":"curl https://example.com/a && curl https://github.com/anthropics/claude-code/pull/3"}}'
	[[ "$output" == *"gh pr view 3"* ]]
}

@test "silent on a command that does not parse as shell" {
	run hook '{"tool_input":{"command":"curl https://github.com/x/y && ("}}'
	[ -z "$output" ]
}

@test "curl inside a subshell still matches" {
	run hook '{"tool_input":{"command":"(cd /tmp && curl -L https://github.com/anthropics/claude-code/issues/4)"}}'
	[[ "$output" == *"gh issue view 4"* ]]
}

@test "missing shfmt lets the command through" {
	stub=$(mktemp -d)
	for tool in bash cat jq dirname; do
		ln -s "$(command -v "$tool")" "$stub/$tool"
	done

	run bash -c "printf '%s' '{\"tool_input\":{\"command\":\"curl https://github.com/yarlson/lnk\"}}' | PATH='$stub' bash '$BATS_TEST_DIRNAME/bash'"
	rm -r "$stub"

	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "gh api contents reads delegate to a clone" {
	run hook '{"session_id":"session-bats","tool_input":{"command":"gh api repos/yarlson/lnk/contents/README.md"}}'
	[[ "$output" == *"A clone of yarlson/lnk was provided"* ]]

	run hook '{"session_id":"session-bats","tool_input":{"command":"gh api /repos/yarlson/lnk/contents?ref=main"}}'
	[[ "$output" == *"A clone of yarlson/lnk was provided"* ]]

	run hook '{"session_id":"session-bats","tool_input":{"command":"gh api https://api.github.com/repos/yarlson/lnk/contents/README.md"}}'
	[[ "$output" == *"A clone of yarlson/lnk was provided"* ]]
}

@test "other gh api paths pass through" {
	run hook '{"tool_input":{"command":"gh api repos/yarlson/lnk"}}'
	[ -z "$output" ]

	run hook '{"tool_input":{"command":"gh api user"}}'
	[ -z "$output" ]

	run hook '{"tool_input":{"command":"gh api repos/x/y/contents-of-something"}}'
	[ -z "$output" ]
}

@test "gh api contents writes pass through" {
	run hook '{"tool_input":{"command":"gh api -X PUT repos/yarlson/lnk/contents/new.md -f message=add -f content=aGk="}}'
	[ -z "$output" ]

	run hook '{"tool_input":{"command":"gh api repos/yarlson/lnk/contents/new.md --method DELETE -f message=rm"}}'
	[ -z "$output" ]
}

@test "cloning without a session id fails loudly" {
	run hook '{"tool_input":{"command":"curl https://github.com/yarlson/lnk"}}'
	[ "$status" -eq 1 ]
	[[ "$output" == *"session_id is empty"* ]]
}

@test "clones a repository fetched by curl" {
	run hook '{"session_id":"session-bats","tool_input":{"command":"curl -fsSL https://github.com/yarlson/lnk"}}'
	[[ "$output" == *"A clone of yarlson/lnk was provided"* ]]
	[[ "$output" == *"/sessionbats-github-yarlson-lnk-"* ]]
}
