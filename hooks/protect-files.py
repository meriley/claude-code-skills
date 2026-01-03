#!/usr/bin/env python3
"""
Hook: Protect sensitive files from accidental edits.
Blocks modifications to .env files, lock files, and .git directory.
"""
import json
import sys
import re
import os

# Protected file patterns
PROTECTED_PATTERNS = [
    # Environment files
    (r"\.env($|\.)", "Environment files contain secrets"),
    (r"\.env\.local$", "Local environment files contain secrets"),
    (r"\.env\..*$", "Environment files contain secrets"),
    # Lock files (auto-generated)
    (r"package-lock\.json$", "Lock file is auto-generated"),
    (r"yarn\.lock$", "Lock file is auto-generated"),
    (r"pnpm-lock\.yaml$", "Lock file is auto-generated"),
    (r"Cargo\.lock$", "Lock file is auto-generated"),
    (r"poetry\.lock$", "Lock file is auto-generated"),
    (r"go\.sum$", "Lock file is auto-generated"),
    (r"Gemfile\.lock$", "Lock file is auto-generated"),
    # Git internals
    (r"\.git/", "Git internal files should not be edited"),
    (r"\.git$", "Git internal files should not be edited"),
    # Other sensitive files
    (r"\.ssh/", "SSH keys are sensitive"),
    (r"id_rsa", "SSH private keys are sensitive"),
    (r"\.pem$", "Certificate files are sensitive"),
    (r"\.key$", "Key files are sensitive"),
]

# Exceptions (patterns that are allowed despite matching above)
ALLOWED_PATTERNS = [
    r"\.env\.example$",
    r"\.env\.sample$",
    r"\.env\.template$",
]

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON input: {e}", file=sys.stderr)
    sys.exit(1)

tool_name = input_data.get("tool_name", "")
file_path = input_data.get("tool_input", {}).get("file_path", "")

# Only check Edit and Write operations
if tool_name not in ("Edit", "Write") or not file_path:
    sys.exit(0)

# Get just the filename/path components
file_name = os.path.basename(file_path)

# Check exceptions first
for pattern in ALLOWED_PATTERNS:
    if re.search(pattern, file_name, re.IGNORECASE):
        sys.exit(0)
    if re.search(pattern, file_path, re.IGNORECASE):
        sys.exit(0)

# Check protected patterns
for pattern, reason in PROTECTED_PATTERNS:
    if re.search(pattern, file_name, re.IGNORECASE) or re.search(
        pattern, file_path, re.IGNORECASE
    ):
        print("BLOCKED: Protected file modification.", file=sys.stderr)
        print("", file=sys.stderr)
        print(f"File: {file_path}", file=sys.stderr)
        print(f"Reason: {reason}", file=sys.stderr)
        print("", file=sys.stderr)
        print("If you need to edit this file:", file=sys.stderr)
        print("  1. Consider if it's truly necessary", file=sys.stderr)
        print("  2. Edit manually outside of Claude", file=sys.stderr)
        print("  3. Or request explicit override", file=sys.stderr)
        sys.exit(2)

sys.exit(0)
