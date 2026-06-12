def word_text:
	[.. | objects | select(.Type? == "Lit" or .Type? == "SglQuoted") | .Value]
	| join("");

def strip_wrappers:
	(.[0] // "") as $word
	| if (["sudo", "env", "command", "exec", "time", "nohup"] | index($word)) != null
		or (($word | contains("=")) and ($word | contains("://") | not))
	then .[1:] | strip_wrappers
	else . end;
