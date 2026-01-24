# MCP Server Production Readiness Checklist

Printable production readiness audit checklist for MCP server deployment.

---

## Pre-Review Information

**Server Name:** **********\_\_\_**********
**Version:** **********\_\_\_**********
**Reviewer:** **********\_\_\_**********
**Date:** **********\_\_\_**********
**Target Environment:** [ ] Development [ ] Staging [ ] Production

---

## Architecture Checks (Must Pass)

### A1: Tool Descriptions

- [ ] All tools have `description` field
- [ ] Descriptions explain purpose and return value
- [ ] Descriptions help LLM understand when to use tool

**Detection Command:**

```bash
grep -rn "name:\s*['\"]" --include="*.ts" src/ -A 5 | grep -v description
```

**Finding:** **********\_\_\_**********

---

### A3: Input Validation

- [ ] All tools validate inputs before processing
- [ ] Ajv or Zod used for schema validation (TypeScript)
- [ ] Type hints and validation decorators used (Python)
- [ ] Validation errors return helpful messages

**Detection Command:**

```bash
grep -rn "validate\|ajv\|zod" --include="*.ts" src/
```

**Finding:** **********\_\_\_**********

---

### A4: Error Response Format

- [ ] All error responses include `isError: true`
- [ ] Error responses have consistent structure
- [ ] Error responses include `suggestion` field
- [ ] HTTP-like status information where applicable

**Detection Command:**

```bash
grep -rn "isError.*true" --include="*.ts" src/ | wc -l
grep -rn "content:.*error" --include="*.ts" src/ | grep -v "isError" | wc -l
```

**Finding:** **********\_\_\_**********

---

### A5: Response Serialization

- [ ] All responses are JSON-serialized
- [ ] No raw string interpolation in responses
- [ ] Consistent response structure across tools

**Finding:** **********\_\_\_**********

---

## Error Handling Checks (Must Pass)

### E1: No Empty Catch Blocks

- [ ] All catch blocks have error handling
- [ ] Errors logged with context
- [ ] Errors re-thrown or returned appropriately

**Detection Command:**

```bash
grep -rn "catch" --include="*.ts" src/ -A 5 | head -50
```

**Finding:** **********\_\_\_**********

---

### E5: Promise Handling

- [ ] All promises awaited or have catch handlers
- [ ] Async operations wrapped in try/catch
- [ ] No unhandled promise rejections

**Finding:** **********\_\_\_**********

---

## Logging & Monitoring (Must Pass)

### P1: Structured Logging

- [ ] JSON format for all log entries
- [ ] Timestamp included in all entries
- [ ] Log level (DEBUG/INFO/WARN/ERROR) included
- [ ] Service name included
- [ ] All output to stderr (not stdout)

**Detection Command:**

```bash
grep -rn "console\.error\|logger\." --include="*.ts" src/ | head -20
```

**Finding:** **********\_\_\_**********

---

### P2: Health Check

- [ ] Health check mechanism exists
- [ ] Can verify server is running and responsive
- [ ] Resource usage can be monitored

**Finding:** **********\_\_\_**********

---

## Configuration & Deployment (Must Pass)

### P3: Timeout Configuration

- [ ] External API calls have timeouts
- [ ] Database queries have timeouts
- [ ] Timeouts configurable via environment

**Detection Command:**

```bash
grep -rn "timeout\|TIMEOUT" --include="*.ts" src/
```

**Finding:** **********\_\_\_**********

---

### P4: Graceful Shutdown

- [ ] SIGTERM handler implemented
- [ ] SIGINT handler implemented
- [ ] Cleanup on shutdown (close connections, flush logs)

**Detection Command:**

```bash
grep -rn "SIGTERM\|SIGINT\|process\.on" --include="*.ts" src/
```

**Finding:** **********\_\_\_**********

---

### P5: No Debug Code

- [ ] No development-only code paths
- [ ] No hardcoded test data
- [ ] No commented-out debug statements
- [ ] No `debugger` statements

**Detection Command:**

```bash
grep -rn "debugger\|TODO.*debug\|console\.log" --include="*.ts" src/
```

**Finding:** **********\_\_\_**********

---

### P6: Dependency Management

- [ ] All dependencies pinned to specific versions
- [ ] No `*` or `latest` version specifiers
- [ ] `package-lock.json` or `requirements.txt` committed
- [ ] No known vulnerable dependencies

**Detection Command:**

```bash
npm audit 2>/dev/null || pip-audit 2>/dev/null
```

**Finding:** **********\_\_\_**********

---

### P7: Deployment Configuration

- [ ] Dockerfile present (if containerized)
- [ ] Environment variables documented
- [ ] README with deployment instructions
- [ ] CI/CD pipeline configured

**Finding:** **********\_\_\_**********

---

## Documentation (Recommended)

### D1: API Documentation

- [ ] All tools documented with examples
- [ ] All resources documented
- [ ] All prompts documented
- [ ] Error codes/messages documented

**Finding:** **********\_\_\_**********

---

### D2: Operational Documentation

- [ ] Deployment steps documented
- [ ] Configuration options documented
- [ ] Troubleshooting guide present
- [ ] Runbook for common issues

**Finding:** **********\_\_\_**********

---

## Testing (Recommended)

### T1: Test Coverage

- [ ] Unit tests for all tools
- [ ] Integration tests for external dependencies
- [ ] Error path testing
- [ ] Coverage > 80%

**Detection Command:**

```bash
npm test -- --coverage 2>/dev/null || pytest --cov 2>/dev/null
```

**Finding:** **********\_\_\_**********

---

## Summary

### Must Pass

| Check                  | Status            | Notes |
| ---------------------- | ----------------- | ----- |
| A1: Tool Descriptions  | [ ] Pass [ ] Fail |       |
| A3: Input Validation   | [ ] Pass [ ] Fail |       |
| A4: Error Responses    | [ ] Pass [ ] Fail |       |
| A5: Serialization      | [ ] Pass [ ] Fail |       |
| E1: Catch Blocks       | [ ] Pass [ ] Fail |       |
| E5: Promise Handling   | [ ] Pass [ ] Fail |       |
| P1: Structured Logging | [ ] Pass [ ] Fail |       |
| P2: Health Check       | [ ] Pass [ ] Fail |       |
| P3: Timeouts           | [ ] Pass [ ] Fail |       |
| P4: Graceful Shutdown  | [ ] Pass [ ] Fail |       |
| P5: No Debug Code      | [ ] Pass [ ] Fail |       |
| P6: Dependencies       | [ ] Pass [ ] Fail |       |
| P7: Deployment Config  | [ ] Pass [ ] Fail |       |

### Recommended

| Check             | Status            | Notes |
| ----------------- | ----------------- | ----- |
| D1: API Docs      | [ ] Pass [ ] Fail |       |
| D2: Ops Docs      | [ ] Pass [ ] Fail |       |
| T1: Test Coverage | [ ] Pass [ ] Fail |       |

---

**Overall Production Readiness:**

- [ ] READY - All must-pass checks passed
- [ ] READY WITH CAVEATS - Minor issues documented
- [ ] NOT READY - Critical issues must be fixed

**Blocking Issues:**

1. ***
2. ***
3. ***

**Non-Blocking Issues:**

1. ***
2. ***
3. ***

**Reviewer Signature:** **********\_\_\_**********
**Approval Date:** **********\_\_\_**********
