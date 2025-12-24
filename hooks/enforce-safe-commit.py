#!/usr/bin/env python3
"""
Hook: Enforce safe-commit skill for git commits.
Blocks direct `git commit` commands to ensure safe-commit skill is used.
"""
import json
import sys
import re

# Patterns that indicate a git commit command
COMMIT_PATTERNS = [
    r'\bgit\s+commit\b',
    r'\bgit\s+.*\bcommit\b',
]

# Patterns to allow (bypass scenarios)
ALLOW_PATTERNS = [
    r'--dry-run',           # Dry runs are fine
    r'--no-commit',         # Merge without commit
    r'git\s+log.*commit',   # Viewing commits
    r'git\s+show.*commit',  # Showing commits
    r'git\s+rev-parse',     # Parsing commit refs
]

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON input: {e}", file=sys.stderr)
    sys.exit(1)

tool_name = input_data.get("tool_name", "")
command = input_data.get("tool_input", {}).get("command", "")

# Only check Bash commands
if tool_name != "Bash" or not command:
    sys.exit(0)

# Check if it's an allowed pattern
for pattern in ALLOW_PATTERNS:
    if re.search(pattern, command, re.IGNORECASE):
        sys.exit(0)

# Check if it's a commit command
is_commit = False
for pattern in COMMIT_PATTERNS:
    if re.search(pattern, command, re.IGNORECASE):
        is_commit = True
        break

if is_commit:
    # Output warning but allow - can't distinguish skill-invoked vs manual
    # The CLAUDE.md instructions are the real enforcement
    print("⚠️  REMINDER: Use safe-commit skill for commits", file=sys.stderr)
    print("   This ensures security scan, quality check, and tests pass.", file=sys.stderr)
    sys.exit(0)  # Allow but warn

sys.exit(0)
