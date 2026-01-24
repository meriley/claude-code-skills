# Python FastMCP Server Template

Quick-start template for production Python MCP servers using FastMCP.

## Usage

```bash
# Create project
mkdir my-mcp-server && cd my-mcp-server

# Install with uv (recommended)
uv init
uv add mcp

# Or with pip
pip install mcp
```

## Copy This: server.py

```python
#!/usr/bin/env python3
"""
My MCP Server - [Description of what this server does]
"""

import json
import logging
import sys
from typing import Optional

from mcp.server.fastmcp import FastMCP

# === Logging Configuration ===
# CRITICAL: Log to stderr, not stdout (stdout is for JSON-RPC)
logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp":"%(asctime)s","level":"%(levelname)s","message":"%(message)s","service":"my-mcp-server"}',
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)

# === Server Initialization ===
mcp = FastMCP("my-mcp-server", json_response=True)

# === Constants ===
MAX_INPUT_LENGTH = 50_000  # ReDoS prevention


def safe_input(text: str) -> str:
    """Limit input length before regex processing."""
    return text[:MAX_INPUT_LENGTH] if len(text) > MAX_INPUT_LENGTH else text


# === Tools ===

@mcp.tool()
def my_tool(input_text: str, option: Optional[str] = None) -> dict:
    """Process input and return structured result.

    Args:
        input_text: Text to process (required)
        option: Processing option (optional, default: 'default')

    Returns:
        Structured result with success status and processed data
    """
    logger.info(f"my_tool called: input_length={len(input_text)}, option={option}")

    try:
        # Validate input
        if not input_text:
            return {
                "success": False,
                "errors": [{
                    "field": "input_text",
                    "message": "input_text cannot be empty",
                    "suggestion": "Provide a non-empty string value",
                }],
            }

        # Apply input safety
        safe_text = safe_input(input_text)

        # Process
        result = safe_text.upper()
        if option:
            result = f"[{option}] {result}"

        return {
            "success": True,
            "data": {
                "result": result,
                "original_length": len(input_text),
                "processed_length": len(result),
            },
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
        "max_input_length": MAX_INPUT_LENGTH,
    })


@mcp.resource("status://{component}")
def get_component_status(component: str) -> str:
    """Get status for a specific component.

    Args:
        component: Component name (database, cache, etc.)
    """
    statuses = {
        "server": {"status": "healthy", "uptime_seconds": 0},
        "tools": {"status": "ready", "count": 1},
    }
    return json.dumps(statuses.get(component, {"status": "unknown"}))


# === Prompts ===

@mcp.prompt()
def analyze_text(text: str, analysis_type: str = "summary") -> str:
    """Generate a text analysis prompt.

    Args:
        text: Text to analyze
        analysis_type: Type of analysis (summary, detailed, keywords)
    """
    prompts = {
        "summary": f"Please provide a brief summary of this text:\n\n{text}",
        "detailed": f"Please provide a detailed analysis of this text:\n\n{text}",
        "keywords": f"Please extract the main keywords from this text:\n\n{text}",
    }
    return prompts.get(analysis_type, prompts["summary"])


# === Main ===

if __name__ == "__main__":
    logger.info("Starting MCP Server")
    mcp.run(transport="stdio")
```

## Claude Desktop Configuration

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "python",
      "args": ["/path/to/my-mcp-server/server.py"],
      "env": {
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

## Using uv for Fast Execution

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "uv",
      "args": ["run", "/path/to/my-mcp-server/server.py"]
    }
  }
}
```

## Testing Locally

```bash
# Run server directly
python server.py

# Test with MCP inspector
npx @modelcontextprotocol/inspector python server.py
```
