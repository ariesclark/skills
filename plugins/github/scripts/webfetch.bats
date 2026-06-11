#!/usr/bin/env bats

hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/webfetch.sh"
}

@test "silent on a non-github url" {
	run hook '{"tool_input":{"url":"https://example.com/page"}}'
	[ -z "$output" ]
}

@test "silent on a github lookalike path" {
	run hook '{"tool_input":{"url":"https://example.com/github.com/x"}}'
	[ -z "$output" ]
}

@test "redirects a pull request to gh" {
	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/pull/9"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"gh pr view"* ]]
	[[ "$output" == *"anthropics/claude-code"* ]]
}

@test "redirects an issue to gh" {
	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/issues/42"}}'
	[[ "$output" == *"gh issue view"* ]]
}

@test "mixed-case host with query string still matches" {
	run hook '{"tool_input":{"url":"https://GitHub.com/anthropics/claude-code/pull/9?diff=split"}}'
	[[ "$output" == *"gh pr view"* ]]
}

@test "generic deny for the github root" {
	run hook '{"tool_input":{"url":"https://github.com/"}}'
	[[ "$output" == *"Clone the repository"* ]]
}

@test "generic deny for unknown github subdomains" {
	run hook '{"tool_input":{"url":"https://codeload.github.com/x/y"}}'
	[[ "$output" == *"Clone the repository"* ]]
}

@test "gist deny when no id present" {
	run hook '{"tool_input":{"url":"https://gist.github.com/"}}'
	[[ "$output" == *"gh gist list"* ]]
}

@test "clones a repository and reports path and sha" {
	[ -n "${NETWORK_TESTS:-}" ] || skip "set NETWORK_TESTS=1 to run network tests"
	run hook '{"tool_input":{"url":"https://github.com/yarlson/lnk"}}'
	[[ "$output" == *"was cloned for you at"* ]]
	[[ "$output" == *"/github/yarlson/lnk on "* ]]
}

@test "raw file url clones the owning repository" {
	[ -n "${NETWORK_TESTS:-}" ] || skip "set NETWORK_TESTS=1 to run network tests"
	run hook '{"tool_input":{"url":"https://raw.githubusercontent.com/yarlson/lnk/main/README.md"}}'
	[[ "$output" == *"/github/yarlson/lnk on "* ]]
}

@test "clones a gist by id" {
	[ -n "${NETWORK_TESTS:-}" ] || skip "set NETWORK_TESTS=1 to run network tests"
	run hook '{"tool_input":{"url":"https://gist.github.com/hage99351-hash/4917aeecf7e6ccba14995a4a9e604f9b"}}'
	[[ "$output" == *"/github/gist/4917aeecf7e6ccba14995a4a9e604f9b on "* ]]
}

@test "unclonable repository falls back to gh" {
	[ -n "${NETWORK_TESTS:-}" ] || skip "set NETWORK_TESTS=1 to run network tests"
	run hook '{"tool_input":{"url":"https://github.com/features/nope-not-a-repo"}}'
	[[ "$output" == *"could not be cloned"* ]]
	[[ "$output" == *"gh repo view features/nope-not-a-repo"* ]]
}
