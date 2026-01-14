---
name: pr-description-writer
description: Writes and verifies GitHub pull request descriptions with zero fabrication tolerance. Discovers project PR templates, generates descriptions from git changes, and applies technical documentation verification standards. Use when creating PR descriptions (automatically invoked by create-pr skill), verifying PR descriptions, updating PR descriptions after additional changes, discovering templates, or when user requests "write PR description" or "verify PR description".
version: 1.0.0
---

# PR Description Writer Skill

## Purpose

Write and verify GitHub pull request descriptions following project templates with zero fabrication tolerance. Ensures all claims are backed by actual code changes and applies technical documentation verification standards to prevent marketing language and unverified claims.

## Two Modes of Operation

### Create Mode (Default)

Generate new PR description from git changes:

- Analyze git diff and commit history
- Follow project PR template if found
- Verify all claims against actual changes
- Generate markdown for `gh pr create --body`

### Verify Mode

Audit existing PR description for accuracy:

- Compare description claims against git changes
- Flag fabricated features or unverified claims
- Identify marketing language
- Report verification findings

## Core Workflow

### Phase 1: Template Discovery (2-3 minutes)

**Locate PR template:**

```bash
# Search common locations
ls .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null
ls .github/pull_request_template.md 2>/dev/null
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
ls docs/pull_request_template.md 2>/dev/null
```

**Template locations (priority order)**:

1. `.github/PULL_REQUEST_TEMPLATE.md` (primary)
2. `.github/pull_request_template.md` (alternative casing)
3. `.github/PULL_REQUEST_TEMPLATE/*.md` (multiple templates)
4. `docs/pull_request_template.md` (less common)
5. Use TEMPLATE_DEFAULT.md if none found

**Parse template sections:**

- Identify required sections (Summary, Changes, Testing, etc.)
- Extract section headers and structure
- Note any special instructions or checklists
- Determine optional vs required fields

### Phase 2: Change Analysis (5-10 minutes)

**Gather git context:**

```bash
# Get file change statistics
git diff [base-branch]...HEAD --stat

# Get commit history
git log [base-branch]...HEAD --oneline --no-decorate

# Get detailed changes
git diff [base-branch]...HEAD

# Check for test changes
git diff [base-branch]...HEAD --name-only | grep -E "(test|spec)" || true
```

**Extract information:**

1. **Files Changed**
   - List of modified files
   - Components/modules affected
   - New files vs modified vs deleted

2. **Commit Messages**
   - Already verified by `safe-commit` skill
   - Extract main themes
   - Identify related issues (Closes #123)

3. **Type of Changes**
   - feat: New features
   - fix: Bug fixes
   - refactor: Code restructuring
   - docs: Documentation only
   - test: Test additions/changes
   - chore: Maintenance tasks

4. **Breaking Changes Detection**
   - API signature changes
   - Removed methods/functions
   - Changed configuration format
   - Dependency version changes

5. **Test Coverage**
   - New test files added
   - Modified test files
   - Coverage reports (if available from test output)

### Phase 3: Description Generation (5-10 minutes)

**Generate each template section with verification:**

#### Summary Section

```markdown
## Summary

- [Main change from commit messages]
- [Second major change from commits]
- [Third change if applicable]
```

**Verification**:

- [ ] All bullet points backed by commits
- [ ] No fabricated features not in git diff
- [ ] Clear, concise technical descriptions

#### Changes Section

```markdown
## Changes

[Technical paragraph explaining modifications]

**Files Modified**:

- `path/to/file1.ext` - [what changed]
- `path/to/file2.ext` - [what changed]

**Components Affected**:

- [Component 1]: [nature of change]
- [Component 2]: [nature of change]
```

**Verification**:

- [ ] All mentioned files exist in git diff
- [ ] All components accurately described
- [ ] No fabricated modifications
- [ ] Technical descriptions only (no marketing)

#### Testing Section

```markdown
## Testing

**Unit Tests**:

- Coverage: [X%] (if available from test output)
- New tests: [count] tests added
- Modified tests: [count] tests updated

**Integration Tests**:

- [Status or N/A]

**Manual Testing**:

- Tested [scenario] in [environment]
- Verified [behavior]

**Test Files Changed**:

- `path/to/test/file1.test.ext`
- `path/to/test/file2.spec.ext`
```

**Verification**:

- [ ] Coverage numbers from actual test output (not fabricated)
- [ ] Test files mentioned exist in git diff
- [ ] Manual testing claims are reasonable
- [ ] No unverified performance claims

#### Breaking Changes Section (Conditional)

````markdown
## Breaking Changes

### Change 1: [API Signature Change]

**Before**:

```[language]
[old signature from git diff]
```
````

**After**:

```[language]
[new signature from git diff]
```

**Migration**: [How to adapt existing code]

### Change 2: [Removed Method]

**Removed**: `MethodName()`
**Replacement**: Use `NewMethodName()` instead

````

**Verification**:
- [ ] All breaking changes verified in git diff
- [ ] Before/after signatures accurate
- [ ] Migration instructions provided
- [ ] Only include if truly breaking (not just additions)

#### Related Issues Section
```markdown
## Related Issues

Closes #123
Fixes #456
Relates to #789
````

**Verification**:

- [ ] Issue numbers extracted from commit messages
- [ ] Using correct keywords (Closes, Fixes, Relates to)
- [ ] Issue numbers are valid (optional GitHub API check)

#### Checklist Section

```markdown
## Checklist

- [x] Tests passing (coverage: X%)
- [x] Linters passing
- [x] Security scan passing
- [x] Documentation updated
- [x] No fabricated claims
- [x] No unverified performance numbers
- [ ] Reviewed by [reviewer] (unchecked for PR template)
```

**Verification**:

- [ ] Checkmarks reflect actual results from safe-commit
- [ ] Coverage number matches test output
- [ ] All pre-submission items checked
- [ ] Review items left unchecked (for reviewers)

### Phase 4: Verification (3-5 minutes)

**Run comprehensive verification checklist:**

```markdown
## PR Description Verification Checklist

### P0 - CRITICAL (Must Fix Before PR)

- [ ] All mentioned features exist in git diff
- [ ] All mentioned files exist in git diff output
- [ ] No fabricated methods or APIs
- [ ] No unverified performance claims ("10x faster")
- [ ] No fabricated timing numbers ("50ms → 5ms")
- [ ] Coverage numbers match actual test output (or not specified)

### P1 - HIGH (Should Fix)

- [ ] No marketing buzzwords (enterprise, blazing, advanced, robust)
- [ ] No decorative emojis in technical text
- [ ] No sales language ("cutting-edge", "revolutionary")
- [ ] Technical descriptions only
- [ ] Breaking changes accurately documented

### P2 - MEDIUM (Consider Fixing)

- [ ] All template sections populated
- [ ] Related issues correctly linked
- [ ] Checklist reflects actual status
- [ ] Consistent formatting
```

**Generate verification report:**

```markdown
### Verification Report

**Status**: ✅ PASSED / ⚠️ WARNINGS / ❌ FAILED

**Files Verified**: X files checked against git diff
**Claims Verified**: Y claims verified
**Issues Found**: Z issues

**P0 Issues (Must Fix)**:

- None

**P1 Issues (Should Fix)**:

- None

**P2 Issues (Consider)**:

- None

**Verification Date**: [timestamp]
```

### Phase 5: Output Generation (1-2 minutes)

**Generate final PR description:**

```markdown
[Populated template with all sections]

---

<!-- Verification metadata (optional - can be hidden in HTML comment) -->

Verification: All claims verified against git diff [commit-range]
Verification Date: [timestamp]
Files Analyzed: X files
Claims Verified: Y claims
```

## Template Sections Reference

### Standard Sections (Industry Best Practices 2025)

#### Required Sections

1. **Summary** - Brief overview (1-3 bullets)
2. **Changes** - Technical details of modifications
3. **Testing** - How changes were tested
4. **Related Issues** - Closes/Fixes/Relates to syntax
5. **Checklist** - Pre-submission verification

#### Conditional Sections

6. **Breaking Changes** - Only if backwards-incompatible
7. **Migration Guide** - If breaking changes exist
8. **Performance Impact** - Only with benchmark evidence

#### Optional Sections

9. **Screenshots** - For UI changes
10. **Security Considerations** - For security-related changes
11. **Deployment Notes** - Special deployment instructions
12. **Rollback Plan** - How to revert if needed

## Critical Verification Rules

### Zero Fabrication Policy (P0 - CRITICAL)

**NEVER fabricate:**

1. **Features** that don't exist in git diff
2. **Files** that aren't in the changeset
3. **Methods/APIs** that weren't modified
4. **Performance claims** without benchmark evidence
5. **Test coverage** numbers without test output
6. **Statistics** without actual measurements

**Example violations:**

```markdown
❌ BAD - Fabricated feature
"Added ToNodeAndEdges() method"
[Method doesn't exist in git diff - actually added ToNode() and ToEdges() separately]

✅ GOOD - Verified against git diff
"Added ToNode() and ToEdges() methods"
[Both methods verified in git diff]
```

### Performance Claims (P0 - CRITICAL)

**NEVER SAY (without benchmarks)**:

- "10x faster"
- "50ms → 5ms"
- "90% performance improvement"
- ANY specific numbers or multipliers

**ALWAYS ACCEPTABLE**:

- "Eliminates network overhead"
- "In-process execution"
- "Reduces database round-trips"
- "Single network call instead of multiple"
- "Batches operations to reduce queries"

**Example violations:**

```markdown
❌ BAD - Unverified performance claim
"Performance improved by 10x (50ms → 5ms per request)"
[No benchmarks provided, numbers fabricated]

✅ GOOD - Factual architectural statement
"Eliminates network overhead by using in-process function calls instead of RPC"
[Architectural fact verified in code]
```

### Marketing Language (P1 - HIGH)

**BANNED BUZZWORDS**:

- enterprise, advanced, robust, comprehensive, modern, rich
- first-class, powerful, seamless, cutting-edge, revolutionary
- blazing-fast, lightning-fast, world-class, state-of-the-art
- significantly, greatly, dramatically (without numbers)
- next-generation, innovative, sophisticated

**BANNED EMOJIS** (in technical text):

- 🏗️⚡📦🔗🔒📝🧪👉💡📚🔧📖🚀💯🔥🎉

**Example violations:**

```markdown
❌ BAD - Marketing language
"Enterprise-grade task management with blazing-fast performance 🚀"

✅ GOOD - Technical description
"Task entity management with CRUD operations using connection pooling"
```

### Code Reference Verification (P0 - CRITICAL)

**MUST verify:**

- All file paths mentioned exist in git diff
- All imports are actual paths (not fabricated)
- All method names match git diff
- All configuration options exist

**Example violations:**

```markdown
❌ BAD - Wrong import path
import "taskcore/converter"
[Actual path is "git.taservs.net/rcom/taskcore/converters"]

✅ GOOD - Verified import path
import "git.taservs.net/rcom/taskcore/converters"
[Path verified in git diff]
```

## Common Issues and Solutions

### Issue: Nil Pointer in Template Parsing

```markdown
Problem: Template has nested YAML front matter
Solution: Parse only markdown headers, ignore YAML
```

### Issue: Multiple PR Templates

```markdown
Problem: .github/PULL_REQUEST_TEMPLATE/ contains multiple files
Solution: Use default.md or ask user which template
```

### Issue: No Git History Available

```markdown
Problem: New repository or shallow clone
Solution: Require full git history, inform user
```

### Issue: Conflicting Commit Messages

```markdown
Problem: Commits say different things about same change
Solution: Analyze actual code changes, use most recent commit message
```

## Integration with Other Skills

### Invoked By:

- **create-pr** skill (Step 6: Generate PR Description)
- User (manual invocation)

### Invokes:

- None (uses git commands via Bash tool)

### Works With:

- **check-history** - Provides git context
- **api-documentation-verify** - Verification pattern reference
- **safe-commit** - Commit messages already verified

### Integration in create-pr Flow:

**Before** (current):

```
create-pr Step 6: Generate PR description (embedded logic)
```

**After** (new):

```
create-pr Step 6: Invoke pr-description-writer skill
  ├─> Input: base branch, commit range, template
  ├─> Process: Analyze, verify, generate
  └─> Output: Verified PR description markdown
```

## Example Usage

### Automatic Invocation (via create-pr)

```bash
User: "create a PR"
Assistant: [create-pr invokes pr-description-writer automatically]

# pr-description-writer executes:
# 1. Finds .github/PULL_REQUEST_TEMPLATE.md
# 2. Analyzes git diff main...feature-branch
# 3. Generates verified description
# 4. Returns to create-pr for gh pr create
```

### Manual Creation

```bash
User: "write a PR description for my changes"
Assistant: "I'll use pr-description-writer to create a verified PR description"

# Skill executes in create mode:
# 1. Discovers template
# 2. Analyzes current branch vs main
# 3. Generates description
# 4. Outputs markdown
```

### Verification Mode

```bash
User: "verify the PR description for #47"
Assistant: "I'll verify the PR description against actual changes"

# Skill executes in verify mode:
# 1. Fetches PR description from GitHub
# 2. Gets PR branch and diff
# 3. Verifies all claims
# 4. Reports findings
```

## Time Estimates

**Create Mode**:

- Small PR (1-5 files, 1-3 commits): 10-15 minutes
- Medium PR (5-15 files, 3-10 commits): 15-25 minutes
- Large PR (15+ files, 10+ commits): 25-40 minutes

**Verify Mode**:

- Review existing description: 5-10 minutes

## Success Criteria

A PR description is complete and verified when:

- ✅ All template sections populated accurately
- ✅ All claims verified against git diff
- ✅ No fabricated features or methods
- ✅ No unverified performance claims
- ✅ No fabricated timing numbers
- ✅ No marketing language or buzzwords
- ✅ Test coverage numbers match actual results (or not specified)
- ✅ All mentioned files exist in git diff
- ✅ Breaking changes documented accurately (if any)
- ✅ Related issues linked correctly
- ✅ Checklist reflects actual status
- ✅ Technical descriptions only
- ✅ Verification metadata included

## Output Format

### Create Mode Output

```markdown
[Complete PR description following template]

<!-- All sections populated -->
<!-- All claims verified -->
<!-- Ready for gh pr create --body -->
```

### Verify Mode Output

```markdown
## PR Description Verification Report

**PR**: #47
**Status**: ✅ PASSED / ⚠️ WARNINGS / ❌ FAILED

### P0 Issues (Must Fix)

- None

### P1 Issues (Should Fix)

- Line 15: Marketing buzzword "enterprise-grade"
- Line 23: Unverified performance claim "10x faster"

### P2 Issues (Consider)

- Breaking changes section could be more detailed

### Recommendations

1. Remove marketing language
2. Replace performance claim with architectural fact
3. Expand breaking changes documentation

**Files Verified**: 12 files
**Claims Verified**: 18 claims
**Verification Date**: 2025-01-12T10:30:00Z
```

## References

- Technical Documentation Expert Agent (verification patterns)
- API Documentation Verify Skill (verification checklist)
- GitHub PR Best Practices: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests
- Semantic PR Guidelines: https://www.conventionalcommits.org/
- Zero Fabrication Policy: Based on technical-documentation-expert (lines 13-35, 239-340)

---

**Maintained by**: Engineering team
**Review Schedule**: Quarterly
**Last Updated**: 2025-01-12
