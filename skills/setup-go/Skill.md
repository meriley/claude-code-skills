---
name: Go Development Setup
description: Sets up Go development environment with proper tooling, linting, testing, and dependencies. Runs go mod tidy, configures golangci-lint, sets up testing framework, and verifies build.
version: 1.0.0
---

# ⚠️ MANDATORY: Go Development Setup Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Starting work on Go project
2. After cloning Go repository
3. When setting up CI/CD for Go
4. When troubleshooting Go environment

**This skill is MANDATORY because:**
- Ensures consistent development environment
- Sets up proper linting and testing
- Prevents dependency conflicts
- Enforces code quality standards
- Reduces environment setup issues

**ENFORCEMENT:**

**P1 Violations (High - Quality Failure):**
- Missing golangci-lint setup
- No testing framework configured
- Outdated dependencies (go mod not tidy)
- Missing code generation setup
- No linting in CI/CD

**P2 Violations (Medium - Efficiency Loss):**
- Not using Makefile
- Missing git hooks
- No pre-commit checks

**Blocking Conditions:**
- Must have golangci-lint configured
- Must have testing framework
- Must have go mod tidy run
- Must have build verification

---

## Purpose

Sets up Go development environment with proper tooling, linting, testing, and dependencies.

## Workflow

### Step 1: Verify Go Installation
```bash
go version  # Go 1.20+
```

### Step 2: Check Project Structure
```bash
ls go.mod
```

### Step 3: Install Dependencies
```bash
go mod download
go mod tidy
```

### Step 4: Setup golangci-lint
```bash
# Install
brew install golangci-lint  # macOS
# or
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Create .golangci.yml
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - staticcheck
    - unused
    - gofmt
    - goimports
    - revive
    - misspell
    - gocritic
    - unparam
```

### Step 5: Setup Testing
```bash
# Run tests
go test ./... -v

# Run with coverage
go test ./... -cover -coverprofile=coverage.out
go tool cover -func=coverage.out
```

### Step 6: Verify Build
```bash
go build ./...
```

### Step 7: Create Makefile
```makefile
.PHONY: build test lint fmt clean coverage all

build:
	go build -v ./...

test:
	go test -v ./...

coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out
	go tool cover -html=coverage.out -o coverage.html

lint:
	golangci-lint run

fmt:
	gofmt -s -w .
	goimports -w .

vet:
	go vet ./...

clean:
	go clean
	rm -f coverage.out coverage.html

all: fmt lint test build
```

### Step 8: Setup Git Hooks
```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
set -e
echo "Running pre-commit checks..."
gofmt -s -w .
golangci-lint run
go test ./...
echo "✅ Pre-commit checks passed"
EOF
chmod +x .git/hooks/pre-commit
```

## Configuration

### go.mod Management
```bash
go mod download       # Download dependencies
go mod tidy          # Clean up dependencies
go mod verify        # Verify dependencies
go mod vendor        # Vendor dependencies (optional)
go get -u <package>  # Update dependency
```

### golangci-lint (.golangci.yml)
```yaml
linters:
  enable:
    - errcheck       # Check unchecked errors
    - gosimple       # Simplification
    - govet          # Vet issues
    - staticcheck    # Static analysis
    - unused         # Unused variables/functions
    - gofmt          # Formatting
    - goimports      # Import organization
    - revive         # Code style
    - misspell       # Spelling
    - gocritic       # Critical issues
    - unparam        # Unused parameters

run:
  timeout: 5m
  tests: true
```

## Common Commands

```bash
# Build
go build ./...

# Run tests
go test ./...
go test -v ./...
go test -race ./...

# Code coverage
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Linting
golangci-lint run

# Formatting
gofmt -s -w .
goimports -w .

# Code generation
go generate ./...

# Cleanup
go mod tidy
go mod verify
```

## Best Practices

1. **Always run `go mod tidy`** before committing
2. **Use `golangci-lint`** for comprehensive linting
3. **Enable race detector** in CI/CD: `go test -race ./...`
4. **Target 90%+ test coverage**
5. **Use `goimports`** instead of `gofmt` (handles imports)
6. **Run `go vet`** to catch common mistakes
7. **Create Makefile** for consistent commands
8. **Setup pre-commit hooks** for early error detection

## Anti-Patterns

### ❌ Anti-Pattern: Not Running go mod tidy

**Wrong:**
```bash
# Commit with outdated go.mod
git add . && git commit -m "feat: add feature"
```

**Correct:**
```bash
# Always tidy before committing
go mod tidy
go mod verify
git add . && git commit -m "feat: add feature"
```

---

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - setup-go)
- Go best practices

**Related skills:**
- `quality-check` - Invokes linting
- `run-tests` - Runs tests
- `control-flow-check` - Go-specific audit
- `error-handling-audit` - Go-specific audit
