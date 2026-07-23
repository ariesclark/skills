#!/usr/bin/env bats

hook() {
	printf '{"tool_input":{"command":%s}}' "$(jq -Rn --arg command "$1" '$command')" \
		| bash "$BATS_TEST_DIRNAME/bash"
}

@test "redirects a curled google search, carrying the query over" {
	run hook 'curl "https://www.google.com/search?q=rust+async"'

	[ "$status" -eq 0 ]
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *'kagi search \"rust async\" --format toon --limit 5'* ]]
}

@test "redirects other search engines" {
	run hook 'wget https://duckduckgo.com/?q=zig+comptime'

	[[ "$output" == *'kagi search \"zig comptime\"'* ]]
}

@test "redirects a search engine result page with no query" {
	run hook 'curl https://www.bing.com/search'

	[[ "$output" == *'kagi search \"<query>\"'* ]]
}

@test "redirects a curled kagi search to the CLI" {
	run hook 'curl "https://kagi.com/search?q=lens+index"'

	[[ "$output" == *'kagi search \"lens index\" --format toon'* ]]
}

@test "redirects other kagi.com paths to the CLI generally" {
	run hook 'curl https://kagi.com/api/v1/search'

	[[ "$output" == *'kagi skills get kagi'* ]]
}

@test "sudo and env wrappers are unwrapped" {
	run hook 'sudo curl "https://google.com/search?q=test"'

	[[ "$output" == *'kagi search \"test\"'* ]]
}

@test "leaves an ordinary page fetch alone" {
	run hook 'curl https://example.com/article.json'

	[ -z "$output" ]
}

@test "leaves a command without curl or wget alone" {
	run hook 'kagi search "already using it"'

	[ -z "$output" ]
}

@test "silent on a command that does not parse as shell" {
	run hook 'curl "https://google.com/search?q=x'

	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "silent when the toggle is off" {
	CLAUDE_PLUGIN_OPTION_bash=false run hook 'curl "https://google.com/search?q=x"'

	[ -z "$output" ]
}
