---
name: GitHub PR Description Writer
description: Writes and verifies GitHub PR descriptions with zero fabrication. Discovers PR templates, generates descriptions from git changes, applies documentation verification.
version: 1.0.0
---

# ⚠️ MANDATORY: PR Description Writer Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before creating pull requests (invoked by create-pr skill)
2. When reviewing/updating PR descriptions
3. Before merging PRs without descriptions
4. When user requests "update PR description"

**This skill is MANDATORY because:**
- Communicates changes clearly to reviewers (CRITICAL)
- Prevents fabricated claims about changes (ZERO TOLERANCE)
- Ensures test coverage metrics are accurate
- Links related issues and PRs
- Maintains quality PR history

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Claiming features/changes that don't exist in diff (FABRICATION)
- Reporting coverage numbers that don't match test output
- Describing changes not actually in the code
- Missing breaking changes documentation (if applicable)

**P1 Violations (High - Quality Failure):**
- Missing test coverage information
- No links to related issues
- Vague change descriptions
- Missing related files/impacts
- Incomplete summary

**P2 Violations (Medium - Efficiency Loss):**
- Not following project PR template
- Unclear formatting
- Missing context about why changes were made

**Blocking Conditions:**
- EVERY claim must be verified against actual git diff
- EVERY coverage number must match test output
- EVERY change must be explained
- Breaking changes must be explicitly noted

---

## Purpose

Write GitHub pull request descriptions with zero fabrication tolerance. Discovers project PR templates, generates descriptions from git changes, applies technical documentation verification.

## Workflow (Abbreviated)

### Step 1: Discover PR Template
Check for `.github/pull_request_template.md` or similar in project.

### Step 2: Analyze Git Diff
```bash
git diff <base>...HEAD
git log <base>...HEAD --oneline
```

Extract actual changes made.

### Step 3: Identify Files Changed
List all modified files with change types (added/modified/deleted).

### Step 4: Write PR Description
- Summary (1-3 bullet points of ACTUAL changes)
- Test coverage (verified from test output)
- Related issues (from commit messages)
- Breaking changes (if any, explicit)
- Files modified

### Step 5: Verify Description
- Every claim matches actual diff
- Coverage numbers match test output
- No fabricated features
- All files mentioned exist in diff
- No marketing language

## PR Description Template

```markdown
## Summary
- [ACTUAL change 1 from diff]
- [ACTUAL change 2 from diff]
- [ACTUAL change 3 from diff]

## Changes
Describe actual implementation details from git diff.
Explain WHAT changed and WHY (from code analysis).

## Test Coverage
- Unit: [verified from test output]%
- E2E: [verified from test output] tests passed

## Related Issues
Closes #XXX (if issue mentioned in commits)

## Breaking Changes
[Only if actual breaking changes in diff]
- Old API: [from diff]
- New API: [from diff]
- Migration: [from code analysis]

## Checklist
- [x] Tests passing ([actual coverage]%)
- [x] Linters passing
- [x] Security scan passing
```

## Integration Points

Invoked by:
- **`create-pr`** - Generates PR description

## Anti-Patterns

### ❌ Anti-Pattern: Fabricating Changes

**Wrong approach:**
```
## Summary
- Added JWT authentication (change doesn't exist in diff)
- Implemented caching (only added one line)
```

**Correct approach:** Describe actual changes
```
## Summary
- Add JWT validation endpoint
- Refactor error handling in auth service
- Update test coverage for new middleware
```

---

### ❌ Anti-Pattern: Incorrect Coverage Numbers

**Wrong approach:**
```
Test coverage: 95%
(Actual output shows 87%)
```

**Correct approach:** Verify coverage
```
Test coverage: 87% (from jest output)
[Note: Below target - needs 3 additional tests]
```

---

## Success Criteria

PR description is complete when:
- ✅ All changes accurately described
- ✅ Coverage numbers verified from test output
- ✅ Related issues linked
- ✅ Breaking changes explicit (if any)
- ✅ Follows project PR template
- ✅ No fabricated claims
- ✅ All files mentioned exist in diff
- ✅ Clear and professional tone

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - pr-description-writer)
- GitHub PR best practices

**Related skills:**
- `create-pr` - Invokes this skill
- `api-documentation-verify` - Verification pattern
