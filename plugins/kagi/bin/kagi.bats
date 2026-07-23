#!/usr/bin/env bats

setup() {
	shim="$BATS_TEST_DIRNAME/kagi"
	elsewhere="$BATS_TEST_TMPDIR/elsewhere"

	# Enough PATH for the shim's own coreutils, without the machine's real kagi.
	system=/usr/bin:/bin
	mkdir -p "$elsewhere"

	# A stale lock in the shared temporary directory makes every install test
	# wait five minutes.
	export TMPDIR="$BATS_TEST_TMPDIR"
}

write_kagi() {
	local directory=$1
	mkdir -p "$directory"
	{
		echo '#!/usr/bin/env bash'
		echo 'printf "real kagi: %s\n" "$*"'
	} > "$directory/kagi"
	chmod +x "$directory/kagi"
}

write_installer() {
	local script="$BATS_TEST_TMPDIR/install"
	cat > "$script" << EOF
#!/usr/bin/env bash
mkdir -p '$elsewhere'
cat > '$elsewhere/kagi' << 'INNER'
#!/usr/bin/env bash
printf "real kagi: %s\n" "\$*"
INNER
chmod +x '$elsewhere/kagi'
EOF
	chmod +x "$script"

	printf '%s' "$script"
}

@test "hands off to a real kagi found elsewhere on PATH" {
	write_kagi "$elsewhere"

	PATH="$BATS_TEST_DIRNAME:$elsewhere:$system" run "$shim" search "rust"

	[ "$status" -eq 0 ]
	[[ "$output" == *'real kagi: search rust'* ]]
}

@test "never resolves back to itself" {
	PATH="$BATS_TEST_DIRNAME:$system" KAGI_SHIM_AUTO_INSTALL=false run "$shim" --version

	[ "$status" -eq 127 ]
	[[ "$output" == *'not installed'* ]]
}

@test "skips itself when reached through a symlinked or relative PATH entry" {
	write_kagi "$elsewhere"

	PATH="$BATS_TEST_DIRNAME/.:$elsewhere:$system" run "$shim" --version

	[ "$status" -eq 0 ]
	[[ "$output" == *'real kagi: --version'* ]]
}

@test "installs on first use, then hands off" {
	installer=$(write_installer)

	PATH="$BATS_TEST_DIRNAME:$elsewhere:$system" KAGI_SHIM_INSTALLER="$installer" run "$shim" search "rust"

	[ "$status" -eq 0 ]
	[[ "$output" == *'not installed. Installing it now'* ]]
	[[ "$output" == *"installed at $elsewhere/kagi"* ]]
	[[ "$output" == *'real kagi: search rust'* ]]
}

@test "reports a failed install instead of hanging" {
	PATH="$BATS_TEST_DIRNAME:$elsewhere:$system" KAGI_SHIM_INSTALLER="true" run "$shim" --version

	[ "$status" -eq 127 ]
	[[ "$output" == *'install finished, but no kagi binary'* ]]
}

@test "auto-install can be turned off" {
	PATH="$BATS_TEST_DIRNAME:$elsewhere:$system" KAGI_SHIM_AUTO_INSTALL=false run "$shim" --version

	[ "$status" -eq 127 ]
	[[ "$output" == *'KAGI_SHIM_AUTO_INSTALL is false'* ]]
	[[ "$output" != *'Installing it now'* ]]
}

@test "passes arguments through untouched" {
	write_kagi "$elsewhere"

	PATH="$BATS_TEST_DIRNAME:$elsewhere:$system" run "$shim" search "two words" --format toon

	[[ "$output" == *'real kagi: search two words --format toon'* ]]
}
