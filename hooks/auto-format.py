#!/usr/bin/env python3
"""
Hook: Auto-format files after Edit/Write.
Runs appropriate formatter based on file extension.
"""
import json
import sys
import os
import subprocess
import shutil

# Formatter configuration: extension -> (formatter_cmd, args)
FORMATTERS = {
    ".ts": ("npx", ["prettier", "--write"]),
    ".tsx": ("npx", ["prettier", "--write"]),
    ".js": ("npx", ["prettier", "--write"]),
    ".jsx": ("npx", ["prettier", "--write"]),
    ".json": ("npx", ["prettier", "--write"]),
    ".css": ("npx", ["prettier", "--write"]),
    ".scss": ("npx", ["prettier", "--write"]),
    ".md": ("npx", ["prettier", "--write"]),
    ".yaml": ("npx", ["prettier", "--write"]),
    ".yml": ("npx", ["prettier", "--write"]),
    ".go": ("gofmt", ["-w"]),
    ".py": ("black", []),
}

# Files/paths to skip
SKIP_PATTERNS = [
    "node_modules",
    ".git",
    "vendor",
    "__pycache__",
    ".next",
    "dist",
    "build",
]

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON input: {e}", file=sys.stderr)
    sys.exit(1)

tool_name = input_data.get("tool_name", "")
file_path = input_data.get("tool_input", {}).get("file_path", "")

# Only process Edit and Write tool results
if tool_name not in ("Edit", "Write") or not file_path:
    sys.exit(0)

# Skip certain paths
for pattern in SKIP_PATTERNS:
    if pattern in file_path:
        sys.exit(0)

# Check if file exists
if not os.path.exists(file_path):
    sys.exit(0)

# Get file extension
_, ext = os.path.splitext(file_path)
ext = ext.lower()

# Check if we have a formatter for this extension
if ext not in FORMATTERS:
    sys.exit(0)

formatter_cmd, args = FORMATTERS[ext]

# Check if formatter is available
if not shutil.which(formatter_cmd):
    # Formatter not installed, skip silently
    sys.exit(0)

# Run formatter
try:
    cmd = [formatter_cmd] + args + [file_path]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=30
    )

    if result.returncode == 0:
        print(f"Formatted: {file_path}")
    else:
        # Formatter failed, but don't block
        print(f"Format warning: {result.stderr}", file=sys.stderr)

except subprocess.TimeoutExpired:
    print(f"Format timeout: {file_path}", file=sys.stderr)
except Exception as e:
    print(f"Format error: {e}", file=sys.stderr)

# Always exit successfully - formatting is best-effort
sys.exit(0)
