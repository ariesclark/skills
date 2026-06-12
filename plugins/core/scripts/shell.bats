#!/usr/bin/env bats

shell_jq() {
	jq -r -L "$BATS_TEST_DIRNAME" -n "include \"shell\"; $1"
}

@test "word_text: joins literal parts" {
	run shell_jq '{Parts: [{Type: "Lit", Value: "cu"}, {Type: "Lit", Value: "rl"}]} | word_text'
	[ "$output" == "curl" ]
}

@test "word_text: descends into quoted parts" {
	run shell_jq '{Parts: [{Type: "DblQuoted", Parts: [{Type: "Lit", Value: "https://a"}, {Type: "SglQuoted", Value: "/b"}]}]} | word_text'
	[ "$output" == "https://a/b" ]
}

@test "word_text: ignores expansions and untyped values" {
	run shell_jq '{Parts: [{Type: "Lit", Value: "x"}, {Type: "ParamExp", Param: {Value: "ORG"}}]} | word_text'
	[ "$output" == "x" ]
}

@test "strip_wrappers: removes wrapper commands and assignments" {
	run shell_jq '["sudo", "env", "DEBUG=1", "curl", "url"] | strip_wrappers | join(" ")'
	[ "$output" == "curl url" ]
}

@test "strip_wrappers: keeps words containing urls" {
	run shell_jq '["--url=https://x", "next"] | strip_wrappers | join(" ")'
	[ "$output" == "--url=https://x next" ]
}

@test "strip_wrappers: empty input stays empty" {
	run shell_jq '[] | strip_wrappers | length'
	[ "$output" == "0" ]
}
