# TypeScript MCP Server Template

Quick-start template for production TypeScript MCP servers.

## Usage

```bash
# Create project
mkdir my-mcp-server && cd my-mcp-server
npm init -y

# Install dependencies
npm install @modelcontextprotocol/sdk ajv
npm install -D typescript @types/node tsx vitest

# Create structure
mkdir -p src/{tools,types,utils}
```

## Copy This: package.json

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

## Copy This: tsconfig.json

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

## Copy This: src/index.ts

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import Ajv from "ajv";

// === Configuration ===
const SERVER_NAME = "my-mcp-server";
const SERVER_VERSION = "1.0.0";

// === Logging (to stderr) ===
function log(level: string, message: string, context?: object): void {
  console.error(
    JSON.stringify({
      timestamp: new Date().toISOString(),
      level,
      message,
      service: SERVER_NAME,
      ...context,
    }),
  );
}

// === Validation ===
const ajv = new Ajv();

const validateMyToolArgs = ajv.compile({
  type: "object",
  properties: {
    input: { type: "string" },
  },
  required: ["input"],
});

// === Tool Definitions ===
const TOOLS: Tool[] = [
  {
    name: "my_tool",
    description:
      "Description of what this tool does. Returns structured result.",
    inputSchema: {
      type: "object",
      properties: {
        input: {
          type: "string",
          description: "Input to process",
        },
      },
      required: ["input"],
    },
  },
];

// === Tool Implementations ===
function myTool(args: { input: string }) {
  return {
    success: true,
    data: { processed: args.input.toUpperCase() },
  };
}

// === Server Setup ===
const server = new Server(
  { name: SERVER_NAME, version: SERVER_VERSION },
  { capabilities: { tools: {} } },
);

server.setRequestHandler(ListToolsRequestSchema, () => ({ tools: TOOLS }));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  const startTime = Date.now();

  log("INFO", "Tool invocation started", { tool: name });

  try {
    switch (name) {
      case "my_tool": {
        if (!validateMyToolArgs(args)) {
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify({
                  success: false,
                  errors: validateMyToolArgs.errors,
                  suggestion: "Check input parameters",
                }),
              },
            ],
            isError: true,
          };
        }

        const result = myTool(args as { input: string });
        log("INFO", "Tool completed", {
          tool: name,
          duration_ms: Date.now() - startTime,
        });

        return {
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
        };
      }

      default:
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({ error: `Unknown tool: ${name}` }),
            },
          ],
          isError: true,
        };
    }
  } catch (error) {
    log("ERROR", "Tool failed", {
      tool: name,
      error: error instanceof Error ? error.message : "Unknown",
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify({
            error: error instanceof Error ? error.message : "Unknown error",
            suggestion: "Check parameters and try again",
          }),
        },
      ],
      isError: true,
    };
  }
});

// === Start Server ===
async function main(): Promise<void> {
  log("INFO", "Starting server", { version: SERVER_VERSION });
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error(`${SERVER_NAME} running on stdio`);
}

main().catch((error) => {
  log("ERROR", "Fatal error", { error: error.message });
  process.exit(1);
});
```

## Claude Desktop Configuration

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "node",
      "args": ["/path/to/my-mcp-server/dist/index.js"],
      "env": {
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```
