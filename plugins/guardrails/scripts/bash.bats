#!/usr/bin/env bats

hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/bash"
}

@test "denies a banner echo" {
	run hook '{"tool_input":{"command":"echo \"=== step 1 ===\""}}'
	[ "$status" -eq 0 ]
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "denies a divider echo" {
	run hook '{"tool_input":{"command":"echo \"---\""}}'
	[[ "$output" == *"decorative separator"* ]]
}

@test "denies a printf banner wrapping a dynamic value" {
	run hook '{"tool_input":{"command":"printf \"===== %s =====\\n\" \"$f\""}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"decorative separator"* ]]
}

@test "denies a banner printed from PowerShell" {
	run hook '{"tool_input":{"command":"powershell.exe -Command \"'\''=== step ==='\''\""}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"decorative separator"* ]]
}

@test "allows a PowerShell command with no banner" {
	run hook '{"tool_input":{"command":"powershell.exe -NoProfile -Command \"Get-Process\""}}'
	[ -z "$output" ]
}

@test "denies a static status echo" {
	run hook '{"tool_input":{"command":"make build && echo done"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "denies a static printf" {
	run hook '{"tool_input":{"command":"printf \"not yet installed\\n\""}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "denies a printf not-found marker in a fallback" {
	run hook '{"tool_input":{"command":"command -v wrk || printf \"missing\\n\""}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "allows static output redirected to a file" {
	run hook '{"tool_input":{"command":"printf \"key=value\\n\" > config.txt"}}'
	[ -z "$output" ]
	run hook '{"tool_input":{"command":"echo done > config.txt"}}'
	[ -z "$output" ]
}

@test "allows an echo of dynamic input" {
	run hook '{"tool_input":{"command":"echo \"$PWD\""}}'
	[ -z "$output" ]
}

@test "denies echoing command output" {
	run hook '{"tool_input":{"command":"echo `hostname`"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"already writes to stdout"* ]]
}

@test "warns on shelling out to grep" {
	run hook '{"tool_input":{"command":"grep -r foo ."}}'
	[[ "$output" == *"additionalContext"* ]]
	[[ "$output" == *"dedicated tool"* ]]
}

@test "warns on sed after a separator" {
	run hook '{"tool_input":{"command":"ls && sed -i s/a/b/ file"}}'
	[[ "$output" == *"dedicated tool"* ]]
}

@test "warns when a leading tool feeds a pipe" {
	run hook '{"tool_input":{"command":"cat file | grep foo"}}'
	[[ "$output" == *"dedicated tool"* ]]
}

@test "silent on a tool used as a downstream pipe stage" {
	run hook '{"tool_input":{"command":"foo | cat bar"}}'
	[ -z "$output" ]
}

@test "silent on a filter at the end of a pipe" {
	run hook '{"tool_input":{"command":"ls | head -5"}}'
	[ -z "$output" ]
}

@test "wrapped commands pass through (tree-sitter does not peel sudo)" {
	run hook '{"tool_input":{"command":"sudo grep foo /etc/hosts"}}'
	[ -z "$output" ]
}

@test "warns on commands stacked with a semicolon" {
	run hook '{"tool_input":{"command":"make build; ls -la"}}'
	[[ "$output" == *"additionalContext"* ]]
	[[ "$output" == *"parallel"* ]]
}

@test "does not warn on a setup statement before a command" {
	run hook '{"tool_input":{"command":"set -euo pipefail; make"}}'
	[ -z "$output" ]
}

@test "does not warn on cd before a command" {
	run hook '{"tool_input":{"command":"cd src; ls"}}'
	[ -z "$output" ]
}

@test "does not treat && as stacking" {
	run hook '{"tool_input":{"command":"mkdir x && cd x"}}'
	[ -z "$output" ]
}

@test "does not treat a multi-line script as stacking" {
	run hook '{"tool_input":{"command":"git add -A\ngit commit -m wip\ngit push"}}'
	[ -z "$output" ]
}

@test "allows cat reading a heredoc" {
	run hook '{"tool_input":{"command":"cat <<EOF > out.txt\nkey=value\nEOF"}}'
	[ -z "$output" ]
}

@test "denies a backgrounded command" {
	run hook '{"tool_input":{"command":"sleep 10 &"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"run_in_background"* ]]
}

@test "backgrounding blocks even with multiple commands" {
	run hook '{"tool_input":{"command":"make & test & wait"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "denies a sleep poll-loop waiting on background work" {
	run hook '{"tool_input":{"command":"while pgrep -f oha >/dev/null; do sleep 1; done"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"run_in_background"* ]]
	[[ "$output" == *"Monitor"* ]]
}

@test "denies an until poll-loop waiting on an install" {
	run hook '{"tool_input":{"command":"until [ -x \"$HOME/.cargo/bin/oha\" ]; do sleep 5; done"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
}

@test "allows a lone sleep outside a loop" {
	run hook '{"tool_input":{"command":"sleep 5"}}'
	[ -z "$output" ]
}

@test "allows a loop with no sleep" {
	run hook '{"tool_input":{"command":"for f in *.log; do process \"$f\"; done"}}'
	[ -z "$output" ]
}

@test "disabled rules stay silent" {
	CLAUDE_PLUGIN_OPTION_bash_no_print_static=false run hook '{"tool_input":{"command":"echo done"}}'
	[ -z "$output" ]

	CLAUDE_PLUGIN_OPTION_bash_no_print_separator=false run hook '{"tool_input":{"command":"printf \"===== %s =====\\n\" \"$f\""}}'
	[ -z "$output" ]

	CLAUDE_PLUGIN_OPTION_bash_shelling_out=false run hook '{"tool_input":{"command":"grep -r foo ."}}'
	[ -z "$output" ]

	CLAUDE_PLUGIN_OPTION_bash_stacking=false run hook '{"tool_input":{"command":"make build; ls -la"}}'
	[ -z "$output" ]

	CLAUDE_PLUGIN_OPTION_bash_no_backgrounding=false run hook '{"tool_input":{"command":"sleep 10 &"}}'
	[ -z "$output" ]

	CLAUDE_PLUGIN_OPTION_bash_no_sleep_poll=false run hook '{"tool_input":{"command":"while pgrep -f oha; do sleep 1; done"}}'
	[ -z "$output" ]
}

@test "reports every error in one verdict" {
	run hook '{"tool_input":{"command":"echo \"---\"; echo done"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *"decorative separator"* ]]
	[[ "$output" == *"entirely noise"* ]]
}

@test "reports every warning in one verdict" {
	run hook '{"tool_input":{"command":"cat a.txt; grep b c.txt"}}'
	[[ "$output" != *"deny"* ]]
	[[ "$output" == *"dedicated tool"* ]]
	[[ "$output" == *"parallel"* ]]
}

@test "silent on a clean command" {
	run hook '{"tool_input":{"command":"ls -la"}}'
	[ -z "$output" ]
}

@test "silent on a dynamic echo in a chain" {
	run hook '{"tool_input":{"command":"echo \"$rev\" && diff a b"}}'
	[ -z "$output" ]
}

@test "silent on empty input" {
	run hook '{"tool_input":{}}'
	[ -z "$output" ]
}

@test "session-start emits the rule notes as context" {
	command -v yq > /dev/null || skip "yq not installed"
	run bash "$BATS_TEST_DIRNAME/session-start"
	[ "$status" -eq 0 ]
	[[ "$output" == *"When running bash commands"* ]]
	[[ "$output" == *"## no-print-static"* ]]
}
