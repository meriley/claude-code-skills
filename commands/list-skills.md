---
allowed-tools: Bash(ls:*), Bash(grep:*), Bash(cat:*), Read, Glob
argument-hint: [category|search-term]
description: List available skills with optional filtering by category or search term
---

# List Skills

Quick reference for all available Claude Code skills with search and filtering.

## Usage

```
/list-skills                    # List all skills grouped by category
/list-skills helm               # Filter to helm-related skills
/list-skills review             # Filter to review skills
/list-skills writing            # Filter to writing skills
/list-skills <search-term>      # Search skill names and descriptions
```

## Step 1: Gather All Skills

Read all skill frontmatter to extract names and descriptions:

```bash
for dir in /home/mriley/.claude/skills/*/; do
  if [ -f "$dir/SKILL.md" ]; then
    name=$(basename "$dir")
    desc=$(grep -m1 "^description:" "$dir/SKILL.md" | sed 's/description: //')
    echo "$name|$desc"
  fi
done
```

## Step 2: Apply Filter (if provided)

If user provided an argument, filter the results:
- Match against skill name
- Match against description
- Case-insensitive search

## Step 3: Group by Category

Organize skills into these categories based on naming patterns:

### Core Workflow
- `check-history` - Git context gathering
- `safe-commit` - Commit with safety checks
- `create-pr` - PR creation workflow
- `manage-branch` - Branch management
- `safe-destroy` - Destructive operation safety

### Quality & Security (Auto-invoked by safe-commit)
- `security-scan` - Security scanning
- `quality-check` - Linting and formatting
- `run-tests` - Test execution

### Language-Specific Audits
- `control-flow-check` - Go control flow
- `error-handling-audit` - Go error handling
- `type-safety-audit` - TypeScript types
- `n-plus-one-detection` - GraphQL N+1

### Documentation
- `api-doc-writer` - API reference docs
- `api-documentation-verify` - Doc verification
- `migration-guide-writer` - Migration guides
- `tutorial-writer` - Tutorials
- `technical-writer` - Base documentation skill

### Planning & Specs
- `sparc-plan` / `sparc-planning` - Implementation planning
- `prd-writing` / `prd-reviewing` - PRDs
- `feature-spec-writing` / `feature-spec-reviewing` - Feature specs
- `technical-spec-writing` / `technical-spec-reviewing` - Tech specs

### Infrastructure
- `helm-chart-writing` / `helm-chart-review` - Helm charts
- `helm-argocd-gitops` - ArgoCD/GitOps
- `helm-production-patterns` - Deployment patterns
- `helm-chart-expert` - Comprehensive Helm guide
- `implementing-casbin` / `reviewing-casbin` - Authorization

### Frontend & UI
- `mantine-developing` / `mantine-reviewing` - Mantine components
- `playwright-writing` / `playwright-reviewing` - E2E testing

### IDE & Tooling
- `cursor-rules-writing` / `cursor-rules-review` - Cursor rules
- `skill-writing` / `skill-review` - Claude Code skills

### Language Setup
- `setup-go` - Go environment
- `setup-node` - Node.js environment
- `setup-python` - Python environment

### PR & GitHub
- `pr-description-writer` - PR descriptions

## Step 4: Output Format

### If no filter provided:

```
## Available Skills (42 total)

### Core Workflow (5 skills)
- check-history - Git context gathering at start of every task
- safe-commit - Complete commit workflow with security, quality, testing
- create-pr - PR creation with branch management
- manage-branch - Branch creation with mriley/ prefix enforcement
- safe-destroy - Destructive operations with confirmation

### Quality & Security (3 skills)
- security-scan - Secrets, vulnerabilities, injection risks
- quality-check - Linting, formatting, static analysis
- run-tests - Unit, integration, E2E testing

[... remaining categories ...]

---
TIP: Use /list-skills <term> to filter (e.g., /list-skills helm)
```

### If filter provided:

```
## Skills matching "helm" (5 results)

- helm-chart-writing - Create production-ready Helm charts
- helm-chart-review - Security and quality audits for Helm charts
- helm-argocd-gitops - ArgoCD Application configuration
- helm-production-patterns - Secrets, blue-green, canary deployments
- helm-chart-expert - Comprehensive Helm guide

---
Showing 5 of 42 skills
```

## Notes

- Skills are stored in `/home/mriley/.claude/skills/`
- Each skill has a `SKILL.md` file with frontmatter (name, description, version)
- Use `/list-skills <category>` to quickly find skills by domain
- Mandatory skills are marked with notes about when they're required
