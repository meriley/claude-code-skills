# Cursor Rules Writing - Test Scenarios

This file provides validation scenarios for testing the cursor-rules-writing skill.

---

## Scenario 1: Create Simple File-Based Rule

**Objective:** Create a basic Cursor rule for TypeScript React components with proper glob patterns and concrete examples.

### Setup
- Project with React/TypeScript codebase
- Components in `src/components/` directory
- No existing Cursor rules

### Task
Create a Cursor rule that provides React component patterns including:
- Props typing conventions
- Component structure patterns
- Common hooks usage
- File organization

### Expected Behavior

#### Step 1: Identify Context Need ✓
- [ ] Evaluates whether rule is needed (not general React knowledge)
- [ ] Identifies specific project patterns worth documenting
- [ ] Determines this is file-specific context (not always-apply)

#### Step 2: Choose Trigger Type ✓
- [ ] Correctly chooses file-based triggering over always-apply
- [ ] Identifies appropriate glob patterns for components
- [ ] Sets `alwaysApply: false`

#### Step 3: Create Frontmatter ✓
```yaml
Expected frontmatter:
---
description: React component patterns including props typing, hooks usage, and component structure. Apply when creating or modifying React components.
globs: ["**/*.tsx", "**/components/**/*.ts", "**/hooks/**/*.ts"]
alwaysApply: false
---
```

Checklist:
- [ ] Description is specific (mentions props typing, hooks, structure)
- [ ] Description includes "when to use" (creating/modifying components)
- [ ] Globs use recursive patterns (`**/`)
- [ ] Globs target TypeScript React files (`.tsx`)
- [ ] Globs cover related files (hooks, utilities)
- [ ] alwaysApply is false (file-based triggering)

#### Step 4: Write Content ✓
- [ ] Includes Overview section with Related rules reference
- [ ] Provides concrete component examples (not abstract advice)
- [ ] Shows good vs bad patterns (✅/❌)
- [ ] Covers props typing with TypeScript
- [ ] Demonstrates hooks usage patterns
- [ ] Includes component structure example
- [ ] Uses code blocks with proper syntax highlighting
- [ ] File is under 500 lines
- [ ] Sections separated with `---`

Example expected content structure:
```markdown
# React Component Patterns

## Overview
...

**Related rules:** See @typescript-patterns.mdc...

---

## Props Typing

\`\`\`typescript
// ✅ Good - Explicit props interface
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  ...
}
\`\`\`

---

## Hooks Usage

\`\`\`typescript
// ✅ Good - Custom hook
function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  ...
}
\`\`\`
```

#### Step 5: Test Rule ✓
- [ ] Rule file created in `.cursor/rules/react-components.mdc`
- [ ] Opens TypeScript component file (e.g., `Button.tsx`)
- [ ] Starts Cursor chat
- [ ] Verifies rule context is loaded
- [ ] Tests @-mention (`@react-components.mdc`) works

### Success Criteria

**Must have:**
- ✅ Frontmatter with clear description
- ✅ Glob patterns using `**/` for recursion
- ✅ alwaysApply is false
- ✅ Concrete code examples (not abstract)
- ✅ Good vs bad comparisons
- ✅ File under 500 lines
- ✅ Rule loads when editing `.tsx` files
- ✅ @-mention works in chat

**Validation methods:**
1. **Frontmatter check:** YAML is valid, fields present
2. **Glob test:** `find . -name "*.tsx"` matches expected files
3. **Content quality:** Contains actual TypeScript/React code
4. **Functionality:** Rule loads in Cursor when editing components
5. **File size:** `wc -l` shows under 500 lines

---

## Scenario 2: Split Large Rule into Composable Units

**Objective:** Take an oversized rule (800+ lines) and split it into multiple focused rules with cross-references.

### Setup
- Existing rule: `helm-all-in-one.mdc` (1200 lines)
- Contains:
  - Chart structure patterns (300 lines)
  - Values.yaml organization (250 lines)
  - Template helpers (200 lines)
  - Testing patterns (200 lines)
  - Deployment strategies (250 lines)
- `alwaysApply: true` (loading 1200 lines always)

### Task
Split the monolithic rule into focused, composable rules following best practices.

### Expected Behavior

#### Step 1: Analyze Existing Rule ✓
- [ ] Reads through entire 1200-line rule
- [ ] Identifies distinct topics/concerns
- [ ] Notes that 1200 lines exceeds 500-line target
- [ ] Recognizes alwaysApply causes context bloat
- [ ] Plans splitting strategy

#### Step 2: Design Rule Structure ✓
Expected structure:
```
helm-expert-skill.mdc (200 lines, alwaysApply: true)
  - Overview of Helm best practices
  - Quick reference guide
  - Cross-references to detailed rules

├─ helm-chart-writing.mdc (400 lines, globs: Chart.yaml, values*.yaml)
│  - Chart.yaml structure
│  - Values.yaml patterns
│  - Template helpers
│
├─ helm-testing.mdc (350 lines, globs: tests/**/*.yaml)
│  - Unit testing patterns
│  - Integration tests
│  - Test automation
│
└─ helm-deployment.mdc (400 lines, manual only)
   - Deployment strategies
   - Production patterns
   - Rollback procedures
```

Checklist:
- [ ] Creates 4 focused rules instead of 1 monolithic
- [ ] Core rule is short (200 lines) and always-applied
- [ ] Detailed rules are file-based or manual
- [ ] Each rule under 500 lines
- [ ] Clear separation of concerns

#### Step 3: Create Core Rule ✓
```yaml
Expected: helm-expert-skill.mdc
---
description: Overview of Helm best practices with references to detailed guidance for chart writing, testing, and deployment.
alwaysApply: true
---

# Helm Expert Skill

## Overview
...

**Related rules:**
- @helm-chart-writing.mdc for chart structure
- @helm-testing.mdc for test patterns
- @helm-deployment.mdc for production deployments

---

## Quick Reference

[High-level guidance - 200 lines total]
```

Checklist:
- [ ] Core rule is under 300 lines
- [ ] alwaysApply: true (universal context)
- [ ] Cross-references all related rules
- [ ] Provides overview, not deep details

#### Step 4: Create Focused Rules ✓

**helm-chart-writing.mdc:**
```yaml
---
description: Helm chart structure patterns for Chart.yaml, values.yaml, and template helpers.
globs: ["**/Chart.yaml", "**/values*.yaml", "**/templates/**/*.yaml"]
alwaysApply: false
---
```
- [ ] File-based triggering with specific globs
- [ ] 400 lines (under 500 ✓)
- [ ] Focuses only on chart writing
- [ ] References core rule and testing rule

**helm-testing.mdc:**
```yaml
---
description: Helm chart testing patterns including unit tests and integration tests.
globs: ["**/tests/**/*.yaml", "**/tests/**/*.sh"]
alwaysApply: false
---
```
- [ ] Targets test files specifically
- [ ] 350 lines (under 500 ✓)
- [ ] Focuses only on testing
- [ ] References core rule

**helm-deployment.mdc:**
```yaml
---
description: Production deployment strategies for Helm charts. Use when planning deployments or troubleshooting.
# No globs - manual only
---
```
- [ ] No globs (manual reference)
- [ ] 400 lines (under 500 ✓)
- [ ] Deployment-specific content
- [ ] Can be @-mentioned when needed

#### Step 5: Test Rule Composition ✓
- [ ] Opens Helm chart file (`Chart.yaml`)
- [ ] Verifies only relevant rules load (core + chart-writing)
- [ ] Deployment rule does NOT auto-load (manual only ✓)
- [ ] Opens test file, verifies testing rule loads
- [ ] Manually @-mentions deployment rule, verifies it loads
- [ ] Checks context is coherent and not duplicated

### Success Criteria

**Must have:**
- ✅ 4 focused rules replacing 1 monolithic
- ✅ Core rule under 300 lines, always-applied
- ✅ Detailed rules under 500 lines each
- ✅ Appropriate triggering (always vs file-based vs manual)
- ✅ Clear cross-references between rules
- ✅ No content duplication
- ✅ Total content similar but better organized

**Performance improvement:**
```
Before:
- 1200 lines always loaded
- Single rule for everything
- Context bloat

After:
- 200 lines always loaded (core)
- 400 lines when editing charts (writing)
- 350 lines when editing tests (testing)
- 400 lines on-demand only (deployment)
- Total context reduced 50-75% in most scenarios
```

**Validation methods:**
1. **File count:** 4 .mdc files created
2. **Size check:** Each under 500 lines
3. **Glob test:** Patterns match expected files
4. **Load test:** Correct rules load for different file types
5. **Cross-reference test:** @-mentions work
6. **Content audit:** No duplication, complete coverage

---

## Scenario 3: Create Manual-Only Reference Rule

**Objective:** Create a troubleshooting/reference rule that should only load on explicit @-mention (not automatically).

### Setup
- Project with complex debugging scenarios
- Developers frequently need troubleshooting guidance
- Don't want guidance loaded in every chat (context bloat)

### Task
Create a manual-only Cursor rule for advanced Node.js/TypeScript debugging that:
- Provides diagnostic steps
- Lists common issues and solutions
- Includes troubleshooting checklists
- Should NOT auto-load

### Expected Behavior

#### Step 1: Determine Rule Type ✓
- [ ] Recognizes this is reference material
- [ ] Understands it should be on-demand only
- [ ] Decides NO globs needed
- [ ] Decides alwaysApply should be false (or omitted)

#### Step 2: Create Frontmatter ✓
```yaml
Expected frontmatter:
---
description: Advanced Node.js debugging techniques for memory leaks, performance issues, and async bugs. Use when diagnosing complex runtime problems.
# Note: No globs field
# Note: No alwaysApply field (or alwaysApply: false)
---
```

Checklist:
- [ ] Description explains what troubleshooting is covered
- [ ] Description includes "when to use" (diagnosing problems)
- [ ] NO globs field (manual-only)
- [ ] NO alwaysApply: true
- [ ] Description is clear about being diagnostic/reference

#### Step 3: Write Reference Content ✓
Expected structure:
```markdown
# Node.js Debugging Guide

## Overview
This rule provides advanced debugging techniques for Node.js/TypeScript applications. Manually invoke with @nodejs-debugging.mdc when troubleshooting.

**When to use this rule:**
- Investigating memory leaks
- Diagnosing performance bottlenecks
- Troubleshooting async/Promise issues
- Analyzing stack traces

---

## Memory Leak Diagnosis

### Step 1: Take Heap Snapshot
\`\`\`bash
node --inspect app.js
# Open chrome://inspect
# Take heap snapshot
\`\`\`

### Step 2: Analyze Retained Objects
[Detailed analysis steps]

---

## Common Issues and Solutions

### Issue 1: Memory Leak in Event Listeners

**Symptoms:**
- Memory usage grows over time
- Not releasing after operations complete

**Diagnosis:**
\`\`\`javascript
// Check event listener count
process.stdout.write(
  \`Listeners: \${emitter.listenerCount('event')}\n\`
);
\`\`\`

**Solution:**
\`\`\`javascript
// ✅ Good - Always remove listeners
function handler() { /* ... */ }
emitter.on('event', handler);
// Later...
emitter.off('event', handler);

// ❌ Bad - Listeners never removed
emitter.on('event', () => { /* ... */ });
\`\`\`
```

Checklist:
- [ ] Overview explains this is diagnostic/reference
- [ ] Lists specific scenarios for using the rule
- [ ] Provides step-by-step diagnostic procedures
- [ ] Includes concrete debugging commands
- [ ] Shows symptom-diagnosis-solution pattern
- [ ] Uses checklists for troubleshooting steps
- [ ] Comprehensive (can be 500-800 lines for reference)

#### Step 4: Test Manual Loading ✓
- [ ] Opens any project file
- [ ] Starts Cursor chat
- [ ] Rule does NOT auto-load (verified)
- [ ] Manually types `@nodejs-debugging.mdc` in chat
- [ ] Rule context loads on @-mention
- [ ] Context is helpful for debugging
- [ ] Doesn't interfere with normal coding

#### Step 5: Verify No Auto-Loading ✓
- [ ] Opens TypeScript file - rule doesn't load
- [ ] Opens JavaScript file - rule doesn't load
- [ ] Opens test file - rule doesn't load
- [ ] Opens config file - rule doesn't load
- [ ] Only loads when explicitly @-mentioned ✓

### Success Criteria

**Must have:**
- ✅ NO globs in frontmatter
- ✅ NO alwaysApply: true
- ✅ Description mentions "Use when..." for manual usage
- ✅ Comprehensive troubleshooting content
- ✅ Step-by-step diagnostic procedures
- ✅ Common issues with solutions
- ✅ Rule does NOT auto-load
- ✅ Rule loads when @-mentioned
- ✅ Content is reference/diagnostic (not everyday guidance)

**Validation methods:**
1. **Frontmatter check:** No globs, no alwaysApply
2. **Auto-load test:** Open various files, verify no auto-load
3. **Manual load test:** @-mention in chat, verify loads
4. **Content audit:** Diagnostic/troubleshooting focused
5. **Usability test:** Ask debugging question, @-mention rule, get helpful context

### Additional Test: Rule Size Justification
- [ ] If rule exceeds 500 lines, content is justified as reference material
- [ ] Could be 500-800 lines for comprehensive troubleshooting
- [ ] Alternative: Could split into multiple troubleshooting rules if needed

---

## Baseline Comparison Methodology

### Without cursor-rules-writing Skill

**Test:** Ask Claude to create a Cursor rule for React components.

**Expected issues:**
- May forget YAML frontmatter entirely
- May use `.cursorrules` format (deprecated)
- May not know about glob patterns
- Might use `alwaysApply: true` inappropriately
- May create vague descriptions
- May write 1000+ line monolithic rule
- Won't understand cross-references

**Typical output quality: 3/10**

### With cursor-rules-writing Skill

**Test:** Same request with skill loaded.

**Expected improvements:**
- Creates proper .mdc file with frontmatter
- Uses specific description with "when to use"
- Applies appropriate glob patterns with `**/`
- Chooses correct triggering (file-based vs always vs manual)
- Keeps rule under 500 lines
- Includes concrete examples
- Uses cross-references for related rules
- Follows best practices from existing Helm rules

**Expected output quality: 9/10**

### Measurable Improvements

| Metric | Without Skill | With Skill |
|--------|---------------|------------|
| Frontmatter present | 40% | 100% |
| Correct glob syntax | 20% | 95% |
| Under 500 lines | 30% | 90% |
| Concrete examples | 50% | 95% |
| Appropriate triggering | 40% | 90% |
| Cross-references | 10% | 85% |
| Follows best practices | 25% | 90% |

---

## Multi-Model Testing

### Test Across Claude Models

**Haiku (Fast model):**
- Should understand basic frontmatter structure
- May produce shorter, less detailed rules
- Should still follow glob pattern guidance
- Expected: 7/10 quality

**Sonnet (Balanced model):**
- Should produce well-structured rules
- Good balance of detail and conciseness
- Proper use of all features
- Expected: 9/10 quality

**Opus (Highest quality):**
- Should produce comprehensive, exemplary rules
- Perfect frontmatter and structure
- Excellent examples and cross-references
- Expected: 10/10 quality

### Consistency Check

Test same request across models:
- All should create .mdc format (not .cursorrules)
- All should include frontmatter
- All should use glob patterns appropriately
- All should reference TEMPLATE.md examples
- Variations in detail level are acceptable

---

## Real-World Validation

### Validation 1: Create Rule from Existing Code

**Task:** Given an existing TypeScript codebase with specific patterns, create appropriate Cursor rule.

**Success criteria:**
- Rule captures actual project patterns (not generic)
- Glob patterns match actual file structure
- Examples use project code style
- Rule loads when editing relevant files

### Validation 2: Team Usage

**Task:** Have multiple team members create rules using the skill.

**Success criteria:**
- All rules follow same structure
- Consistent quality across team
- Rules compose well together
- No duplicated content
- Team can maintain rules over time

### Validation 3: Performance Impact

**Task:** Measure context usage before/after applying skill best practices.

**Success criteria:**
- Always-apply rules under 300 lines total
- File-based rules target specific files correctly
- Manual rules don't auto-load
- Total context reduced compared to monolithic approach
- Cursor remains responsive

---

## Continuous Improvement

### Skill Iteration Based on Testing

**After running test scenarios:**
1. Identify any confusion or mistakes
2. Check if TEMPLATE.md needs updates
3. Verify EXAMPLES.md covers common pitfalls
4. Update REFERENCE.md with edge cases discovered
5. Add new test scenarios for any gaps found

**Success metrics for skill itself:**
- 90%+ correct frontmatter on first try
- 85%+ appropriate triggering choice
- 90%+ rules under 500 lines
- 95%+ valid YAML syntax
- 80%+ proper use of cross-references

---

**These test scenarios follow the skill-writing meta skill testing best practices and should be updated as Cursor adds new features.**
