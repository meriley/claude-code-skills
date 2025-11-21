# Skill Review: error-handling-audit
**Reviewer:** Claude Code
**Date:** 2025-01-21
**Version Reviewed:** 1.0.0

## Summary
Strong error handling audit skill with excellent pattern documentation and clear priorities. Good examples throughout. Main weaknesses are abstract execution steps and missing test documentation.

**Recommendation:** ⚠️ **NEEDS WORK**

## Findings by Category

### Structure [✅ PASS]
- [x] Directory structure correct
- [x] File naming conventions followed
- [x] Under 500 lines (369 lines)

**Issues:** None

**Positive highlights:**
- Well under the 500-line limit
- Clean single-file structure
- Appropriate comprehensive scope

---

### Frontmatter [✅ PASS]
- [x] Valid YAML
- [x] Name matches directory
- [x] Description quality excellent

**Frontmatter:**
```yaml
---
name: Go Error Handling Audit
description: Audits Go code for error handling best practices - proper wrapping with %w, preserved context, meaningful messages, no error swallowing. Use before committing Go code or during error handling reviews.
version: 1.0.0
---
```

**Issues:**
1. [MINOR] Name could use gerund form: "error-handling-auditing" but noun form is acceptable for audit skills

**Analysis:**
- ✅ Third person
- ✅ Specific capabilities (%w wrapping, context, messages, swallowing)
- ✅ Clear triggers ("before committing", "during error handling reviews")
- ✅ Key terms included (Go, error handling, wrapping)
- ✅ Max 1024 characters

**Recommendation:** PASS - excellent description

---

### Content Quality [✅ PASS]
- [x] Clear purpose and workflows
- [x] Concrete examples provided (excellent)
- [x] Progressive disclosure appropriate
- [x] Consistent terminology

**Issues:**
1. [MAJOR] Step-by-step execution is conceptual without concrete tool usage
2. [MAJOR] Report generation is template-heavy

**Positive highlights:**
- Exceptional "What This Skill Checks" section with 6 detailed patterns
- Clear priority system (CRITICAL, HIGH, MEDIUM)
- Excellent good vs bad pattern examples
- Good coverage of RMS standards
- CRITICAL EXCEPTIONS documented (important!)
- Strong before/after fix examples
- Integration points documented

**Line count:** 369 lines (excellent)

**Content breakdown:**
- Purpose: Clear and specific
- When to Use: 4 specific scenarios
- What This Skill Checks: 6 detailed patterns with priorities
- Step-by-Step Execution: 6 steps
- Integration points: Documented
- Exit criteria: Clear with blocker enforcement

---

### Instruction Clarity [⚠️ NEEDS WORK]
- [x] Clear sequential steps (conceptually)
- [ ] Code examples need implementation details
- [ ] Validation steps need specifics

**Issues:**
1. [MAJOR] Step 2 "Read Target Go Files" lacks specifics on parsing approach
2. [MAJOR] Step 3 "Analyze Error Handling Patterns" describes what but not how
3. [MAJOR] Missing concrete grep/search patterns for finding issues
4. [CRITICAL] No examples showing how to detect %v vs %w programmatically

**Good aspects:**
- Excellent conceptual breakdown
- Clear priorities
- Great before/after examples
- Good fix templates

**Needs improvement:**
```markdown
# Current (too abstract):
**A. Error Wrapping**
1. Find all `fmt.Errorf` calls with error arguments
2. Check if using `%w` (good) or `%v/%s` (bad)

# Better (more concrete):
**A. Error Wrapping**
Use Grep tool to find all error formatting:

\`\`\`bash
# Find potential %v usage with errors
grep -n 'fmt.Errorf.*%v.*err' *.go

# Find potential %s usage with errors
grep -n 'fmt.Errorf.*%s.*err' *.go

# Find proper %w usage (for comparison)
grep -n 'fmt.Errorf.*%w.*err' *.go
\`\`\`

For each match:
1. Use Read tool to examine context
2. Verify if error is being wrapped
3. Flag %v or %s usage with error variables
```

---

### Testing [❌ NEEDS DOCUMENTATION]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing matrix provided
3. [CRITICAL] No example execution on real Go code

**Required before final release:**
- Test scenario 1: Detect %v usage in error wrapping
- Test scenario 2: Identify error swallowing
- Test scenario 3: Find panic in runtime code
- Document real codebase results
- Test across models

---

## Blockers (must fix)
None

## Critical Issues (should fix)
1. No documented test scenarios
2. No testing matrix provided
3. Missing concrete detection examples (how to find %v vs %w)

## Major Issues (fix soon)
1. Step-by-step execution lacks concrete implementation
2. Missing grep/search patterns for issue detection
3. Report generation is template without population guidance

## Minor Issues (nice to have)
1. Could show AST parsing for more accurate detection
2. Could integrate with existing Go error linters
3. Could provide automated fix scripts

## Positive Highlights
- Exceptional pattern documentation (6 detailed checks)
- Clear priority system with CRITICAL/HIGH/MEDIUM
- Excellent good vs bad examples for all patterns
- CRITICAL EXCEPTIONS documented (important nuance)
- Strong before/after fix examples
- RMS standards integration documented
- Good coverage of panic usage rules
- Clear exit criteria with blocker enforcement
- Integration points documented

## Recommendations

### Priority 1 (Required before release)
1. **Add concrete detection examples**:
   ```markdown
   ### Step 3A: Detect Error Wrapping Issues

   Use Grep tool to find formatting patterns:

   \`\`\`bash
   # Find %v with error variables (CRITICAL issue)
   grep -n 'fmt\.Errorf.*%v.*\berr\b' --include="*.go" -r .

   # Find %s with error variables (CRITICAL issue)
   grep -n 'fmt\.Errorf.*%s.*\berr\b' --include="*.go" -r .
   \`\`\`

   For each match:
   1. Use Read tool to get surrounding context
   2. Verify variable is an error type
   3. Flag as CRITICAL if error not using %w
   4. Check for EXCEPTION comments (API boundary, logging)
   ```

2. **Add testing documentation**:
   - Test case 1: Detect %v usage in service/task.go line 42
   - Test case 2: Find error swallowing in handler/api.go line 156
   - Test case 3: Identify panic in util/parse.go line 89
   - Show expected skill output for each
   - Multi-model testing results
   - Real RMS codebase results (if applicable)

3. **Add concrete report example**:
   Show actual report generated from real Go file with specific line numbers

### Priority 2 (Nice to have)
1. Add section on Go AST parsing for accurate error analysis
2. Show integration with golangci-lint errcheck
3. Provide automated fix script (change %v to %w)
4. Consider REFERENCE.md for:
   - Advanced AST-based error detection
   - Integration with existing tools
   - Automated fix scripts

## Next Steps
- [ ] Add concrete grep/search patterns to execution steps
- [ ] Complete testing documentation with real examples
- [ ] Add example report from real codebase
- [ ] Add automated detection examples
- [ ] Consider REFERENCE.md for advanced topics
- [ ] Re-review after fixes
- [ ] Approve for merge

**Estimated effort:** 4-5 hours

---

## Overall Assessment

**Total Issues:**
- Blockers: 0
- Critical: 3
- Major: 3
- Minor: 3

**Pass Criteria Analysis:**
- ✅ Zero blockers: YES
- ✅ Zero critical: NO (has 3)
- ✅ < 3 major: NO (has 3)

**Recommendation:** NEEDS WORK (Critical + Major issues need addressing)

**Strong Points:**
- Exceptional pattern documentation
- Clear priorities and comprehensive checks
- Excellent good vs bad examples
- CRITICAL EXCEPTIONS well documented
- Strong fix examples
- Good RMS standards integration
- Clear blocker enforcement

**Weak Points:**
- Too abstract in execution steps
- Missing concrete detection patterns
- No test documentation
- No example execution on real code
