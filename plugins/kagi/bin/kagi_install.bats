#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
	install="$BATS_TEST_DIRNAME/kagi_install"
	elsewhere="$BATS_TEST_TMPDIR/elsewhere"
	system=/usr/bin:/bin
	mkdir -p "$elsewhere"

	# PATH holds where an install lands, and the shim beside this installer,
	# which its lookup has to skip.
	export PATH="$BATS_TEST_DIRNAME:$elsewhere:$system"
	export TMPDIR="$BATS_TEST_TMPDIR"
	lock="$TMPDIR/kagi_install.lock"

	# Stands in for the real installer, which drops a kagi onto PATH.
	installer="printf '#!/usr/bin/env bash\n' > $elsewhere/kagi; chmod +x $elsewhere/kagi"
}

@test "installs, then prints where it landed" {
	KAGI_SHIM_INSTALLER="$installer" run --separate-stderr "$install"

	[ "$status" -eq 0 ]
	[ "$output" = "$elsewhere/kagi" ]
	[[ "$stderr" == *'not installed. Installing it now'* ]]
	[[ "$stderr" == *"installed at $elsewhere/kagi"* ]]
}

@test "reports an install that produced no binary, never finding the shim beside it" {
	KAGI_SHIM_INSTALLER="true" run -127 "$install"

	[[ "$output" == *'install finished, but no kagi binary'* ]]
}

@test "releases the lock when it finishes" {
	KAGI_SHIM_INSTALLER="$installer" run "$install"

	[ ! -d "$lock" ]
}

@test "waits for another install instead of starting its own" {
	mkdir "$lock"
	(
		sleep 1
		bash -c "$installer"
		rmdir "$lock"
	) &

	KAGI_SHIM_INSTALLER="false" run --separate-stderr "$install"

	[ "$status" -eq 0 ]
	[ "$output" = "$elsewhere/kagi" ]
	[[ "$stderr" == *'another install is running'* ]]
	[[ "$stderr" != *'Installing it now'* ]]
}
