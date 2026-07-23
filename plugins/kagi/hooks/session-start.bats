#!/usr/bin/env bats

setup() {
	root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	stub="$BATS_TEST_TMPDIR/stub"
	mkdir -p "$stub"

	export CLAUDE_PLUGIN_ROOT="$root"
	export PATH="$stub:/usr/bin:/bin"

	# The manifest holds the whole hook, so run what Claude Code runs.
	command=$(jq -r '.hooks.SessionStart[0].hooks[0].command' "$root/.claude-plugin/plugin.json")
}

# Stub `kagi auth status` with a fixed report, whatever arguments it is given.
stub_status() {
	{
		echo '#!/usr/bin/env bash'
		echo "cat << 'REPORT'"
		printf '%s\n' "$@"
		echo 'REPORT'
	} > "$stub/kagi"
	chmod +x "$stub/kagi"
}

@test "names a command per need, and where the rest of them live" {
	stub_status 'session token: configured via config'
	run bash -c "$command"

	[ "$status" -eq 0 ]
	[[ "$output" == *'kagi search "<query>" --format toon --limit 5'* ]]
	[[ "$output" == *'kagi extract "<url>"'* ]]
	[[ "$output" == *'kagi skills get kagi'* ]]
}

@test "emits the guide even when kagi is not on PATH" {
	PATH=/usr/bin:/bin run bash -c "$command"

	[ "$status" -eq 0 ]
	[[ "$output" == *'kagi search'* ]]
	[[ "$output" != *'not configured yet'* ]]
}

@test "prompts for both when neither is configured" {
	stub_status \
		'api key: not configured' \
		'legacy api token: not configured' \
		'session token: not configured'
	run bash -c "$command"

	[[ "$output" == *'kagi auth set --session-token'* ]]
	[[ "$output" == *'kagi auth set --api-key'* ]]
}

@test "prompts only for the session token when the api key is set" {
	stub_status \
		'api key: configured via config' \
		'session token: not configured'
	run bash -c "$command"

	[[ "$output" == *'kagi auth set --session-token'* ]]
	[[ "$output" != *'kagi auth set --api-key'* ]]
}

@test "prompts only for the api key when the session token is set" {
	stub_status \
		'api key: not configured' \
		'session token: configured via config'
	run bash -c "$command"

	[[ "$output" == *'kagi auth set --api-key'* ]]
	[[ "$output" != *'kagi auth set --session-token'* ]]
}

@test "stays silent about setup when both are configured" {
	stub_status \
		'api key: configured via config' \
		'session token: configured via config'
	run bash -c "$command"

	[[ "$output" == *'kagi search'* ]]
	[[ "$output" != *'not configured yet'* ]]
}

@test "silent when the toggle is off" {
	stub_status 'session token: not configured'
	CLAUDE_PLUGIN_OPTION_context=false run bash -c "$command"

	[ "$status" -eq 0 ]
	[ -z "$output" ]
}
