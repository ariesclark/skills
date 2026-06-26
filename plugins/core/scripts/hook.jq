def deny($reason; $context):
	{
		hookSpecificOutput: (
			{
				hookEventName: "PreToolUse",
				permissionDecision: "deny",
				permissionDecisionReason: $reason
			}
			+ (if $context == null or $context == "" then {} else {additionalContext: $context} end)
		)
	};

def deny($reason): deny($reason; null);

def warn($context):
	{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			additionalContext: $context
		}
	};
