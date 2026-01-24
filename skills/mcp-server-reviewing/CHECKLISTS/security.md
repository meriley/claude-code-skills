# MCP Server Security Checklist

Printable security audit checklist for MCP server code review.

---

## Pre-Review Information

**Server Name:** **********\_\_\_**********
**Reviewer:** **********\_\_\_**********
**Date:** **********\_\_\_**********
**Language:** [ ] TypeScript [ ] Python [ ] Other: **\_\_\_**

---

## Critical Security Checks (Must Pass)

### S1: No Hardcoded Secrets

- [ ] No API keys in source code
- [ ] No passwords in source code
- [ ] No tokens (Bearer, JWT, etc.) in source code
- [ ] No private keys or certificates
- [ ] All secrets loaded from environment variables

**Detection Command:**

```bash
grep -rn "api[_-]\?key\s*[:=]\s*['\"]" --include="*.ts" --include="*.py" src/
grep -rn "password\s*[:=]\s*['\"][^'\"]*['\"]" --include="*.ts" --include="*.py" src/
```

**Finding:** **********\_\_\_**********

---

### S2: Logging to stderr Only

- [ ] No `console.log()` in TypeScript source
- [ ] No `print()` to stdout in Python source
- [ ] All logging uses `console.error()` or `sys.stderr`
- [ ] Structured JSON logging format used

**Detection Command:**

```bash
grep -rn "console\.log" --include="*.ts" src/
grep -rn "print(" --include="*.py" src/ | grep -v "sys\.stderr"
```

**Finding:** **********\_\_\_**********

---

### S4: No Unsafe Code Execution

- [ ] No `eval()` calls
- [ ] No `new Function()` calls
- [ ] No `exec()` (Python)
- [ ] No dynamic code generation from user input

**Detection Command:**

```bash
grep -rn "eval(\|new Function(" --include="*.ts" src/
grep -rn "exec(\|eval(" --include="*.py" src/
```

**Finding:** **********\_\_\_**********

---

### S5: No SQL Injection

- [ ] All SQL queries use parameterized statements
- [ ] No string concatenation in queries
- [ ] No template literals with user input in queries

**Detection Command:**

```bash
grep -rn "query.*\${" --include="*.ts" src/
grep -rn "execute.*f\"" --include="*.py" src/
```

**Finding:** **********\_\_\_**********

---

### S6: No Command Injection

- [ ] User input sanitized before shell commands
- [ ] No direct user input to exec/spawn
- [ ] Allowlist approach for command arguments

**Detection Command:**

```bash
grep -rn "child_process\|exec\|spawn" --include="*.ts" src/
grep -rn "subprocess\|os\.system" --include="*.py" src/
```

**Finding:** **********\_\_\_**********

---

## High Security Checks (Should Pass)

### S3: ReDoS Protection

- [ ] Input length limited before regex operations
- [ ] MAX_INPUT_LENGTH constant defined
- [ ] `safeInput()` function used consistently

**Detection Command:**

```bash
grep -rn "MAX_INPUT\|safeInput" --include="*.ts" --include="*.py" src/
```

**Finding:** **********\_\_\_**********

---

### S7: No Path Traversal

- [ ] User input not used directly in file paths
- [ ] Path validation before file operations
- [ ] No `..` sequences allowed in paths

**Detection Command:**

```bash
grep -rn "readFile.*\+\|path.*user" --include="*.ts" src/
```

**Finding:** **********\_\_\_**********

---

### S8: No Sensitive Data Logging

- [ ] Passwords not logged
- [ ] Tokens not logged
- [ ] PII not logged
- [ ] Request bodies sanitized before logging

**Detection Command:**

```bash
grep -rn "log.*password\|log.*token\|log.*secret" --include="*.ts" --include="*.py" src/
```

**Finding:** **********\_\_\_**********

---

### S10: Input Sanitization

- [ ] All user inputs validated
- [ ] Type checking on inputs
- [ ] Length limits enforced
- [ ] Format validation where applicable

**Finding:** **********\_\_\_**********

---

## Medium Security Checks (Recommended)

### S9: Secure Randomness

- [ ] No `Math.random()` for security purposes
- [ ] Using `crypto.randomUUID()` or equivalent
- [ ] No `random.random()` (Python) for security

**Detection Command:**

```bash
grep -rn "Math\.random" --include="*.ts" src/
grep -rn "random\.random" --include="*.py" src/
```

**Finding:** **********\_\_\_**********

---

## Summary

| Check          | Status            | Notes |
| -------------- | ----------------- | ----- |
| S1: Secrets    | [ ] Pass [ ] Fail |       |
| S2: Logging    | [ ] Pass [ ] Fail |       |
| S4: Code Exec  | [ ] Pass [ ] Fail |       |
| S5: SQL Inject | [ ] Pass [ ] Fail |       |
| S6: Cmd Inject | [ ] Pass [ ] Fail |       |
| S3: ReDoS      | [ ] Pass [ ] Fail |       |
| S7: Path Trav  | [ ] Pass [ ] Fail |       |
| S8: Data Log   | [ ] Pass [ ] Fail |       |
| S10: Sanitize  | [ ] Pass [ ] Fail |       |
| S9: Random     | [ ] Pass [ ] Fail |       |

**Overall Security Assessment:**

- [ ] PASS - No security issues found
- [ ] PASS WITH NOTES - Minor issues, can proceed
- [ ] FAIL - Critical/High issues must be fixed

**Reviewer Signature:** **********\_\_\_**********
