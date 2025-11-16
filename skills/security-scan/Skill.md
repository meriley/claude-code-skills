---
name: Security Scan
description: Comprehensive security scanning before commits: checks for secrets (API keys, passwords, tokens), dependency vulnerabilities, code injection risks. MUST pass before commit.
version: 1.0.0
---

# ⚠️ MANDATORY: Security Scan Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before EVERY single commit (ZERO EXCEPTIONS)
2. Before creating pull requests
3. When adding new dependencies
4. After modifying authentication/authorization code
5. When user requests security review

**This skill is MANDATORY because:**
- Prevents committing secrets to repository (PERMANENT and IRREVERSIBLE)
- Stops code with known vulnerabilities from entering codebase
- Detects injection vectors that could compromise security
- Protects sensitive authentication/authorization logic
- First line of defense in security pipeline (CRITICAL)

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Running commit WITHOUT invoking security-scan (security risk)
- Committing code with secrets (API keys, passwords, tokens) - PERMANENT DAMAGE
- Committing known HIGH/CRITICAL vulnerabilities (compliance violation)
- Ignoring detected secrets without explicit investigation (negligence)
- Adding hardcoded credentials to authentication code (CRITICAL RISK)

**P1 Violations (High - Quality Failure):**
- Not scanning for all secret patterns (incomplete)
- Failing to audit dependencies (vulnerabilities missed)
- Not checking for code injection risks (input validation missed)
- Missing hardcoded credential detection
- Not reporting specific file:line for issues

**P2 Violations (Medium - Efficiency Loss):**
- Running security checks sequentially instead of parallel
- Not suggesting remediation steps
- Failing to verify false positives

**Blocking Conditions:**
- ANY HIGH or CRITICAL vulnerabilities found → MUST FIX or STOP
- ANY secrets detected in files → MUST REMOVE
- ANY hardcoded credentials → MUST REMOVE or STOP
- Code injection risks → MUST VERIFY or STOP
- Weak cryptography detected → MUST FIX or STOP

---

## Purpose
Comprehensive security verification to ensure no secrets, vulnerabilities, or security issues are committed to the repository.

## When to Use
- **REQUIRED** before every commit
- Before creating pull requests
- When adding new dependencies
- After modifying authentication/authorization code
- When user requests security review

## Security Checklist

### 1. Secrets Scanning

**Step 1.1: Scan for Common Secret Patterns**
```bash
grep -r -E "(api_key|API_KEY|apikey|APIKEY)" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor
```

**Step 1.2: Scan for Passwords and Tokens**
```bash
grep -r -E "(password|PASSWORD|secret|SECRET|token|TOKEN|bearer|BEARER)" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor
```

**Step 1.3: Scan for Private Keys**
```bash
grep -r -E "(private_key|PRIVATE_KEY|-----BEGIN.*PRIVATE KEY-----)" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor
```

**Step 1.4: Scan for Database Credentials**
```bash
grep -r -E "(db_password|DB_PASSWORD|database_url|DATABASE_URL|connection_string)" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor
```

**Step 1.5: Check Common Secret Files**
Check if these files exist and are in .gitignore:
- `.env`
- `.env.local`
- `.env.production`
- `credentials.json`
- `secrets.yaml`
- `config/secrets.yml`
- `*.pem`
- `*.key`

**Action on Match:**
- **HALT** if secrets found in files to be committed
- Verify matches are false positives (test fixtures, documentation)
- If real secrets: MUST remove before proceeding
- Update .gitignore to prevent future commits
- Suggest using environment variables or secret management tools

### 2. Dependency Vulnerability Scanning

**Step 2.1: Detect Project Type**
Identify language/framework by checking for:
- `package.json` → Node.js/npm
- `go.mod` → Go
- `requirements.txt` or `Pipfile` → Python
- `Cargo.toml` → Rust
- `pom.xml` or `build.gradle` → Java

**Step 2.2: Run Language-Specific Audit**

For **Node.js**:
```bash
npm audit --audit-level=moderate
```

For **Go**:
```bash
go list -json -m all | nancy sleuth  # If nancy is installed
# OR
go list -json -m all > go.list && docker run --rm -v $(pwd):/src sonatypecommunity/nancy:latest sleuth --path /src/go.list
```

For **Python**:
```bash
pip-audit  # If pip-audit is installed
# OR
safety check  # If safety is installed
```

For **Rust**:
```bash
cargo audit
```

**Action on Vulnerabilities:**
- **HALT** on HIGH or CRITICAL vulnerabilities
- Report vulnerability details to user
- Suggest update commands
- Allow MEDIUM/LOW with user acknowledgment

### 3. Code Injection Risk Scanning

**Step 3.1: SQL Injection Patterns**
```bash
grep -r -E "(exec|execute|query|prepare).*\+|string.*concat.*query|fmt\.Sprintf.*query" . --include="*.go" --include="*.py" --include="*.js" --include="*.ts"
```

**Step 3.2: Command Injection Patterns**
```bash
grep -r -E "exec.*user|system.*user|os\.system.*\+|subprocess.*shell=True" . --include="*.py" --include="*.go" --include="*.js" --include="*.ts"
```

**Step 3.3: XSS Patterns (for web projects)**
```bash
grep -r -E "innerHTML.*\+|dangerouslySetInnerHTML|document\.write.*\+" . --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx"
```

**Action on Match:**
- Review each match for proper input validation
- Verify parameterized queries are used (SQL)
- Check for proper escaping/sanitization
- Flag suspicious patterns to user for review

### 4. Authentication & Authorization Checks

**Step 4.1: Check for Hardcoded Credentials**
```bash
grep -r -E "(username|user).*=.*['\"].*['\"]" . --include="*.go" --include="*.py" --include="*.js" --include="*.ts" | grep -v "test" | grep -v "example"
```

**Step 4.2: Check for Weak Cryptography**
```bash
grep -r -E "(md5|MD5|sha1|SHA1|DES|ECB)" . --include="*.go" --include="*.py" --include="*.js" --include="*.ts"
```

**Step 4.3: Check for Insecure Random**
```bash
grep -r -E "(math\.random|Math\.random|rand\.Seed\(time)" . --include="*.go" --include="*.py" --include="*.js" --include="*.ts"
```

**Action on Match:**
- Verify cryptographic operations use strong algorithms
- Recommend SHA-256+ for hashing
- Recommend crypto/rand for security-sensitive random numbers
- Flag weak crypto as CRITICAL issues

### 5. Data Exposure Checks

**Step 5.1: Check for Debug/Verbose Logging**
```bash
git diff --cached | grep -E "console\.log|fmt\.Println|print\(|logger\.debug" | grep -v "//.*console\|#.*print"
```

**Step 5.2: Check for TODO Security Comments**
```bash
grep -r -E "TODO.*security|FIXME.*security|XXX.*security" . --exclude-dir=.git
```

**Action on Match:**
- Verify no sensitive data in debug statements
- Ensure debug logging disabled in production
- Flag unresolved security TODOs

## Reporting

### Success Report Format
```
✅ Security Scan PASSED

Checks Performed:
- Secrets scanning: No secrets detected
- Dependency audit: No critical vulnerabilities
- Code injection: No suspicious patterns
- Authentication: No hardcoded credentials
- Data exposure: No sensitive data in logs

Safe to proceed with commit.
```

### Failure Report Format
```
❌ Security Scan FAILED

CRITICAL Issues Found:
1. [SECRETS] API key detected in config/settings.py:42
   - Pattern: "api_key = 'sk_live_abc123'"
   - Action: Remove from code, use environment variables

2. [VULNERABILITY] lodash@4.17.19 has prototype pollution (CVE-2020-8203)
   - Severity: HIGH
   - Action: Run 'npm update lodash' to upgrade

CANNOT PROCEED until issues are resolved.

Suggestions:
- Move secrets to .env file and add to .gitignore
- Run: npm audit fix
- Review authentication code in auth/handlers.go:156
```

## Integration with Other Skills

This skill is invoked by:
- **`safe-commit`** - Before committing changes
- **`create-pr`** - Before creating pull requests

## Best Practices

1. **Never skip** - Security scanning is mandatory, not optional
2. **Be thorough** - Better to flag false positives than miss real issues
3. **Educate** - Explain WHY each issue is a problem
4. **Suggest fixes** - Provide concrete remediation steps
5. **Document exceptions** - If allowing a flagged pattern, document why

## Common False Positives

- Test fixtures containing example secrets
- Documentation with placeholder values
- Variable names containing "password" (e.g., `hasPasswordField`)
- Comment references to security concepts

**How to handle:**
- Verify context of each match
- If false positive: document and proceed
- If uncertain: flag to user for review

## Emergency Override

If user explicitly states "I have reviewed and approved these security findings", you may proceed with:
1. Document the user's explicit approval
2. List what was approved in commit message
3. Suggest creating follow-up ticket for remediation

---

## Anti-Patterns

### ❌ Anti-Pattern: Skipping Security Scan

**Wrong approach:**
```
User: "Commit these changes"
Assistant: *immediately runs `git commit` without invoking security-scan*
```

**Why wrong:**
- Secrets can be committed permanently to history
- Vulnerabilities go undetected until deployment
- Hardcoded credentials expose authentication
- Once pushed, secret removal is very difficult

**Correct approach:** Always run security-scan first
```
User: "Commit these changes"
Assistant: "Let me scan for security issues first..."
*Invokes security-scan skill*
*Checks for secrets, vulnerabilities, injection risks*
*Reports any issues before proceeding*
```

---

### ❌ Anti-Pattern: Accepting Secrets as "False Positives"

**Wrong approach:**
```
Security scan finds: api_key = 'sk_live_12345' in config.js
Assistant: *determines it's likely a real secret but commits anyway*
```

**Why wrong:**
- Better safe than sorry with security
- Real secrets get committed to permanent history
- Secret removal requires force push and history rewrite
- Compromises entire system if leaked

**Correct approach:** Always investigate and remove
```
Security scan finds: api_key = 'sk_live_12345'
Assistant: "Found potential secret in config.js:45"
Assistant: "This looks like a real secret. Recommend: Use .env instead"
*STOPS commit until user removes secret*
```

---

### ❌ Anti-Pattern: Ignoring Vulnerabilities

**Wrong approach:**
```
Dependency audit finds: HIGH severity vulnerability in lodash
Assistant: *commits anyway without updating*
```

**Why wrong:**
- Known vulnerabilities are attack vectors
- Compliance issues (security policies violated)
- Users/data at risk
- Difficult to fix after deployment

**Correct approach:** Block on vulnerabilities
```
Dependency audit finds: HIGH vulnerability in lodash
Assistant: "Cannot commit - HIGH severity vulnerability detected"
Assistant: "Action: Run 'npm update lodash' to fix"
*STOPS commit until vulnerability fixed*
```

---

## References

**Based on:**
- CLAUDE.md Section 1 (Core Policies - Security Requirements)
- CLAUDE.md Section 3 (Available Skills Reference - security-scan)
- OWASP security principles

**Related skills:**
- `quality-check` - Runs after security-scan
- `run-tests` - Verifies security with test coverage
- `safe-commit` - Invokes this skill before all commits
