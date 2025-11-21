# Skill Review: safe-destroy
**Reviewer:** Claude Code
**Date:** 2025-01-21
**Version Reviewed:** 1.0.1

## Summary
Skill has BLOCKER frontmatter issues (name doesn't match directory, uses spaces). File exceeds 500 line recommendation at 520 lines. Description is verbose with enforcement language. Content is comprehensive but needs refactoring.

**Recommendation:** ❌ **FAIL**

## Findings by Category

### Structure [❌ FAIL]
- [x] Directory structure correct
- [x] File naming conventions followed
- [ ] Exceeds 500 line limit (520 lines) ✗

**Line count:** 520 lines

**Issues:**
1. [BLOCKER] File is 520 lines (exceeds 500 line optimal limit by 20 lines)

**Justification:**
The skill covers multiple destructive operations with detailed alternatives for each. However, 520 lines is too long. Safe alternatives reference section (lines 402-495) should be extracted to REFERENCE.md.

**Recommended refactoring:**
- Main file: 350 lines (core workflow + examples)
- REFERENCE.md: Safe alternatives, recovery procedures, detailed examples

**Positive highlights:**
- Well-organized sections per operation type
- No nested supporting files

---

### Frontmatter [❌ FAIL]
- [x] Valid YAML
- [ ] Name field INCORRECT
- [ ] Description too long and verbose

**Frontmatter:**
```yaml
---
name: Safe Destructive Operations
description: ⚠️ MANDATORY - YOU MUST invoke this skill before ANY destructive operation. Safety protocol for destructive git/file operations. Lists affected files, warns about data loss, suggests safe alternatives, requires explicit double confirmation. NEVER run destructive commands without invoking this skill.
version: 1.0.1
---
```

**Issues:**
1. [BLOCKER] Name "Safe Destructive Operations" doesn't match directory name "safe-destroy"
2. [BLOCKER] Name uses spaces and capital letters (should be "safe-destroy")
3. [CRITICAL] Description is 346 characters and overly verbose with enforcement statements
4. [MAJOR] Description has marketing-style urgency ("⚠️ MANDATORY", all caps)

**Required rewrite:**
```yaml
---
name: safe-destroy
description: Safety protocol for destructive git and file operations. Lists affected files, shows what will be lost, suggests safer alternatives (stash, backup, archive), requires explicit double confirmation. Use before reset --hard, clean -fd, rm -rf, or other data-deleting commands.
version: 1.0.1
---
```

---

### Content Quality [⚠️ NEEDS WORK]
- [x] Clear purpose and workflows
- [x] Concrete examples provided (6+ operations)
- [x] Consistent terminology
- [x] Safe alternatives documented

**Issues:**
1. [BLOCKER] File exceeds 500 lines (should extract to REFERENCE.md)
2. [MAJOR] Safe alternatives section (100+ lines) should be in REFERENCE.md
3. [MAJOR] Emergency recovery section (90+ lines) should be in REFERENCE.md
4. [MINOR] Repetitive structure across operation types

**Positive highlights:**
- Comprehensive coverage of dangerous operations
- Excellent safe alternatives for each operation
- Strong double-confirmation workflow
- Good emergency recovery guidance
- Clear reporting formats

---

### Instruction Clarity [✅ PASS]
- [x] Clear sequential steps (STOP, LIST, ASK, WAIT, VERIFY, EXECUTE)
- [x] Code examples complete and runnable
- [x] Expected outputs documented

**Issues:**
None

**Positive highlights:**
- Excellent 6-step workflow pattern (STOP, LIST, ASK, WAIT, VERIFY, EXECUTE)
- Concrete examples for each destructive operation
- Clear confirmation requirements
- Good differentiation between valid/invalid confirmations

---

### Testing [⚠️ UNKNOWN]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing documentation provided

**Required before release:**
- Test scenario 1: User requests git reset --hard (shows alternatives, gets confirmation)
- Test scenario 2: User requests git clean -fd (lists files, suggests backup)
- Test scenario 3: User provides ambiguous confirmation (requires clarification)
- Test scenario 4: User cancels operation
- Document across models

---

## Blockers (must fix)
1. Name field "Safe Destructive Operations" must be changed to "safe-destroy" to match directory
2. Name field uses spaces and capitals - must use lowercase-with-hyphens
3. File is 520 lines - MUST reduce to under 500 by extracting to REFERENCE.md

## Critical Issues (should fix)
1. No documented test scenarios or testing matrix
2. Description too long (346 chars) with excessive enforcement language

## Major Issues (fix soon)
1. Safe alternatives section (100+ lines) should be extracted to REFERENCE.md
2. Emergency recovery section (90+ lines) should be extracted to REFERENCE.md
3. Description uses marketing-style urgency markers and all caps

## Minor Issues (nice to have)
1. Repetitive structure across operation types could be templatized
2. Could add more examples of ambiguous user responses

## Positive Highlights
- Excellent 6-step workflow pattern (STOP, LIST, ASK, WAIT, VERIFY, EXECUTE)
- Comprehensive coverage of all major destructive operations
- Strong safe alternatives for each operation type
- Clear double-confirmation workflow
- Good emergency recovery procedures
- Excellent examples showing before/after state
- Strong user protection focus

## Recommendations

### Priority 1 (Required before release - BLOCKERS)
1. **Fix name field immediately** - Change from "Safe Destructive Operations" to "safe-destroy"
   ```yaml
   name: safe-destroy  # Must match directory name exactly
   ```

2. **Fix name format** - Use lowercase-with-hyphens only
   - Current: "Safe Destructive Operations"
   - Required: "safe-destroy"

3. **Reduce file length to under 500 lines** - Extract to REFERENCE.md:
   - Lines 402-495: Safe Alternatives Reference → REFERENCE.md
   - Lines 458-495: Emergency Recovery → REFERENCE.md
   - Keep core workflow (Steps 1-7) in main file
   - Add signpost in main file: "See REFERENCE.md for detailed alternatives and recovery"
   - Target: 350-380 lines in Skill.md

### Priority 2 (Required before release - CRITICAL)
1. **Improve description** - Remove enforcement language, reduce to ~250 chars:
   ```yaml
   description: Safety protocol for destructive git and file operations. Lists affected files, shows what will be lost, suggests safer alternatives (stash, backup, archive), requires explicit double confirmation. Use before reset --hard, clean -fd, rm -rf, or other data-deleting commands.
   ```

2. **Complete testing documentation**:
   - Test various destructive operations
   - Test confirmation handling
   - Test alternative suggestions
   - Document across models

### Priority 3 (Recommended)
1. **Create REFERENCE.md** with extracted content:
   ```markdown
   # Safe Alternatives Reference
   [100+ lines from current Skill.md]

   # Emergency Recovery Procedures
   [90+ lines from current Skill.md]
   ```

2. **Add signposting in main file**:
   ```markdown
   For detailed safe alternatives, see REFERENCE.md.
   For emergency recovery procedures, see REFERENCE.md.
   ```

## Next Steps
- [ ] Address blocker: Fix name field
- [ ] Address blocker: Fix name format
- [ ] Address blocker: Extract content to REFERENCE.md to get under 500 lines
- [ ] Address critical: Complete testing
- [ ] Address critical: Improve description
- [ ] Re-review after fixes
- [ ] Approve for merge

**Estimated effort:** 3-4 hours (extraction + testing)

---

## Overall Assessment

**Total Issues:**
- Blockers: 3
- Critical: 2
- Major: 3
- Minor: 2

**Reasoning:**
This skill provides critical user protection and has an excellent workflow design with the 6-step pattern. However, three BLOCKER issues prevent release:

1. Name field must be changed to "safe-destroy"
2. Name must use lowercase-with-hyphens format
3. File must be under 500 lines (currently 520)

The 520-line length is NOT justified - the skill should extract safe alternatives and recovery procedures to REFERENCE.md. This will make the main file more focused on the core workflow while keeping detailed references easily accessible.

Once blockers are fixed and testing is documented, this skill will be excellent. The core workflow and protection mechanisms are already very strong.
