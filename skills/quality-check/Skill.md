---
name: Code Quality Check
description: Runs language-specific linting, formatting, static analysis, and type checking. Treats linter issues as build failures that MUST be fixed before commit. Auto-fixes when possible.
version: 1.0.0
---

# ⚠️ MANDATORY: Code Quality Check Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before EVERY single commit (ZERO EXCEPTIONS)
2. During code refinement phase
3. After making any code changes
4. Before creating pull requests
5. When user requests code quality review

**This skill is MANDATORY because:**
- Prevents linting errors from entering codebase (MANDATORY)
- Ensures code consistency across all files and developers
- Catches type errors and static analysis issues early
- Improves code readability and maintainability
- Prevents technical debt accumulation
- Enforces project coding standards

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Running commit WITHOUT invoking quality-check (standards violation)
- Committing code with linting errors (ZERO TOLERANCE)
- Committing with unresolved type errors (type safety violation)
- Committing code with format violations (standards violation)
- Using any/unknown types without addressing (type-safety violation)

**P1 Violations (High - Quality Failure):**
- Auto-fix available but not applied before reporting
- Not running all applicable language checks
- Missing language-specific deep audits (control-flow, error-handling, type-safety, n-plus-one)
- Unclear error messages or line references
- Not suggesting fixes for manual issues

**P2 Violations (Medium - Efficiency Loss):**
- Running linter checks sequentially instead of parallel
- Not checking for project-specific configuration
- Failing to verify fixes after auto-fixing

**Blocking Conditions:**
- ALL linting issues must be resolved (no exceptions)
- ALL type errors must be fixed
- ALL formatting issues must be corrected
- Language-specific deep audits must PASS
- Project configuration must be respected

---

## Purpose
Enforce code quality standards through automated linting, formatting, and static analysis. Ensures code meets project conventions before committing.

## When to Use
- **REQUIRED** before every commit
- During code refinement phase
- After making code changes
- When user requests code quality review

## Philosophy

**CRITICAL: Treat linter issues as syntax errors, not warnings.**
- All linter issues MUST be fixed before commit
- No exceptions unless explicitly approved by user
- Auto-fix when tools support it
- Manual fix when auto-fix unavailable

## Workflow

### Step 1: Detect Project Language(s)

Check for language indicators in parallel:

```bash
ls package.json go.mod requirements.txt Cargo.toml setup.py pyproject.toml 2>/dev/null
```

**Language Detection Rules:**
- `package.json` → Node.js/TypeScript
- `go.mod` or `*.go` files → Go
- `requirements.txt`, `Pipfile`, or `pyproject.toml` → Python
- `Cargo.toml` → Rust
- `pom.xml` or `build.gradle` → Java

Multiple languages possible (e.g., monorepo).

### Step 2: Run Language-Specific Quality Checks

Run all applicable checks in parallel when possible.

---

## Node.js / TypeScript

### Check 2.1: ESLint (Linting)
```bash
npm run lint
# OR if direct eslint:
npx eslint . --ext .js,.jsx,.ts,.tsx
```

**If issues found:**
```bash
npx eslint . --ext .js,.jsx,.ts,.tsx --fix
```

### Check 2.2: Prettier (Formatting)
```bash
npx prettier --check "**/*.{js,jsx,ts,tsx,json,css,md}"
```

**If issues found:**
```bash
npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,md}"
```

### Check 2.3: TypeScript Type Checking (if TypeScript)
```bash
npm run type-check
# OR if direct tsc:
npx tsc --noEmit
```

**No auto-fix available** - must fix type errors manually.

### Check 2.4: Package Audit (bonus)
```bash
npm audit --audit-level=moderate
```

---

## Go

### Check 2.1: go fmt (Formatting)
```bash
gofmt -l .
```

**If files listed (not formatted):**
```bash
gofmt -w .
```

### Check 2.2: go vet (Static Analysis)
```bash
go vet ./...
```

**No auto-fix** - must address issues manually.

### Check 2.3: golangci-lint (Comprehensive Linting)
```bash
golangci-lint run
```

**If auto-fix supported:**
```bash
golangci-lint run --fix
```

### Check 2.4: go mod tidy (Dependency Cleanup)
```bash
go mod tidy
```

Auto-fixes dependency issues.

---

## Python

### Check 2.1: black (Formatting)
```bash
black --check .
```

**If issues found:**
```bash
black .
```

### Check 2.2: flake8 (Linting)
```bash
flake8 .
```

**No auto-fix** - must address issues manually.

### Check 2.3: mypy (Type Checking)
```bash
mypy .
```

**No auto-fix** - must add type hints manually.

### Check 2.4: isort (Import Sorting)
```bash
isort --check-only .
```

**If issues found:**
```bash
isort .
```

---

## Rust

### Check 2.1: rustfmt (Formatting)
```bash
cargo fmt --check
```

**If issues found:**
```bash
cargo fmt
```

### Check 2.2: clippy (Linting)
```bash
cargo clippy -- -D warnings
```

**If auto-fix available:**
```bash
cargo clippy --fix --allow-dirty --allow-staged
```

---

## Java

### Check 2.1: Maven/Gradle Formatting
```bash
# Maven:
mvn spotless:check

# Gradle:
gradle spotlessCheck
```

**If issues found:**
```bash
# Maven:
mvn spotless:apply

# Gradle:
gradle spotlessApply
```

### Check 2.2: Maven/Gradle Linting
```bash
# Maven:
mvn checkstyle:check

# Gradle:
gradle checkstyleMain
```

---

## Step 2.5: Language-Specific Deep Audits

After standard linting/formatting, run specialized audits based on detected languages.

### For Go Projects

#### Invoke `control-flow-check` Skill
```bash
/skill control-flow-check
```

**What it audits:**
- Early return pattern usage
- Excessive nesting (> 2-3 levels)
- Large if/else blocks (> 10 lines)
- Guard clause placement
- Complex control flow refactoring opportunities

#### Invoke `error-handling-audit` Skill
```bash
/skill error-handling-audit
```

**What it audits:**
- Error wrapping with `%w` vs `%v`
- Error context sufficiency
- Error message formatting
- Error swallowing
- Panic usage outside initialization
- Error propagation patterns

**Report CRITICAL issues** from these audits - they should block commit.

---

### For JavaScript / TypeScript Projects

#### Invoke `eslint-master` Skill
```bash
/skill eslint-master
```

**What it does:**
- Sets up optimal ESLint configuration
- Migrates from legacy `.eslintrc` to flat config
- Configures framework-specific rules (React, Vue, Angular)
- Resolves ESLint errors efficiently
- Optimizes for CI/CD performance

**Report CRITICAL ESLint errors** - configuration must be valid before proceeding.

---

### For TypeScript Projects

#### Invoke `type-safety-audit` Skill (in addition to eslint-master)
```bash
/skill type-safety-audit
```

**What it audits:**
- `any` type usage (zero tolerance)
- Branded types for IDs
- Runtime validation at API boundaries
- Type guards vs type assertions
- Null/undefined handling
- Generic constraints
- tsconfig.json strict mode

**Report CRITICAL issues** from this audit - they should block commit.

---

### For React Projects

#### Invoke `react-hooks-optimizer` Skill (in addition to eslint-master)
```bash
/skill react-hooks-optimizer
```

**What it audits:**
- useEffect anti-patterns (state sync, event handling in effects)
- Memory leaks from uncleaned effects
- Race conditions in async effects
- Missing dependencies or unstable references
- Performance issues from excessive re-renders
- Hook composition and architecture problems

**Report CRITICAL issues** from this audit - memory leaks and race conditions block commit.

---

### For TypeScript + GraphQL Projects

#### Invoke `n-plus-one-detection` Skill (in addition to type-safety-audit)
```bash
/skill n-plus-one-detection
```

**What it audits:**
- N+1 query problems in resolvers
- Missing DataLoader usage
- Sequential queries in loops
- Nested resolver chains
- Performance impact estimation

**Report CRITICAL N+1 problems** - they have severe performance impact.

---

### Audit Results Integration

After running language-specific audits:

1. **Collect all CRITICAL issues** from specialized audits
2. **Combine with linting/formatting results**
3. **Block commit if any CRITICAL issues found**
4. **Report HIGH/MEDIUM issues as warnings**

Example combined output:
```
📊 Quality Check Summary:

Standard Checks:
✅ Go formatting (gofmt)
✅ Go static analysis (go vet)
✅ Go linting (golangci-lint)

Deep Audits:
❌ Control Flow: 2 CRITICAL issues
  - TaskService.ProcessTask (line 45): Nesting depth 4 levels
  - UserService.ValidateUser (line 120): 15-line if block needs extraction
⚠️  Error Handling: 5 HIGH issues
  - Using %v instead of %w in 3 locations
  - Missing error context in 2 locations

RESULT: ❌ FAILED - Must fix 2 CRITICAL control flow issues before commit
```

---

## Step 3: Handle Check Results

### If All Checks Pass:
```
✅ Code Quality PASSED

All checks completed:
- [Language]: Formatting ✓
- [Language]: Linting ✓
- [Language]: Type checking ✓
- [Language]: Static analysis ✓

Code quality verified. Safe to commit.
```

### If Auto-Fixable Issues:
1. Run auto-fix commands
2. Show what was fixed:
   ```
   🔧 Auto-fixed code quality issues:
   
   - Formatted 5 files with prettier
   - Fixed 3 linting issues with eslint --fix
   - Sorted imports in 2 Python files
   
   Changes have been applied. Please review the fixes.
   ```
3. Re-run checks to verify
4. If still failing after auto-fix, report manual issues

### If Manual Fixes Required:
```
❌ Code Quality FAILED

Manual fixes required:

[TypeScript Type Errors]
src/utils/parser.ts:42:15 - error TS2339: Property 'value' does not exist on type '{}'.
src/api/handlers.ts:128:20 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.

[Python flake8]
app/models.py:56:80: E501 line too long (88 > 79 characters)
app/views.py:23:1: F401 'typing.Optional' imported but unused

[Go vet]
pkg/parser/parser.go:145: composite literal uses unkeyed fields

MUST fix these issues before commit.

Suggestions:
- Review type definitions in parser.ts
- Add type assertions where needed
- Break long lines or increase line length limit
- Remove unused imports
- Use keyed fields in Go structs
```

## Step 4: Verify All Languages

If project has multiple languages, ensure ALL languages pass before proceeding.

```
Multi-Language Check:
- Go: ✅ PASSED
- TypeScript: ❌ FAILED (3 type errors)
- Python: ✅ PASSED

Cannot proceed - TypeScript checks must pass.
```

## Integration with Other Skills

This skill is invoked by:
- **`safe-commit`** - Before committing changes
- **`create-pr`** - Before creating pull requests

## Best Practices

1. **Run in parallel** - Multiple languages? Check simultaneously
2. **Auto-fix first** - Always attempt auto-fix before asking user
3. **Be specific** - Show exact file, line, and error
4. **Suggest solutions** - Don't just report errors, help fix them
5. **Verify fixes** - Re-run checks after auto-fixing
6. **No skip option** - Quality checks are mandatory

## Tool Installation Detection

Before running tools, check if they're available:

```bash
# Example for Node.js:
if ! command -v eslint &> /dev/null; then
    echo "ESLint not found. Install with: npm install -D eslint"
    exit 1
fi
```

**If tool missing:**
- Report missing tool
- Provide installation command
- Ask user to install or use project's package.json scripts

## Configuration Detection

Check for project-specific configuration:
- `.eslintrc.js`, `.eslintrc.json` (ESLint)
- `.prettierrc`, `prettier.config.js` (Prettier)
- `.golangci.yml` (golangci-lint)
- `pyproject.toml` (Python tools)
- `.editorconfig` (Cross-language)

**Use project config when available**, otherwise use sensible defaults.

## Handling Make/NPM Scripts

If project has quality scripts in Makefile or package.json:

```bash
# Check for make target:
make lint
make fmt

# Check for npm script:
npm run lint
npm run format
```

**Prefer project scripts** over direct tool invocation when available.

## Emergency Override

Only if user explicitly states "skip quality checks" or "I acknowledge quality issues":
1. Document the override in output
2. List specific issues being ignored
3. Suggest creating follow-up ticket
4. Proceed with commit

**This should be RARE - quality checks exist for good reason.**

---

## Anti-Patterns

### ❌ Anti-Pattern: Skipping Quality Checks

**Wrong approach:**
```
User: "Commit these changes"
Assistant: *immediately commits without running linters or type checks*
```

**Why wrong:**
- Linting errors accumulate in codebase
- Type issues cause runtime failures
- Code format becomes inconsistent
- Technical debt increases
- Makes future maintenance harder

**Correct approach:** Always run quality-check first
```
User: "Commit these changes"
Assistant: "Let me check code quality first..."
*Invokes quality-check skill*
*Runs linters, formatters, type checking*
*Auto-fixes what can be fixed*
*Reports any manual fixes needed*
```

---

### ❌ Anti-Pattern: Ignoring Manual Quality Issues

**Wrong approach:**
```
Type error: Property 'value' doesn't exist on type '{}'
Assistant: *commits code with type error anyway*
```

**Why wrong:**
- Type errors indicate bugs or inconsistencies
- Will fail in production
- Other developers can't use the code safely
- Violates type safety contract

**Correct approach:** Block on quality failures
```
Type error: Property 'value' doesn't exist
Assistant: "Cannot commit - Type error in parser.ts:42"
Assistant: "Fix: Add 'value' property to type definition"
*STOPS commit until type error fixed*
```

---

### ❌ Anti-Pattern: Not Running Deep Audits

**Wrong approach:**
```
User: "Commit these changes"
Assistant: *runs standard linting and formatting*
Assistant: *commits without running control-flow-check or error-handling-audit*
```

**Why wrong:**
- Control flow issues remain hidden (nesting, complexity)
- Error handling problems go undetected
- Type safety issues not caught
- Performance problems (N+1 queries) missed

**Correct approach:** Run all applicable audits
```
User: "Commit these changes"
Assistant: *runs linters and formatters*
Assistant: *invokes control-flow-check for Go*
Assistant: *invokes error-handling-audit for Go*
Assistant: *invokes type-safety-audit for TypeScript*
Assistant: *reports and blocks on CRITICAL issues*
```

---

## References

**Based on:**
- CLAUDE.md Section 1 (Core Policies - Code Quality Requirements)
- CLAUDE.md Section 3 (Available Skills Reference - quality-check)
- CLAUDE.md Section 3 (Available Skills Reference - language-specific audits)

**Related skills:**
- `security-scan` - Runs before quality-check
- `run-tests` - Runs after quality-check
- `eslint-master` - Language-specific audit (JavaScript/TypeScript)
- `react-hooks-optimizer` - Language-specific audit (React)
- `control-flow-check` - Language-specific audit (Go)
- `error-handling-audit` - Language-specific audit (Go)
- `type-safety-audit` - Language-specific audit (TypeScript)
- `n-plus-one-detection` - Language-specific audit (TypeScript + GraphQL)
- `safe-commit` - Invokes this skill before all commits
