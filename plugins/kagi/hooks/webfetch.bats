#!/usr/bin/env bats

hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/webfetch"
}

@test "redirects a fetch to kagi ask-page" {
	run hook '{"tool_input":{"url":"https://example.com/article","prompt":"what are the claims?"}}'

	[ "$status" -eq 0 ]
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *'kagi ask-page \"https://example.com/article\" \"what are the claims?\"'* ]]
}

@test "offers extract and summarize as the other readings" {
	run hook '{"tool_input":{"url":"https://example.com/article","prompt":"summarize"}}'

	[[ "$output" == *'kagi extract'* ]]
	[[ "$output" == *'kagi summarize --subscriber --url'* ]]
}

@test "substitutes a question when the prompt is empty" {
	run hook '{"tool_input":{"url":"https://example.com/article"}}'

	[[ "$output" == *'what does this page say?'* ]]
}

@test "leaves github urls to the github plugin" {
	run hook '{"tool_input":{"url":"https://github.com/kagisearch/kagimcp","prompt":"read it"}}'

	[ -z "$output" ]
}

@test "leaves claude.ai artifacts to WebFetch" {
	run hook '{"tool_input":{"url":"https://claude.ai/code/artifact/abc","prompt":"read it"}}'

	[ -z "$output" ]
}

@test "leaves localhost alone" {
	run hook '{"tool_input":{"url":"http://localhost:3000/api","prompt":"read it"}}'

	[ -z "$output" ]
}

@test "leaves a private address alone" {
	run hook '{"tool_input":{"url":"http://192.168.1.4:8080/status","prompt":"read it"}}'

	[ -z "$output" ]
}

@test "silent on a call with no url" {
	run hook '{"tool_input":{"prompt":"read it"}}'

	[ -z "$output" ]
}

@test "silent when the toggle is off" {
	CLAUDE_PLUGIN_OPTION_webfetch=false run hook '{"tool_input":{"url":"https://example.com","prompt":"read it"}}'

	[ -z "$output" ]
}
