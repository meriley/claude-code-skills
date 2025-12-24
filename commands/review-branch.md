---
allowed-tools: Bash(git:*), Read, Grep, Glob, Task
argument-hint: [quick|standard|deep]
description: Review current branch changes against origin/main or origin/master
---

# Code Review: Current Branch vs origin/main

You are performing a comprehensive code review of changes in the current branch compared to the base branch (origin/main or origin/master).

## Step 1: Detect Base Branch and Current Branch

Execute these commands to determine the base branch:

```bash
!git rev-parse --verify origin/main 2>/dev/null && echo "origin/main exists" || echo "origin/main not found"
!git rev-parse --verify origin/master 2>/dev/null && echo "origin/master exists" || echo "origin/master not found"
!git branch --show-current
```

Based on the results, set BASE_BRANCH to either `origin/main` or `origin/master` (whichever exists).

## Step 2: Get Changed Files and Summary

Execute these commands to understand the scope of changes:

```bash
!git diff --name-only ${BASE_BRANCH}...HEAD
!git diff --stat ${BASE_BRANCH}...HEAD
!git log ${BASE_BRANCH}...HEAD --oneline
```

## Step 3: Detect Project Language

Execute this command to detect the project type:

```bash
!ls -1 package.json go.mod requirements.txt setup.py Cargo.toml 2>/dev/null | head -1
```

Based on the detected files:
- `package.json` → TypeScript/JavaScript project
- `go.mod` → Go project
- `requirements.txt` or `setup.py` → Python project
- `Cargo.toml` → Rust project

## Step 4: Determine Review Depth

The user may have specified a review depth argument: `quick`, `standard`, or `deep`.

- **quick**: Focus on P0 issues only (security, bugs, breaking changes)
- **standard**: P0 + P1 issues (performance, maintainability, best practices)
- **deep**: P0 + P1 + P2 issues (style, documentation, suggestions)

If no argument provided, default to `standard`.

## Step 4.5: Detect File Types for Specialized Reviews

Execute these commands to detect which specialized review skills should be invoked:

```bash
# Save changed files list for reuse
CHANGED_FILES=$(git diff --name-only ${BASE_BRANCH}...HEAD)

# Check for Playwright test files
echo "$CHANGED_FILES" | grep -E "\.spec\.ts$|\.test\.ts$|playwright" && echo "PLAYWRIGHT_TESTS_FOUND=true"

# Check for React/Mantine component files (TSX)
echo "$CHANGED_FILES" | grep -E "\.tsx$" && echo "TSX_COMPONENTS_FOUND=true"

# Check for Helm chart files
echo "$CHANGED_FILES" | grep -E "charts/|helm/|Chart\.yaml|values\.yaml|templates/" && echo "HELM_CHARTS_FOUND=true"

# Check for Claude Code skill files
echo "$CHANGED_FILES" | grep -E "skills/.*\.(md|MD)$" && echo "SKILL_FILES_FOUND=true"

# Check for Casbin authorization files
echo "$CHANGED_FILES" | grep -E "casbin|policy\.csv|model\.conf" && echo "CASBIN_FILES_FOUND=true"

# Check for Cursor rules files
echo "$CHANGED_FILES" | grep -E "\.mdc$" && echo "CURSOR_RULES_FOUND=true"

# Check for PRD/spec documentation files
echo "$CHANGED_FILES" | grep -iE "prd|spec|requirements" | grep -E "\.md$" && echo "SPEC_DOCS_FOUND=true"
```

Track which specialized reviews are needed based on the detection results.

## Step 5: Invoke Appropriate Reviewer Agent

Based on the project language detected, invoke the appropriate specialized reviewer agent:

### For TypeScript/JavaScript Projects:

Use the Task tool with `subagent_type=hermes-code-reviewer`:

```
Task(
  subagent_type: "hermes-code-reviewer",
  description: "Review TypeScript branch changes",
  prompt: "Perform a [depth] code review of all changes between ${BASE_BRANCH}...HEAD. Focus on:

  P0 - CRITICAL:
  - Security vulnerabilities (XSS, injection, auth bypass)
  - Data integrity bugs
  - Race conditions
  - Memory leaks
  - Breaking API changes

  P1 - HIGH:
  - N+1 query problems (missing DataLoader)
  - Performance issues
  - Error handling gaps
  - Type safety violations (any usage, missing branded types)
  - Missing runtime validation

  P2 - MEDIUM:
  - Code organization
  - Documentation gaps
  - Test coverage gaps

  For each file changed, provide:
  1. Summary of changes
  2. Issues found (grouped by priority)
  3. Code snippets showing the problem
  4. Specific fix recommendations

  Generate an executive summary at the end with:
  - Total P0/P1/P2 issues
  - Must-fix-before-merge items (P0)
  - Recommended fixes (P1)
  - Suggestions (P2)"
)
```

### For Go Projects:

Use the Task tool with `subagent_type=go-code-reviewer`:

```
Task(
  subagent_type: "go-code-reviewer",
  description: "Review Go branch changes",
  prompt: "Perform a [depth] code review of all changes between ${BASE_BRANCH}...HEAD. Focus on:

  P0 - CRITICAL:
  - Security vulnerabilities
  - Data race conditions
  - Resource leaks (goroutines, connections, files)
  - Panic usage outside initialization
  - Breaking API changes

  P1 - HIGH:
  - Error handling (errors not wrapped with %w, missing context)
  - Control flow violations (deep nesting, missing early returns)
  - Missing nil checks
  - Inefficient algorithms
  - Missing synchronization

  P2 - MEDIUM:
  - Code organization
  - Comment quality
  - Test coverage gaps
  - Naming conventions

  For each file changed, provide:
  1. Summary of changes
  2. Issues found (grouped by priority)
  3. Code snippets showing the problem
  4. Specific fix recommendations

  Generate an executive summary at the end with:
  - Total P0/P1/P2 issues
  - Must-fix-before-merge items (P0)
  - Recommended fixes (P1)
  - Suggestions (P2)"
)
```

### For Python Projects:

Use the Task tool with `subagent_type=general-purpose`:

```
Task(
  subagent_type: "general-purpose",
  description: "Review Python branch changes",
  prompt: "Perform a [depth] code review of all changes between ${BASE_BRANCH}...HEAD. Focus on:

  P0 - CRITICAL:
  - Security vulnerabilities (SQL injection, XSS, path traversal)
  - Data integrity bugs
  - Resource leaks
  - Breaking API changes

  P1 - HIGH:
  - Exception handling gaps
  - Performance issues (N+1 queries, inefficient algorithms)
  - Type hint violations
  - Missing input validation

  P2 - MEDIUM:
  - Code organization (PEP 8)
  - Documentation gaps
  - Test coverage gaps

  For each file changed, provide:
  1. Summary of changes
  2. Issues found (grouped by priority)
  3. Code snippets showing the problem
  4. Specific fix recommendations

  Generate an executive summary at the end with:
  - Total P0/P1/P2 issues
  - Must-fix-before-merge items (P0)
  - Recommended fixes (P1)
  - Suggestions (P2)"
)
```

## Step 5.5: Invoke Specialized Review Skills

Based on the file types detected in Step 4.5, invoke additional specialized review skills. These run IN ADDITION to the language-specific reviewer from Step 5.

**IMPORTANT:** Invoke these skills based on the detected file types. Multiple skills may run for a single branch review.

### If Playwright Test Files Found (`PLAYWRIGHT_TESTS_FOUND`):

Invoke the `playwright-reviewing` skill for ALL changed test files:

```
Review Playwright E2E tests for:
- CRITICAL: Mocked application APIs (page.route('/api...'))
- CRITICAL: Skipped tests (test.skip, .skip(), test.fixme)
- HIGH: waitForTimeout() usage (explicit timeouts)
- HIGH: CSS class selectors (.locator('.classname'))
- HIGH: Manual assertions (isVisible()).toBe(true))
- MEDIUM: selectOption() on Mantine components
- Check web-first assertions usage
- Verify test isolation patterns
```

### If TSX Component Files Found (`TSX_COMPONENTS_FOUND`):

Invoke the `mantine-reviewing` skill for ALL changed TSX files:

```
Review Mantine UI components for:
- CRITICAL: Missing aria-labels on ActionIcon
- CRITICAL: Nested interactive elements (Button inside Accordion.Control)
- HIGH: Tooltip on disabled elements (need data-disabled pattern)
- HIGH: ActionIcon.Group with wrapped children
- HIGH: Inline styles prop objects (performance)
- MEDIUM: Incorrect Styles API usage (!important hacks)
- MEDIUM: Hardcoded colors (dark mode compatibility)
- Check Select vs Autocomplete choice
- Verify @mantine/form usage for forms
```

### If Helm Chart Files Found (`HELM_CHARTS_FOUND`):

Invoke the `helm-chart-review` skill for ALL changed chart files:

```
Review Helm charts for:
- CRITICAL: Security contexts missing or disabled
- CRITICAL: Secrets in plain text values
- HIGH: Missing resource limits/requests
- HIGH: Missing health probes
- MEDIUM: Template syntax issues
- MEDIUM: Values.yaml structure
- Check ArgoCD Application patterns
- Verify testing hooks
```

### If Skill Files Found (`SKILL_FILES_FOUND`):

Invoke the `skill-review` skill for ALL changed skill files:

```
Review Claude Code skills for:
- Frontmatter completeness (name, description, version)
- Description quality (triggering accuracy)
- Content structure (sections, examples)
- Cross-references to related skills
- Testing/verification guidance
```

### If Casbin Files Found (`CASBIN_FILES_FOUND`):

Invoke the `reviewing-casbin` skill for ALL changed Casbin files:

```
Review Casbin authorization for:
- Model syntax correctness (RBAC/ABAC/RESTful)
- Policy syntax and coverage
- Adapter configuration patterns
- Middleware integration
- Performance considerations
```

### If Cursor Rules Found (`CURSOR_RULES_FOUND`):

Invoke the `cursor-rules-review` skill for ALL changed .mdc files:

```
Review Cursor rules for:
- Frontmatter structure
- Glob pattern correctness
- Content quality and clarity
- Rule triggering accuracy
- File length and organization
```

### If Spec/PRD Docs Found (`SPEC_DOCS_FOUND`):

Invoke the appropriate documentation review skill:

```
For PRD files → prd-reviewing skill
For Feature specs → feature-spec-reviewing skill
For Technical specs → technical-spec-reviewing skill

Check for:
- Completeness of requirements
- Testability of acceptance criteria
- Technical feasibility
- Ambiguity and gaps
```

## Step 6: Generate Output

After ALL reviews complete (language-specific + specialized), provide a unified output:

### 6.1 Executive Summary

```
## Branch Review: [branch-name]

### Overview
- **Files Changed:** X files
- **Languages Detected:** [TypeScript/Go/Python/etc.]
- **Specialized Reviews Run:** [list of skills invoked]
- **Overall Status:** [🔴 Major Issues / 🟡 Needs Fixes / 🟢 Ready for Review]

### Issue Summary
| Priority | Language Review | Specialized Reviews | Total |
|----------|-----------------|---------------------|-------|
| P0 (Critical) | X | Y | Z |
| P1 (High) | X | Y | Z |
| P2 (Medium) | X | Y | Z |
```

### 6.2 Language-Specific Review Results

Include the full output from the language-specific reviewer (Step 5).

### 6.3 Specialized Review Results

For EACH specialized review that was invoked, include a separate section:

```
## Playwright E2E Test Review (if invoked)
[Output from playwright-reviewing skill]

## Mantine Component Review (if invoked)
[Output from mantine-reviewing skill]

## Helm Chart Review (if invoked)
[Output from helm-chart-review skill]

## Claude Code Skill Review (if invoked)
[Output from skill-review skill]

## Casbin Authorization Review (if invoked)
[Output from reviewing-casbin skill]

## Cursor Rules Review (if invoked)
[Output from cursor-rules-review skill]

## Documentation Review (if invoked)
[Output from prd-reviewing / feature-spec-reviewing / technical-spec-reviewing]
```

### 6.4 Consolidated Must-Fix Items (P0)

Aggregate ALL P0 issues from all reviews:

```
### Must Fix Before Merge (P0)

**From Language Review:**
- [ ] [Issue] - file:line

**From Playwright Review:**
- [ ] [Issue] - file:line

**From Mantine Review:**
- [ ] [Issue] - file:line

[etc. for each specialized review with P0 issues]
```

### 6.5 Recommended Fixes (P1)

Aggregate ALL P1 issues from all reviews.

### 6.6 Suggestions (P2)

Aggregate ALL P2 issues from all reviews.

### 6.7 Next Steps

Based on the consolidated findings:

- **If ANY P0 issues:** "🔴 Fix P0 issues before requesting review"
- **If only P1 issues:** "🟡 Address P1 issues, then ready for review"
- **If only P2 issues:** "🟢 Consider P2 suggestions, ready for review"
- **If no issues:** "✅ Code looks good, ready for review"

## Notes

- This command does NOT create commits or modify files
- This is a local review only (no GitHub API calls)
- The agent will read all changed files automatically
- Review results are displayed in the terminal
- Multiple specialized reviews may run for a single branch
- Specialized reviews complement (don't replace) language-specific reviews
