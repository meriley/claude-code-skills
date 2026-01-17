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

**CRITICAL: After --fix, MUST re-run check to verify. NEVER assume fix succeeded.**

### Check 2.2: Prettier (Formatting)

```bash
npx prettier --check "**/*.{js,jsx,ts,tsx,json,css,md}"
```

**If issues found:**

```bash
npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,md}"
```

**CRITICAL: After --write, MUST re-run check to verify. NEVER assume fix succeeded.**

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

**CRITICAL: After -w, MUST re-run `gofmt -l .` to verify. NEVER assume fix succeeded.**

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

**CRITICAL: After --fix, MUST re-run `golangci-lint run` to verify. NEVER assume fix succeeded.**

### Check 2.4: go mod tidy (Dependency Cleanup)

```bash
go mod tidy
```

Auto-fixes dependency issues.

---

## Python

### Check 2.1: ruff (Linting)

```bash
ruff check .
```

**If issues found:**

```bash
ruff check --fix .
```

**CRITICAL: After --fix, MUST re-run `ruff check .` to verify. NEVER assume fix succeeded.**

### Check 2.2: ruff format (Formatting)

```bash
ruff format --check .
```

**If issues found:**

```bash
ruff format .
```

**CRITICAL: After formatting, MUST re-run `ruff format --check .` to verify.**

### Check 2.3: mypy (Type Checking)

```bash
mypy .
```

**No auto-fix** - must add type hints manually.

**CRITICAL: Type errors are build failures, not warnings. ALL must be resolved.**

### Legacy Tools (if ruff unavailable)

If project doesn't have ruff configured, fall back to:

- black --check / black (formatting)
- flake8 (linting)
- isort --check-only / isort (import sorting)

**Same rerun policy applies to legacy tools.**

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

**CRITICAL: After formatting, MUST re-run `cargo fmt --check` to verify. NEVER assume fix succeeded.**

### Check 2.2: clippy (Linting)

```bash
cargo clippy -- -D warnings
```

**If auto-fix available:**

```bash
cargo clippy --fix --allow-dirty --allow-staged
```

**CRITICAL: After --fix, MUST re-run `cargo clippy -- -D warnings` to verify. NEVER assume fix succeeded.**

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

**CRITICAL: After :apply, MUST re-run :check to verify. NEVER assume fix succeeded.**

### Check 2.2: Maven/Gradle Linting

```bash
# Maven:
mvn checkstyle:check

# Gradle:
gradle checkstyleMain
```
