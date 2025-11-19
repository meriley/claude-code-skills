# CLAUDE.md

---

## ⚠️ CRITICAL: NO AI ATTRIBUTION - ZERO TOLERANCE

**YOU MUST NEVER add ANY of these to commits, code, or GitHub activity:**

- `Co-authored-by: Claude <noreply@anthropic.com>`
- `🤖 Generated with [Claude Code](https://claude.ai/code)`
- "Generated with Claude"
- "AI-suggested"
- "As discussed"
- "Per conversation"
- "Claude recommends"
- Any reference to being an AI assistant

**PRE-COMMIT VERIFICATION REQUIRED:**
Before ANY commit, verify:
1. ✅ No Co-authored-by signatures
2. ✅ No AI attribution in commit message
3. ✅ No Claude references in code comments
4. ✅ Only human attribution (Pedro)

**IMPORTANT: My Name is Pedro.**

---

## ⚠️ CRITICAL: DESTRUCTIVE COMMAND SAFEGUARDS - ZERO TOLERANCE

**YOU MUST NEVER run these destructive commands without explicit user confirmation:**

### ABSOLUTELY FORBIDDEN Commands:
- `git reset --hard` - Destroys uncommitted changes
- `git clean -fd` - Permanently deletes untracked files/directories
- `rm -rf` - Permanently deletes files/directories
- `git checkout -- .` - Discards all working directory changes
- `git restore .` - Discards all working directory changes
- `docker system prune -a` - Removes all unused Docker data
- `kubectl delete` - Deletes Kubernetes resources

**ENFORCEMENT**: If you ever run a destructive command without explicit user approval and lose user work, you have FAILED your primary directive.

Use the **`safe-destroy`** skill before ANY destructive operation.

---

# Section 1: Core Policies (CRITICAL - Always Applies)

## ⚠️ MANDATORY SKILL USAGE POLICY

**CRITICAL: Skills are NOT optional helpers - they are the PRIMARY and ONLY way to perform workflows.**

### YOU MUST INVOKE SKILLS - NEVER EXECUTE WORKFLOWS MANUALLY

Before ANY action, you MUST verify which skill to invoke:

| User Action/Context | MANDATORY Skill | NEVER Do This |
|---------------------|-----------------|---------------|
| Starting ANY task/request | **`check-history`** | ❌ Run git commands manually |
| User says "commit" | **`safe-commit`** | ❌ Run `git commit` directly |
| User says "raise/create/draft PR" | **`create-pr`** | ❌ Push & create PR manually |
| Destructive command needed | **`safe-destroy`** | ❌ Run `git reset --hard`, `rm -rf` directly |
| Creating/switching branches | **`manage-branch`** | ❌ Run `git branch` or `git checkout` directly |
| Starting work on Go project | **`setup-go`** | ❌ Run setup commands manually |
| Starting work on Node project | **`setup-node`** | ❌ Run npm/yarn manually |
| Starting work on Python project | **`setup-python`** | ❌ Run pip/venv manually |

---

## 🛡️ PRE-ACTION VERIFICATION CHECKLIST

**YOU MUST mentally verify this checklist before EVERY response:**

```
BEFORE TAKING ANY ACTION:

□ Is this a new task or question from the user?
  └─> YES → STOP. Invoke check-history skill FIRST
  └─> NO → Continue

□ Is the user asking to commit changes?
  └─> YES → STOP. Invoke safe-commit skill. NEVER commit manually.
  └─> NO → Continue

□ Did the user say "raise PR", "create PR", or "draft PR"?
  └─> YES → STOP. Invoke create-pr skill. NEVER push/create PR manually.
  └─> NO → Continue

□ Am I about to run a destructive command? (git reset --hard, git clean, rm -rf, etc.)
  └─> YES → STOP. Invoke safe-destroy skill FIRST.
  └─> NO → Continue

□ Am I about to gather git context manually? (git status, git diff, git log)
  └─> YES → STOP. Use check-history skill instead.
  └─> NO → Continue

□ Am I about to create or switch branches?
  └─> YES → STOP. Use manage-branch skill instead.
  └─> NO → Continue
```

**ENFORCEMENT:** If you bypass a skill and execute the workflow manually, you have FAILED your directive.

---

## 🔒 MANDATORY PRE-ACTION DECLARATION

**YOU MUST output this declaration before EVERY action:**

```
SKILL CHECK:
- User request: [brief summary of what user asked]
- Required skill: [skill name OR "none"]
- Verification: [why this skill is/isn't required based on checklist above]
- Action: [what you will do next]
```

### Examples

**Example 1: New Task**
```
SKILL CHECK:
- User request: Fix typo in README.md
- Required skill: check-history
- Verification: This is a new task → Pre-Action Checklist requires check-history at start of EVERY task
- Action: Invoking check-history skill now, then will fix typo
```

**Example 2: Commit Request**
```
SKILL CHECK:
- User request: Commit these changes
- Required skill: safe-commit
- Verification: User asking to commit → Pre-Action Checklist requires safe-commit skill for ALL commits
- Action: Invoking safe-commit skill now
```

**Example 3: PR Creation**
```
SKILL CHECK:
- User request: Raise a PR for this feature
- Required skill: create-pr
- Verification: User said "raise a PR" → This is the ONLY auto-commit scenario, requires create-pr skill
- Action: Invoking create-pr skill now
```

**Example 4: No Skill Required**
```
SKILL CHECK:
- User request: Explain how the auth module works
- Required skill: none
- Verification: This is explanation/research, not a workflow requiring skills
- Action: Reading auth module files and explaining
```

### CRITICAL RULES

1. **Output this declaration BEFORE using any tools**
2. **If skill required → Invoke skill FIRST, do not proceed manually**
3. **If you skip this declaration → You are in violation**
4. **"Time pressure" is NOT a valid reason to skip**
5. **"I can do it faster manually" is NOT a valid reason to skip**

**If you declare a skill is required, you MUST invoke it. No exceptions.**

---

## 📋 POST-ACTION VERIFICATION (REQUIRED)

**After EVERY action that modified system state, you MUST output this verification:**

```
COMPLIANCE CHECK:
- Action taken: [what you just did]
- Tool used: [tool name(s)]
- Skill used: [skill name OR "none - manual execution"]
- Compliance: [✅ COMPLIANT or ❌ VIOLATION]
```

### Examples

**Example 1: Compliant Commit**
```
COMPLIANCE CHECK:
- Action taken: Committed changes with message "feat(auth): add JWT validation"
- Tool used: Skill
- Skill used: safe-commit
- Compliance: ✅ COMPLIANT - Used mandatory safe-commit skill for commit
```

**Example 2: VIOLATION - Manual Commit**
```
COMPLIANCE CHECK:
- Action taken: Ran `git commit -m "fix: update config"`
- Tool used: Bash
- Skill used: none - manual execution
- Compliance: ❌ VIOLATION - Should have used safe-commit skill

ACKNOWLEDGMENT:
I bypassed the safe-commit skill due to time pressure. This was wrong.
The safe-commit skill would have:
- Run security-scan (skipped)
- Run quality-check (skipped)
- Run run-tests (skipped)
- Requested user approval (skipped)

COMMITMENT:
I will invoke safe-commit skill for all future commits. No exceptions.
```

**Example 3: Compliant Research**
```
COMPLIANCE CHECK:
- Action taken: Read auth module files and explained architecture
- Tool used: Read
- Skill used: none - no skill required for research
- Compliance: ✅ COMPLIANT - Research tasks don't require skills
```

### If You Detect a VIOLATION

You MUST:
1. **Acknowledge the violation immediately** - State what rule you broke
2. **Explain why you bypassed** - Be honest about reasoning
3. **State consequences** - What checks were skipped
4. **Commit to compliance** - Promise to use skill next time

### Valid Reasons to Skip Post-Action Check

**NONE.** You must ALWAYS output the compliance check after system-modifying actions.

### Actions Requiring Verification

- ✅ Git operations (commit, push, branch creation, etc.)
- ✅ File creation/modification/deletion
- ✅ Configuration changes
- ✅ Dependency installation
- ✅ Test execution
- ✅ Build/deploy operations

**If you modified the system, verify compliance. No exceptions.**

---

## 🌳 SKILL DECISION TREE

**Use this decision tree for EVERY user interaction:**

```
User provides input
       │
       ├─> New task/question?
       │   └─> Invoke check-history skill
       │       └─> Analyze context
       │           └─> Continue with task
       │
       ├─> "commit these changes"?
       │   └─> Invoke safe-commit skill
       │       ├─> Runs security-scan
       │       ├─> Runs quality-check
       │       │   └─> Runs language-specific audits
       │       ├─> Runs run-tests
       │       ├─> Shows diff
       │       ├─> Requests approval
       │       └─> Creates commit
       │
       ├─> "raise/create/draft PR"?
       │   └─> Invoke create-pr skill
       │       ├─> Validates/creates branch
       │       ├─> Invokes safe-commit (auto-commit mode)
       │       ├─> Pushes to remote
       │       └─> Creates GitHub PR
       │
       ├─> Creating/switching branches?
       │   └─> Invoke manage-branch skill
       │       └─> Validates mriley/ prefix
       │
       ├─> Destructive operation needed?
       │   └─> Invoke safe-destroy skill
       │       ├─> Lists affected files
       │       ├─> Shows what will be lost
       │       ├─> Suggests alternatives
       │       └─> Requires double confirmation
       │
       ├─> Starting work on [language] project?
       │   └─> Invoke setup-[language] skill
       │       └─> Configures environment
       │
       └─> Other task
           └─> Complete task
               └─> If committing → Use safe-commit
```

---

## 🚫 ANTI-PATTERNS (NEVER DO THIS)

**These are FORBIDDEN actions that violate the skill-first policy:**

### Git Operations
- ❌ Running `git status && git diff && git log` manually → **Use `check-history` skill**
- ❌ Running `git add . && git commit -m "message"` → **Use `safe-commit` skill**
- ❌ Running `git push && gh pr create` → **Use `create-pr` skill**
- ❌ Running `git branch` or `git checkout -b` → **Use `manage-branch` skill**
- ❌ Running `git reset --hard` or `git clean -fd` → **Use `safe-destroy` skill**

### Testing & Quality
- ❌ Running `npm test` or `go test` manually before commit → **Let `safe-commit` invoke `run-tests`**
- ❌ Running `eslint` or `golangci-lint` manually → **Let `safe-commit` invoke `quality-check`**
- ❌ Checking for secrets manually → **Let `safe-commit` invoke `security-scan`**

### Project Setup
- ❌ Running `go mod tidy && golangci-lint install` → **Use `setup-go` skill**
- ❌ Running `npm install && npm init -y` → **Use `setup-node` skill**
- ❌ Running `python -m venv .venv && pip install` → **Use `setup-python` skill**

### Documentation
- ❌ Writing API docs without verifying source code → **Use `api-doc-writer` skill**
- ❌ Creating migration guides without checking both APIs → **Use `migration-guide-writer` skill**
- ❌ Writing tutorials without testing examples → **Use `tutorial-writer` skill**

**REMEMBER:** If a skill exists for the workflow, you MUST invoke it. Manual execution is a policy violation.

---

## Git Commit Permission Rules

### When You MAY Commit Automatically

**ONLY when user says: "raise a PR", "create a PR", "draft PR", or similar**

This phrase grants permission to:
1. ✅ Stage all unstaged changes (`git add .`)
2. ✅ Create commit with conventional commit message
3. ✅ Create branch with `mriley/` prefix
4. ✅ Push to remote
5. ✅ Create pull request

**YOU MUST invoke the `create-pr` skill for this workflow.**

### When You MUST Ask for Approval

**ALL commits after the initial PR creation require explicit user approval.**

**Before ANY subsequent commit or amend:**
1. Show diff: `git status & git diff`
2. Ask explicitly: "Should I [commit/amend] these changes?"
3. **STOP and WAIT** for explicit approval ("yes", "commit", "amend", "go ahead")
4. Only after approval: proceed with commit

**Phrases that DO NOT grant commit permission:**
- ❌ "looks good" (code approval ≠ commit approval)
- ❌ "correct"
- ❌ "that's right"
- ❌ "fix the bug" (instruction to code, not commit)
- ❌ Silence or no response

**YOU MUST invoke the `safe-commit` skill for all commits.**

<system-reminder>
MANDATORY SKILL USAGE - COMMITS:
- User says "commit" → YOU MUST invoke safe-commit skill
- User says "raise/create/draft PR" → YOU MUST invoke create-pr skill
- NEVER run `git commit` directly - this is a VIOLATION

Before using Bash tool for git commit:
❓ Have you invoked safe-commit skill?
   NO → STOP. You are about to VIOLATE core directive. Invoke safe-commit skill instead.
   YES → Proceed (skill will handle commit)
</system-reminder>

## Branch Naming Requirements

**CRITICAL: ALL branches MUST be prefixed with `mriley/`**

**Correct branch names:**
- ✅ `mriley/feat/parallel-rule-evaluation`
- ✅ `mriley/fix/race-condition`
- ✅ `mriley/refactor/config-cleanup`
- ✅ `mriley/perf/optimize-query`

**Incorrect branch names:**
- ❌ `feat/parallel-rule-evaluation`
- ❌ `parallel-rule-evaluation`
- ❌ `fix-bug`

**YOU MUST invoke the `manage-branch` skill for branch operations.**

## Testing Coverage Thresholds

- **Unit Tests**: Minimum 90% code coverage (REQUIRED)
- **Integration Tests**: All integration points tested
- **End-to-End Tests**: 100% pass rate (REQUIRED - no mocks)

**YOU MUST invoke the `run-tests` skill before committing. NEVER run tests manually.**

## Security Requirements

**YOU MUST enforce these security practices:**

1. **Secrets Scanning**: Never commit API keys, passwords, or tokens
2. **Dependency Security**: Check for known vulnerabilities
3. **Code Injection**: Validate all user inputs
4. **Authentication**: Verify proper authentication mechanisms
5. **Data Sanitization**: Ensure sensitive data is properly handled

**YOU MUST invoke the `security-scan` skill before committing. NEVER scan manually.**

## Code Quality Requirements

**CRITICAL: Treat all linter issues as build failures - they MUST be fixed before commit.**

- All linter issues MUST be resolved
- Code must be properly formatted
- Type checks must pass (TypeScript/Python)
- Static analysis must be clean

**YOU MUST invoke the `quality-check` skill before committing. NEVER run linters manually.**

<system-reminder>
MANDATORY SKILL USAGE - QUALITY & SECURITY:
- These skills are AUTO-INVOKED by safe-commit:
  • security-scan - Checks for secrets, vulnerabilities
  • quality-check - Runs linters, formatters, static analysis
  • run-tests - Runs unit/integration/E2E tests

- NEVER run these manually before commit:
  ❌ git status && git diff && git log → Use check-history skill
  ❌ npm test, go test, pytest → Let safe-commit invoke run-tests
  ❌ eslint, golangci-lint, flake8 → Let safe-commit invoke quality-check
  ❌ grep for secrets → Let safe-commit invoke security-scan

- When to invoke safe-commit:
  ✅ User says "commit these changes"
  ✅ User says "commit this"
  ✅ After fixing bugs/adding features when ready to commit
  ✅ When user explicitly requests a commit

- Safe-commit will handle ALL quality/security/testing checks automatically.
</system-reminder>

---

# Section 2: Standards & Formats

## Conventional Commit Format

**YOU MUST follow the Conventional Commits specification for all commit messages:**

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

**IMPORTANT: Scope is REQUIRED for all commits**

### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Changes to build system or dependencies
- `ci`: CI/CD configuration changes
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

### Common Scopes
- `auth`: Authentication related
- `api`: API endpoints
- `db`: Database related
- `ui`: User interface
- `core`: Core functionality
- `utils`: Utility functions
- `config`: Configuration
- `deps`: Dependencies
- `security`: Security-related changes
- `perf`: Performance improvements
- `*`: Use asterisk for truly global changes

### Examples
```bash
# Good commits (scope required)
feat(auth): add OAuth2 integration for GitHub
fix(parser): handle empty input gracefully
refactor(metadata): extract functionality to dedicated package
docs(api): update endpoint documentation
test(utils): add test cases for string helpers
chore(deps): update dependencies
style(*): apply consistent formatting across codebase
security(auth): implement rate limiting for login attempts

# Bad commits (NEVER use these)
refactor: extract metadata functionality  # Missing scope!
Updated code
Fixed stuff
WIP
```

### Breaking Changes
Mark breaking changes with `!` after type/scope:
```
feat(api)!: change response format for /users endpoint
```

---

# Section 3: Available Skills Reference

All major workflows have been extracted into composable skills. **YOU MUST invoke these skills - manual execution is FORBIDDEN.**

## Core Git Workflow Skills (Phase 1)

### `check-history` - Git Context Gathering
**⚠️ MANDATORY:** YOU MUST invoke this skill at the start of EVERY task or when investigating bugs

**What it does:**
- Runs parallel git commands (status, diff, log)
- Analyzes current branch state
- Identifies recent related work
- Provides context summary

**Invoke:** ALWAYS before starting any task. NEVER gather git context manually.

---

### `safe-commit` - Complete Commit Workflow
**⚠️ MANDATORY:** YOU MUST invoke this skill when committing changes (user says "commit these changes")

**What it does:**
- Runs security-scan skill
- Runs quality-check skill
- Runs run-tests skill
- Shows diff to user
- Requests approval (REQUIRED except during PR creation)
- Creates conventional commit
- NO AI attribution

**Approval required:** YES (except when invoked by `create-pr`)

**NEVER commit manually using git commands.**

---

### `create-pr` - Pull Request Creation
**⚠️ MANDATORY:** YOU MUST invoke this skill ONLY when user says "raise/create/draft PR"

**What it does:**
- Validates or creates branch with `mriley/` prefix
- Auto-commits all changes (invokes `safe-commit` WITHOUT approval)
- Pushes to remote
- Creates GitHub PR
- Returns PR URL

**This is the ONLY auto-commit scenario.**

**NEVER create PRs manually using git push and gh pr create.**

---

## Quality & Security Skills (Phase 2)

### `security-scan` - Comprehensive Security Checks
**⚠️ MANDATORY:** Automatically invoked by `safe-commit`. NEVER run security checks manually.

**What it does:**
- Scans for secrets (API keys, passwords, tokens)
- Checks dependency vulnerabilities
- Detects code injection risks
- Verifies authentication mechanisms
- Checks for weak cryptography

**MUST pass before commit.**

---

### `quality-check` - Code Quality Verification
**⚠️ MANDATORY:** Automatically invoked by `safe-commit`. NEVER run linters manually.

**What it does:**
- Runs language-specific linting (ESLint, golangci-lint, flake8, etc.)
- Checks code formatting (Prettier, black, gofmt)
- Runs static analysis (go vet, mypy)
- Auto-fixes when possible

**MUST pass before commit.**

---

### `run-tests` - Comprehensive Testing
**⚠️ MANDATORY:** Automatically invoked by `safe-commit`. NEVER run tests manually before commit.

**What it does:**
- Runs unit tests (90%+ coverage required)
- Runs integration tests
- Runs E2E tests (100% pass required)
- Generates coverage reports
- Identifies coverage gaps

**MUST pass before commit.**

---

### Language-Specific Quality Skills

These skills provide deep, language-specific code quality audits. They are automatically invoked by `quality-check` when working with their respective languages.

#### `control-flow-check` - Go Control Flow Excellence
**When to use:** Automatically invoked by `quality-check` for Go projects

**What it does:**
- Checks for early return pattern usage
- Detects excessive nesting depth (> 2-3 levels)
- Identifies large if/else blocks (> 10 lines)
- Verifies guard clauses at function start
- Suggests refactoring for complex control flow

**Based on:** RMS Go Coding Standards

---

#### `error-handling-audit` - Go Error Handling
**When to use:** Automatically invoked by `quality-check` for Go projects

**What it does:**
- Verifies errors wrapped with `%w` (not `%v`)
- Checks error context sufficiency
- Validates error message format
- Detects error swallowing
- Flags panic usage outside initialization
- Ensures proper error propagation

**Based on:** RMS Go Coding Standards

---

#### `n-plus-one-detection` - GraphQL/TypeScript Performance
**When to use:** Automatically invoked by `quality-check` for TypeScript + GraphQL projects

**What it does:**
- Detects N+1 query problems in resolvers
- Verifies DataLoader usage for batching
- Identifies sequential queries in loops
- Checks nested resolver chains
- Estimates performance impact
- Suggests DataLoader implementations

**Based on:** Hermes Code Reviewer patterns

---

#### `type-safety-audit` - TypeScript Type Safety
**When to use:** Automatically invoked by `quality-check` for TypeScript projects

**What it does:**
- Detects `any` type usage (zero tolerance)
- Checks for branded types on IDs
- Verifies runtime validation at API boundaries
- Validates type guards vs assertions
- Checks null/undefined handling
- Verifies generic constraints
- Validates tsconfig.json strict mode

**Based on:** Hermes Code Reviewer patterns

---

#### `api-documentation-verify` - Documentation Accuracy
**When to use:** Before committing API documentation or during doc reviews

**What it does:**
- Verifies API methods exist in source code
- Validates parameter and return types
- Tests code examples for runnability
- Checks performance claims have benchmarks
- Verifies configuration options exist
- Flags undocumented errors
- Detects marketing language and buzzwords

**Based on:** Technical Documentation Expert patterns

---

## Planning & Safety Skills (Phase 3)

### `sparc-plan` - Implementation Planning
**When to use:** Before starting significant features (> 8 hours work)

**What it does:**
- Creates comprehensive SPARC framework plans:
  1. **Specification**: Requirements, constraints, success criteria
  2. **Pseudocode**: Algorithm descriptions
  3. **Architecture**: System design, components, data models
  4. **Refinement**: Quality, performance, security plans
  5. **Completion**: Definition of done, checklists
- Generates ranked task list with dependencies
- Identifies risks and blockers
- Creates security and performance plans

**Invokes:** `check-history` for context

---

### `safe-destroy` - Destructive Operation Safety
**⚠️ MANDATORY:** YOU MUST invoke this skill before ANY destructive operation

**What it does:**
- Lists what will be affected/deleted
- Shows diff/files that will be lost
- Suggests safer alternatives
- Requires explicit double confirmation
- Provides recovery options

**Commands requiring this skill:**
- `git reset --hard`
- `git clean -fd`
- `rm -rf`
- `docker system prune`

**NEVER run destructive commands without invoking this skill first.**

---

### `manage-branch` - Branch Management
**⚠️ MANDATORY:** YOU MUST invoke this skill when creating or switching branches

**What it does:**
- Enforces `mriley/` prefix naming convention
- Validates branch names
- Creates branches with proper type prefix
- Handles branch switching with safety checks

**Branch format:** `mriley/<type>/<descriptive-name>`

**NEVER create or switch branches manually using git commands.**

---

## Language Setup Skills (Phase 4)

### `setup-go` - Go Development Environment
**When to use:** Starting work on Go project

**What it does:**
- Verifies Go installation
- Runs `go mod tidy`
- Sets up golangci-lint
- Configures testing
- Creates Makefile
- Sets up git hooks

---

### `setup-python` - Python Development Environment
**When to use:** Starting work on Python project

**What it does:**
- Creates virtual environment
- Installs dependencies
- Sets up pytest, black, flake8, mypy
- Configures pre-commit hooks
- Creates requirements files

---

### `setup-node` - Node.js Development Environment
**When to use:** Starting work on Node.js/TypeScript project

**What it does:**
- Installs dependencies (npm/yarn/pnpm)
- Sets up ESLint + Prettier
- Configures TypeScript
- Sets up Jest/Vitest
- Configures Husky + lint-staged

---

## Documentation Creation Skills (Phase 5)

These skills create different types of technical documentation following the Diátaxis framework. All enforce zero-fabrication policy for APIs.

### `api-doc-writer` - API Reference Documentation
**When to use:** Documenting APIs, packages, or public interfaces

**What it does:**
- Reads source code before documenting
- Extracts exact method signatures
- Creates structured API reference (Diátaxis Reference pattern)
- Verifies every method exists with correct signature
- Includes working examples from tests
- Zero tolerance for fabricated methods

**Includes:** REFERENCE.md template for structured output

**Based on:** Technical Documentation Expert patterns

---

### `migration-guide-writer` - Migration How-To Guides
**When to use:** Breaking changes, version upgrades, system replacements

**What it does:**
- Creates problem-oriented migration guides (Diátaxis How-To pattern)
- Maps old APIs to new APIs (both verified)
- Before/After examples for common patterns
- Documents breaking changes explicitly
- Troubleshooting for common migration errors
- No unverified performance claims

**Based on:** Technical Documentation Expert patterns

---

### `tutorial-writer` - Learning-Oriented Tutorials
**When to use:** Onboarding, new features, getting started guides

**What it does:**
- Creates beginner-friendly tutorials (Diátaxis Tutorial pattern)
- Step-by-step with time estimates and success criteria
- Clear prerequisites and learning outcomes
- Complete working examples (tested and verified)
- Minimal explanations (WHAT not WHY)
- Builds confidence through progressive success

**Based on:** Technical Documentation Expert patterns

---

## Infrastructure & DevOps Skills

### `helm-chart-expert` - Helm Chart Development & Review
**When to use:** Creating or reviewing Helm charts, ArgoCD integration, GitOps workflows

**What it does:**
- Provides production-ready Helm chart templates
- Comprehensive chart review checklist (security, structure, values, templates, testing, documentation)
- ArgoCD Application and ApplicationSet patterns for multi-environment deployments
- Secrets management strategies (Helm Secrets, External Secrets Operator)
- Testing templates (unit tests with helm-unittest, integration tests, helm test hooks)
- Production deployment patterns (blue-green, canary, multi-stage, rolling updates)
- Troubleshooting guide for common Helm issues
- Quality gates and CI/CD integration patterns
- Monitoring and observability templates (ServiceMonitor, Grafana dashboards)

**Based on:** DevOps team best practices

---

### `pr-description-writer` - GitHub PR Description Writer
**When to use:** Creating or verifying pull request descriptions

**What it does:**
- Discovers and follows project PR templates in .github directory
- Generates PR descriptions from git changes (diff, log, commits)
- Verifies all claims against actual code changes
- Zero fabrication tolerance (no fake features or methods)
- No marketing language or unverified performance claims
- Verifies test coverage numbers match test output
- Documents breaking changes from API signature changes
- Links related issues from commit messages
- Two modes: Create (generate new) and Verify (audit existing)

**Based on:** Technical Documentation Expert verification patterns

---

## Skill Composition

Skills can invoke other skills:

```
create-pr
  ├─> check-history (context)
  ├─> manage-branch (if needed)
  └─> safe-commit (auto-commit mode)
       ├─> security-scan
       ├─> quality-check
       │    ├─> control-flow-check (Go projects)
       │    ├─> error-handling-audit (Go projects)
       │    ├─> n-plus-one-detection (TypeScript + GraphQL)
       │    └─> type-safety-audit (TypeScript projects)
       └─> run-tests

sparc-plan
  └─> check-history (context)

Documentation Skills (work together):
  api-doc-writer
    (creates API reference)
    ↓ references ↓
  migration-guide-writer
    (shows before/after with verified APIs)
    ↓ links to ↓
  tutorial-writer
    (teaches with verified examples)
    ↓ verified by ↓
  api-documentation-verify
    (audits all docs for accuracy)
```

---

# Section 4: Tools & Performance Guidelines

## Available Tools

### Context7 (Documentation Research)
**ALWAYS check Context7 first when working with external libraries:**
- `mcp__context7__resolve-library-id`: Find library documentation
- `mcp__context7__get-library-docs`: Retrieve library docs

### Filesystem Tools
- `mcp__filesystem__read_file`: Read files
- `mcp__filesystem__write_file`: Write files
- `mcp__filesystem__edit_file`: Line-based edits
- `mcp__filesystem__list_directory`: Directory listings
- `mcp__filesystem__directory_tree`: Recursive structure
- `mcp__filesystem__create_directory`: Create directories
- `mcp__filesystem__search_files`: Pattern search

### Git Operations
- `mcp__git__git_status`: Check status
- `mcp__git__git_diff`: View differences
- `mcp__git__git_add`: Stage files
- `mcp__git__git_commit`: Create commits
- `mcp__git__git_log`: View history

## Parallel Tool Usage

**IMPORTANT: Claude Code supports concurrent tool calls - use this for maximum efficiency:**

**YOU MUST use parallel tool calls when:**
- Reading multiple unrelated files
- Running multiple independent bash commands
- Performing multiple searches across different directories
- Executing multiple git operations

**Example:**
```bash
# Always batch independent operations in a single response
git status & git diff & git log --oneline -10 &
```

## Memory and Resource Management

- **Large Codebases**: Use targeted searches instead of reading entire files
- **Long Operations**: Set appropriate timeouts (default 2min, max 10min)
- **Batch Operations**: Group related tasks to minimize context switching

---

# Section 5: Development Philosophy & Best Practices

## SPARC Framework Overview

When developing any significant project, follow the **SPARC** framework:

1. **Specification**: Define project requirements, user scenarios, and constraints
2. **Pseudocode**: Create high-level code outlines and algorithm descriptions
3. **Architecture**: Design the system structure, components, and interactions
4. **Refinement**: Iteratively improve the implementation
5. **Completion**: Finalize and prepare for deployment

**Use the `sparc-plan` skill to generate comprehensive implementation plans.**

## Code Documentation Standards

Write self-documenting code:
- **Descriptive naming**: Functions and variables clearly express purpose
- **Comments for WHY, not WHAT**: Explain business logic only
- **No self-explanatory comments**: Avoid obvious descriptions
- **Concise API docs**: Minimal, maintainable comments
- **Refactor over explain**: Extract complex logic into well-named functions

## Best Practices Summary

1. **Check git history before starting** (YOU MUST invoke `check-history` skill)
2. **Plan before implementing** (YOU MUST invoke `sparc-plan` skill for significant work)
3. **Security by design** (never retrofit security)
4. **Performance awareness** (profile early and often)
5. **Start simple, enhance progressively**
6. **Test incrementally** (TDD when appropriate)
7. **Use descriptive naming** (code as documentation)
8. **Follow language conventions** (NEVER run linters manually)
9. **Handle errors gracefully** (fail fast, recover gracefully)
10. **Get user approval for milestones** (never surprise the user)
11. **Batch tool calls** (use parallel operations for efficiency)
12. **Security scanning** (NEVER commit secrets or vulnerabilities)

## Workflow Summary

1. **Check History**: YOU MUST invoke `check-history` skill
2. **Plan** (if significant): YOU MUST invoke `sparc-plan` skill
3. **Implement**: Build following the plan
4. **Commit**: YOU MUST invoke `safe-commit` skill (requires approval)
5. **Create PR**: YOU MUST invoke `create-pr` skill (only auto-commit scenario)

**CRITICAL:** NEVER execute these workflows manually with git commands.

<system-reminder>
MANDATORY SKILL ENFORCEMENT SUMMARY:

Before EVERY action:
1. Output SKILL CHECK declaration
2. Verify which skill (if any) is required
3. If skill required → Invoke it FIRST
4. After action → Output COMPLIANCE CHECK

Skill Usage Rules:
- New task → check-history skill (ALWAYS)
- Commit → safe-commit skill (ALWAYS)
- Raise PR → create-pr skill (ONLY trigger)
- Destructive command → safe-destroy skill (ALWAYS)
- Branch ops → manage-branch skill (ALWAYS)

NEVER bypass skills for:
❌ "Time pressure" - NOT valid
❌ "Can do it faster" - NOT valid
❌ "Skill is loading" - NOT valid
❌ "Just this once" - NOT valid

If you bypass a mandatory skill, you have VIOLATED your core directive.
</system-reminder>

---

## Important Reminders

- **Name**: User's name is Pedro
- **Attribution**: Never self-identify as AI in any outputs
- **Branches**: ALL branches MUST use `mriley/` prefix
- **Commits**: Always use conventional commit format with scope
- **Commit Permission**: ONLY "raise/create/draft PR" grants automatic commit permission
- **Post-PR Commits**: ALL commits after initial PR require explicit approval
- **Review**: Show diff and ask before every commit (except initial PR)
- **Testing**: Never compromise on coverage requirements (90%+ unit, 100% E2E)
- **Quality**: Treat linting as mandatory, not optional
- **Security**: Never commit secrets or ignore security issues
- **SAFETY**: Never run destructive commands without explicit user confirmation (YOU MUST invoke `safe-destroy` skill)
- **Efficiency**: Use parallel tool calls whenever possible
- **Skills**: YOU MUST invoke skills for workflows - manual execution is FORBIDDEN
