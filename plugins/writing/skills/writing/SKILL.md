---
name: writing
disable-model-invocation: true
description: Write clearly and concisely, for humans and agents.
---

Apply these rules to any text you have written or are about to write. Check every line against every rule, delegating to a subagent when the text is long. Rewrite each line that fails until it passes; delete the ones you cannot fix.

!`awk 'c>1; /^---$/{c++}' ${CLAUDE_SKILL_DIR}/output-style.md`
