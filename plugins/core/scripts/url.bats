#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/url.sh"
}

@test "url_host: plain url" {
	[ "$(url_host 'https://github.com/a/b')" = "github.com" ]
}

@test "url_host: lowercases mixed case" {
	[ "$(url_host 'HTTPS://GitHub.COM/a')" = "github.com" ]
}

@test "url_host: strips port" {
	[ "$(url_host 'https://github.com:443/a')" = "github.com" ]
}

@test "url_host: strips userinfo" {
	[ "$(url_host 'https://user:pass@github.com/a')" = "github.com" ]
}

@test "url_host: spoofed userinfo resolves to real host" {
	[ "$(url_host 'https://github.com@evil.com/a')" = "evil.com" ]
}

@test "url_host: no path, query only" {
	[ "$(url_host 'https://github.com?x=1')" = "github.com" ]
}

@test "url_host: empty input" {
	[ "$(url_host '')" = "" ]
}

@test "url_path: strips query and fragment" {
	[ "$(url_path 'https://g.com/a/b?x=1#sec')" = "/a/b" ]
}

@test "url_path: no path yields nothing" {
	[ "$(url_path 'https://g.com')" = "" ]
}

@test "url_path: keeps trailing slash" {
	[ "$(url_path 'https://g.com/a/b/')" = "/a/b/" ]
}

@test "url_segment: positions are one-indexed" {
	[ "$(url_segment 'https://g.com/owner/repo/pull/5' 1)" = "owner" ]
	[ "$(url_segment 'https://g.com/owner/repo/pull/5' 2)" = "repo" ]
	[ "$(url_segment 'https://g.com/owner/repo/pull/5' 3)" = "pull" ]
	[ "$(url_segment 'https://g.com/owner/repo/pull/5' 4)" = "5" ]
}

@test "url_segment: out of range is empty" {
	[ "$(url_segment 'https://g.com/owner/repo' 5)" = "" ]
}

@test "url_segment: query containing slash is ignored" {
	[ "$(url_segment 'https://g.com/a/b?x=/y' 2)" = "b" ]
}

@test "url_host_is: exact and subdomain match" {
	url_host_is 'https://github.com/a' github.com
	url_host_is 'https://gist.github.com/a' github.com
}

@test "url_host_is: second domain matches" {
	url_host_is 'https://raw.githubusercontent.com/a' github.com githubusercontent.com
}

@test "url_host_is: lookalike hosts are rejected" {
	! url_host_is 'https://evilgithub.com/a' github.com
	! url_host_is 'https://github.com.evil.com/a' github.com
	! url_host_is 'https://example.com/github.com' github.com
}

@test "url_host_is: port does not break matching" {
	url_host_is 'https://github.com:8443/a' github.com
}

@test "fuzz: helpers survive garbage input" {
	charset='aZ9.:/?#@%[]-_~ !$&()*+,;=\'
	for _ in $(seq 1 200); do
		length=$((RANDOM % 50))
		input=''
		for ((j = 0; j < length; j++)); do
			input+=${charset:RANDOM % ${#charset}:1}
		done
		url_host "$input" > /dev/null
		url_path "$input" > /dev/null || true
		url_segment "$input" $((RANDOM % 5)) > /dev/null
		url_host_is "$input" github.com || true
	done
}
