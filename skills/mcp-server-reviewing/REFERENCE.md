# MCP Server Reviewing - Reference

Complete violation catalog, detection commands, and audit patterns for MCP server code review.

---

## Complete Violation Catalog

### Security Violations (S1-S10)

| Code | Name                       | Severity | Description                                      |
| ---- | -------------------------- | -------- | ------------------------------------------------ |
| S1   | Hardcoded Secrets          | CRITICAL | API keys, passwords, tokens in source code       |
| S2   | stdout Logging             | CRITICAL | Logging to stdout corrupts stdio transport       |
| S3   | Missing ReDoS Protection   | HIGH     | Unbounded input to regex patterns                |
| S4   | Unsafe Code Execution      | CRITICAL | eval(), exec(), dynamic code execution           |
| S5   | SQL Injection              | CRITICAL | Unsanitized input in SQL queries                 |
| S6   | Command Injection          | CRITICAL | Unsanitized input in shell commands              |
| S7   | Path Traversal             | HIGH     | User input used in file paths without validation |
| S8   | Sensitive Data Logging     | HIGH     | Passwords, tokens, PII in log output             |
| S9   | Insecure Randomness        | MEDIUM   | Math.random() for security-sensitive operations  |
| S10  | Missing Input Sanitization | HIGH     | User input used without sanitization             |

### Architecture Violations (A1-A10)

| Code | Name                         | Severity | Description                                       |
| ---- | ---------------------------- | -------- | ------------------------------------------------- |
| A1   | Missing Tool Description     | MEDIUM   | Tool lacks description field                      |
| A2   | Missing Property Description | LOW      | inputSchema property lacks description            |
| A3   | Missing Validation           | HIGH     | No input validation before processing             |
| A4   | Missing isError Flag         | HIGH     | Error responses lack isError: true                |
| A5   | Non-JSON Response            | MEDIUM   | Response text not JSON-serialized                 |
| A6   | Invalid Resource URI         | MEDIUM   | Resource URI doesn't follow scheme://path pattern |
| A7   | Missing Prompt Arguments     | LOW      | Prompt lacks argument descriptions                |
| A8   | Duplicate Tool Names         | HIGH     | Multiple tools with same name                     |
| A9   | Missing Required Fields      | HIGH     | inputSchema lacks required array                  |
| A10  | Invalid Schema Type          | MEDIUM   | inputSchema type not "object"                     |

### Error Handling Violations (E1-E10)

| Code | Name                      | Severity | Description                                    |
| ---- | ------------------------- | -------- | ---------------------------------------------- |
| E1   | Empty Catch Block         | HIGH     | Catch block with no handling                   |
| E2   | Swallowed Error           | HIGH     | Error caught but not logged/thrown             |
| E3   | Missing Error Context     | MEDIUM   | Error message lacks context                    |
| E4   | Generic Error Message     | MEDIUM   | Unhelpful "error occurred" messages            |
| E5   | Unhandled Promise         | HIGH     | Promise without catch handler                  |
| E6   | Missing Suggestion        | LOW      | Error response lacks suggestion field          |
| E7   | Inconsistent Error Format | MEDIUM   | Different error response structures            |
| E8   | Silent Failure            | CRITICAL | Function returns normally on error             |
| E9   | Missing Error Type        | LOW      | Error lacks error code or type                 |
| E10  | Nested Error Swallowing   | HIGH     | Error caught in nested try/catch and swallowed |

### Maintainability Violations (M1-M10)

| Code | Name                     | Severity | Description                               |
| ---- | ------------------------ | -------- | ----------------------------------------- |
| M1   | Magic Numbers            | LOW      | Hardcoded numbers without named constants |
| M2   | Missing Type Annotations | LOW      | Python functions without type hints       |
| M3   | TODO/FIXME Comments      | LOW      | Incomplete work markers in production     |
| M4   | Duplicate Code           | MEDIUM   | Repeated logic that should be extracted   |
| M5   | Inconsistent Naming      | LOW      | Mixed naming conventions                  |
| M6   | Large Functions          | MEDIUM   | Functions over 50 lines                   |
| M7   | Deep Nesting             | MEDIUM   | Nesting depth over 4 levels               |
| M8   | Missing Tests            | MEDIUM   | Tool functions without test coverage      |
| M9   | Outdated Dependencies    | MEDIUM   | Known vulnerable dependency versions      |
| M10  | Missing Documentation    | LOW      | Public APIs without documentation         |

---

## Detection Command Reference

### Security Detection Commands

```bash
# S1: Hardcoded Secrets - API keys and passwords
grep -rn "api[_-]\?key\s*[:=]\s*['\"]" --include="*.ts" --include="*.py" src/
grep -rn "password\s*[:=]\s*['\"][^'\"]*['\"]" --include="*.ts" --include="*.py" src/
grep -rn "secret\s*[:=]\s*['\"]" --include="*.ts" --include="*.py" src/
grep -rn "token\s*[:=]\s*['\"]sk_\|pk_\|Bearer" --include="*.ts" --include="*.py" src/

# S2: stdout Logging
grep -rn "console\.log(" --include="*.ts" src/ | grep -v "\.test\.\|\.spec\."
grep -rn "print(" --include="*.py" src/ | grep -v "sys\.stderr\|file="

# S3: ReDoS Risk - Regex without input limits
grep -rn "\.match\|\.replace\|\.split\|new RegExp" --include="*.ts" src/
# Then verify each match has MAX_INPUT_LENGTH protection

# S4: Unsafe Code Execution
grep -rn "eval(\|new Function(" --include="*.ts" src/
grep -rn "exec(\|eval(" --include="*.py" src/

# S5: SQL Injection
grep -rn "query.*\${" --include="*.ts" src/
grep -rn "execute.*f\"" --include="*.py" src/
grep -rn "cursor\.execute.*%" --include="*.py" src/

# S6: Command Injection
grep -rn "child_process\|exec\|spawn" --include="*.ts" src/
grep -rn "subprocess\|os\.system\|os\.popen" --include="*.py" src/

# S7: Path Traversal
grep -rn "readFile.*\+\|join.*user\|path.*user" --include="*.ts" src/
grep -rn "open.*user\|Path.*user" --include="*.py" src/

# S8: Sensitive Data Logging
grep -rn "log.*password\|log.*token\|log.*secret" --include="*.ts" --include="*.py" src/
grep -rn "console\.error.*password\|console\.error.*token" --include="*.ts" src/

# S9: Insecure Randomness
grep -rn "Math\.random" --include="*.ts" src/
grep -rn "random\.random\|random\.randint" --include="*.py" src/ | grep -v "secrets\."

# S10: Missing Input Sanitization
grep -rn "request\.params\.\|args\.\|input\." --include="*.ts" src/ | head -20
# Manual review required for each usage
```

### Architecture Detection Commands

```bash
# A1: Missing Tool Description
grep -rn "name:\s*['\"]" --include="*.ts" src/ -A 5 | grep -v "description"

# A2: Missing Property Description (requires manual review)
grep -rn "properties:" --include="*.ts" src/ -A 20 | grep -E "type.*:" | grep -v "description"

# A3: Missing Validation
grep -rn "CallToolRequestSchema" --include="*.ts" src/ -A 30 | grep "request\.params" | grep -v "validate\|ajv\|zod"

# A4: Missing isError Flag
grep -rn "content:.*text:" --include="*.ts" src/ -B 5 -A 5 | grep -E "error|fail|invalid" | grep -v "isError"

# A5: Non-JSON Response
grep -rn "text:\s*\`" --include="*.ts" src/ | grep -v "JSON\.stringify"

# A6: Invalid Resource URI
grep -rn "uri:\s*['\"]" --include="*.ts" src/ | grep -v "://\|resource://\|config://\|status://"

# A7: Missing Prompt Arguments (Python)
grep -rn "@mcp\.prompt" --include="*.py" src/ -A 10 | grep "def " | grep -v "->"

# A8: Duplicate Tool Names
grep -rn "name:\s*['\"]" --include="*.ts" src/ | grep -oP "name:\s*['\"]\\K[^'\"]+(?=['\"])" | sort | uniq -d

# A9: Missing Required Fields
grep -rn "inputSchema" --include="*.ts" src/ -A 10 | grep -v "required"

# A10: Invalid Schema Type
grep -rn "inputSchema" --include="*.ts" src/ -A 5 | grep "type:" | grep -v "object"
```

### Error Handling Detection Commands

```bash
# E1: Empty Catch Blocks
grep -rn "catch\s*(" --include="*.ts" src/ -A 3 | grep -E "catch.*\{$" -A 2 | grep -E "^\s*\}$"

# E2: Swallowed Errors
grep -rn "catch\s*(" --include="*.ts" src/ -A 10 | grep -v "throw\|return\|logger\|console\.error\|reject"

# E3: Missing Error Context
grep -rn "throw new Error(" --include="*.ts" src/ | grep -v ":\|failed\|context\|unable"

# E4: Generic Error Messages
grep -rn "error.*occurred\|something.*wrong\|unknown error" --include="*.ts" src/

# E5: Unhandled Promises
grep -rn "\.then(" --include="*.ts" src/ | grep -v "\.catch\|await"
grep -rn "async.*=>" --include="*.ts" src/ | head -20
# Manual review for proper await/catch

# E6: Missing Suggestion Field
grep -rn "isError.*true" --include="*.ts" src/ -B 10 | grep "text:" | grep -v "suggestion"

# E7: Inconsistent Error Format
grep -rn "isError.*true" --include="*.ts" src/ -B 15 | grep "text:" | head -20
# Manual comparison required

# E8: Silent Failure (requires manual review)
grep -rn "return\s*;\s*$\|return null\|return undefined" --include="*.ts" src/

# E9: Missing Error Type
grep -rn "errors:\s*\[" --include="*.ts" src/ -A 5 | grep -v "type\|code"

# E10: Nested Try/Catch
grep -rn "try\s*{" --include="*.ts" src/ | wc -l
# Compare with catch count - manual review for nesting
```

### Maintainability Detection Commands

```bash
# M1: Magic Numbers
grep -rn "[^a-zA-Z][0-9]\{4,\}" --include="*.ts" src/ | grep -v "const\|MAX_\|MIN_\|DEFAULT_\|PORT\|test\|spec"

# M2: Missing Type Annotations (Python)
grep -rn "def [a-z_]*(" --include="*.py" src/ | grep -v "->.*:"

# M3: TODO/FIXME Comments
grep -rn "TODO\|FIXME\|XXX\|HACK\|WORKAROUND" --include="*.ts" --include="*.py" src/

# M4: Duplicate Code (manual review required)
# Use tools like jscpd for automated detection

# M5: Inconsistent Naming
grep -rn "const [a-z_]*[A-Z]" --include="*.ts" src/  # camelCase in const
grep -rn "function [A-Z]" --include="*.ts" src/       # PascalCase functions

# M6: Large Functions
# Use eslint with max-lines-per-function rule
grep -rn "function\|=>" --include="*.ts" src/ | wc -l

# M7: Deep Nesting
grep -rn "^\s\{16,\}" --include="*.ts" src/ | head -20

# M8: Missing Tests
ls src/**/*.ts | while read f; do
  test_file="${f%.ts}.test.ts"
  [ ! -f "$test_file" ] && echo "Missing test: $f"
done

# M9: Outdated Dependencies
npm audit 2>/dev/null || pip-audit 2>/dev/null

# M10: Missing Documentation
grep -rn "export function\|export class\|export const" --include="*.ts" src/ | while read line; do
  # Check if preceded by JSDoc
  file=$(echo "$line" | cut -d: -f1)
  lineno=$(echo "$line" | cut -d: -f2)
  prev=$((lineno - 1))
  sed -n "${prev}p" "$file" | grep -q "\*/" || echo "Missing docs: $line"
done
```

---

## Production Readiness Checklist

### Required for Production

- [ ] **Structured Logging**: JSON format with timestamp, level, service name
- [ ] **Error Boundaries**: All async operations wrapped in try/catch
- [ ] **Input Validation**: All tool inputs validated before processing
- [ ] **Timeout Configuration**: External calls have configurable timeouts
- [ ] **Health Monitoring**: Way to check server health/readiness
- [ ] **Graceful Shutdown**: Handle SIGTERM/SIGINT properly
- [ ] **Dependency Pinning**: All dependencies at specific versions

### Recommended for Production

- [ ] **Metrics Collection**: Request counts, latencies, error rates
- [ ] **Rate Limiting**: Protection against abuse
- [ ] **Circuit Breaker**: For external service calls
- [ ] **Retry Logic**: With exponential backoff for transient failures
- [ ] **Request Tracing**: Correlation IDs for distributed tracing
- [ ] **Documentation**: API documentation for all tools/resources

### Dockerfile Template

```dockerfile
# Production MCP Server Dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM node:20-alpine AS runner

WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S mcp -u 1001

COPY --from=builder --chown=mcp:nodejs /app/dist ./dist
COPY --from=builder --chown=mcp:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=mcp:nodejs /app/package.json ./

USER mcp
ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "process.exit(0)" || exit 1

CMD ["node", "dist/index.js"]
```

---

## TypeScript-Specific Patterns

### Proper Tool Registration

```typescript
import Ajv from "ajv";

const ajv = new Ajv();

// Define schema once
const processDataSchema = {
  type: "object",
  properties: {
    data: { type: "string", description: "Input data to process" },
    format: {
      type: "string",
      enum: ["json", "csv"],
      description: "Expected format",
    },
  },
  required: ["data", "format"],
};

// Compile validator
const validateProcessData = ajv.compile(processDataSchema);

// Tool definition references same schema
const TOOLS: Tool[] = [
  {
    name: "process_data",
    description:
      "Validates and transforms input data. Returns structured result.",
    inputSchema: processDataSchema,
  },
];

// Handler validates before processing
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "process_data") {
    if (!validateProcessData(args)) {
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              success: false,
              errors: validateProcessData.errors?.map((e) => ({
                field: e.instancePath || "root",
                message: e.message || "Validation failed",
                suggestion: "Check parameter types and required fields",
              })),
            }),
          },
        ],
        isError: true,
      };
    }

    // Safe to use args now
    return await processData(args as ProcessDataArgs);
  }
});
```

### Proper Logging Pattern

```typescript
interface LogEntry {
  timestamp: string;
  level: "DEBUG" | "INFO" | "WARN" | "ERROR";
  message: string;
  service: string;
  context?: Record<string, unknown>;
  error?: { name: string; message: string; stack?: string };
}

class Logger {
  private service: string;

  constructor(service: string) {
    this.service = service;
  }

  private log(
    level: LogEntry["level"],
    message: string,
    context?: Record<string, unknown>,
    error?: Error,
  ): void {
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      service: this.service,
      context,
      error: error
        ? { name: error.name, message: error.message, stack: error.stack }
        : undefined,
    };

    // CRITICAL: Use stderr, never stdout
    console.error(JSON.stringify(entry));
  }

  info(message: string, context?: Record<string, unknown>): void {
    this.log("INFO", message, context);
  }

  error(
    message: string,
    context?: Record<string, unknown>,
    error?: Error,
  ): void {
    this.log("ERROR", message, context, error);
  }
}

export const logger = new Logger("my-mcp-server");
```

---

## Python-Specific Patterns

### Proper FastMCP Tool

```python
from mcp.server.fastmcp import FastMCP
import logging
import sys

# Configure logging to stderr
logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp":"%(asctime)s","level":"%(levelname)s","message":"%(message)s","service":"my-mcp-server"}',
    stream=sys.stderr
)
logger = logging.getLogger(__name__)

mcp = FastMCP("my-mcp-server", json_response=True)

# ReDoS protection
MAX_INPUT_LENGTH = 50_000

def safe_input(text: str) -> str:
    """Limit input length before regex processing."""
    return text[:MAX_INPUT_LENGTH] if len(text) > MAX_INPUT_LENGTH else text


@mcp.tool()
def process_data(data: str, format: str = "json") -> dict:
    """Process and validate input data.

    Args:
        data: Raw data string to process (max 50KB)
        format: Expected format - 'json' or 'csv'

    Returns:
        Structured result with success status and processed data
    """
    logger.info(f"process_data called: format={format}, data_length={len(data)}")

    try:
        # Validate inputs
        if not data:
            return {
                "success": False,
                "errors": [{
                    "field": "data",
                    "message": "data cannot be empty",
                    "suggestion": "Provide a non-empty string"
                }]
            }

        if format not in ("json", "csv"):
            return {
                "success": False,
                "errors": [{
                    "field": "format",
                    "message": f"Invalid format: {format}",
                    "suggestion": "Use 'json' or 'csv'"
                }]
            }

        # Apply safety limits
        safe_data = safe_input(data)

        # Process
        result = {"processed": safe_data, "format": format}

        return {"success": True, "data": result}

    except Exception as e:
        logger.error(f"process_data failed: {e}")
        return {
            "success": False,
            "errors": [{
                "field": "system",
                "message": str(e),
                "suggestion": "Check input format and try again"
            }]
        }
```

---

## Review Workflow Scripts

### Full Audit Script

````bash
#!/bin/bash
# mcp-audit.sh - Full MCP server audit

SERVER_DIR="${1:-.}"
REPORT_FILE="mcp-audit-report.md"

echo "# MCP Server Audit Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Date:** $(date)" >> "$REPORT_FILE"
echo "**Directory:** $SERVER_DIR" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Security Checks
echo "## Security Violations" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "### S2: stdout Logging" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
grep -rn "console\.log" --include="*.ts" "$SERVER_DIR/src" 2>/dev/null || echo "None found"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "### S1: Hardcoded Secrets" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
grep -rn "api[_-]\?key\s*[:=]\s*['\"]" --include="*.ts" "$SERVER_DIR/src" 2>/dev/null | grep -v "process\.env" || echo "None found"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Architecture Checks
echo "## Architecture Violations" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "### A4: Missing isError Flag" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
grep -rn "content:.*error" --include="*.ts" "$SERVER_DIR/src" 2>/dev/null | grep -v "isError" || echo "None found"
echo '```' >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "Audit complete. See $REPORT_FILE"
````

### Quick Check Script

```bash
#!/bin/bash
# mcp-quick-check.sh - Quick MCP server sanity check

echo "🔍 MCP Server Quick Check"
echo "========================="

# Check for critical issues only
ISSUES=0

# S2: stdout logging
if grep -rq "console\.log" --include="*.ts" src/ 2>/dev/null; then
  echo "❌ CRITICAL: console.log found (use console.error for MCP)"
  ISSUES=$((ISSUES + 1))
fi

# S1: Hardcoded secrets
if grep -rq "api_key\s*[:=]\s*['\"]sk_\|password\s*[:=]\s*['\"][^'\"]\+" --include="*.ts" src/ 2>/dev/null; then
  echo "❌ CRITICAL: Possible hardcoded secrets found"
  ISSUES=$((ISSUES + 1))
fi

# A4: Missing isError
if grep -rq "content:.*error\|success.*false" --include="*.ts" src/ 2>/dev/null | grep -qv "isError"; then
  echo "⚠️  HIGH: Error responses may be missing isError flag"
  ISSUES=$((ISSUES + 1))
fi

if [ $ISSUES -eq 0 ]; then
  echo "✅ No critical issues found"
else
  echo ""
  echo "Found $ISSUES potential issue(s). Run full audit for details."
fi
```

---

## Cross-Platform Considerations

### Windows Command Equivalents

```powershell
# S2: stdout logging (PowerShell)
Select-String -Path "src\*.ts" -Pattern "console\.log" -Recurse

# S1: Hardcoded secrets (PowerShell)
Select-String -Path "src\*.ts" -Pattern "api[_-]?key\s*[:=]" -Recurse

# A4: Missing isError (PowerShell)
Select-String -Path "src\*.ts" -Pattern "content:.*error" -Recurse |
  Where-Object { $_.Line -notmatch "isError" }
```

### macOS Considerations

```bash
# Use ggrep for extended regex on macOS
# Install: brew install grep
alias grep='ggrep'

# Or use ripgrep (rg) for better performance
# Install: brew install ripgrep
rg "console\.log" --type ts src/
```

---

## Integration with CI/CD

### GitHub Actions Workflow

```yaml
name: MCP Server Audit

on:
  pull_request:
    paths:
      - "src/**"
      - "package.json"

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for stdout logging
        run: |
          if grep -rn "console\.log" --include="*.ts" src/; then
            echo "::error::Found console.log - use console.error for MCP servers"
            exit 1
          fi

      - name: Check for hardcoded secrets
        run: |
          if grep -rn "api_key\s*[:=]\s*['\"]" --include="*.ts" src/ | grep -v "process\.env"; then
            echo "::error::Possible hardcoded secrets found"
            exit 1
          fi

      - name: Check for missing isError
        run: |
          grep -rn "isError" --include="*.ts" src/ || {
            echo "::warning::No isError flags found - verify error handling"
          }
```
