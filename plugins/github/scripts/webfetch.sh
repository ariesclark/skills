#!/usr/bin/env bash

directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$directory/core/url.sh"
source "$directory/core/verdict.sh"

url=${1:-$(jq -r '.tool_input.url // empty')}
verdict_prefix='Blocked: fetching GitHub pages yields a lossy summary, not the underlying content.'
generic='Clone the repository and read the files directly, or use gh (gh api, gh pr view, gh issue view) for PRs, issues, and metadata.'

url_host_is "$url" github.com githubusercontent.com || exit 0

host=$(url_host "$url")

if [[ "$host" == gist.github.com ]]; then
	gist=$(url_segment "$url" 2)
	[[ -n "$gist" ]] || gist=$(url_segment "$url" 1)
	[[ -n "$gist" ]] || deny 'Clone the gist and read the files directly, or use gh gist list / gh gist view.'

	target="gist $gist"
	fallback="gh gist view $gist"
	clone_arguments=(--gist "$gist")
elif [[ "$host" == github.com || "$host" == www.github.com || "$host" == raw.githubusercontent.com ]]; then
	owner=$(url_segment "$url" 1)
	repository=$(url_segment "$url" 2)
	repository=${repository%.git}
	section=$(url_segment "$url" 3)

	[[ "$host" != raw.githubusercontent.com && ( "$section" == pull || "$section" == issues ) ]] &&
		deny "Use gh pr view / gh issue view --repo $owner/$repository, with --comments or gh pr diff, for the complete data including comments, review threads, and diffs."
	[[ -n "$owner" && -n "$repository" ]] || deny "$generic"

	target="$owner/$repository"
	fallback="gh api or gh repo view $owner/$repository"
	clone_arguments=("$owner/$repository")
else
	deny "$generic"
fi

clone=$("$directory/gh-clone-tmp.sh" "${clone_arguments[@]}" 2>/dev/null) ||
	deny "$target could not be cloned (private, nonexistent, or inaccessible). Use $fallback instead."

destination=${clone% *}
sha=${clone##* }

deny "$target was cloned for you at $destination on $sha; read the files there with Read/Grep/Glob. For PRs, issues, and metadata use gh."
