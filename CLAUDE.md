# CLAUDE.md - AI Development Assistant Guide

## 🎯 PRIORITY DIRECTIVES (READ FIRST)

### Step 1: Understand Context
1. **ALWAYS run `git log --oneline -20` first** to understand project history
2. **Check `git status`** to see current state
3. **Read recent commits** to understand what previous Claude sessions accomplished
4. **Never duplicate work** already done in previous commits
5. **The Users Name** is Mark

### Step 2: Critical Rules
1. **Lint errors = Syntax errors** - Fix ALL before proceeding
2. **Never create test/example files** in production code
3. **Git commits are your memory** - Commit at every working milestone
4. **90% unit test coverage + 100% E2E pass rate** required

## 🚫 FORBIDDEN ACTIONS

❌ Creating "simple_test.py" or "example.js" files
❌ Ignoring linter warnings
❌ Committing without tests
❌ Using mocks in E2E tests
❌ Making changes without checking git history first
❌ Checking .plans or .prompts directories into git

## 📋 SPARC Framework

### Quick Reference
1. **S**pecification - Define what to build
2. **P**seudocode - Plan the implementation  
3. **A**rchitecture - Design the structure
4. **R**efinement - Improve and test
5. **C**ompletion - Finalize with full tests

## 🛠️ MCP Tools Quick Reference

### Research First
# Always check documentation before coding
context7: resolve-library-id → get-library-docs

### File Operations
filesystem: read_file, write_file, edit_file, list_directory

### Git Memory System
# Start every session with:
git_status     # Current state
git_log        # Project history (your memory)
git_diff       # Uncommitted changes

# After each milestone:
git_add [files]
git_commit -m "[SPARC Phase] What you accomplished"

## 📝 Git Commit Strategy

### When to Commit
- ✅ Feature works and compiles
- ✅ Tests pass
- ✅ Linter clean
- ✅ Meaningful progress made

### Commit Message Format
[SPARC-Phase] Brief description

- Bullet point of specific changes
- Another specific change
- Test coverage: XX%

### Example Commits
[Architecture] Add user authentication module
- Created JWT token service
- Added password hashing utilities  
- Unit test coverage: 95%

[Refinement] Fix all ESLint errors in auth module
- Fixed 23 linting issues
- Updated import statements
- No functionality changes

## 🔄 Session Recovery Protocol

When starting work on existing project:
1. `git_log` - Read last 20 commits
2. `git_status` - Check working state
3. `filesystem:read_file README.md` - Understand project
4. `filesystem:list_directory` - See structure
5. **Check for .plans directories** - Read TODO status
6. Continue from last commit's work

## 📊 Quality Gates

Before ANY commit:
- [ ] Code compiles/runs
- [ ] All tests pass
- [ ] Linter shows 0 errors
- [ ] Changes match commit message

## 🎯 Working Example

# Starting a session
$ git_log --oneline -10
> a1b2c3d [Refinement] Add input validation to user service
> d4e5f6g [Architecture] Create user service structure
> ...

# Understanding: "Previous Claude added user service, needs testing"

# Continue work
$ filesystem:read_file src/services/userService.js
$ # Write tests...
$ git_add src/services/userService.test.js
$ git_commit -m "[Testing] Add unit tests for user service
- Test coverage: 92%
- All edge cases covered"

## 🚀 Quick Start Checklist

- [ ] Run `git_log` to read project history
- [ ] Check `git_status` for current state
- [ ] Use Context7 for unfamiliar libraries
- [ ] Write code incrementally
- [ ] Test as you go
- [ ] Fix all linter issues immediately
- [ ] Commit at working milestones
- [ ] Update docs with progress

## 🔧 Available MCP Servers

### 1. Context7 - Library Documentation
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp

### 2. Filesystem - File Operations  
claude mcp add-json --scope user filesystem '{"type":"stdio","command":"npx","args":["-y","@modelcontextprotocol/server-filesystem","/home", "/mnt"]}'

### 3. Git - Version Control
claude mcp add-json --scope user git '{"type":"stdio","command":"uvx","args":["mcp-server-git"]}'

### 4. Playwright - Browser Automation
claude mcp add-json --scope user playwright '{"type":"stdio","command":"npx","args":["-y","@playwright/mcp@latest","--headless"]}'

### 5. Playwright Vision - Visual Browser Automation
claude mcp add-json --scope user playwright-vision '{"type":"stdio","command":"npx","args":["-y","@playwright/mcp@latest","--headless", "--vision"]}'

### 6. Fetch - Web Content Retrieval
claude mcp add-json --scope user fetch '{"type":"stdio","command":"uvx","args":["mcp-server-fetch"]}'

### 7. Sequential Thinking - Extended Reasoning
claude mcp add-json --scope user sequential-thinking '{"type":"stdio","command":"npx","args":["-y","@modelcontextprotocol/server-sequential-thinking"]}'

## 📁 Documentation Structure

./docs
├── api/
├── architecture/
│   ├── .plans/     # Implementation plans (NEVER commit to git)
│   └── .prompts/   # AI prompts (NEVER commit to git)
├── testing/
│   ├── unit/       # Unit test plans
│   └── e2e/        # E2E test plans
└── deployment/

### ⚠️ CRITICAL: Plan Management

1. **NEVER commit .plans or .prompts to git** - Add to .gitignore:
   docs/**/.plans/
   docs/**/.prompts/

2. **Plan documents are living TODOs** - Update as you work:
   ## TODO
   - [x] Create user model - COMPLETED 2024-01-15
   - [x] Add validation - COMPLETED 2024-01-15  
   - [ ] Write unit tests
   - [ ] Add integration tests

3. **Check existing docs first** - Before creating new:
   # Check if topic already documented
   $ filesystem:search_files docs/ "authentication"
   $ filesystem:read_file docs/api/authentication.md
   # Append to existing file if relevant

4. **Persist important decisions** - Move from .plans to permanent docs:
   - Architecture decisions → docs/architecture/
   - API changes → docs/api/
   - Testing strategies → docs/testing/

## 🔄 Plan Execution Workflow

1. **Find active plans**:
   $ filesystem:list_directory docs/architecture/.plans/
   $ filesystem:read_file docs/architecture/.plans/auth_implementation_plan.md

2. **Rebuild TODO from plan**:
   # Read plan, identify incomplete items
   # Continue from last completed task

3. **Update plan as you work**:
   $ filesystem:edit_file docs/architecture/.plans/auth_implementation_plan.md
   # Mark completed items with [x] and date
   # Add notes about implementation decisions

4. **Extract permanent documentation**:
   # Move important decisions to versioned docs
   $ filesystem:append_file docs/architecture/auth_design.md

## Remember
- **Git = Your Memory**: Always check history first
- **Plans = Your TODO**: Keep updated, never commit
- **Quality > Speed**: No shortcuts
- **Test Everything**: Not optional
- **Lint Clean**: Always
- **Small Commits**: Easier to understand later