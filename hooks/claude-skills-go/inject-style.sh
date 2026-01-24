#!/usr/bin/env bash
# inject-style.sh - Inject relevant style rules before file write operations
#
# Usage: inject-style.sh <file_path>
#
# Outputs skill content to stdout for Claude to consider during writes.
# The resolver handles all skill resolution including core skills,
# so we only need to call the resolver (which deduplicates).

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip silently if no file path or not a Go file
if [[ -z "$FILE_PATH" ]] || [[ "${FILE_PATH##*.}" != "go" ]]; then
    exit 0
fi

# Determine script directory and skills directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/skills/claude-skills-go"

# Function to safely cat a file if it exists
cat_if_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "---"
        echo "# $(basename "$file" .md)"
        echo "---"
        cat "$file"
        echo ""
    fi
}

# Run resolver to get all applicable skills (includes core via manifest "always")
if [[ -f "$SKILLS_DIR/resolve.py" ]]; then
    while IFS= read -r skill_file; do
        cat_if_exists "$skill_file"
    done < <(uv run "$SKILLS_DIR/resolve.py" "$FILE_PATH" 2>/dev/null || true)
fi

exit 0
