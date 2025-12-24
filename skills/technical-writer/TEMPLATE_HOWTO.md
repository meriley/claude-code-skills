# How to [Accomplish Specific Task]

## Problem

[1-2 sentences describing the specific problem this guide solves. Be concrete about the problem scenario.]

**Example Problem Statement**:
> "You need to migrate from API v1 to v2, which changed the authentication mechanism from API keys to OAuth2."

---

## Prerequisites

**Required Knowledge**:
- [Concept 1] - Link to explanation if available
- [Concept 2] - Link to explanation if available

**Required Tools**:
- [Tool 1]: [Version or higher]
- [Tool 2]: [Version or higher]

**Before You Begin**:
- [ ] [Prerequisite action 1, e.g., "Backup existing configuration"]
- [ ] [Prerequisite action 2, e.g., "Have API credentials ready"]
- [ ] [Prerequisite action 3]

**Assumptions**:
- This guide assumes [assumption 1, e.g., "you're already using v1.x"]
- This guide assumes [assumption 2, e.g., "you have admin access"]

---

## Overview

[Brief overview of the solution approach - 2-3 sentences]

**What You'll Accomplish**:
- [Outcome 1]
- [Outcome 2]
- [Outcome 3]

**Estimated Time**: [Realistic time estimate based on testing]

---

## Strategy 1: [Approach Name]

[When to use this strategy vs alternatives]

**Best For**:
- [Scenario where this strategy is ideal]
- [Another scenario]

**Trade-offs**:
- ✅ Advantage: [Factual benefit]
- ❌ Limitation: [Factual limitation]

### Step 1: [Action Description]

[Detailed instructions for this step]

```[language]
// Complete, tested code example
import { VerifiedAPI } from 'verified/path';

// [Step-by-step code with inline comments]
const result = VerifiedAPI.method(params);
```

**Expected Result**:
```
[Actual output from testing this step]
```

**Verification**:
- [ ] [How to verify this step worked]
- [ ] [Another verification check]

---

### Step 2: [Action Description]

[Detailed instructions for this step]

```[language]
// Complete, tested code building on previous step
// [Code continues from Step 1]
```

**Expected Result**:
```
[Actual output from testing this step]
```

**Common Issues**:
- **Issue**: [Actual common issue from testing/experience]
  - **Cause**: [Why this happens]
  - **Solution**: [How to fix]

---

### Step 3: [Action Description]

[Continue with remaining steps...]

---

### Step N: Verify Solution

[Final verification steps to confirm the task is complete]

```[language]
// Verification code (tested)
// [How to verify the complete solution works]
```

**Success Criteria**:
- [ ] [Specific, measurable criterion 1]
- [ ] [Specific, measurable criterion 2]
- [ ] [Specific, measurable criterion 3]

---

## Strategy 2: [Alternative Approach Name]

[ONLY include if there's a genuinely different approach]

**Best For**:
- [Different scenario where this strategy is better]

**Trade-offs**:
- ✅ Advantage: [Factual benefit compared to Strategy 1]
- ❌ Limitation: [Factual limitation compared to Strategy 1]

**Key Differences from Strategy 1**:
- [Difference 1]
- [Difference 2]

### Steps for Strategy 2

[Similar step-by-step structure as Strategy 1]

---

## Troubleshooting

### Issue: [Common Problem 1]

**Symptoms**:
- [Observable symptom 1]
- [Observable symptom 2]

**Cause**:
[Why this happens - based on actual experience, not speculation]

**Solution**:
```[language]
// Tested fix for this issue
```

**Verification**:
- [ ] [How to verify the fix worked]

---

### Issue: [Common Problem 2]

**Symptoms**:
- [Observable symptom]

**Cause**:
[Root cause]

**Solution**:
```[language]
// Tested fix
```

**Prevention**:
[How to avoid this issue in the future]

---

### Issue: [Common Problem 3]

[Continue with additional common issues...]

---

## Before/After Comparison

[ESPECIALLY useful for migration guides - show the difference]

### Before (Old Approach)

```[language]
// OLD approach (verified against old source/docs)
import { OldAPI } from 'old/path';

const result = OldAPI.oldMethod(param1, param2);
```

**Limitations of Old Approach**:
- [Factual limitation 1]
- [Factual limitation 2]

---

### After (New Approach)

```[language]
// NEW approach (verified against new source)
import { NewAPI } from 'new/path';

const result = NewAPI.newMethod({ param1, param2 });
```

**Benefits of New Approach**:
- [Factual benefit 1 - from benchmarks or source features]
- [Factual benefit 2]

**Breaking Changes**:
- [Change 1 verified in git diff]
- [Change 2 verified in git diff]

---

## Complete Example

[Full, working example showing the entire solution from start to finish]

```[language]
// Complete, tested example
// File: example-solution.ts (or appropriate extension)

// All imports (verified)
import { API1 } from 'verified/path1';
import { API2 } from 'verified/path2';

// Complete working code that solves the problem
async function solutionExample() {
  // [Step-by-step implementation with comments]

  // Step 1: [...]
  const step1Result = await API1.method1(params);

  // Step 2: [...]
  const step2Result = await API2.method2(step1Result);

  // Step 3: [...]
  return finalResult;
}

// Usage
solutionExample()
  .then(result => {
    console.log('Success:', result);
  })
  .catch(error => {
    console.error('Error:', error);
  });
```

**To Run This Example**:
```bash
# Installation commands (tested)
npm install dependency1 dependency2

# Run command (tested)
node example-solution.js
```

**Expected Output**:
```
[Actual output from running this example]
```

---

## Performance Considerations

[ONLY include if you have actual benchmark data or measurable differences]

### Performance Comparison

**Benchmark Setup**:
- Hardware: [Specific hardware]
- Dataset: [What was tested]
- Date: [When benchmark was run]

| Approach | Time | Memory | Notes |
|----------|------|--------|-------|
| Strategy 1 | [X]ms | [Y]MB | [Context] |
| Strategy 2 | [X]ms | [Y]MB | [Context] |

**Source**: [Link to benchmark code]

**Recommendation**:
- For [scenario]: Use Strategy 1 ([factual reason from benchmarks])
- For [scenario]: Use Strategy 2 ([factual reason from benchmarks])

---

## Alternative Approaches

[ONLY include if there are other valid approaches not covered above]

### Approach: [Alternative Method Name]

**Description**: [Brief description of alternative]

**When to Use**:
- [Specific scenario where this is better]

**Trade-offs**:
- ✅ [Advantage]
- ❌ [Disadvantage]

**Reference**: [Link to documentation for this approach]

---

## Related Documentation

- **Tutorial**: [Getting Started with [Topic]](link) - Learn from scratch
- **Reference**: [API Reference for [Module]](link) - Complete API details
- **How-To**: [How to [Related Task]](link) - Solve related problems
- **Explanation**: [Understanding [Concept]](link) - Design rationale

---

## Next Steps

After completing this guide:

1. **[Logical next action]** - [Link to relevant guide]
2. **[Another next action]** - [Link to relevant guide]
3. **[Optional enhancement]** - [Link to relevant guide]

---

## Verification Metadata

**Last Updated**: [YYYY-MM-DD]
**Verification Status**: ✅ All steps tested and working
**Tested On**:
- Platform: [OS/Platform]
- Version: [Software version]
- Environment: [Development/Production/etc.]

**APIs Verified**:
- `API1.method1` - Source: `path/to/source.ts`
- `API2.method2` - Source: `path/to/source.ts`

---

## Verification Checklist

### P0 - CRITICAL (Must Pass)
- [ ] All steps tested and working
- [ ] All code examples run successfully
- [ ] All API calls verified against source
- [ ] All imports are correct and complete
- [ ] Expected outputs match actual outputs
- [ ] No fabricated solutions or workarounds
- [ ] Troubleshooting issues are real (not speculative)

### P1 - HIGH (Should Pass)
- [ ] Complete Before/After comparison (for migrations)
- [ ] All common issues documented (from actual experience)
- [ ] All trade-offs are factual (not marketing)
- [ ] Source references included for all APIs
- [ ] No marketing language or buzzwords
- [ ] Alternative approaches are viable (tested)
- [ ] Prerequisites are complete and accurate

### P2 - MEDIUM (Consider)
- [ ] Performance comparison included (if relevant)
- [ ] Clear cross-links to related documentation
- [ ] Consistent structure throughout
- [ ] Complete example provided
- [ ] Next steps guidance included

---

## Template Usage Notes

**This is a TEMPLATE. Replace all bracketed placeholders with actual content.**

**When to Use This Template**:
- Migration guides (v1 → v2)
- System integration ("How to integrate System A with System B")
- Configuration guides ("How to configure X for Y scenario")
- Deployment guides ("How to deploy to Z platform")
- Problem-solving guides ("How to debug X issues")

**Structure Variations**:
- **Migration guides**: Emphasize Before/After comparison
- **Integration guides**: Focus on connection steps and configuration
- **Debugging guides**: Emphasize Troubleshooting section
- **Multi-strategy guides**: Include Strategy 1, Strategy 2, etc.

**Remember**:
1. ✅ Test ALL steps before publishing
2. ✅ Verify ALL API calls against source
3. ✅ Include REAL troubleshooting issues (from experience)
4. ✅ Show complete working examples
5. ✅ Document trade-offs factually
6. ❌ NO untested solutions
7. ❌ NO fabricated issues or fixes
8. ❌ NO marketing language ("seamlessly", "effortlessly")

**Diátaxis Type**: How-To (Problem-oriented)
**Focus**: HOW to accomplish a specific task
**Assumes**: Reader has basic knowledge (not a beginner tutorial)
**Do NOT include**: Complete API reference (link to Reference docs), beginner step-by-step tutorials (use tutorial-writer), deep WHY explanations (link to Explanation docs)
