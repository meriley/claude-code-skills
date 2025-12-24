#!/bin/bash
# Hook: Inject git context at session start.
# Provides immediate awareness of repository state.

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not in a git repository"
    exit 0
fi

# Gather git context
BRANCH=$(git branch --show-current 2>/dev/null || echo "detached HEAD")
STATUS=$(git status --porcelain 2>/dev/null | head -10)
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null)
AHEAD_BEHIND=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "0	0")

# Build context message
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Git Context:\\n- Branch: ${BRANCH}\\n- Ahead/Behind: ${AHEAD_BEHIND}\\n\\nRecent commits:\\n${RECENT_COMMITS}\\n\\nUncommitted changes:\\n${STATUS:-None}\\n\\nReminder: Use check-history skill for full context."
  }
}
EOF

exit 0
