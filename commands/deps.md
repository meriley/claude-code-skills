---
allowed-tools: Bash(npm:*), Bash(go:*), Bash(pip:*), Bash(yarn:*), Bash(pnpm:*), Read, Glob
argument-hint: [audit|outdated|unused]
description: Dependency health check - outdated packages, vulnerabilities, unused deps
---

# Dependency Health Check

Quick audit of project dependencies for security, updates, and cleanup.

## Usage

```
/deps                 # Full dependency health report
/deps audit           # Security vulnerabilities only
/deps outdated        # Outdated packages only
/deps unused          # Unused dependencies only
```

## Step 1: Detect Package Manager

Check for project type:

```bash
ls -1 package.json go.mod requirements.txt Pipfile Cargo.toml 2>/dev/null
```

- `package.json` → npm/yarn/pnpm
- `go.mod` → Go modules
- `requirements.txt` or `Pipfile` → Python pip/pipenv
- `Cargo.toml` → Rust cargo

## Step 2: Run Dependency Checks

### For Node.js (npm/yarn/pnpm)

```bash
# Security audit
npm audit --json 2>/dev/null || yarn audit --json 2>/dev/null

# Outdated packages
npm outdated --json 2>/dev/null || yarn outdated --json 2>/dev/null

# Unused dependencies (requires depcheck)
npx depcheck --json 2>/dev/null
```

### For Go

```bash
# Security vulnerabilities
go list -m -json all | go run golang.org/x/vuln/cmd/govulncheck@latest ./...

# Outdated dependencies
go list -m -u -json all

# Unused (go mod tidy shows what would be removed)
go mod tidy -v 2>&1 | grep "unused"
```

### For Python

```bash
# Security audit
pip-audit --format=json 2>/dev/null || safety check --json 2>/dev/null

# Outdated packages
pip list --outdated --format=json

# Unused (requires pip-autoremove or pipdeptree)
pipdeptree --warn silence 2>/dev/null
```

## Step 3: Parse and Categorize Results

Group findings by severity:

### Security Vulnerabilities
- **Critical**: Immediate action required
- **High**: Fix before next release
- **Medium**: Plan to address
- **Low**: Consider updating

### Outdated Packages
- **Major**: Breaking changes likely (e.g., 1.x → 2.x)
- **Minor**: New features available (e.g., 1.1 → 1.2)
- **Patch**: Bug fixes available (e.g., 1.1.1 → 1.1.2)

### Unused Dependencies
- Listed in package file but not imported
- Dev dependencies in production
- Transitive dependencies that could be removed

## Step 4: Output Format

```
╔══════════════════════════════════════════════════════════════╗
║                  DEPENDENCY HEALTH REPORT                     ║
╠══════════════════════════════════════════════════════════════╣
║  Project: my-app (Node.js)                                   ║
║  Dependencies: 145 total (42 direct, 103 transitive)         ║
╠══════════════════════════════════════════════════════════════╣

## Security Vulnerabilities (3 found)

| Severity | Package      | Current | Fixed In | CVE           |
|----------|--------------|---------|----------|---------------|
| CRITICAL | lodash       | 4.17.15 | 4.17.21  | CVE-2021-1234 |
| HIGH     | axios        | 0.21.1  | 0.21.2   | CVE-2021-5678 |
| MEDIUM   | minimist     | 1.2.5   | 1.2.6    | CVE-2021-9012 |

**Action**: Run `npm audit fix` or update manually

---

## Outdated Packages (12 found)

| Package    | Current | Latest | Type  | Breaking? |
|------------|---------|--------|-------|-----------|
| react      | 17.0.2  | 18.2.0 | Major | Yes       |
| typescript | 4.9.5   | 5.3.2  | Major | Yes       |
| eslint     | 8.45.0  | 8.56.0 | Minor | No        |

**Action**: Review changelogs before major updates

---

## Unused Dependencies (4 found)

| Package     | Type | Reason                    |
|-------------|------|---------------------------|
| moment      | prod | Not imported anywhere     |
| lodash      | prod | Only _.get used (use ?.)) |
| jest-cli    | dev  | Already in jest           |
| @types/node | dev  | Bundled with typescript   |

**Action**: Run `npm uninstall <package>` to remove

---

## Summary

| Category       | Count | Action                          |
|----------------|-------|---------------------------------|
| Vulnerabilities| 3     | Fix critical/high immediately   |
| Outdated       | 12    | Update minors, review majors    |
| Unused         | 4     | Remove to reduce bundle size    |

╚══════════════════════════════════════════════════════════════╝
```

## Step 5: Suggested Commands

Based on findings, suggest fix commands:

```
QUICK FIXES:
├── npm audit fix --force        # Fix vulnerabilities
├── npm update                   # Update to latest minor/patch
├── npm uninstall moment lodash  # Remove unused
└── npm outdated                 # Check what remains
```

## Notes

- This complements `/security-audit` with proactive dependency management
- Security vulnerabilities are also checked by `security-scan` skill
- For major version updates, always check changelogs for breaking changes
- Use `package-lock.json` / `go.sum` to ensure reproducible builds
