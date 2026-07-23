include "shell";

[
	..
	| objects
	| select(.Type? == "CallExpr")
][]
| [.Args[]? | word_text]
| strip_wrappers
| select(.[0] == "curl" or .[0] == "wget")
| .[1:][]
| select(contains("://"))
