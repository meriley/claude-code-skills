# Claude Code Configuration

This repository contains my personal Claude Code configuration and customizations.

## What's Included

- **CLAUDE.md** - Core development policies and standards
- **29 Custom Skills** - Workflow automation (safe-commit, create-pr, security-scan, etc.)
- **6 Slash Commands** - Quick command shortcuts
- **MCP Configuration** - Model Context Protocol servers
- **Settings** - Claude Code preferences

## Setup on New Machine (Mac)

### 1. Clone the Repository

```bash
cd ~
git clone https://gitea.cmtriley.com/mriley/claude-config.git .claude
```

### 2. Install Claude Code (if not already installed)

```bash
npm install -g @anthropic-ai/claude-code
```

### 3. Configure MCP Servers

The `mcp.json` file includes these servers:
- **context7** - Library documentation
- **fetch** - Web content retrieval
- **filesystem** - File operations
- **git** - Version control
- **playwright** - Browser automation

Make sure you have the required tools:

```bash
# Install uvx (for Python-based MCP servers)
pip install uv

# MCP servers will auto-install via npx/uvx when first used
```

### 4. Set Environment Variables

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Gitea
export GITEA_ACCESS_TOKEN="your-token-here"

# GitHub (if needed)
export GITHUB_ACCESS_TOKEN="your-token-here"
```

### 5. Update Filesystem Paths

Edit `~/.claude/mcp.json` and update the filesystem server paths to match your Mac:

```json
{
  "filesystem": {
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/Users/yourusername/projects"  // Update this path
    ]
  }
}
```

## Skills Overview

### Core Workflow
- `check-history` - Review git history at start of tasks
- `safe-commit` - Commit with quality checks
- `create-pr` - Create pull request
- `manage-branch` - Branch management (enforces mriley/ prefix)

### Quality & Security
- `security-scan` - Scan for vulnerabilities
- `quality-check` - Lint and format checks
- `run-tests` - Execute test suites

### Documentation
- `api-doc-writer` - Generate API documentation
- `migration-guide-writer` - Create migration guides
- `tutorial-writer` - Write tutorials

### Language Setup
- `setup-go` - Go development environment
- `setup-python` - Python development environment
- `setup-node` - Node.js/TypeScript environment

## Usage

After setup, start Claude Code in any project:

```bash
cd ~/projects/myproject
claude
```

Use skills with the `/` prefix:
```
/check-history
/safe-commit
/create-pr
```

## Syncing Changes

### Pull Latest Changes
```bash
cd ~/.claude
git pull
```

### Push Changes
```bash
cd ~/.claude
git add -A
git commit -m "Update configuration"
git push
```

## Important Notes

- Runtime files (history, credentials, debug logs) are excluded via `.gitignore`
- Never commit `.plans/` or `.prompts/` directories
- MCP server configurations may need path adjustments per machine
- Access tokens should be set as environment variables, not committed

## Troubleshooting

### MCP Servers Not Working
```bash
# Check MCP configuration
cat ~/.claude/mcp.json

# Test individual server
npx @upstash/context7-mcp@latest
```

### Skills Not Loading
```bash
# Verify skills directory
ls ~/.claude/skills/

# Check skill format
cat ~/.claude/skills/safe-commit/Skill.md
```

### Permission Issues
```bash
# Fix permissions
chmod -R 755 ~/.claude
```

## Repository

- **Gitea:** https://gitea.cmtriley.com/mriley/claude-config
- **Private Repository** - Not publicly accessible
