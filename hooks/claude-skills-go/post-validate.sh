#!/usr/bin/env bash
# post-validate.sh - Run linters after file write operations
#
# Usage: post-validate.sh <file_path>
#
# Runs appropriate linter based on file extension.
# On failure, outputs relevant skills and exits non-zero.

set -uo pipefail

# Read JSON input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip silently if no file path
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Determine script directory and skills directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/skills/claude-skills-go"

# Function to output skills on lint failure
output_skills_on_failure() {
    # Write to stderr so Claude Code sees the failure reason
    echo "Lint check failed for: $FILE_PATH" >&2

    echo "---"
    echo "# Lint Failure - Review Style Guidelines"
    echo "---"

    # Output core skills
    if [[ -d "$SKILLS_DIR/core" ]]; then
        for skill_file in "$SKILLS_DIR/core"/*.md; do
            if [[ -f "$skill_file" ]]; then
                cat "$skill_file"
                echo ""
            fi
        done
    fi

    # Output resolved skills
    if [[ -f "$SKILLS_DIR/resolve.py" ]]; then
        while IFS= read -r skill_file; do
            if [[ -f "$skill_file" ]]; then
                cat "$skill_file"
                echo ""
            fi
        done < <(uv run "$SKILLS_DIR/resolve.py" "$FILE_PATH" 2>/dev/null || true)
    fi
}

# Get file extension
EXT="${FILE_PATH##*.}"

# Run appropriate linter based on extension
case "$EXT" in
    py|pyi)
        # Python: use ruff via uvx
        if command -v uvx &>/dev/null; then
            if ! uvx ruff check "$FILE_PATH" 2>&1; then
                output_skills_on_failure
                exit 1
            fi
        fi
        ;;

    ts|tsx|js|jsx)
        # TypeScript/JavaScript: use eslint if available
        if command -v eslint &>/dev/null; then
            if ! eslint "$FILE_PATH" 2>&1; then
                output_skills_on_failure
                exit 1
            fi
        elif command -v npx &>/dev/null && [[ -f "package.json" ]]; then
            # Try npx eslint if in a node project
            if ! npx eslint "$FILE_PATH" 2>&1; then
                output_skills_on_failure
                exit 1
            fi
        fi
        ;;

    go)
        # Go: use project's golangci-lint config, fallback to go vet
        # RMS repos define their own .golangci.yml with gofumpt, goimports, errorlint, etc.

        # Find project root (where .golangci.yml or go.mod lives)
        FILE_DIR="$(dirname "$FILE_PATH")"
        PROJECT_ROOT="$FILE_DIR"
        while [[ "$PROJECT_ROOT" != "/" ]]; do
            if [[ -f "$PROJECT_ROOT/.golangci.yml" ]] || \
               [[ -f "$PROJECT_ROOT/.golangci.yaml" ]] || \
               [[ -f "$PROJECT_ROOT/go.mod" ]]; then
                break
            fi
            PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
        done

        if command -v golangci-lint &>/dev/null && [[ "$PROJECT_ROOT" != "/" ]]; then
            # Run from project root so golangci-lint picks up project config
            #
            # Step 1: Auto-fix formatting (gofumpt, goimports) using project config
            # This matches how RMS repos handle formatting locally before commits
            (cd "$PROJECT_ROOT" && golangci-lint run --fix "$FILE_PATH" 2>/dev/null) || true

            # Step 2: Check for remaining lint issues
            # Formatting is already fixed, so failures here are real code issues
            if ! (cd "$PROJECT_ROOT" && golangci-lint run "$FILE_PATH" 2>&1); then
                output_skills_on_failure
                exit 1
            fi
        elif command -v go &>/dev/null; then
            # Fallback to go vet if golangci-lint not installed or no project found
            if ! go vet "$FILE_PATH" 2>&1; then
                output_skills_on_failure
                exit 1
            fi
        fi
        ;;

    *)
        # Unknown extension - skip gracefully
        ;;
esac

# Success
exit 0
