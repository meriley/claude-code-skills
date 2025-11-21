#!/usr/bin/env bash
#
# Skill Review Automation Script
#
# Validates Claude Code skills against quality checklist
# Usage: ./review-automation.sh [skill-directory]
#        ./review-automation.sh --all (review all skills)
#
# Exit codes:
#   0 - All checks passed
#   1 - Blockers found
#   2 - Critical issues found
#   3 - Major issues found
#   4 - Minor issues found

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
BLOCKER_COUNT=0
CRITICAL_COUNT=0
MAJOR_COUNT=0
MINOR_COUNT=0

# Arrays to store issues
declare -a BLOCKERS
declare -a CRITICALS
declare -a MAJORS
declare -a MINORS

# Helper functions
log_blocker() {
    BLOCKERS+=("$1")
    ((BLOCKER_COUNT++))
    echo -e "${RED}❌ BLOCKER:${NC} $1"
}

log_critical() {
    CRITICALS+=("$1")
    ((CRITICAL_COUNT++))
    echo -e "${RED}⚠️  CRITICAL:${NC} $1"
}

log_major() {
    MAJORS+=("$1")
    ((MAJOR_COUNT++))
    echo -e "${YELLOW}⚠️  MAJOR:${NC} $1"
}

log_minor() {
    MINORS+=("$1")
    ((MINOR_COUNT++))
    echo -e "${BLUE}ℹ️  MINOR:${NC} $1"
}

log_pass() {
    echo -e "${GREEN}✅${NC} $1"
}

log_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Check if skill directory is valid
check_skill_directory() {
    local skill_dir="$1"

    if [[ ! -d "$skill_dir" ]]; then
        echo -e "${RED}Error: Directory does not exist: $skill_dir${NC}"
        exit 1
    fi

    if [[ ! -f "$skill_dir/Skill.md" ]]; then
        log_blocker "Skill.md not found (must be capital S)"
        return 1
    fi

    return 0
}

# Check directory naming (gerund + kebab-case)
check_directory_naming() {
    local skill_dir="$1"
    local dir_name
    dir_name=$(basename "$skill_dir")

    echo ""
    echo "=== Checking Directory Naming ==="

    # Check kebab-case (lowercase with hyphens)
    if [[ ! "$dir_name" =~ ^[a-z]+(-[a-z]+)*$ ]]; then
        log_blocker "Directory name not kebab-case: $dir_name"
    else
        log_pass "Directory name is kebab-case: $dir_name"
    fi

    # Check gerund form (ends in -ing or common gerund patterns)
    if [[ "$dir_name" =~ ing$ ]] || [[ "$dir_name" =~ (processing|analyzing|managing|reviewing|writing|planning) ]]; then
        log_pass "Directory name uses gerund form: $dir_name"
    else
        log_major "Directory name should use gerund form (verb + -ing): $dir_name"
    fi
}

# Check frontmatter
check_frontmatter() {
    local skill_file="$1"

    echo ""
    echo "=== Checking Frontmatter ==="

    # Extract frontmatter
    local frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed '1d;$d')

    if [[ -z "$frontmatter" ]]; then
        log_blocker "No YAML frontmatter found"
        return 1
    fi

    # Check name field
    local name_field
    name_field=$(echo "$frontmatter" | grep -E "^name:" || echo "")

    if [[ -z "$name_field" ]]; then
        log_blocker "Frontmatter missing 'name' field"
    else
        local name_value
        name_value=$(echo "$name_field" | sed -E 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")

        # Check if kebab-case
        if [[ "$name_value" =~ ^[a-z]+(-[a-z]+)*$ ]]; then
            log_pass "Frontmatter name is kebab-case: $name_value"
        else
            log_blocker "Frontmatter name must be kebab-case (not Title Case): $name_value"
        fi
    fi

    # Check description field
    local desc_field
    desc_field=$(echo "$frontmatter" | grep -E "^description:" || echo "")

    if [[ -z "$desc_field" ]]; then
        log_blocker "Frontmatter missing 'description' field"
    else
        local desc_value
        desc_value=$(echo "$frontmatter" | sed -n '/^description:/,/^[a-z]/p' | sed '$d' | sed 's/^description:[[:space:]]*//')
        local desc_length=${#desc_value}

        if [[ $desc_length -eq 0 ]]; then
            log_blocker "Description is empty"
        elif [[ $desc_length -gt 1024 ]]; then
            log_critical "Description exceeds 1024 characters ($desc_length chars)"
        else
            log_pass "Description length OK ($desc_length chars)"
        fi

        # Check if third person (very basic check)
        if echo "$desc_value" | grep -qiE "\b(I|me|my|we|you|your)\b"; then
            log_major "Description may use first/second person (should be third person)"
        else
            log_pass "Description appears to be third person"
        fi
    fi

    # Check version field
    local version_field
    version_field=$(echo "$frontmatter" | grep -E "^version:" || echo "")

    if [[ -z "$version_field" ]]; then
        log_blocker "Frontmatter missing 'version' field"
    else
        local version_value
        version_value=$(echo "$version_field" | sed -E 's/^version:[[:space:]]*//')

        if [[ "$version_value" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            log_pass "Version follows SemVer: $version_value"
        else
            log_major "Version should follow SemVer (MAJOR.MINOR.PATCH): $version_value"
        fi
    fi
}

# Check file length
check_file_length() {
    local skill_file="$1"

    echo ""
    echo "=== Checking File Length ==="

    local line_count
    line_count=$(wc -l < "$skill_file")

    if [[ $line_count -lt 500 ]]; then
        log_pass "File length under 500 lines ($line_count lines)"
    elif [[ $line_count -lt 600 ]]; then
        log_minor "File length over 500 lines ($line_count lines) - consider progressive disclosure"
    else
        log_major "File length significantly over 500 lines ($line_count lines) - extract to REFERENCE.md"
    fi
}

# Check required sections
check_required_sections() {
    local skill_file="$1"

    echo ""
    echo "=== Checking Required Sections ==="

    # When to Use
    if grep -q "^## When to Use" "$skill_file"; then
        log_pass "Has 'When to Use' section"
    else
        log_critical "Missing 'When to Use' section"
    fi

    # When NOT to Use
    if grep -q "^## When NOT to Use" "$skill_file"; then
        log_pass "Has 'When NOT to Use' section"
    else
        log_major "Missing 'When NOT to Use' section"
    fi

    # Workflow
    if grep -q "^## Workflow" "$skill_file"; then
        log_pass "Has 'Workflow' section"
    else
        log_major "Missing 'Workflow' section"
    fi

    # Examples
    if grep -qE "^## Examples?$" "$skill_file"; then
        log_pass "Has 'Examples' section"
    else
        log_major "Missing 'Examples' section"
    fi
}

# Check for concrete examples (basic heuristic)
check_examples_quality() {
    local skill_file="$1"

    echo ""
    echo "=== Checking Examples Quality ==="

    # Count code blocks
    local code_block_count
    code_block_count=$(grep -c '```' "$skill_file" || echo "0")
    code_block_count=$((code_block_count / 2))  # Divide by 2 since each block has opening and closing

    if [[ $code_block_count -ge 2 ]]; then
        log_pass "Has $code_block_count code examples"
    elif [[ $code_block_count -eq 1 ]]; then
        log_major "Only 1 code example (need 2-3)"
    else
        log_critical "No code examples found"
    fi

    # Check for placeholder values (common anti-pattern)
    if grep -qE "your_file|your-file|placeholder|foo\.txt|example\.txt|your_" "$skill_file"; then
        log_minor "Possible placeholder values in examples (use realistic values)"
    fi
}

# Check reference file links
check_reference_links() {
    local skill_dir="$1"
    local skill_file="$skill_dir/Skill.md"

    echo ""
    echo "=== Checking Reference File Links ==="

    # Find all REFERENCE.md references
    local ref_mentions
    ref_mentions=$(grep -oE "REFERENCE\.md( Section [0-9]+)?" "$skill_file" || echo "")

    if [[ -z "$ref_mentions" ]]; then
        log_pass "No REFERENCE.md references (self-contained)"
        return 0
    fi

    # Check if REFERENCE.md exists
    if [[ ! -f "$skill_dir/REFERENCE.md" ]]; then
        log_blocker "Skill references REFERENCE.md but file does not exist"
        return 1
    fi

    log_pass "REFERENCE.md exists"

    # Check if referenced sections exist
    local section_refs
    section_refs=$(echo "$ref_mentions" | grep -oE "Section [0-9]+" | sort -u || echo "")

    if [[ -n "$section_refs" ]]; then
        while IFS= read -r ref; do
            if [[ -n "$ref" ]]; then
                local section_num
                section_num=$(echo "$ref" | grep -oE "[0-9]+")

                if grep -qE "^## Section $section_num:" "$skill_dir/REFERENCE.md"; then
                    log_pass "REFERENCE.md Section $section_num exists"
                else
                    log_blocker "REFERENCE.md Section $section_num referenced but not found"
                fi
            fi
        done <<< "$section_refs"
    fi
}

# Check test scenarios
check_test_scenarios() {
    local skill_dir="$1"

    echo ""
    echo "=== Checking Test Scenarios ==="

    if [[ -f "$skill_dir/test-scenarios.md" ]]; then
        log_pass "test-scenarios.md exists"

        # Check if it has content
        local line_count
        line_count=$(wc -l < "$skill_dir/test-scenarios.md")

        if [[ $line_count -lt 50 ]]; then
            log_minor "test-scenarios.md seems brief ($line_count lines)"
        else
            log_pass "test-scenarios.md has substantial content ($line_count lines)"
        fi
    else
        log_critical "Missing test-scenarios.md (required for testing validation)"
    fi
}

# Generate summary report
generate_summary() {
    local skill_dir="$1"
    local dir_name
    dir_name=$(basename "$skill_dir")

    echo ""
    echo "======================================"
    echo "Review Summary: $dir_name"
    echo "======================================"
    echo ""

    echo "Issue Count:"
    echo "  BLOCKER:  $BLOCKER_COUNT"
    echo "  CRITICAL: $CRITICAL_COUNT"
    echo "  MAJOR:    $MAJOR_COUNT"
    echo "  MINOR:    $MINOR_COUNT"
    echo ""

    # Determine status
    local status="PASS"
    local exit_code=0

    if [[ $BLOCKER_COUNT -gt 0 ]]; then
        status="FAIL"
        exit_code=1
    elif [[ $CRITICAL_COUNT -gt 0 ]]; then
        status="FAIL"
        exit_code=2
    elif [[ $MAJOR_COUNT -gt 0 ]]; then
        status="NEEDS WORK"
        exit_code=3
    elif [[ $MINOR_COUNT -gt 0 ]]; then
        status="PASS (with minor issues)"
        exit_code=4
    fi

    echo "Overall Status: $status"
    echo ""

    # Priority actions
    if [[ $BLOCKER_COUNT -gt 0 ]]; then
        echo "Priority Actions (BLOCKER issues must be fixed):"
        for issue in "${BLOCKERS[@]}"; do
            echo "  - $issue"
        done
        echo ""
    fi

    if [[ $CRITICAL_COUNT -gt 0 ]]; then
        echo "Critical Actions:"
        for issue in "${CRITICALS[@]}"; do
            echo "  - $issue"
        done
        echo ""
    fi

    return $exit_code
}

# Main review function
review_skill() {
    local skill_dir="$1"
    local dir_name
    dir_name=$(basename "$skill_dir")

    echo ""
    echo "======================================"
    echo "Reviewing Skill: $dir_name"
    echo "======================================"

    # Reset counters
    BLOCKER_COUNT=0
    CRITICAL_COUNT=0
    MAJOR_COUNT=0
    MINOR_COUNT=0
    BLOCKERS=()
    CRITICALS=()
    MAJORS=()
    MINORS=()

    # Run checks
    check_skill_directory "$skill_dir" || return 1

    check_directory_naming "$skill_dir"
    check_frontmatter "$skill_dir/Skill.md"
    check_file_length "$skill_dir/Skill.md"
    check_required_sections "$skill_dir/Skill.md"
    check_examples_quality "$skill_dir/Skill.md"
    check_reference_links "$skill_dir"
    check_test_scenarios "$skill_dir"

    # Generate summary
    generate_summary "$skill_dir"
    return $?
}

# Review all skills
review_all_skills() {
    local skills_dir="${HOME}/.claude/skills"
    local total_skills=0
    local pass_count=0
    local needs_work_count=0
    local fail_count=0

    echo "Reviewing all skills in $skills_dir"
    echo ""

    for skill_dir in "$skills_dir"/*; do
        if [[ -d "$skill_dir" && -f "$skill_dir/Skill.md" ]]; then
            ((total_skills++))

            review_skill "$skill_dir"
            local result=$?

            if [[ $result -eq 0 || $result -eq 4 ]]; then
                ((pass_count++))
            elif [[ $result -eq 3 ]]; then
                ((needs_work_count++))
            else
                ((fail_count++))
            fi

            echo ""
            echo "--------------------------------------"
        fi
    done

    echo ""
    echo "======================================"
    echo "All Skills Review Summary"
    echo "======================================"
    echo ""
    echo "Total Skills: $total_skills"
    echo "  PASS:       $pass_count"
    echo "  NEEDS WORK: $needs_work_count"
    echo "  FAIL:       $fail_count"
    echo ""

    if [[ $fail_count -gt 0 ]]; then
        echo "Status: Skills require attention (${fail_count} failing)"
        return 1
    elif [[ $needs_work_count -gt 0 ]]; then
        echo "Status: Some skills need improvement (${needs_work_count} need work)"
        return 3
    else
        echo "Status: All skills passing!"
        return 0
    fi
}

# Main script
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <skill-directory>"
        echo "       $0 --all"
        echo ""
        echo "Examples:"
        echo "  $0 ~/.claude/skills/processing-pdfs"
        echo "  $0 --all"
        exit 1
    fi

    if [[ "$1" == "--all" ]]; then
        review_all_skills
        exit $?
    else
        review_skill "$1"
        exit $?
    fi
}

main "$@"
