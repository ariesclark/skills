#!/usr/bin/env bats

setup() {
	papercuts="$BATS_TEST_DIRNAME/../bin/papercuts"
	primer="$BATS_TEST_DIRNAME/session-start"
	export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/.claude"
	unset CLAUDE_CODE_SESSION_ID
	cd "$BATS_TEST_TMPDIR" || exit 1
}

# writes a one-model transcript and echoes the session id to pass as CLAUDE_CODE_SESSION_ID
seed_session() {
	mkdir -p "$CLAUDE_CONFIG_DIR/projects/proj"
	printf '{"type":"assistant","message":{"model":"%s"}}\n' "$1" \
		> "$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl"
	printf 'sid\n'
}

# writes a transcript with a failed Bash call and a later Edit, plus attribution and
# a version; echoes the session id
seed_rich_session() {
	mkdir -p "$CLAUDE_CONFIG_DIR/projects/proj"
	cat > "$CLAUDE_CONFIG_DIR/projects/proj/sid.jsonl" <<- 'EOF'
		{"type":"assistant","version":"2.1.218","attributionSkill":"writing:writing","attributionPlugin":"writing","message":{"model":"claude-opus-4-8","content":[{"type":"tool_use","id":"t1","name":"Bash","input":{"command":"make"}}]}}
		{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","content":"stale cache","is_error":true}]}}
		{"type":"assistant","version":"2.1.218","attributionSkill":"writing:writing","attributionPlugin":"writing","message":{"model":"claude-opus-4-8","content":[{"type":"tool_use","id":"t2","name":"Edit","input":{"file_path":"a.txt"}}]}}
		{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t2","content":"edited"}]}}
	EOF
	printf 'sid\n'
}

@test "add writes a JSON line tagged with the model" {
	run "$papercuts" add -m claude-opus-4-8 "ran the build, hit a stale cache"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"model":"claude-opus-4-8"'* ]]
	[[ "$output" == *'"message":"ran the build, hit a stale cache"'* ]]
}

@test "add appends one line per entry" {
	"$papercuts" add -m a "first, one" > /dev/null
	"$papercuts" add -m b "second, two" > /dev/null
	run grep -c '^{' PAPERCUTS.jsonl
	[ "$output" -eq 2 ]
}

@test "add auto-detects the model from the session transcript" {
	seed_session claude-opus-4-8 > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add "ran the build, hit a stale cache"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"model":"claude-opus-4-8"'* ]]
}

@test "add -m overrides the auto-detected model" {
	seed_session claude-opus-4-8 > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add -m sonnet-5 "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"model":"sonnet-5"'* ]]
}

@test "add records no tool unless -t is passed" {
	seed_rich_session > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" != *'"tool"'* ]]
}

@test "add -t attaches the most recent call with its input, output, and error flag" {
	seed_rich_session > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add -t "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"tool":{"name":"Edit"'* ]]
	[[ "$output" == *'"input":{"file_path":"a.txt"}'* ]]
	[[ "$output" == *'"output":"edited"'* ]]
	[[ "$output" == *'"error":false'* ]]
	[[ "$output" == *'"message":"x, y"'* ]]
}

@test "add -t <tool> attaches the most recent call of that tool" {
	seed_rich_session > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add -t Bash "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"name":"Bash"'* ]]
	[[ "$output" == *'"command":"make"'* ]]
	[[ "$output" == *'"output":"stale cache"'* ]]
	[[ "$output" == *'"error":true'* ]]
}

@test "add --tool=<tool> names the tool unambiguously" {
	seed_rich_session > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add --tool=Bash "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"name":"Bash"'* ]]
}

@test "add -t keeps an unquoted message out of the tool name" {
	seed_rich_session > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add -t ran the build, hit a stale cache
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"message":"ran the build, hit a stale cache"'* ]]
	[[ "$output" == *'"name":"Edit"'* ]]
}

@test "add -t warns when no call matches, and still logs the papercut" {
	seed_rich_session > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add -t Glob "x, y"
	[ "$status" -eq 0 ]
	[[ "$output" == *"no Glob tool call found"* ]]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"message":"x, y"'* ]]
	[[ "$output" != *'"tool"'* ]]
}

@test "add truncates a long tool output" {
	seed_rich_session > /dev/null
	PAPERCUTS_OUTPUT_LIMIT=4 CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add -t Bash "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"output":"stal…"'* ]]
}

@test "add records the session, skill, plugin, and version" {
	seed_rich_session > /dev/null
	CLAUDE_CODE_SESSION_ID=sid run "$papercuts" add "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *'"session":"sid"'* ]]
	[[ "$output" == *'"skill":"writing:writing"'* ]]
	[[ "$output" == *'"plugin":"writing"'* ]]
	[[ "$output" == *'"version":"2.1.218"'* ]]
}

@test "add omits the fields the transcript cannot supply" {
	run "$papercuts" add -m claude-opus-4-8 "x, y"
	[ "$status" -eq 0 ]
	run cat PAPERCUTS.jsonl
	[[ "$output" != *'"tool"'* ]]
	[[ "$output" != *'"session"'* ]]
	[[ "$output" != *'"skill"'* ]]
	[[ "$output" != *'"plugin"'* ]]
	[[ "$output" != *'"version"'* ]]
}

@test "add without a model or a resolvable session errors" {
	run "$papercuts" add "no model, no session"
	[ "$status" -eq 2 ]
	[[ "$output" == *"pass -m"* ]]
}

@test "add requires a message" {
	run "$papercuts" add -m claude-opus-4-8
	[ "$status" -eq 2 ]
}

@test "add honors PAPERCUTS_FILE" {
	PAPERCUTS_FILE=notes/friction.jsonl run "$papercuts" add -m a "x, y"
	[ "$status" -eq 0 ]
	[ -f notes/friction.jsonl ]
}

@test "add --json echoes the new entry" {
	run "$papercuts" add --json -m claude-opus-4-8 "ran the build, hit a stale cache"
	[ "$status" -eq 0 ]
	[[ "$output" == *'"model":"claude-opus-4-8"'* ]]
	[[ "$output" == *'"message":"ran the build, hit a stale cache"'* ]]
	run cat PAPERCUTS.jsonl
	[[ "$output" == *"ran the build, hit a stale cache"* ]]
}

@test "list prints a readable line per entry" {
	"$papercuts" add -m a "first, one" > /dev/null
	"$papercuts" add -m b "second, two" > /dev/null
	run "$papercuts" list
	[ "$status" -eq 0 ]
	[[ "$output" == *"(a) first, one"* ]]
	[[ "$output" == *"(b) second, two"* ]]
}

@test "list unescapes quotes in the readable view" {
	"$papercuts" add -m a 'used "sed" here' > /dev/null
	run "$papercuts" list
	[ "$status" -eq 0 ]
	[[ "$output" == *'used "sed" here'* ]]
}

@test "list --json emits a JSON array" {
	"$papercuts" add -m claude-opus-4-8 "ran the build, hit a stale cache" > /dev/null
	run "$papercuts" list --json
	[ "$status" -eq 0 ]
	[[ "$output" == '['* ]]
	[[ "$output" == *']' ]]
	[[ "$output" == *'"model":"claude-opus-4-8"'* ]]
	[[ "$output" == *'"message":"ran the build, hit a stale cache"'* ]]
}

@test "list --json preserves escaped quotes and backslashes" {
	"$papercuts" add -m a 'used "sed" with C:\path' > /dev/null
	run "$papercuts" list --json
	[ "$status" -eq 0 ]
	echo "$output" | grep -Fq '\"sed\"'
	echo "$output" | grep -Fq 'C:\\path'
}

@test "list on a missing file is empty" {
	run "$papercuts" list
	[ "$status" -eq 0 ]
	[ -z "$output" ]
	run "$papercuts" list --json
	[ "$status" -eq 0 ]
	[ "$output" = "[]" ]
}

@test "an unknown command exits with usage" {
	run "$papercuts" frobnicate
	[ "$status" -eq 2 ]
}

@test "session-start primes the agent with the papercuts add command" {
	run "$primer"
	[ "$status" -eq 0 ]
	[[ "$output" == *"papercuts add "* ]]
}
