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

## Step 6: Generate Output

After the agent completes the review, provide:

1. **Executive Summary**:
   - Total files changed
   - Total issues by priority (P0/P1/P2)
   - Overall assessment (Ready to merge / Needs fixes / Major issues)

2. **Must-Fix Items** (P0):
   - List all P0 issues with file references

3. **Recommended Fixes** (P1):
   - List all P1 issues with file references

4. **Suggestions** (P2):
   - List all P2 issues with file references

5. **Next Steps**:
   - If P0 issues: "Fix P0 issues before requesting review"
   - If only P1 issues: "Address P1 issues, then ready for review"
   - If only P2 issues: "Consider P2 suggestions, ready for review"
   - If no issues: "Code looks good, ready for review"

## Notes

- This command does NOT create commits or modify files
- This is a local review only (no GitHub API calls)
- The agent will read all changed files automatically
- Review results are displayed in the terminal
