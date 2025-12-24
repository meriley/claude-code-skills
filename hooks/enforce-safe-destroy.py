#!/usr/bin/env python3
"""
Hook: Enforce safe-destroy skill for destructive commands.
Blocks dangerous commands that could cause data loss.
"""
import json
import sys
import re

# Destructive command patterns
DESTRUCTIVE_PATTERNS = [
    # Git destructive commands
    (r'\bgit\s+reset\s+--hard\b', "git reset --hard destroys uncommitted changes"),
    (r'\bgit\s+clean\s+-[fd]+\b', "git clean permanently deletes untracked files"),
    (r'\bgit\s+checkout\s+--\s+\.', "git checkout -- . discards all changes"),
    (r'\bgit\s+restore\s+\.', "git restore . discards all changes"),
    (r'\bgit\s+push\s+.*--force\b', "git push --force can overwrite remote history"),
    (r'\bgit\s+push\s+.*-f\b', "git push -f can overwrite remote history"),

    # File system destructive commands
    (r'\brm\s+-rf\b', "rm -rf permanently deletes files"),
    (r'\brm\s+-fr\b', "rm -fr permanently deletes files"),
    (r'\brm\s+.*-r.*-f\b', "rm with -rf permanently deletes files"),

    # Docker destructive commands
    (r'\bdocker\s+system\s+prune\b', "docker system prune removes unused data"),
    (r'\bdocker\s+volume\s+prune\b', "docker volume prune removes volumes"),

    # Kubernetes destructive commands
    (r'\bkubectl\s+delete\b', "kubectl delete removes resources"),
]

# Allow patterns (safe variants)
ALLOW_PATTERNS = [
    r'--dry-run',
    r'-n\b',  # dry-run short form for some commands
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

# Check if it's a dry run (allowed)
for pattern in ALLOW_PATTERNS:
    if re.search(pattern, command, re.IGNORECASE):
        sys.exit(0)

# Check for destructive patterns
for pattern, reason in DESTRUCTIVE_PATTERNS:
    if re.search(pattern, command, re.IGNORECASE):
        # Output warning but allow - skill needs to run after user confirms
        # The CLAUDE.md instructions and skill are the real enforcement
        print("⚠️  DESTRUCTIVE COMMAND WARNING", file=sys.stderr)
        print(f"   {reason}", file=sys.stderr)
        print("   Ensure safe-destroy skill was used for confirmation.", file=sys.stderr)
        sys.exit(0)  # Allow but warn

sys.exit(0)
