# Tutorial Testing and Verification

Complete guide to testing and verifying tutorials before publishing. This is NOT optional - every tutorial MUST be tested.

---

## Why Testing is Mandatory

**Testing prevents**:

- Fabricated APIs that don't exist
- Code examples that don't run
- Wrong expected outputs
- Missing prerequisites
- Broken workflow steps
- Lost learner trust

**Testing ensures**:

- Every command works
- Every code example runs
- Every API is real
- Expected outputs are accurate
- Time estimates are realistic
- Success criteria are achievable

---

## Testing Workflow

### Step 1: Source Code Verification (10-15 minutes)

**Before writing the tutorial**, verify all APIs you plan to use.

#### 1.1: Read Source Files

```bash
# Find the source files for the APIs
Read [source_file.ext]

# Check API definitions
# Verify method signatures
# Note parameter types
# Check return types
```

#### 1.2: Create API Verification Checklist

```markdown
## APIs to Use in Tutorial

- [ ] `APIMethod1` - Verified in [source_file.ext:line]
  - Parameters: [exact signature]
  - Returns: [exact type]
- [ ] `APIMethod2` - Verified in [source_file.ext:line]
  - Parameters: [exact signature]
  - Returns: [exact type]
- [ ] `ConfigOption1` - Verified in [config_file.ext:line]
  - Type: [exact type]
  - Required: [yes/no]
- [ ] `Type1` - Verified in [types_file.ext:line]
  - Fields: [list all fields]

All signatures copied exactly ✅
All imports verified ✅
```

#### 1.3: Check Test Files for Usage Patterns

```bash
# Read test files to see how APIs are actually used
Read [test_file.ext]

# Look for:
# - How to instantiate classes
# - How to call methods
# - What parameters are required
# - What the expected behavior is
```

**Example verification**:

```typescript
// Source: node_modules/@company/service/dist/index.d.ts
export class TaskService {
  constructor(config?: ServiceConfig);
  create(options: CreateTaskOptions): Promise<Task>;
  list(filter?: TaskFilter): Promise<Task[]>;
  complete(taskId: string): Promise<void>;
}

// Verified:
// ✅ constructor - optional config parameter
// ✅ create() - requires CreateTaskOptions object
// ✅ list() - optional TaskFilter
// ✅ complete() - requires string taskId
```

---

### Step 2: Create Test Environment (5-10 minutes)

**Create a fresh environment** to simulate beginner experience.

#### 2.1: Set Up Test Directory

```bash
# Create isolated test directory
mkdir tutorial-test-$(date +%Y%m%d)
cd tutorial-test-$(date +%Y%m%d)

# Initialize if needed
npm init -y  # for Node.js
# or
go mod init test  # for Go
# or
python -m venv venv && source venv/bin/activate  # for Python
```

#### 2.2: Document Starting State

```markdown
## Test Environment

**Date**: 2024-01-15
**OS**: macOS 14.2
**Node.js**: v18.16.0
**npm**: 9.5.1

**Starting state**:

- Empty directory
- No packages installed
- No configuration files
```

---

### Step 3: Execute Tutorial Step-by-Step (15-30 minutes)

**Follow your own tutorial EXACTLY** - no shortcuts, no assumptions.

#### 3.1: Test Prerequisites Section

```bash
# Run every prerequisite check command
node --version
npm --version
# etc.

# Verify outputs match documented versions
```

**Document results**:

```markdown
✅ Node.js v18.16.0 (matches requirement: >= 18.0)
✅ npm 9.5.1 (matches requirement: >= 9.0)
```

#### 3.2: Test Each Step Sequentially

For each step:

1. **Read the step instructions**
2. **Execute commands exactly as written**
3. **Compare actual output to documented output**
4. **Verify success criteria**
5. **Note any discrepancies**

**Testing log template**:

````markdown
## Step 1 Testing: Install the package

**Command run**:

```bash
npm install @company/service
```
````

**Actual output**:

```
added 45 packages, and audited 46 packages in 3s
```

**Matches documented output?**: ✅ Yes (package count varies, acceptable)

**Success criteria verified**: ✅ Package appears in package.json

**Time taken**: 3 minutes (estimated: 5 minutes) ✅

**Issues found**: None

````

#### 3.3: Test All Code Examples

For each code example:

```bash
# Copy the code EXACTLY from tutorial
# Save to file
# Run it
# Compare output
````

**Code example testing log**:

````markdown
## Code Example: create-task.js

**File created**: create-task.js
**Code source**: Step 2, lines 15-30
**Copied exactly**: ✅ Yes

**Run command**:

```bash
node create-task.js
```
````

**Expected output** (from tutorial):

```
Task created: task-123
Status: pending
```

**Actual output**:

```
Task created: task-123
Status: pending
```

**Match**: ✅ Perfect match

**APIs verified working**:

- ✅ TaskService() constructor
- ✅ service.create() method
- ✅ task.id property
- ✅ task.status property

````

#### 3.4: Test Complete Working Example

```bash
# Test the final complete code
# Run it
# Verify it produces documented output
# Ensure all features work
````

---

### Step 4: Verify Time Estimates (During Testing)

Track time for each step:

```markdown
## Time Tracking

| Step             | Estimated  | Actual     | Notes              |
| ---------------- | ---------- | ---------- | ------------------ |
| 1. Install       | 5 min      | 3 min      | Quick download     |
| 2. Create task   | 10 min     | 8 min      | Typing took time   |
| 3. List tasks    | 7 min      | 12 min     | Had to debug typo  |
| 4. Complete task | 8 min      | 7 min      | Straightforward    |
| **Total**        | **30 min** | **30 min** | Includes debugging |

**Adjustment needed**: Step 3 estimate should be 10 min (account for typos)
```

**Time estimate formula**:

- Your expert time × 2 = beginner time
- Add 50% buffer for debugging
- Round up to nearest 5 minutes

---

### Step 5: Verification Checklist (5-10 minutes)

After testing, complete this checklist:

```markdown
## Tutorial Verification Checklist

### P0 - CRITICAL (Must Fix Before Publishing)

- [ ] Tutorial tested start-to-finish in fresh environment
- [ ] All commands run successfully
- [ ] All outputs match documentation
- [ ] Complete code tested and works
- [ ] Time estimates verified realistic
- [ ] All APIs verified against source code
- [ ] All signatures exact (no fabricated methods)
- [ ] No compile/runtime errors
- [ ] Success criteria for each step achievable

### P1 - HIGH (Should Fix)

- [ ] Expected outputs documented for every command
- [ ] Success verification present for each step
- [ ] Prerequisites clearly stated and tested
- [ ] Time estimates include beginner buffer
- [ ] Progressive complexity (simple → complex)

### P2 - MEDIUM (Nice to Have)

- [ ] Minimal explanations (WHAT not WHY)
- [ ] No marketing language
- [ ] Clear, simple language throughout
- [ ] Confidence-building progression
- [ ] Troubleshooting section covers common issues
- [ ] Metadata section complete
```

---

### Step 6: Document Test Results (5 minutes)

**Add to tutorial footer**:

```markdown
---

**Tutorial Metadata**

**Last Updated**: 2024-01-15
**System Version**: TaskService v2.1.0
**Verified**: ✅ Tutorial tested and working
**Test Date**: 2024-01-15
**Test Environment**: macOS 14.2, Node.js v18.16.0

**Verification**:

- ✅ All code examples tested
- ✅ All APIs verified against source
- ✅ Expected outputs confirmed
- ✅ Time estimates realistic (30-45 min total)
- ✅ Success criteria clear and achievable

**Source files verified**:

- `node_modules/@company/task-service/dist/index.d.ts`
- `node_modules/@company/task-service/dist/types.d.ts`
- `node_modules/@company/task-service/README.md`

**Test log**: Available at `tests/tutorial-test-20240115.md`
```

---

## Common Testing Discoveries

### Issue: Output Doesn't Match

**What you find**:

```
Expected: Service started on port 3000
Actual:   🚀 Service ready! Port: 3000
```

**Fix**:

- Update tutorial to show actual output
- Or note that output format may vary

### Issue: API Doesn't Exist

**What you find**:

```
Error: service.processTask is not a function
```

**Fix**:

- Find correct API name in source code
- Update tutorial to use real API
- Verify all method names

### Issue: Missing Parameters

**What you find**:

```
Error: Missing required field: title
```

**Fix**:

- Check API signature for required fields
- Update code example to include all required parameters
- Document parameter requirements

### Issue: Import Path Wrong

**What you find**:

```
Error: Cannot find module '@company/service/api'
```

**Fix**:

- Verify correct import path from source
- Update tutorial imports
- Test imports actually work

### Issue: Step Takes Much Longer

**What you find**:

- Estimated: 5 minutes
- Actually took: 20 minutes (with debugging typo)

**Fix**:

- Increase time estimate to 15 minutes
- Account for common beginner delays
- Add troubleshooting note for common issue

---

## Testing Tools and Techniques

### Automated Testing

**For code examples**:

```bash
# Create test script
cat > test-tutorial.sh << 'EOF'
#!/bin/bash
set -e  # Exit on error

echo "Testing Step 1..."
npm install @company/service

echo "Testing Step 2..."
node step2-create-task.js | grep -q "Task created: task-123"

echo "Testing Step 3..."
node step3-list-tasks.js | grep -q "All tasks:"

echo "All tests passed ✅"
EOF

chmod +x test-tutorial.sh
./test-tutorial.sh
```

### Snapshot Testing

**Capture actual outputs for documentation**:

```bash
# Run command and capture output
node create-task.js > expected-output-step2.txt 2>&1

# Include in tutorial exactly as captured
```

### API Signature Extraction

**Extract exact signatures from source**:

```typescript
// Read from: node_modules/@company/service/dist/index.d.ts
export function createTask(options: {
  id: string;
  title: string;
  priority: "low" | "medium" | "high";
}): Promise<Task>;

// Use EXACT signature in tutorial
// Copy parameter types exactly
// Don't guess or approximate
```

---

## Beginner Testing (Bonus)

**Have an actual beginner test your tutorial**:

### Beginner Test Protocol

1. **Find a beginner** (someone unfamiliar with the system)
2. **Observe them** following the tutorial
3. **Don't help** unless they're completely stuck
4. **Note where they struggle**
5. **Time how long each step takes**
6. **Ask for feedback**

### Observation Notes

```markdown
## Beginner Testing: TaskService Tutorial

**Tester**: Sarah (junior developer, 6 months experience)
**Date**: 2024-01-15
**Time**: 45 minutes total

**Observations**:

**Step 1** (8 min):

- Completed easily
- No issues

**Step 2** (15 min):

- Confused about where to create file (assumed src/)
- Had typo in import statement
- Eventually succeeded

**Step 3** (12 min):

- Straightforward
- Followed instructions well

**Feedback**:

- "Where do I create the file?" - needs clarification
- "What if I get an error?" - needs troubleshooting section
- Overall: "Clear and helpful once I figured out file location"

**Changes needed**:

- Add explicit file location in Step 2
- Add troubleshooting for import errors
- Increase Step 2 estimate to 15 minutes
```

---

## Testing Checklist Summary

Before publishing, verify:

1. **Fresh environment tested** ✅
2. **All commands work** ✅
3. **All code runs** ✅
4. **Outputs match** ✅
5. **APIs verified** ✅
6. **Times realistic** ✅
7. **Success criteria achievable** ✅
8. **Troubleshooting tested** ✅
9. **Metadata documented** ✅
10. **Test log saved** ✅

---

## Emergency: Tutorial Already Published

If tutorial is already published and you discover issues:

### Priority 1: API Errors

- Fix immediately
- Add "Updated: [date]" notice
- Note what was wrong

### Priority 2: Wrong Outputs

- Update with correct outputs
- Add note: "Output format changed in v2.0"

### Priority 3: Missing Steps

- Add missing steps
- Renumber if needed
- Update total time estimate

### Priority 4: Time Estimates

- Update estimates
- Note: "Time estimates updated based on user feedback"

---

## References

- Common Pitfalls Guide: See PITFALLS-GUIDE.md
- Tutorial Template: See TUTORIAL-TEMPLATE.md
- API Verification: Use api-documentation-verify skill
