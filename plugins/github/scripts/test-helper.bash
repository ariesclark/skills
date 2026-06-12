hook() {
	printf '%s' "$1" | bash "$BATS_TEST_DIRNAME/webfetch"
}

teardown() {
	rm -rf "${TMPDIR:-/tmp}/sessionbats"-*
}
