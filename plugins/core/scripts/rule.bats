#!/usr/bin/env bats

setup() {
	error_rule="$BATS_TEST_TMPDIR/echo.yml"
	printf '%s\n' \
		'id: echo-call' \
		'language: bash' \
		'severity: error' \
		'message: no echo allowed' \
		'note: use printf instead' \
		'rule: { kind: command, has: { field: name, regex: "^echo$" } }' \
		> "$error_rule"
	warning_rule="$BATS_TEST_TMPDIR/ls.yml"
	printf '%s\n' \
		'id: ls-call' \
		'language: bash' \
		'severity: warning' \
		'message: avoid ls' \
		'rule: { kind: command, has: { field: name, regex: "^ls$" } }' \
		> "$warning_rule"
}

call() {
	local func=$1 code=$2
	shift 2
	printf '%s' "$code" | bash -c 'source "$1"; func=$2; shift 2; "$func" "$@"' _ "$BATS_TEST_DIRNAME/rule" "$func" "$@"
}

@test "rule_inline: joins rule files with a document separator" {
	run bash -c 'source "$1"; rule_inline "$2" "$3"' _ "$BATS_TEST_DIRNAME/rule" "$error_rule" "$warning_rule"
	[[ "$output" == *"echo-call"* ]]
	[[ "$output" == *"---"* ]]
	[[ "$output" == *"ls-call"* ]]
}

@test "rule_pick: returns the most-severe match as severity, message, note" {
	run bash -c 'source "$1"; rule_pick "[{\"severity\":\"warning\",\"message\":\"w\"},{\"severity\":\"error\",\"message\":\"e\",\"note\":\"n\"}]"' _ "$BATS_TEST_DIRNAME/rule"
	[[ "$output" == "error	e	n" ]]
}

@test "rule_pick: breaks severity ties by ruleId, regardless of input order" {
	run bash -c 'source "$1"; rule_pick "[{\"ruleId\":\"b-rule\",\"severity\":\"error\",\"message\":\"b\"},{\"ruleId\":\"a-rule\",\"severity\":\"error\",\"message\":\"a\"}]"' _ "$BATS_TEST_DIRNAME/rule"
	[[ "$output" == "error	a	" ]]
	run bash -c 'source "$1"; rule_pick "[{\"ruleId\":\"a-rule\",\"severity\":\"error\",\"message\":\"a\"},{\"ruleId\":\"b-rule\",\"severity\":\"error\",\"message\":\"b\"}]"' _ "$BATS_TEST_DIRNAME/rule"
	[[ "$output" == "error	a	" ]]
}

@test "rule_scan: returns matches for code on stdin" {
	run call rule_scan 'echo hi' "$error_rule"
	[[ "$output" == *'"ruleId":"echo-call"'* ]]
}

@test "rule_scan: empty array when nothing matches" {
	run call rule_scan 'pwd' "$error_rule"
	[ "$output" == "[]" ]
}

@test "rule_scan: combines multiple rule files" {
	run call rule_scan 'ls -la' "$error_rule" "$warning_rule"
	[[ "$output" == *'"ruleId":"ls-call"'* ]]
}

@test "apply_rules: error severity denies, with note as additional context" {
	run call apply_rules 'echo hi' "$error_rule"
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"no echo allowed"* ]]
	[[ "$output" == *"additionalContext"* ]]
	[[ "$output" == *"use printf instead"* ]]
}

@test "apply_rules: warning severity warns" {
	run call apply_rules 'ls -la' "$warning_rule"
	[[ "$output" == *"additionalContext"* ]]
	[[ "$output" == *"avoid ls"* ]]
}

@test "apply_rules: error wins over warning" {
	run call apply_rules 'echo hi; ls' "$error_rule" "$warning_rule"
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "apply_rules: silent when nothing matches" {
	run call apply_rules 'pwd' "$error_rule"
	[ -z "$output" ]
}
