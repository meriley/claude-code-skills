#!/usr/bin/env python3
"""
Hook: Enforce mriley/ branch prefix.
Blocks branch creation without the required prefix.
"""
import json
import sys
import re

REQUIRED_PREFIX = "mriley/"

# Patterns for branch creation
BRANCH_CREATE_PATTERNS = [
    r'\bgit\s+checkout\s+-b\s+(\S+)',
    r'\bgit\s+branch\s+(?!-[dD])\s*(\S+)',
    r'\bgit\s+switch\s+-c\s+(\S+)',
]

# Branches that don't need prefix
ALLOWED_BRANCHES = [
    "main",
    "master",
    "develop",
    "dev",
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

# Check for branch creation patterns
for pattern in BRANCH_CREATE_PATTERNS:
    match = re.search(pattern, command, re.IGNORECASE)
    if match:
        branch_name = match.group(1)

        # Skip allowed branches
        if branch_name in ALLOWED_BRANCHES:
            sys.exit(0)

        # Check for required prefix
        if not branch_name.startswith(REQUIRED_PREFIX):
            print("BLOCKED: Branch name must start with 'mriley/'", file=sys.stderr)
            print("", file=sys.stderr)
            print(f"Invalid branch: {branch_name}", file=sys.stderr)
            print(f"Expected format: mriley/<type>/<description>", file=sys.stderr)
            print("", file=sys.stderr)
            print("Examples:", file=sys.stderr)
            print("  mriley/feat/new-feature", file=sys.stderr)
            print("  mriley/fix/bug-description", file=sys.stderr)
            print("  mriley/refactor/cleanup", file=sys.stderr)
            print("", file=sys.stderr)
            print("Use the manage-branch skill:", file=sys.stderr)
            print("  /manage-branch", file=sys.stderr)
            sys.exit(2)

sys.exit(0)
