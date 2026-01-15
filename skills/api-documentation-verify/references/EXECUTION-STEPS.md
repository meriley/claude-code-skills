## Step-by-Step Execution

### Step 1: Identify Documentation Files

```bash
# Find all documentation files
find . -name "*.md" -o -name "README*" -o -name "DOCS*" -o -name "API*"
find . -path "*/docs/*" -name "*.md"
```

### Step 2: Read Documentation Files

Use Read tool to examine documentation, focusing on:

- API method signatures
- Code examples
- Configuration options
- Error documentation
- Performance claims

### Step 3: Extract Claims to Verify

For each documentation file:

**A. API Methods/Functions**

1. Extract all documented methods: names, parameters, return types
2. Note the source file/class they should exist in
3. Create verification checklist

**B. Code Examples**

1. Extract all code blocks from documentation
2. Note expected imports and setup
3. Identify what needs verification

**C. Configuration**

1. Extract all configuration examples
2. Note expected config fields and types
3. List what needs verification

**D. Performance Claims**

1. Extract all statements about speed, latency, throughput
2. Note if benchmark reference provided
3. Flag unsupported claims

### Step 4: Verify Against Source Code

**A. Method Existence and Signatures**

```bash
# Find the source file mentioned in docs
Read [source_file_path]

# Extract actual method signatures
# Compare with documented signatures
```

For each documented method:

1. Search for method definition in source
2. Extract actual signature (parameters, return type)
3. Compare actual vs documented
4. Flag: FABRICATED, VERIFIED, or MISMATCH

**B. Code Example Validation**
For each code example:

1. Check if imports reference real modules
2. Verify API calls use actual signatures
3. Check if variables are properly defined
4. Verify error handling exists
5. Flag if example couldn't run

**C. Configuration Verification**

1. Find configuration interface/type in source
2. Extract actual config fields
3. Compare with documented options
4. Flag fabricated or misnamed options

**D. Error Verification**

1. Search source for `throw` statements
2. Extract all error types thrown
3. Compare with documented errors
4. Flag undocumented errors

**E. Performance Claim Verification**

1. Search for benchmark files
2. If claim has benchmark reference, verify file exists
3. If no benchmark, flag as UNVERIFIED
4. Check if benchmark results match claims

### Step 5: Check for Marketing Language

1. Scan documentation text for banned words/phrases
2. Flag marketing language instances
3. Suggest objective alternatives

### Step 6: Generate Report

```markdown
## API Documentation Verification: [doc_file]

### 🚨 CRITICAL Issues (Must Fix Before Commit)

#### Fabricated API Method

- **Documentation**: `updateUserPreferences(userId: string, prefs: object)`
  - **Location**: README.md:45
  - **Issue**: Method does not exist in UserService
  - **Fix**: Remove from documentation or implement the method

#### API Signature Mismatch

- **Documentation**: `getTasks(): Promise<Task[]>`
  - **Actual**: `getTasks(partnerId: string, filters?: TaskFilters): Promise<PaginatedResult<Task>>`
  - **Location**: API.md:120
  - **Issues**:
    - Missing required parameter `partnerId`
    - Missing optional parameter `filters`
    - Wrong return type: `Task[]` vs `PaginatedResult<Task>`
  - **Fix**: Update documentation to match actual signature

#### Non-Runnable Code Example

- **Location**: EXAMPLES.md:67-74
  - **Issues**:
    - `taskService` variable not defined
    - Missing required `partnerId` parameter
    - No import statements
    - No error handling
  - **Fix**: Provide complete, runnable example with imports and error handling

#### Unverified Performance Claim

- **Location**: README.md:89
  - **Claim**: "Response times under 10ms for most queries"
  - **Issue**: No benchmark data or reference provided
  - **Fix**: Either add benchmark reference or remove claim

### ⚠️ HIGH Priority Issues

#### Undocumented Error

- **Error**: `PermissionError`
  - **Thrown In**: TaskService.getTask() (line 45)
  - **Documentation**: Not mentioned in error documentation
  - **Fix**: Add to error documentation with conditions when thrown

#### Configuration Mismatch

- **Documented Field**: `timeout: 5000`
  - **Actual Field**: `timeoutMs: 5000`
  - **Location**: CONFIG.md:23
  - **Fix**: Update documentation to use `timeoutMs`

#### Fabricated Configuration Option

- **Documented**: `cacheSize: 1000`
  - **Issue**: Option doesn't exist in TaskServiceConfig interface
  - **Fix**: Remove from documentation

### ℹ️ MEDIUM Priority Issues

#### Marketing Language

- **Location**: README.md:12
  - **Text**: "blazing-fast, enterprise-grade performance"
  - **Issue**: Marketing buzzwords in technical documentation
  - **Fix**: Replace with objective description: "Uses connection pooling to reduce query latency"

#### Dependency Version Mismatch

- **Documentation**: "Requires Node.js 16+"
  - **package.json**: "node": ">=18.0.0"
  - **Location**: README.md:150
  - **Fix**: Update docs to "Requires Node.js 18+"

### ✅ Verified Accurate

- `getUser(id: string): Promise<User>` - Signature matches (UserService.ts:23)
- `TaskNotFoundError` - Error exists and is thrown (errors.ts:45)
- Code example at EXAMPLES.md:10-25 - Runnable and accurate
```

### Step 7: Provide Corrected Examples

For each critical issue, provide the correct version:

````markdown
#### Corrected Example: getTasks

**Incorrect Documentation**:
\```typescript
const tasks = await taskService.getTasks();
\```

**Correct Documentation**:
\```typescript
import { TaskService } from '@/services/TaskService';
import type { TaskFilters, PaginatedResult, Task } from '@/types';

async function example() {
const taskService = new TaskService();

const filters: TaskFilters = {
status: 'open'
};

const result: PaginatedResult<Task> = await taskService.getTasks(
'partner-123', // Required partnerId parameter
filters
);

console.log(`Found ${result.total} tasks, showing ${result.items.length}`);
return result.items;
}
\```
````

### Step 8: Summary Statistics

```markdown
## Summary

- Documentation files checked: X
- API methods verified: Y
- Issues found: Z
  - CRITICAL (fabricated/mismatch): A
  - HIGH (missing docs): B
  - MEDIUM (marketing language): C
- Code examples verified: W
- Accurate items: V
```

