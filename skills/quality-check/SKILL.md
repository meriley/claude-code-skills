---
name: quality-check
description: ⚠️ MANDATORY - Automatically invoked by safe-commit. Runs language-specific linting, formatting, static analysis, and type checking. Treats linter issues as build failures that MUST be fixed before commit. Auto-fixes when possible. NEVER run linters manually.
version: 1.0.1
---

# Code Quality Check Skill

## ⚠️ MANDATORY SKILL - AUTO-INVOKED BY SAFE-COMMIT

## Purpose

Enforce code quality standards through automated linting, formatting, and static analysis. Ensures code meets project conventions before committing.

**CRITICAL:** This skill is automatically invoked by safe-commit. NEVER run linters manually.

## 🚫 NEVER DO THIS

- ❌ Running `eslint` or `npm run lint` manually before commit
- ❌ Running `golangci-lint run` manually before commit
- ❌ Running `flake8` or `black` manually before commit
- ❌ Running linters outside of this skill during commit workflow

**Let safe-commit invoke this skill automatically. Manual linting before commit is REDUNDANT and FORBIDDEN.**

---

## ⚠️ SKILL GUARD - READ BEFORE RUNNING LINTERS MANUALLY

**Before using Bash tool to run linters, answer these questions:**

### ❓ Are you about to run `npm run lint` or `eslint`?

→ **STOP.** Are you doing this before commit? If YES, use safe-commit instead (it invokes this skill).

### ❓ Are you about to run `golangci-lint run`?

→ **STOP.** Are you doing this before commit? If YES, use safe-commit instead (it invokes this skill).

### ❓ Are you about to run `flake8`, `black`, or `mypy`?

→ **STOP.** Are you doing this before commit? If YES, use safe-commit instead (it invokes this skill).

### ❓ Are you about to run `prettier --check` or formatting tools?

→ **STOP.** Are you doing this before commit? If YES, use safe-commit instead (it invokes this skill).

### ❓ Are you checking code quality before committing?

→ **STOP.** Invoke safe-commit skill (it will invoke this skill automatically).

**IF YOU RUN LINTERS MANUALLY BEFORE COMMIT, YOU ARE CREATING REDUNDANCY AND WASTING TIME.**

When to run linters manually:

- ✅ During development/refinement (not for commit)
- ✅ When user explicitly requests quality check

When NOT to run linters manually:

- ❌ Before commit (use safe-commit instead)
- ❌ As part of commit workflow (use safe-commit instead)

**Safe-commit invokes this skill automatically. Don't duplicate the work.**

---

## Philosophy

**CRITICAL: Treat linter issues as syntax errors, not warnings.**

- All linter issues MUST be fixed before commit
- No exceptions unless explicitly approved by user
- Auto-fix when tools support it
- Manual fix when auto-fix unavailable

## Workflow (Quick Summary)

### Core Steps

1. **Detect Languages**: Check for package.json, go.mod, requirements.txt, Cargo.toml, etc.
2. **Run Standard Checks**: Linting, formatting, type checking, static analysis (auto-fix when possible)
3. **Run Deep Audits**: Language-specific skills (control-flow-check, type-safety-audit, n-plus-one-detection)
4. **Handle Results**: Report pass/auto-fix/fail, provide specific error locations and fixes
5. **Verify Multi-Language**: All languages must pass before commit

### Language Support

- **Node.js/TypeScript**: ESLint, Prettier, tsc, npm audit
- **Go**: gofmt, go vet, golangci-lint, go mod tidy
- **Python**: black, flake8, mypy, isort
- **Rust**: rustfmt, clippy
- **Java**: Maven/Gradle spotless, checkstyle

**For detailed language-specific commands and checks:**

```
Read `~/.claude/skills/quality-check/references/LANGUAGE-CHECKS.md`
```

Use when: Need specific tool commands, troubleshooting linter issues, or setting up new language

**For deep audit integration (control-flow, type-safety, N+1 detection):**

```
Read `~/.claude/skills/quality-check/references/DEEP-AUDITS.md`
```

Use when: Running language-specific deep audits or integrating specialized checks

**For result handling and reporting patterns:**

```
Read `~/.claude/skills/quality-check/references/RESULT-HANDLING.md`
```

Use when: Formatting output, handling auto-fix scenarios, or reporting manual fix requirements

---

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
