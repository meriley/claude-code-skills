## Workflow

### Step 1: Check Git Status

Run parallel git commands to understand current state:

```bash
git status & git diff & git log --oneline -5 &
```

**Analyze:**

- What files are changed (staged and unstaged)
- Current branch name
- Recent commit messages (for context)
- Uncommitted changes

### Step 2: Invoke Dependent Skills

Run these skills in sequence (each must pass):

#### 2.1: Security Scan

```
Invoke: security-scan skill
```

**Must pass before proceeding.**

- No secrets in code
- No dependency vulnerabilities
- No code injection risks

#### 2.2: Quality Check

```
Invoke: quality-check skill
```

**Must pass before proceeding.**

- All linters pass
- Code formatted correctly
- Type checks pass
- Static analysis clean

#### 2.3: Run Tests

```
Invoke: run-tests skill
```

**Must pass before proceeding.**

- Unit tests: 90%+ coverage
- Integration tests: All pass
- E2E tests: 100% pass rate

**If ANY skill fails:**

- STOP the commit workflow
- Report failure to user
- Provide remediation steps
- Wait for user to fix issues
- Restart from Step 1 when ready

### Step 3: Show Diff to User

Display what will be committed:

```bash
git status
echo "---"
git diff --stat
echo "---"
git diff
```

**Present to user:**

```
Ready to commit the following changes:

Files changed:
- src/api/handlers.go (modified)
- src/api/handlers_test.go (modified)
- pkg/auth/validator.go (new file)

Summary:
M  src/api/handlers.go          | 45 ++++++++++++++++++++++++++++++
M  src/api/handlers_test.go     | 28 +++++++++++++++++++
A  pkg/auth/validator.go        | 67 ++++++++++++++++++++++++++++++++++++++++++

All safety checks passed:
✅ Security scan: PASSED
✅ Quality check: PASSED
✅ Tests: PASSED (coverage: 94.2%)

Changes add JWT token validation with comprehensive tests.
```

### Step 4: Request User Approval

**CRITICAL: You MUST ask and WAIT for approval (except during PR creation)**

```
Should I commit these changes?
```

**STOP and WAIT for user response.**

**Proceed only if user says:**

- "yes"
- "commit"
- "go ahead"
- "proceed"
- "approve"

**DO NOT proceed if user says:**

- "looks good" (ambiguous - ask for clarification)
- "correct" (not explicit permission)
- Provides no response (wait)

### Step 5: Generate Commit Message

Use Conventional Commits format with REQUIRED scope:

```
<type>(<scope>): <subject>

[optional body]
```

**Commit Type Selection:**

- `feat`: New feature added
- `fix`: Bug fix
- `refactor`: Code restructuring (no functionality change)
- `perf`: Performance improvement
- `test`: Adding/updating tests only
- `docs`: Documentation only
- `style`: Code style/formatting only
- `build`: Build system or dependencies
- `ci`: CI/CD configuration
- `chore`: Other changes (config, tooling)

**Scope Selection:**
Analyze the files changed and determine scope:

- Single area (e.g., `auth`, `api`, `parser`) → Use specific scope
- Multiple related areas (e.g., `api` and `api_test`) → Use primary area
- Truly global changes → Use `*`

**Subject Guidelines:**

- Use imperative mood ("add", not "added" or "adds")
- No capital first letter
- No period at end
- Max 50 characters
- Describe WHAT and WHY, not HOW

**Body Guidelines (optional):**

- Provide additional context if needed
- Explain motivation for changes
- Note any breaking changes
- Reference issues/tickets: "Closes #123"

**Example Commit Messages:**

```
feat(auth): add JWT token validation

Implement JWT token validation middleware with expiry
checking and refresh token support. Includes comprehensive
unit tests and integration tests.

Closes #156
```

```
fix(parser): handle empty input gracefully

Previously panicked on empty input. Now returns
appropriate error with helpful message.
```

```
refactor(api): extract validation logic to dedicated package

Move validation code from handlers to pkg/validation
for better testability and reusability.
```

### Step 6: Create Commit

Stage all changes and create commit:

```bash
git add .
```

**Create commit with heredoc for proper formatting:**

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT token validation

Implement JWT token validation middleware with expiry
checking and refresh token support. Includes comprehensive
unit tests and integration tests.

Closes #156
EOF
)"
```

**CRITICAL: NO AI attribution in commit message or Co-authored-by tags**

### Step 7: Verify Commit Success

```bash
git show --stat HEAD
```

**Confirm:**

- Commit created successfully
- Correct files included
- Commit message formatted correctly
- NO AI attribution present
- Author is mriley (mriley)

**Report to user:**

```
✅ Commit created successfully

Commit: a1b2c3d
Author: mriley
Message: feat(auth): add JWT token validation

Files committed:
- src/api/handlers.go
- src/api/handlers_test.go
- pkg/auth/validator.go

Working directory: clean
```

### Step 8: Post-Commit Status Check

```bash
git status
```

Confirm working directory is clean.

