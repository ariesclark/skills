#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/claude"
	export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/.claude"
	unset CLAUDE_CODE_SESSION_ID
	session_id=""
	mkdir -p "$CLAUDE_CONFIG_DIR/projects/proj"
}

# writes assistant lines for the given models, then returns the transcript path
write_transcript() {
	local id=$1 path model
	shift
	path="$CLAUDE_CONFIG_DIR/projects/proj/$id.jsonl"
	: > "$path"
	for model in "$@"; do
		printf '{"type":"assistant","message":{"model":"%s"}}\n' "$model" >> "$path"
	done
	printf '%s\n' "$path"
}

@test "claude_config_directory: honors CLAUDE_CONFIG_DIR" {
	CLAUDE_CONFIG_DIR=/tmp/somewhere
	[ "$(claude_config_directory)" = "/tmp/somewhere" ]
}

@test "claude_config_directory: defaults to ~/.claude" {
	unset CLAUDE_CONFIG_DIR
	HOME=/home/someone
	[ "$(claude_config_directory)" = "/home/someone/.claude" ]
}

@test "claude_projects_directory: is the projects subdirectory" {
	CLAUDE_CONFIG_DIR=/tmp/somewhere
	[ "$(claude_projects_directory)" = "/tmp/somewhere/projects" ]
}

@test "claude_session_id: reads the environment, then the global" {
	[ -z "$(claude_session_id)" ]
	export CLAUDE_CODE_SESSION_ID=from-env
	[ "$(claude_session_id)" = "from-env" ]
	session_id=from-global
	[ "$(claude_session_id)" = "from-global" ]
}

@test "get_transcript: finds the transcript for a session id" {
	write_transcript sid claude-opus-4-8 > /dev/null
	run get_transcript sid
	[ "$status" -eq 0 ]
	[ "$output" = "$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl" ]
}

@test "get_transcript: fails quietly for an unknown session" {
	run get_transcript nope
	[ "$status" -eq 1 ]
	[ -z "$output" ]
}

@test "get_transcript: fails quietly without an argument" {
	run get_transcript
	[ "$status" -eq 1 ]
	[ -z "$output" ]
}

@test "get_transcript: does not read the session from the environment" {
	write_transcript sid claude-opus-4-8 > /dev/null
	export CLAUDE_CODE_SESSION_ID=sid
	session_id=sid
	run get_transcript
	[ "$status" -eq 1 ]
}

@test "get_models: lists models in order, dropping synthetic and non-assistant" {
	path="$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl"
	{
		printf '{"type":"user","message":{"role":"user"}}\n'
		printf '{"type":"assistant","message":{"model":"claude-opus-4-8"}}\n'
		printf '{"type":"assistant","message":{"model":"<synthetic>"}}\n'
		printf '{"type":"assistant","message":{"model":"claude-sonnet-5"}}\n'
	} > "$path"
	run get_models sid
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "claude-opus-4-8" ]
	[ "${lines[1]}" = "claude-sonnet-5" ]
	[ "${#lines[@]}" -eq 2 ]
}

@test "get_recent_model: is the last model used" {
	write_transcript sid claude-opus-4-8 claude-opus-4-8 claude-sonnet-5 > /dev/null
	run get_recent_model sid
	[ "$status" -eq 0 ]
	[ "$output" = "claude-sonnet-5" ]
}

@test "get_top_model: is the most used model" {
	write_transcript sid claude-opus-4-8 claude-sonnet-5 claude-opus-4-8 claude-opus-4-8 > /dev/null
	run get_top_model sid
	[ "$status" -eq 0 ]
	[ "$output" = "claude-opus-4-8" ]
}

@test "get_ranked_models: distinct models, most used first" {
	write_transcript sid \
		claude-opus-4-8 claude-opus-4-8 claude-opus-4-8 \
		claude-sonnet-5 claude-sonnet-5 \
		claude-haiku-4-5-20251001 > /dev/null
	run get_ranked_models sid
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "claude-opus-4-8" ]
	[ "${lines[1]}" = "claude-sonnet-5" ]
	[ "${lines[2]}" = "claude-haiku-4-5-20251001" ]
	[ "${#lines[@]}" -eq 3 ]
}

@test "get_model_counts: reports a count per model" {
	write_transcript sid claude-opus-4-8 claude-sonnet-5 claude-opus-4-8 > /dev/null
	run get_model_counts sid
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "2 claude-opus-4-8" ]
	[ "${lines[1]}" = "1 claude-sonnet-5" ]
}

# writes a transcript with a failed Bash call and a later Edit
write_tool_transcript() {
	cat > "$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl" <<- 'EOF'
		{"type":"user","message":{"content":[{"type":"tool_use","id":"x","name":"Ignored","input":{}}]}}
		{"type":"assistant","message":{"content":[{"type":"text","text":"hi"},{"type":"tool_use","id":"t1","name":"Bash","input":{"command":"make"}}]}}
		{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","content":"boom","is_error":true}]}}
		{"type":"assistant","message":{"model":"claude-opus-4-8"}}
		{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t2","name":"Edit","input":{"file_path":"a.txt"}}]}}
		{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t2","content":[{"type":"text","text":"edited"}]}]}}
	EOF
}

@test "get_tool_calls: lists assistant calls in order, joined to their results" {
	write_tool_transcript
	run get_tool_calls sid
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[0]}" == '{"name":"Bash","input":{"command":"make"},"output":"boom","error":true}' ]]
	[[ "${lines[1]}" == '{"name":"Edit","input":{"file_path":"a.txt"},"output":"edited","error":false}' ]]
}

@test "get_tool_calls: filters by tool name" {
	write_tool_transcript
	run get_tool_calls sid Bash
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 1 ]
	[[ "${lines[0]}" == *'"name":"Bash"'* ]]
}

@test "get_tool_calls: a call with no result yet has empty output" {
	printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t1","name":"Bash","input":{}}]}}' \
		> "$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl"
	run get_tool_calls sid
	[ "$status" -eq 0 ]
	[[ "$output" == *'"output":"","error":false'* ]]
}

@test "get_recent_tool_call: is the last call, or the last of a named tool" {
	write_tool_transcript
	run get_recent_tool_call sid
	[ "$status" -eq 0 ]
	[[ "$output" == *'"name":"Edit"'* ]]

	run get_recent_tool_call sid Bash
	[ "$status" -eq 0 ]
	[[ "$output" == *'"name":"Bash"'* ]]
}

@test "get_recent_tool_call: fails when no call matches" {
	write_tool_transcript
	run get_recent_tool_call sid Glob
	[ "$status" -eq 1 ]

	write_transcript sid claude-opus-4-8 > /dev/null
	run get_recent_tool_call sid
	[ "$status" -eq 1 ]
}

@test "get_recent_field: is the last value of a top-level field" {
	path="$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl"
	{
		printf '{"type":"assistant","version":"2.1.1"}\n'
		printf '{"type":"user"}\n'
		printf '{"type":"assistant","version":"2.1.218"}\n'
	} > "$path"
	run get_recent_field version sid
	[ "$status" -eq 0 ]
	[ "$output" = "2.1.218" ]
}

@test "get_recent_field: fails without a field name, or when the field is absent" {
	write_transcript sid claude-opus-4-8 > /dev/null
	run get_recent_field
	[ "$status" -eq 1 ]
	run get_recent_field attributionSkill sid
	[ "$status" -eq 1 ]
}

@test "a transcript with no real models yields nothing" {
	path="$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl"
	{
		printf '{"type":"user","message":{"role":"user"}}\n'
		printf '{"type":"assistant","message":{"model":"<synthetic>"}}\n'
	} > "$path"

	run get_models sid
	[ "$status" -eq 0 ]
	[ -z "$output" ]

	run get_ranked_models sid
	[ "$status" -eq 0 ]
	[ -z "$output" ]

	run get_recent_model sid
	[ "$status" -eq 1 ]

	run get_top_model sid
	[ "$status" -eq 1 ]
}

@test "a missing session fails through every helper" {
	for helper in get_models get_recent_model get_top_model get_ranked_models get_model_counts get_tool_calls get_recent_tool_call; do
		run "$helper" nope
		[ "$status" -eq 1 ]
	done
}

@test "get_current_*: infer the session from CLAUDE_CODE_SESSION_ID" {
	write_transcript sid claude-opus-4-8 claude-sonnet-5 claude-opus-4-8 > /dev/null
	export CLAUDE_CODE_SESSION_ID=sid

	[ "$(get_current_transcript)" = "$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl" ]
	[ "$(get_current_model)" = "claude-opus-4-8" ]
	[ "$(get_current_top_model)" = "claude-opus-4-8" ]

	run get_current_models
	[ "${#lines[@]}" -eq 3 ]
	run get_current_ranked_models
	[ "${lines[0]}" = "claude-opus-4-8" ]
	[ "${lines[1]}" = "claude-sonnet-5" ]
	run get_current_model_counts
	[ "${lines[0]}" = "2 claude-opus-4-8" ]
}

@test "get_current_*: read the tool call, skill, plugin, and version" {
	path="$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl"
	printf '%s\n' '{"type":"assistant","version":"2.1.218","attributionSkill":"writing:writing","attributionPlugin":"writing","message":{"content":[{"type":"tool_use","id":"t1","name":"Edit","input":{}}]}}' > "$path"
	export CLAUDE_CODE_SESSION_ID=sid

	[[ "$(get_current_tool_call)" == *'"name":"Edit"'* ]]
	[[ "$(get_current_tool_call Edit)" == *'"name":"Edit"'* ]]
	[ "$(get_current_skill)" = "writing:writing" ]
	[ "$(get_current_plugin)" = "writing" ]
	[ "$(get_current_version)" = "2.1.218" ]
}

@test "get_current_*: the session_id global wins over the environment" {
	write_transcript wanted claude-opus-4-8 > /dev/null
	export CLAUDE_CODE_SESSION_ID=other
	session_id=wanted
	[ "$(get_current_transcript)" = "$CLAUDE_CONFIG_DIR/projects/proj/wanted.jsonl" ]
}

@test "get_current_model: fails without a session" {
	run get_current_model
	[ "$status" -eq 1 ]
}
