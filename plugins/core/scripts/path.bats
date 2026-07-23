#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/path"

	shim="$BATS_TEST_TMPDIR/shim"
	real="$BATS_TEST_TMPDIR/real"
	system=/usr/bin:/bin
	mkdir -p "$shim" "$real"

	write_example "$shim"
	write_example "$real"
}

write_example() {
	printf '#!/usr/bin/env bash\n' > "$1/example"
	chmod +x "$1/example"
}

@test "command_elsewhere: skips the excluded directory" {
	PATH="$shim:$real:$system" run command_elsewhere example "$shim"

	[ "$status" -eq 0 ]
	[ "$output" = "$real/example" ]
}

@test "command_elsewhere: skips a symlinked or relative path entry" {
	ln -s "$shim" "$BATS_TEST_TMPDIR/link"

	PATH="$BATS_TEST_TMPDIR/link:$shim/.:$real:$system" run command_elsewhere example "$shim"

	[ "$output" = "$real/example" ]
}

@test "command_elsewhere: fails when the command lives only in the excluded directory" {
	PATH="$shim:$system" run command_elsewhere example "$shim"

	[ "$status" -ne 0 ]
	[ -z "$output" ]
}

@test "command_elsewhere: defaults to the calling script's directory" {
	caller="$shim/caller"
	{
		printf '#!/usr/bin/env bash\n'
		printf 'source %q\n' "$BATS_TEST_DIRNAME/path"
		printf 'command_elsewhere example\n'
	} > "$caller"
	chmod +x "$caller"

	PATH="$shim:$real:$system" run "$caller"

	[ "$status" -eq 0 ]
	[ "$output" = "$real/example" ]
}

@test "command_elsewhere: fails on an excluded directory that does not exist" {
	PATH="$real:$system" run command_elsewhere example "$BATS_TEST_TMPDIR/missing"

	[ "$status" -ne 0 ]
}

@test "command_elsewhere: leaves an empty PATH entry alone" {
	PATH=":$shim:$real:$system" run command_elsewhere example "$shim"

	[ "$output" = "$real/example" ]
}
