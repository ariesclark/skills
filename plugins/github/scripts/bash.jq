include "shell";

def contents_path: "(https://api\\.github\\.com)?/?repos/[^/]+/[^/]+/contents([/?].*)?$";

def writes: ["-X", "--method", "--input", "-f", "--field", "-F", "--raw-field"];

[.. | objects | select(.Type? == "CallExpr")][]
| [.Args[]? | word_text]
| strip_wrappers
| if .[0] == "curl" or .[0] == "wget" then
	.[1:][] | select(contains("://"))
elif .[0] == "gh" and (.[1] // "") == "api"
	and (any(.[]; . as $word | writes | index($word)) | not)
then
	(.[2] // "")
	| select(test("^" + contents_path))
	| if startswith("https://") then . else "https://api.github.com/" + ltrimstr("/") end
else empty end
