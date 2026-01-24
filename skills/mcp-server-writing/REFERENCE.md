# MCP Server Writing Reference

Detailed patterns, complete templates, and advanced configurations for MCP server development.

## Table of Contents

1. [Complete TypeScript Server Template](#complete-typescript-server-template)
2. [Complete Python FastMCP Template](#complete-python-fastmcp-template)
3. [Tool Design Patterns](#tool-design-patterns)
4. [Resource Design Patterns](#resource-design-patterns)
5. [Prompt Design Patterns](#prompt-design-patterns)
6. [Error Handling Patterns](#error-handling-patterns)
7. [Security Patterns](#security-patterns)
8. [Testing Strategies](#testing-strategies)
9. [Production Checklist](#production-checklist)

---

## Complete TypeScript Server Template

### Project Structure

```
my-mcp-server/
├── src/
│   ├── index.ts              # Server entry point
│   ├── tools/                # Tool implementations
│   │   └── my-tool.ts
│   ├── types/                # Type definitions and validators
│   │   └── index.ts
│   └── utils/
│       └── logger.ts         # Structured logging
├── package.json
├── tsconfig.json
└── README.md
```

### package.json

```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "main": "dist/index.js",
  "bin": {
    "my-mcp-server": "dist/index.js"
  },
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsx src/index.ts",
    "lint": "eslint src/",
    "test": "vitest"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0",
    "ajv": "^8.17.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "tsx": "^4.0.0",
    "vitest": "^2.0.0"
  }
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### src/index.ts (Complete Server)

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";

import { myTool, validateMyToolArgs } from "./tools/my-tool.js";
import { createValidationErrorResponse } from "./types/index.js";
import { logger } from "./utils/logger.js";

import type { MyToolArgs } from "./types/index.js";

/**
 * Available MCP tools
 */
const TOOLS: Tool[] = [
  {
    name: "my_tool",
    description:
      "Description of what this tool does. Returns structured result.",
    inputSchema: {
      type: "object",
      properties: {
        param1: {
          type: "string",
          description: "Description of param1",
        },
        param2: {
          type: "number",
          description: "Description of param2 (optional)",
        },
      },
      required: ["param1"],
    },
  },
];

/**
 * Main server instance
 */
const server = new Server(
  { name: "my-mcp-server", version: "1.0.0" },
  { capabilities: { tools: {} } },
);

/**
 * Handle list_tools requests
 */
server.setRequestHandler(ListToolsRequestSchema, () => ({
  tools: TOOLS,
}));

/**
 * Handle call_tool requests
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  const startTime = Date.now();

  logger.info("Tool invocation started", {
    tool: name,
    args_provided: JSON.stringify(Object.keys(args || {})),
  });

  try {
    switch (name) {
      case "my_tool": {
        if (!validateMyToolArgs(args)) {
          logger.warn("Tool argument validation failed", {
            tool: name,
            errors: JSON.stringify(validateMyToolArgs.errors),
          });
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(
                  createValidationErrorResponse(validateMyToolArgs.errors),
                ),
              },
            ],
            isError: true,
          };
        }

        const validatedArgs = args as unknown as MyToolArgs;
        const result = myTool(validatedArgs);

        logger.info("Tool invocation completed", {
          tool: name,
          duration_ms: Date.now() - startTime,
        });

        return {
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
        };
      }

      default:
        logger.warn("Unknown tool requested", { tool: name });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                error: `Unknown tool: ${name}`,
                available_tools: TOOLS.map((t) => t.name),
                suggestion: "Use one of the available tools listed above",
              }),
            },
          ],
          isError: true,
        };
    }
  } catch (error) {
    logger.error(
      "Tool invocation failed",
      {
        tool: name,
        duration_ms: Date.now() - startTime,
      },
      error instanceof Error ? error : new Error(String(error)),
    );

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify({
            error: error instanceof Error ? error.message : "Unknown error",
            suggestion: "Check the tool parameters and try again",
          }),
        },
      ],
      isError: true,
    };
  }
});

/**
 * Start the server
 */
async function main(): Promise<void> {
  try {
    logger.info("Starting MCP Server", {
      version: "1.0.0",
      transport: "stdio",
    });

    const transport = new StdioServerTransport();
    await server.connect(transport);

    logger.info("MCP Server started successfully", {
      tools_count: TOOLS.length,
    });

    // Legacy stderr output for backward compatibility
    console.error("MCP Server running on stdio");
  } catch (error) {
    logger.error(
      "Failed to start server",
      {},
      error instanceof Error ? error : new Error(String(error)),
    );
    throw error;
  }
}

main().catch((error) => {
  logger.error(
    "Fatal error during startup",
    {},
    error instanceof Error ? error : new Error(String(error)),
  );
  console.error("Fatal error:", error);
  process.exit(1);
});
```

### src/types/index.ts

```typescript
import Ajv from "ajv";

const ajv = new Ajv();

/**
 * Tool argument interfaces
 */
export interface MyToolArgs {
  param1: string;
  param2?: number;
}

/**
 * Validation error response
 */
export interface ValidationError {
  field: string;
  message: string;
  suggestion: string;
}

/**
 * Ajv validator for MyToolArgs
 */
export const validateMyToolArgs = ajv.compile({
  type: "object",
  properties: {
    param1: { type: "string" },
    param2: { type: "number" },
  },
  required: ["param1"],
  additionalProperties: false,
});

/**
 * Format Ajv errors into ValidationError array
 */
export function formatAjvErrors(
  errors: typeof validateMyToolArgs.errors,
): ValidationError[] {
  if (!errors) return [];

  return errors.map((err) => ({
    field:
      err.instancePath.replace(/^\//, "") ||
      err.params?.missingProperty ||
      "unknown",
    message: err.message || "Validation failed",
    suggestion: getSuggestionForError(err),
  }));
}

function getSuggestionForError(
  err: NonNullable<typeof validateMyToolArgs.errors>[0],
): string {
  if (err.keyword === "required") {
    return `Add the required field: ${err.params?.missingProperty}`;
  }
  if (err.keyword === "type") {
    return `Expected type: ${err.params?.type}`;
  }
  return "Check the parameter format and try again";
}

/**
 * Create standardized validation error response
 */
export function createValidationErrorResponse(
  errors: typeof validateMyToolArgs.errors,
) {
  return {
    success: false,
    errors: formatAjvErrors(errors),
  };
}
```

### src/utils/logger.ts

```typescript
export enum LogLevel {
  DEBUG = "DEBUG",
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR",
}

export interface LogContext {
  tool?: string;
  [key: string]: string | number | boolean | undefined;
}

class Logger {
  private minLevel: LogLevel = LogLevel.INFO;

  constructor() {
    const envLevel = process.env.LOG_LEVEL?.toUpperCase();
    if (envLevel && envLevel in LogLevel) {
      this.minLevel = LogLevel[envLevel as keyof typeof LogLevel];
    }
  }

  private shouldLog(level: LogLevel): boolean {
    const levels = [
      LogLevel.DEBUG,
      LogLevel.INFO,
      LogLevel.WARN,
      LogLevel.ERROR,
    ];
    return levels.indexOf(level) >= levels.indexOf(this.minLevel);
  }

  private log(
    level: LogLevel,
    message: string,
    context?: LogContext,
    error?: Error,
  ): void {
    if (!this.shouldLog(level)) return;

    const entry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      service: "my-mcp-server",
      ...(context && Object.keys(context).length > 0 ? { context } : {}),
      ...(error
        ? {
            error: {
              name: error.name,
              message: error.message,
              stack: error.stack,
            },
          }
        : {}),
    };

    // CRITICAL: Log to stderr, not stdout
    console.error(JSON.stringify(entry));
  }

  debug(message: string, context?: LogContext): void {
    this.log(LogLevel.DEBUG, message, context);
  }

  info(message: string, context?: LogContext): void {
    this.log(LogLevel.INFO, message, context);
  }

  warn(message: string, context?: LogContext, error?: Error): void {
    this.log(LogLevel.WARN, message, context, error);
  }

  error(message: string, context?: LogContext, error?: Error): void {
    this.log(LogLevel.ERROR, message, context, error);
  }
}

export const logger = new Logger();
```

---

## Complete Python FastMCP Template

```python
#!/usr/bin/env python3
"""
My MCP Server - Description of what this server does.
"""

import json
import logging
import sys
from typing import Optional

from mcp.server.fastmcp import FastMCP

# Configure logging to stderr (required for MCP stdio transport)
logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp":"%(asctime)s","level":"%(levelname)s","message":"%(message)s","service":"my-mcp-server"}',
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)

# Initialize FastMCP server
mcp = FastMCP("my-mcp-server", json_response=True)


# === Tools ===

@mcp.tool()
def my_tool(param1: str, param2: Optional[int] = None) -> dict:
    """Process data and return structured result.

    Args:
        param1: Description of param1 (required)
        param2: Description of param2 (optional)

    Returns:
        Structured result with success status
    """
    logger.info(f"my_tool called with param1={param1}, param2={param2}")

    try:
        # Validate inputs
        if not param1:
            return {
                "success": False,
                "errors": [{
                    "field": "param1",
                    "message": "param1 cannot be empty",
                    "suggestion": "Provide a non-empty string value",
                }],
            }

        # Process
        result = f"Processed: {param1}"
        if param2:
            result += f" with value {param2}"

        return {
            "success": True,
            "data": {"result": result},
        }

    except Exception as e:
        logger.error(f"my_tool failed: {e}")
        return {
            "success": False,
            "errors": [{
                "field": "system",
                "message": str(e),
                "suggestion": "Check parameters and try again",
            }],
        }


# === Resources ===

@mcp.resource("config://settings")
def get_settings() -> str:
    """Current server configuration."""
    return json.dumps({
        "version": "1.0.0",
        "features": ["tool1", "tool2"],
    })


@mcp.resource("status://{component}")
def get_component_status(component: str) -> str:
    """Get status for a specific component."""
    statuses = {
        "database": {"status": "healthy", "latency_ms": 5},
        "cache": {"status": "healthy", "hit_rate": 0.95},
    }
    return json.dumps(statuses.get(component, {"status": "unknown"}))


# === Prompts ===

@mcp.prompt()
def analyze_data(data: str, analysis_type: str = "summary") -> str:
    """Generate a data analysis prompt.

    Args:
        data: The data to analyze
        analysis_type: Type of analysis (summary, detailed, comparison)
    """
    prompts = {
        "summary": f"Please provide a brief summary of this data:\n\n{data}",
        "detailed": f"Please provide a detailed analysis of this data:\n\n{data}",
        "comparison": f"Please compare the elements in this data:\n\n{data}",
    }
    return prompts.get(analysis_type, prompts["summary"])


# === Main ===

if __name__ == "__main__":
    logger.info("Starting MCP Server")
    mcp.run(transport="stdio")
```

---

## Tool Design Patterns

### Pattern: Input Length Limiting (ReDoS Prevention)

```typescript
const MAX_INPUT_LENGTH = 50_000;

function safeInput(text: string): string {
  return text.length > MAX_INPUT_LENGTH
    ? text.slice(0, MAX_INPUT_LENGTH)
    : text;
}

// Use before any regex operations
const safeText = safeInput(args.text);
const matches = safeText.match(/pattern/);
```

### Pattern: Structured Tool Response

```typescript
interface ToolResponse<T> {
  success: boolean;
  data?: T;
  errors?: ValidationError[];
  warnings?: string[];
}

function createSuccessResponse<T>(data: T): ToolResponse<T> {
  return { success: true, data };
}

function createErrorResponse(errors: ValidationError[]): ToolResponse<never> {
  return { success: false, errors };
}
```

### Pattern: Tool with Prerequisites Check

```typescript
// Check prerequisites before main operation
if (!args.issue_data?.fields) {
  return {
    content: [
      {
        type: "text",
        text: JSON.stringify({
          success: false,
          errors: [
            {
              field: "issue_data",
              message: "Missing Jira ticket data",
              suggestion:
                "Call mcp__atlassian__getJiraIssue first and pass the result",
            },
          ],
        }),
      },
    ],
    isError: true,
  };
}
```

---

## Resource Design Patterns

### Pattern: Static Resource

```typescript
server.setRequestHandler(ListResourcesRequestSchema, () => ({
  resources: [
    {
      uri: "config://settings",
      name: "Server Configuration",
      description: "Current server configuration values",
      mimeType: "application/json",
    },
  ],
}));
```

### Pattern: Dynamic Resource Template

```typescript
// Resource with URI parameters
server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const uri = request.params.uri;

  // Parse dynamic URI: users://123/profile
  const userMatch = uri.match(/^users:\/\/(\d+)\/profile$/);
  if (userMatch) {
    const userId = userMatch[1];
    const user = await fetchUser(userId);
    return {
      contents: [
        {
          uri,
          mimeType: "application/json",
          text: JSON.stringify(user),
        },
      ],
    };
  }

  throw new Error(`Unknown resource: ${uri}`);
});
```

---

## Error Handling Patterns

### Pattern: Error Classification

```typescript
enum ErrorCategory {
  CLIENT_ERROR = "client_error", // Invalid input from LLM
  SERVER_ERROR = "server_error", // Our server failed
  EXTERNAL_ERROR = "external_error", // Dependency failed
}

interface MCPError {
  category: ErrorCategory;
  code: string;
  message: string;
  suggestion: string;
  retryable: boolean;
}

function classifyError(error: unknown): MCPError {
  if (error instanceof ValidationError) {
    return {
      category: ErrorCategory.CLIENT_ERROR,
      code: "INVALID_INPUT",
      message: error.message,
      suggestion: "Check input parameters match the schema",
      retryable: false,
    };
  }

  if (error instanceof NetworkError) {
    return {
      category: ErrorCategory.EXTERNAL_ERROR,
      code: "NETWORK_FAILURE",
      message: "External service unavailable",
      suggestion: "Try again in a few seconds",
      retryable: true,
    };
  }

  return {
    category: ErrorCategory.SERVER_ERROR,
    code: "INTERNAL_ERROR",
    message: "Unexpected error occurred",
    suggestion: "Contact server administrator",
    retryable: false,
  };
}
```

---

## Security Patterns

### Pattern: Secrets Management

```typescript
// NEVER hardcode secrets
// ❌ Bad
const API_KEY = "sk-abc123...";

// ✅ Good - Use environment variables
const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error("API_KEY environment variable required");
}

// ✅ Better - Delegate secrets to client
// MCP servers should NOT handle secrets
// Return instructions for the client to use their own credentials
return {
  action: "CALL_EXTERNAL_API",
  instruction: "Use your configured API credentials to call this endpoint",
  endpoint: "https://api.example.com/data",
};
```

### Pattern: Input Sanitization

```typescript
function sanitizeForLog(obj: unknown): unknown {
  if (typeof obj !== "object" || obj === null) {
    return obj;
  }

  const sanitized: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(obj)) {
    // Redact sensitive fields
    if (["password", "token", "secret", "apiKey", "api_key"].includes(key)) {
      sanitized[key] = "[REDACTED]";
    } else {
      sanitized[key] = sanitizeForLog(value);
    }
  }
  return sanitized;
}

// Use in logging
logger.info("Request received", { args: sanitizeForLog(args) });
```

---

## Testing Strategies

### Unit Testing Tool Handlers

```typescript
import { describe, it, expect } from "vitest";
import { myTool } from "../src/tools/my-tool.js";

describe("myTool", () => {
  it("should return success for valid input", () => {
    const result = myTool({ param1: "test", param2: 42 });
    expect(result.success).toBe(true);
    expect(result.data).toBeDefined();
  });

  it("should return error for invalid input", () => {
    const result = myTool({ param1: "" });
    expect(result.success).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0].field).toBe("param1");
  });
});
```

### Integration Testing with Mock Transport

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";

describe("MCP Server Integration", () => {
  it("should list available tools", async () => {
    const server = createServer();
    const response = await server.handleRequest({
      method: "tools/list",
      params: {},
    });
    expect(response.tools).toHaveLength(1);
    expect(response.tools[0].name).toBe("my_tool");
  });
});
```

---

## Production Checklist

### Before Deployment

- [ ] All tools have descriptions
- [ ] All input schema properties have descriptions
- [ ] Input validation on all tool handlers
- [ ] Error responses include `isError: true`
- [ ] Logging goes to stderr only
- [ ] No hardcoded secrets
- [ ] Input length limited before regex (ReDoS prevention)
- [ ] Unit tests for all tools
- [ ] Integration tests passing

### Dockerfile Template

```dockerfile
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

ENV NODE_ENV=production
ENV LOG_LEVEL=INFO

CMD ["node", "dist/index.js"]
```

### Health Check Endpoint (HTTP Transport)

```typescript
// For HTTP-based MCP servers
import express from "express";

const app = express();

app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    version: "1.0.0",
    uptime: process.uptime(),
  });
});

app.get("/ready", async (req, res) => {
  // Check dependencies
  const dbHealthy = await checkDatabase();
  if (dbHealthy) {
    res.json({ status: "ready" });
  } else {
    res
      .status(503)
      .json({ status: "not ready", reason: "database unavailable" });
  }
});
```
