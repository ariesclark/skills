#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/url"
}

@test "parse_url: plain url" {
	parse_url url 'https://github.com/owner/repo'
	[ "$url_host" = "github.com" ]
	[ "$url_pathname" = "/owner/repo" ]
	[ "${url_segments[0]}" = "owner" ]
	[ "${url_segments[1]}" = "repo" ]
}

@test "parse_url: lowercases a mixed-case host" {
	parse_url url 'HTTPS://GitHub.COM/a'
	[ "$url_host" = "github.com" ]
}

@test "parse_url: strips port and userinfo from the host" {
	parse_url url 'https://user:pass@github.com:443/a'
	[ "$url_host" = "github.com" ]
}

@test "parse_url: spoofed userinfo resolves to the real host" {
	parse_url url 'https://github.com@evil.com/a'
	[ "$url_host" = "evil.com" ]
}

@test "parse_url: no path, query only" {
	parse_url url 'https://github.com?x=1'
	[ "$url_host" = "github.com" ]
	[ -z "$url_pathname" ]
}

@test "parse_url: empty input" {
	parse_url url ''
	[ -z "$url_host" ]
	[ -z "$url_pathname" ]
}

@test "parse_url: pathname strips search and fragment" {
	parse_url url 'https://g.com/a/b?x=1#sec'
	[ "$url_pathname" = "/a/b" ]
	[ "$url_search" = "x=1" ]
}

@test "parse_url: search is empty without one" {
	parse_url url 'https://g.com/a/b#sec'
	[ -z "$url_search" ]
}

@test "parse_url: pathname keeps a trailing slash" {
	parse_url url 'https://g.com/a/b/'
	[ "$url_pathname" = "/a/b/" ]
}

@test "parse_url: segments are zero-indexed" {
	parse_url url 'https://g.com/owner/repo/pull/5'
	[ "${url_segments[0]}" = "owner" ]
	[ "${url_segments[1]}" = "repo" ]
	[ "${url_segments[2]}" = "pull" ]
	[ "${url_segments[3]}" = "5" ]
}

@test "parse_url: out-of-range segments are unset" {
	parse_url url 'https://g.com/owner/repo'
	[ -z "${url_segments[5]:-}" ]
}

@test "parse_url: search containing a slash is ignored" {
	parse_url url 'https://g.com/a/b?x=/y'
	[ "${url_segments[1]}" = "b" ]
	[ -z "${url_segments[2]:-}" ]
}

@test "parse_url: results land under the given name" {
	parse_url other 'https://g.com/a?x=1'
	[ "$other_host" = "g.com" ]
	[ "$other_search" = "x=1" ]
}

@test "parse_search_params: decodes values into the named array" {
	declare -A params
	parse_search_params params 'q=fix%20a+bug&type=repos'
	[ "${params[q]}" = "fix a bug" ]
	[ "${params[type]}" = "repos" ]
}

@test "parse_search_params: encoded delimiters stay in one value" {
	declare -A params
	parse_search_params params 'q=a%26b%3Dc&t=1'
	[ "${params[q]}" = "a&b=c" ]
	[ "${params[t]}" = "1" ]
}

@test "parse_search_params: valueless keys are empty, repeated keys keep the last" {
	declare -A params
	parse_search_params params 'flag&x=1&x=2'
	[ -z "${params[flag]}" ]
	[ "${params[x]}" = "2" ]
}

@test "parse_search_params: an empty string resets the array" {
	declare -A params=([stale]=1)
	parse_search_params params ''
	[ "${#params[@]}" -eq 0 ]
}

@test "url_decode: decodes plus signs and percent escapes" {
	[ "$(url_decode 'fix+bug')" = "fix bug" ]
	[ "$(url_decode 'fix%20a%20bug%21')" = "fix a bug!" ]
}

@test "url_decode: passes plain text through" {
	[ "$(url_decode 'plain-text_1.2')" = "plain-text_1.2" ]
}

@test "host_is: exact and subdomain match" {
	parse_url url 'https://github.com/a'
	host_is "$url_host" github.com

	parse_url url 'https://gist.github.com/a'
	host_is "$url_host" github.com
}

@test "host_is: second domain matches" {
	parse_url url 'https://raw.githubusercontent.com/a'
	host_is "$url_host" github.com githubusercontent.com
}

@test "host_is: lookalike hosts are rejected" {
	parse_url url 'https://evilgithub.com/a'
	! host_is "$url_host" github.com

	parse_url url 'https://github.com.evil.com/a'
	! host_is "$url_host" github.com

	parse_url url 'https://example.com/github.com'
	! host_is "$url_host" github.com
}

@test "host_is: port does not break matching" {
	parse_url url 'https://github.com:8443/a'
	host_is "$url_host" github.com
}

@test "fuzz: helpers survive garbage input" {
	declare -A fuzz_params
	charset='aZ9.:/?#@%[]-_~ !$&()*+,;=\'
	for _ in $(seq 1 200); do
		length=$((RANDOM % 50))
		input=''
		for ((j = 0; j < length; j++)); do
			input+=${charset:RANDOM%${#charset}:1}
		done
		parse_url url "$input"
		host_is "$url_host" github.com || true
		parse_search_params fuzz_params "$input"
		url_decode "$input" > /dev/null
	done
}
