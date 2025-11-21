---
allowed-tools: Bash(gh:*, git:*), Read, Grep, Glob, Task
argument-hint: <PR number or URL>
description: Review a GitHub pull request
---

# GitHub PR Review

You are performing a comprehensive code review of a GitHub pull request.

## Step 1: Parse PR Argument

The user must provide a PR number or URL as an argument.

**Expected formats**:
- `123` - PR number in current repo
- `#123` - PR number with # prefix
- `https://github.com/owner/repo/pull/123` - Full PR URL
- `owner/repo#123` - Repo and PR number

If no argument provided, show error and usage:
```
Error: PR number or URL required

Usage:
  /review-pr 123
  /review-pr #123
  /review-pr https://github.com/owner/repo/pull/123
  /review-pr owner/repo#123
```

## Step 2: Fetch PR Details

Use GitHub CLI to get PR information:

```bash
!gh pr view [PR_NUMBER] --json number,title,state,author,headRefName,baseRefName,body,additions,deletions,changedFiles,labels
!gh pr diff [PR_NUMBER] --color=never
!gh pr checks [PR_NUMBER]
```

Extract:
- PR number and title
- Author
- Source branch → Target branch
- PR description
- Files changed count
- Lines added/removed
- CI/CD check status
- Labels (if any)

Show user a summary:
```
═══════════════════════════════════════════════════════════════
                    PULL REQUEST REVIEW
═══════════════════════════════════════════════════════════════

PR #XXX: [Title]
Author: @[author]
Branch: [head] → [base]

Status: [Open/Closed/Merged]
Files changed: XXX
Lines: +XXX -XXX

Labels: [label1, label2, ...]
CI/CD: [✅ Passing / ⚠️  Pending / ❌ Failed]
```

## Step 3: Analyze Changed Files

Get the list of changed files:

```bash
!gh pr view [PR_NUMBER] --json files --jq '.files[].path'
!gh pr diff [PR_NUMBER] --name-only
```

Categorize files by type:
- Source files (.ts, .js, .go, .py)
- Test files (*test*, *spec*)
- Configuration files (*.json, *.yaml, *.yml)
- Documentation files (*.md)
- Other

## Step 4: Detect Project Language

Based on changed files, determine project type:

```bash
!ls -1 package.json go.mod requirements.txt Cargo.toml 2>/dev/null | head -1
!echo "[Changed files]" | grep -E "\.(ts|tsx)$" | wc -l
!echo "[Changed files]" | grep -E "\.go$" | wc -l
!echo "[Changed files]" | grep -E "\.py$" | wc -l
```

Identify:
- Primary language (TypeScript/Go/Python/Rust)
- GraphQL presence (*.graphql, *resolver*)
- Framework (React, Vue, Express, etc.)

## Step 5: Check for Review Checklist

Search PR description for review checklist items:

Look for common checklist items:
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] Security considerations reviewed
- [ ] Performance impact assessed

Flag if important items are unchecked.

## Step 6: Invoke Appropriate Reviewer Agent

Based on project language, invoke the specialized reviewer agent:

### For TypeScript/JavaScript Projects:

Use Task tool with `subagent_type=hermes-code-reviewer`:

```
Task(
  subagent_type: "hermes-code-reviewer",
  description: "Review GitHub PR #[NUMBER]",
  prompt: "Perform a comprehensive code review of GitHub PR #[NUMBER].

  PR Details:
  - Title: [title]
  - Author: @[author]
  - Branch: [head] → [base]
  - Files changed: XXX
  - Lines: +XXX -XXX

  Changed files:
  [list all changed files]

  PR Description:
  [paste PR description]

  Review focus areas:

  P0 - CRITICAL:
  - Security vulnerabilities (XSS, injection, auth bypass)
  - Data integrity bugs
  - Race conditions
  - Memory leaks
  - Breaking API changes not documented

  P1 - HIGH:
  - N+1 query problems (missing DataLoader)
  - Performance issues
  - Error handling gaps
  - Type safety violations (any usage, missing branded types)
  - Missing runtime validation
  - Missing tests for new code
  - Incomplete documentation

  P2 - MEDIUM:
  - Code organization
  - Naming conventions
  - Comment quality
  - Test coverage gaps
  - Missing edge case tests

  For each changed file, provide:
  1. Summary of changes
  2. Issues found (grouped by P0/P1/P2)
  3. Code snippets with specific line references
  4. Suggested improvements

  Generate PULL REQUEST REVIEW:

  ## Executive Summary
  - Overall assessment: [Approve / Request Changes / Comment]
  - P0 issues: X (BLOCK MERGE)
  - P1 issues: X (SHOULD FIX)
  - P2 issues: X (SUGGESTIONS)

  ## Detailed Review by File
  [For each file...]

  ## Review Decision
  [Final recommendation with reasoning]"
)
```

### For Go Projects:

Use Task tool with `subagent_type=go-code-reviewer`:

```
Task(
  subagent_type: "go-code-reviewer",
  description: "Review GitHub PR #[NUMBER]",
  prompt: "Perform a comprehensive code review of GitHub PR #[NUMBER].

  PR Details:
  - Title: [title]
  - Author: @[author]
  - Branch: [head] → [base]
  - Files changed: XXX
  - Lines: +XXX -XXX

  Changed files:
  [list all changed files]

  PR Description:
  [paste PR description]

  Review focus areas:

  P0 - CRITICAL:
  - Security vulnerabilities
  - Data race conditions
  - Resource leaks (goroutines, connections, files)
  - Panic usage outside initialization
  - Breaking API changes not documented

  P1 - HIGH:
  - Error handling (errors not wrapped with %w, missing context)
  - Control flow violations (deep nesting, missing early returns)
  - Missing nil checks
  - Inefficient algorithms
  - Missing synchronization
  - Missing tests for new code

  P2 - MEDIUM:
  - Code organization
  - Comment quality
  - Naming conventions
  - Test coverage gaps

  For each changed file, provide:
  1. Summary of changes
  2. Issues found (grouped by P0/P1/P2)
  3. Code snippets with specific line references
  4. Suggested improvements

  Generate PULL REQUEST REVIEW:

  ## Executive Summary
  - Overall assessment: [Approve / Request Changes / Comment]
  - P0 issues: X (BLOCK MERGE)
  - P1 issues: X (SHOULD FIX)
  - P2 issues: X (SUGGESTIONS)

  ## Detailed Review by File
  [For each file...]

  ## Review Decision
  [Final recommendation with reasoning]"
)
```

### For Python Projects:

Use Task tool with `subagent_type=general-purpose`:

```
Task(
  subagent_type: "general-purpose",
  description: "Review GitHub PR #[NUMBER]",
  prompt: "Perform a comprehensive code review of GitHub PR #[NUMBER].

  [Similar structure to TypeScript/Go reviews but with Python-specific concerns:
  - SQL injection, path traversal
  - Exception handling
  - Type hints
  - PEP 8 compliance
  - etc.]"
)
```

## Step 7: Check CI/CD Status

Analyze CI/CD check results:

```bash
!gh pr checks [PR_NUMBER] --watch=false
```

Flag if:
- Any checks are failing
- Tests are not run
- Linting is failing
- Coverage dropped

## Step 8: Generate Review Summary

After agent completes review, provide formatted output:

```
═══════════════════════════════════════════════════════════════
                  PULL REQUEST REVIEW SUMMARY
═══════════════════════════════════════════════════════════════

PR #XXX: [Title]
Author: @[author]
Branch: [head] → [base]

───────────────────────────────────────────────────────────────
                    REVIEW ASSESSMENT
───────────────────────────────────────────────────────────────

Overall Decision: APPROVE / REQUEST CHANGES / COMMENT

P0 Issues (Blocking): XXX
P1 Issues (Should Fix): XXX
P2 Issues (Suggestions): XXX

CI/CD Status: [✅ All Passing / ⚠️  Some Pending / ❌ Some Failed]

[If CI/CD failed]
⚠️  CI/CD Checks:
- [Check name]: ❌ Failed
- ...

───────────────────────────────────────────────────────────────
                    DETAILED FINDINGS
───────────────────────────────────────────────────────────────

[Agent's detailed review output here]

───────────────────────────────────────────────────────────────
                    REVIEW CHECKLIST
───────────────────────────────────────────────────────────────

Code Quality:
- [✅/❌] No security vulnerabilities
- [✅/❌] No data integrity issues
- [✅/❌] No performance regressions
- [✅/❌] Follows language best practices
- [✅/❌] Error handling is complete

Testing:
- [✅/❌] Tests added for new code
- [✅/❌] Tests pass (CI/CD)
- [✅/❌] Coverage meets threshold (90%+)
- [✅/❌] Edge cases covered

Documentation:
- [✅/❌] PR description is complete
- [✅/❌] Breaking changes documented
- [✅/❌] Code comments where needed
- [✅/❌] README updated (if applicable)

───────────────────────────────────────────────────────────────
                    RECOMMENDATION
───────────────────────────────────────────────────────────────

[If APPROVE]
✅ APPROVE

This PR is well-implemented and ready to merge.

Minor suggestions (P2):
- [List P2 suggestions if any]

Great work! ✅

[If REQUEST CHANGES]
❌ REQUEST CHANGES

This PR has issues that must be addressed before merging.

BLOCKING ISSUES (P0):
1. [Issue with file:line reference]
2. ...

SHOULD FIX (P1):
1. [Issue with file:line reference]
2. ...

Please address the blocking issues and update the PR.

[If COMMENT]
💬 COMMENT

This PR looks good overall with some suggestions for improvement.

SHOULD FIX (P1):
1. [Issue with file:line reference]
2. ...

SUGGESTIONS (P2):
1. [Suggestion]
2. ...

Consider addressing P1 issues before merging.

═══════════════════════════════════════════════════════════════
```

## Step 9: Provide Next Steps

```
Review complete. Next steps:

1. Post review comments to GitHub:
   gh pr review [PR_NUMBER] --[approve|request-changes|comment] --body "[summary]"

2. Leave inline comments:
   gh pr comment [PR_NUMBER] --body "[comment]"

3. View PR in browser:
   gh pr view [PR_NUMBER] --web

Would you like me to post this review to GitHub?
```

## Notes

- Requires GitHub CLI (`gh`) installed and authenticated
- Works with any GitHub repository (public or private)
- Can review PRs from other repositories using owner/repo#number format
- Does NOT automatically post review comments (requires user approval)
- Invokes specialized reviewer agents based on project language
- Provides actionable feedback with file:line references
- Checks CI/CD status and flags failures
- Generates structured review format suitable for GitHub
