#!/usr/bin/env bats

load test-helper

@test "silent on a non-github url" {
	run hook '{"tool_input":{"url":"https://example.com/page"}}'
	[ -z "$output" ]
}

@test "silent on github lookalikes" {
	run hook '{"tool_input":{"url":"https://example.com/github.com/x"}}'
	[ -z "$output" ]

	run hook '{"tool_input":{"url":"https://github.com.evil.com/yarlson/lnk"}}'
	[ -z "$output" ]
}

@test "silent without a url" {
	run hook '{}'
	[ -z "$output" ]
}

@test "silent on github content subdomains" {
	run hook '{"tool_input":{"url":"https://docs.github.com/en/actions"}}'
	[ -z "$output" ]

	run hook '{"tool_input":{"url":"https://avatars.githubusercontent.com/u/1?v=4"}}'
	[ -z "$output" ]

	run hook '{"tool_input":{"url":"https://github.com"}}'
	[ -z "$output" ]

	run hook '{"tool_input":{"url":"https://codeload.github.com/x/y"}}'
	[ -z "$output" ]
}

@test "missing gh warns and suggests installing it" {
	stub=$(mktemp -d)
	for tool in bash cat jq dirname; do
		ln -s "$(command -v "$tool")" "$stub/$tool"
	done

	run bash -c "printf '%s' '{\"tool_input\":{\"url\":\"https://github.com/yarlson/lnk\"}}' | PATH='$stub' bash '$BATS_TEST_DIRNAME/webfetch'"
	rm -r "$stub"

	[[ "$output" == *'additionalContext'* ]]
	[[ "$output" == *'cli.github.com'* ]]
}

@test "pull requests deny with a gh redirect as hook JSON" {
	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/pull/9"}}'
	[[ "$output" == *'"permissionDecision": "deny"'* ]]
	[[ "$output" == *'gh pr view 9 --repo anthropics/claude-code --comments'* ]]
	[[ "$output" == *'gh pr diff 9 --repo anthropics/claude-code'* ]]
}


@test "issues and api variants deny with a gh redirect" {
	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/issues/42"}}'
	[[ "$output" == *'gh issue view 42 --repo anthropics/claude-code --comments'* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/repos/anthropics/claude-code/pulls/9"}}'
	[[ "$output" == *'gh pr view 9 --repo anthropics/claude-code'* ]]
}

@test "pull and issue lists deny with the list commands" {
	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/issues"}}'
	[[ "$output" == *'gh issue list --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/issues/new"}}'
	[[ "$output" == *'gh issue list --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/pulls"}}'
	[[ "$output" == *'gh pr list --repo anthropics/claude-code'* ]]
}

@test "host variants still match" {
	run hook '{"tool_input":{"url":"https://GitHub.com/anthropics/claude-code/pull/9?diff=split"}}'
	[[ "$output" == *"gh pr view"* ]]

	run hook '{"tool_input":{"url":"https://www.github.com/anthropics/claude-code/pull/9"}}'
	[[ "$output" == *"gh pr view"* ]]

	run hook '{"tool_input":{"url":"http://github.com/anthropics/claude-code/issues/4"}}'
	[[ "$output" == *"gh issue view"* ]]
}

@test "releases and actions deny with gh redirects" {
	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/releases/download/v2.0.0/claude.tar.gz"}}'
	[[ "$output" == *'gh release download v2.0.0 --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/releases/tag/v1.0.0"}}'
	[[ "$output" == *'gh release view v1.0.0 --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/repos/anthropics/claude-code/releases/tags/v1.0.0"}}'
	[[ "$output" == *'gh release view v1.0.0 --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/repos/anthropics/claude-code/releases/latest"}}'
	[[ "$output" == *'gh release view --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/releases"}}'
	[[ "$output" == *'gh release list --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/actions/runs/123456"}}'
	[[ "$output" == *'gh run view 123456 --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/actions"}}'
	[[ "$output" == *'gh run list --repo anthropics/claude-code'* ]]
}

@test "unresolvable github urls deny generically" {
	run hook '{"tool_input":{"url":"https://github.com/"}}'
	[[ "$output" == *"Clone the repository"* ]]

	run hook '{"tool_input":{"url":"https://github.com/yarlson"}}'
	[[ "$output" == *"Clone the repository"* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/users/yarlson"}}'
	[[ "$output" == *'gh api users/yarlson'* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/users/yarlson/repos?per_page=10"}}'
	[[ "$output" == *'gh api users/yarlson/repos?per_page=10'* ]]
}

@test "search urls deny with gh search redirects" {
	run hook '{"tool_input":{"url":"https://github.com/search?q=lnk&type=repositories"}}'
	[[ "$output" == *'gh search repos lnk'* ]]

	run hook '{"tool_input":{"url":"https://github.com/search?type=pullrequests&q=fix+bug"}}'
	[[ "$output" == *'gh search prs fix bug'* ]]

	run hook '{"tool_input":{"url":"https://github.com/search?q=fix%20login%20bug"}}'
	[[ "$output" == *'gh search repos fix login bug'* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/search/code?q=parse_url"}}'
	[[ "$output" == *'gh search code parse_url'* ]]

	run hook '{"tool_input":{"url":"https://github.com/search"}}'
	[[ "$output" == *'gh search repos <query>'* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/search/issues?q=bug"}}'
	[[ "$output" == *'gh search issues bug'* ]]
}

@test "unsupported search types list the real gh search commands" {
	run hook '{"tool_input":{"url":"https://github.com/search?q=x&type=wikis"}}'
	[[ "$output" != *'gh search wikis'* ]]
	[[ "$output" == *'gh search <code|commits|issues|prs|repos> x'* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/search/users?q=foo"}}'
	[[ "$output" != *'gh search users foo'* ]]
	[[ "$output" == *'gh search <code|commits|issues|prs|repos> foo'* ]]
}

@test "gh subcommand discovery is cached and reused" {
	cache_home=$(mktemp -d)
	search_hook() {
		XDG_CACHE_HOME="$cache_home" bash "$BATS_TEST_DIRNAME/webfetch" \
			<<< '{"tool_input":{"url":"https://github.com/search?q=x&type=wikis"}}'
	}

	run search_hook
	[[ "$output" == *'gh search <code|commits|issues|prs|repos> x'* ]]
	[ -s "$cache_home/claude/github/subcommands-search" ]

	printf 'bogus\n' > "$cache_home/claude/github/subcommands-search"
	run search_hook
	rm -r "$cache_home"

	[[ "$output" == *'gh search <bogus> x'* ]]
}

@test "discussions deny with gh discussion redirects" {
	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/discussions/123"}}'
	[[ "$output" == *'gh discussion view 123 --repo anthropics/claude-code'* ]]

	run hook '{"tool_input":{"url":"https://github.com/anthropics/claude-code/discussions"}}'
	[[ "$output" == *'gh discussion list --repo anthropics/claude-code'* ]]
}

@test "wiki urls clone the wiki repository" {
	run hook '{"session_id":"session-bats","tool_input":{"url":"https://github.com/yarlson/lnk/wiki"}}'
	[[ "$output" == *"lnk.wiki could not be cloned"* ]]
}

@test "gist without an id denies with gist guidance" {
	run hook '{"tool_input":{"url":"https://gist.github.com/"}}'
	[[ "$output" == *"gh gist list"* ]]

	run hook '{"tool_input":{"url":"https://api.github.com/gists"}}'
	[[ "$output" == *"gh gist list"* ]]
}

@test "clones a repository and reports the path, stripping .git" {
	run hook '{"session_id":"session-bats","tool_input":{"url":"https://github.com/yarlson/lnk.git"}}'
	[[ "$output" == *"A clone of yarlson/lnk was provided"* ]]
	[[ "$output" == *'additionalContext'* ]]
	[[ "$output" == *"/sessionbats-github-yarlson-lnk-"* ]]
}

@test "clones a gist" {
	run hook '{"session_id":"session-bats","tool_input":{"url":"https://gist.github.com/hage99351-hash/4917aeecf7e6ccba14995a4a9e604f9b"}}'
	[[ "$output" == *"/sessionbats-github-gist-4917aeecf7e6ccba14995a4a9e604f9b-"* ]]
}

@test "raw gist urls clone the gist" {
	run hook '{"session_id":"session-bats","tool_input":{"url":"https://gist.githubusercontent.com/hage99351-hash/4917aeecf7e6ccba14995a4a9e604f9b/raw/file"}}'
	[[ "$output" == *"/sessionbats-github-gist-4917aeecf7e6ccba14995a4a9e604f9b-"* ]]
}

@test "cloning without a session id fails loudly" {
	run bash -c "printf '%s' '{\"tool_input\":{\"url\":\"https://github.com/yarlson/lnk\"}}' | env -u CLAUDE_CODE_SESSION_ID bash '$BATS_TEST_DIRNAME/webfetch'"
	[ "$status" -eq 1 ]
	[[ "$output" == *"session_id is empty"* ]]
}

@test "raw urls clone the repository, prefixed with the session id" {
	run hook '{"session_id":"session-bats","tool_input":{"url":"https://raw.githubusercontent.com/yarlson/lnk/main/README.md"}}'

	[[ "$output" == *"/sessionbats-github-yarlson-lnk-"* ]]

	clones=("${TMPDIR:-/tmp}/sessionbats-github-yarlson-lnk-"*)
	[ -d "${clones[0]}" ]
}

@test "unclonable repository falls back to gh" {
	run hook '{"session_id":"session-bats","tool_input":{"url":"https://github.com/features/nope-not-a-repo"}}'
	[[ "$output" == *"could not be cloned"* ]]
	[[ "$output" == *"gh repo view features/nope-not-a-repo"* ]]
}

@test "unclonable gist falls back to gh" {
	run hook '{"session_id":"session-bats","tool_input":{"url":"https://gist.github.com/00000000000000000000000000000dead"}}'
	[[ "$output" == *"could not be cloned"* ]]
	[[ "$output" == *"gh gist view"* ]]
}
