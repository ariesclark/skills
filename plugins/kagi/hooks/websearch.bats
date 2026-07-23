#!/usr/bin/env bats

hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/websearch"
}

@test "redirects a search to kagi search" {
	run hook '{"tool_input":{"query":"rust async cancellation"}}'

	[ "$status" -eq 0 ]
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *'kagi search \"rust async cancellation\" --format toon --limit 5'* ]]
}

@test "folds a single allowed domain into a site: filter" {
	run hook '{"tool_input":{"query":"lens","allowed_domains":["help.kagi.com"]}}'

	[[ "$output" == *'kagi search \"lens site:help.kagi.com\"'* ]]
}

@test "leaves several allowed domains out of the query" {
	run hook '{"tool_input":{"query":"lens","allowed_domains":["a.com","b.com"]}}'

	[[ "$output" == *'kagi search \"lens\"'* ]]
}

@test "quotes a query carrying quotes and newlines" {
	run hook '{"tool_input":{"query":"the \"exact\" error\nsecond line"}}'

	[[ "$output" == *'kagi search \"the \\\"exact\\\" error second line\"'* ]]
}

@test "silent on a call with no query" {
	run hook '{"tool_input":{}}'

	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "silent when the toggle is off" {
	CLAUDE_PLUGIN_OPTION_websearch=false run hook '{"tool_input":{"query":"anything"}}'

	[ -z "$output" ]
}
