---
allowed-tools: Bash(git:*, npm:*, go:*, pip:*), Read, Grep, Glob, Skill, Task
argument-hint: [quick|standard|deep]
description: Comprehensive security analysis (OWASP Top 10, secrets, auth)
---

# Security Audit: Comprehensive Analysis

You are performing a deep security audit of the codebase, checking for vulnerabilities, secrets, and security best practices violations.

## Step 1: Determine Audit Depth

The user may have specified a depth: `quick`, `standard`, or `deep`.

- **quick**: Secrets + dependency scan only (~2-3 min)
- **standard**: Quick + OWASP Top 10 basic checks (~5-10 min)
- **deep**: Standard + auth flows + data exposure + secure coding review (~15-30 min)

If no argument provided, default to `standard`.

## Step 2: Show Audit Scope

Execute these commands to understand the codebase:

```bash
!find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.py" \) ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./vendor/*" ! -path "./.venv/*" | wc -l
!ls -1 package.json go.mod requirements.txt Cargo.toml 2>/dev/null
!git ls-files | wc -l
```

Show user:
- Total source files to audit
- Project type detected
- Estimated audit time based on depth

## Step 3: Invoke Base Security Scan Skill

**ALWAYS run the base security-scan skill first:**

```
Skill: security-scan
```

This provides:
- Secrets detection (API keys, passwords, tokens)
- Hardcoded credentials
- Dependency vulnerabilities
- Basic security issues

Collect results for the final report.

## Step 4: OWASP Top 10 Analysis (Standard and Deep modes)

**If mode is `standard` or `deep`, perform OWASP Top 10 checks:**

### A01: Broken Access Control

Search for potential access control issues:

```bash
!grep -r "req\\.user" --include="*.ts" --include="*.js" ! -path "./node_modules/*" | head -20
!grep -r "isAdmin\|isAuthorized\|checkPermission" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- Missing authorization checks before sensitive operations
- Client-side only authorization
- Broken IDOR (Insecure Direct Object References)
- Missing ownership verification

### A02: Cryptographic Failures

Search for cryptography usage:

```bash
!grep -r "crypto\|encrypt\|decrypt\|hash\|md5\|sha1" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | grep -v "node_modules" | head -20
!grep -r "password.*=\|secret.*=\|key.*=" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- Weak hashing algorithms (MD5, SHA1)
- Hardcoded encryption keys
- Missing encryption for sensitive data
- Improper key storage

### A03: Injection

Search for injection vulnerabilities:

```bash
!grep -r "query.*+\|exec.*+\|eval\|innerHTML\|dangerouslySetInnerHTML" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
!grep -r "SELECT.*FROM\|INSERT.*INTO\|UPDATE.*SET" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- SQL injection (string concatenation in queries)
- Command injection (unsanitized exec/system calls)
- XSS (innerHTML, dangerouslySetInnerHTML)
- NoSQL injection

### A04: Insecure Design

Analyze architecture patterns:

```bash
!find . -name "*auth*" -o -name "*session*" -o -name "*token*" | grep -E "\.(ts|js|go|py)$" | head -20
!grep -r "jwt\|session\|cookie" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | grep -i "secret\|key\|sign" | head -20
```

**Look for**:
- Weak session management
- Missing rate limiting
- Insecure authentication flows
- Missing security headers

### A05: Security Misconfiguration

Check configuration files:

```bash
!find . -name "*.config.*" -o -name ".env*" -o -name "*.yml" -o -name "*.yaml" | head -20
!grep -r "debug.*true\|DEBUG.*=.*true" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" --include="*.yml" --include="*.yaml" ! -path "./node_modules/*" | head -10
```

**Look for**:
- Debug mode enabled in production
- Verbose error messages
- Default credentials
- Missing security headers
- Exposed admin interfaces

### A06: Vulnerable and Outdated Components

Check dependencies (already covered by security-scan, but verify):

```bash
!npm audit --json 2>/dev/null || echo "No npm"
!go list -json -m all 2>/dev/null | grep -i "version\|path" || echo "No go.mod"
!pip list --outdated 2>/dev/null || echo "No pip"
```

### A07: Identification and Authentication Failures

Search for authentication code:

```bash
!grep -r "password\|authenticate\|login\|signin" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | grep -E "(compare|verify|check)" | head -20
!grep -r "bcrypt\|argon2\|scrypt\|pbkdf2" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -10
```

**Look for**:
- Weak password storage (plaintext, weak hashing)
- Missing password complexity requirements
- No rate limiting on login
- Missing MFA support
- Insecure session management

### A08: Software and Data Integrity Failures

Check for integrity verification:

```bash
!grep -r "verify\|signature\|checksum" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
!find . -name "*.lock" -o -name "*-lock.*" | head -10
```

**Look for**:
- Missing dependency lock files
- No signature verification
- Insecure deserialization
- Missing integrity checks

### A09: Security Logging and Monitoring Failures

Check logging practices:

```bash
!grep -r "log\|Log\|logger" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | grep -i "error\|warn\|info" | head -20
!grep -r "console\\.log\|print\|fmt\\.Println" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- Missing audit logs for security events
- Sensitive data in logs
- Console.log in production code
- No monitoring for security events

### A10: Server-Side Request Forgery (SSRF)

Search for HTTP request code:

```bash
!grep -r "fetch\|axios\|http\\.get\|http\\.Get\|requests\\.get" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- User-controlled URLs in HTTP requests
- Missing URL validation
- No allowlist for external requests

## Step 5: Deep Analysis (Deep mode only)

**If mode is `deep`, perform additional analysis:**

### Authentication Flow Analysis

Invoke Task agent to trace authentication flows:

```
Task(
  subagent_type: "general-purpose",
  description: "Analyze authentication flows",
  prompt: "Trace all authentication and authorization flows in this codebase.

  For each flow, document:
  1. Entry point (login endpoint, middleware, etc.)
  2. Authentication method (JWT, session, OAuth, etc.)
  3. Token/session storage location
  4. Authorization checks performed
  5. Security weaknesses identified

  Provide a flow diagram and list of security concerns."
)
```

### Data Exposure Analysis

Search for potential data leaks:

```bash
!grep -r "password\|secret\|token\|key\|ssn\|creditcard\|credit_card" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | grep -E "(log|Log|print|console)" | head -20
!grep -r "JSON\\.stringify\|json\\.dumps\|json\\.Marshal" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- Sensitive data in logs
- Sensitive data in error messages
- PII exposure in API responses
- Missing data sanitization

### Secure Coding Practices Review

Check for common secure coding violations:

```bash
!grep -r "TODO.*security\|FIXME.*security\|XXX.*security" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*"
!grep -r "disable.*lint\|nosec\|skipcq" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- Security TODOs not addressed
- Linter security rules disabled
- Security checks bypassed

## Step 6: Generate Comprehensive Security Report

```
═══════════════════════════════════════════════════════════════
                    SECURITY AUDIT REPORT
═══════════════════════════════════════════════════════════════

Project: [detected from package.json/go.mod/etc]
Audit Date: [current date]
Audit Depth: [quick|standard|deep]
Total Files Scanned: XXX

───────────────────────────────────────────────────────────────
                    EXECUTIVE SUMMARY
───────────────────────────────────────────────────────────────

Overall Security Score: A / B / C / D / F

Critical Issues (P0): X (MUST FIX IMMEDIATELY)
High Issues (P1): X (SHOULD FIX SOON)
Medium Issues (P2): X (SHOULD ADDRESS)
Low Issues (P3): X (NICE TO HAVE)

Risk Level: LOW / MEDIUM / HIGH / CRITICAL

[If CRITICAL or HIGH]
⚠️  This codebase has serious security vulnerabilities that must be addressed.

[If MEDIUM]
⚠️  This codebase has security issues that should be addressed before production.

[If LOW]
✅ This codebase follows most security best practices with minor issues.

───────────────────────────────────────────────────────────────
                OWASP TOP 10 ASSESSMENT
───────────────────────────────────────────────────────────────

A01: Broken Access Control       ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A02: Cryptographic Failures      ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A03: Injection                   ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A04: Insecure Design             ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A05: Security Misconfiguration   ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A06: Vulnerable Components       ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A07: Auth Failures               ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A08: Integrity Failures          ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A09: Logging Failures            ✅ PASS / ⚠️  ISSUES / ❌ FAIL
A10: SSRF                        ✅ PASS / ⚠️  ISSUES / ❌ FAIL

───────────────────────────────────────────────────────────────
                DETAILED FINDINGS
───────────────────────────────────────────────────────────────

P0 - CRITICAL (FIX IMMEDIATELY):

1. [Issue Title]
   Category: [OWASP Category]
   Location: [file:line]
   Description: [detailed description]
   Impact: [what could happen]
   Recommendation: [specific fix]
   References: [CWE/CVE if applicable]

2. ...

P1 - HIGH (FIX SOON):

1. [Issue Title]
   Category: [OWASP Category]
   Location: [file:line]
   Description: [detailed description]
   Impact: [what could happen]
   Recommendation: [specific fix]

2. ...

P2 - MEDIUM (ADDRESS):

1. [Issue Title]
   Category: [OWASP Category]
   Location: [file:line]
   Description: [detailed description]
   Recommendation: [specific fix]

2. ...

P3 - LOW (NICE TO HAVE):

1. [Issue Title]
   Category: [Best Practice]
   Recommendation: [suggestion]

2. ...

───────────────────────────────────────────────────────────────
                SECURITY BEST PRACTICES
───────────────────────────────────────────────────────────────

✅ Implemented:
- [List of security practices currently in place]

❌ Missing:
- [List of recommended security practices not implemented]

───────────────────────────────────────────────────────────────
                REMEDIATION ROADMAP
───────────────────────────────────────────────────────────────

Immediate (This Week):
- Fix all P0 issues
- [List specific P0 items]

Short-term (This Month):
- Address P1 issues
- [List specific P1 items]

Medium-term (This Quarter):
- Implement missing security best practices
- Address P2 issues
- [List specific items]

Long-term (Ongoing):
- Security training for team
- Regular security audits
- Dependency updates
- [List ongoing items]

═══════════════════════════════════════════════════════════════
```

## Step 7: Provide Next Steps

Based on risk level:

### If CRITICAL:
```
🚨 CRITICAL SECURITY ISSUES FOUND

Your codebase has serious security vulnerabilities that could lead to:
- Data breaches
- Unauthorized access
- System compromise

IMMEDIATE ACTIONS REQUIRED:
1. Fix all P0 issues before any deployment
2. Review authentication and authorization flows
3. Implement missing security controls
4. Consider security code review with security team

DO NOT deploy to production until P0 issues are resolved.
```

### If HIGH:
```
⚠️  HIGH RISK SECURITY ISSUES FOUND

Your codebase has security vulnerabilities that should be addressed urgently.

RECOMMENDED ACTIONS:
1. Prioritize P0 fixes this week
2. Address P1 issues before next release
3. Implement security best practices
4. Run `/security-audit deep` for complete analysis

Consider delaying production deployment until high-risk issues are resolved.
```

### If MEDIUM:
```
⚠️  MODERATE SECURITY ISSUES FOUND

Your codebase has security issues that should be addressed.

RECOMMENDED ACTIONS:
1. Fix P0 issues before production
2. Plan to address P1 issues in next sprint
3. Review security best practices

Can proceed with deployment after P0 fixes are applied.
```

### If LOW:
```
✅ GOOD SECURITY POSTURE

Your codebase follows most security best practices.

OPTIONAL IMPROVEMENTS:
- Address P2/P3 issues when convenient
- Keep dependencies updated
- Regular security audits recommended

Safe to proceed with deployment.
```

## Notes

- This command does NOT modify files
- Provides comprehensive security assessment
- Composes the `security-scan` skill with deeper analysis
- OWASP Top 10 checks in standard and deep modes
- Deep mode includes flow analysis and secure coding review
- Can be run regularly as part of security program
