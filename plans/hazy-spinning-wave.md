# Plan: Claude Code Hooks for Skills Enforcement

## Summary
Evaluate and implement hooks to enforce skill usage, prevent dangerous operations, and enhance workflow automation.

## Hook Opportunities Analysis

Based on our skills/agents system, here are high-value hook opportunities:

---

## Tier 1: Critical Enforcement Hooks

### 1. Block Direct Git Commits (PreToolUse)
**Problem:** CLAUDE.md requires `safe-commit` skill, but manual `git commit` can bypass it.

**Hook:**
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "uv run ~/.claude/hooks/enforce-safe-commit.py"
  }]
}
```

**Script Logic:**
- Detect `git commit` in command
- Return exit 2 (block) with message: "Use safe-commit skill instead"
- Allow if explicitly bypassed

---

### 2. Block Destructive Commands (PreToolUse)
**Problem:** `safe-destroy` skill should gate `git reset --hard`, `rm -rf`, `git clean -fd`.

**Hook:**
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "uv run ~/.claude/hooks/enforce-safe-destroy.py"
  }]
}
```

**Script Logic:**
- Detect destructive patterns
- Return exit 2 (block) with message: "Use safe-destroy skill first"

---

### 3. Session Start Context (SessionStart)
**Problem:** `check-history` skill should run at session start.

**Hook:**
```json
{
  "hooks": [{
    "type": "command",
    "command": "~/.claude/hooks/session-context.sh"
  }]
}
```

**Script Logic:**
- Run `git status`, `git log --oneline -5`, `git branch`
- Output as additionalContext
- Reminds to invoke check-history skill

---

## Tier 2: Quality Enhancement Hooks

### 4. Auto-Format After Edits (PostToolUse)
**Problem:** Ensure consistent formatting after file modifications.

**Hook:**
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "uv run ~/.claude/hooks/auto-format.py"
  }]
}
```

**Script Logic:**
- Detect file extension (.ts, .tsx, .go, .py)
- Run appropriate formatter (prettier, gofmt, black)

---

### 5. Protect Sensitive Files (PreToolUse)
**Problem:** Prevent accidental edits to .env, package-lock.json, .git/.

**Hook:**
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "uv run ~/.claude/hooks/protect-files.py"
  }]
}
```

**Script Logic:**
- Check file_path against protected patterns
- Block with explanation if matched

---

### 6. Branch Naming Enforcement (PreToolUse)
**Problem:** All branches must use `mriley/` prefix.

**Hook:**
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "uv run ~/.claude/hooks/enforce-branch-prefix.py"
  }]
}
```

**Script Logic:**
- Detect `git checkout -b` or `git branch`
- Verify branch name starts with `mriley/`
- Block if invalid

---

## Tier 3: Nice-to-Have Hooks

### 7. Command Logging (PreToolUse)
**Purpose:** Audit trail of all bash commands.

### 8. Stop Verification (Stop)
**Purpose:** Check if todos completed, remind about uncommitted changes.

### 9. Notification Enhancement (Notification)
**Purpose:** Desktop notifications when Claude needs input.

---

## Recommended Implementation

### Phase 1: Critical Enforcement
| Hook | Priority | Effort | Impact |
|------|----------|--------|--------|
| Block direct git commit | HIGH | Medium | Enforces safe-commit |
| Block destructive commands | HIGH | Medium | Enforces safe-destroy |
| Session context | HIGH | Low | Better context awareness |

### Phase 2: Quality Enhancement
| Hook | Priority | Effort | Impact |
|------|----------|--------|--------|
| Auto-format after edits | MEDIUM | Medium | Consistent formatting |
| Protect sensitive files | MEDIUM | Low | Security improvement |
| Branch naming | MEDIUM | Low | Consistency |

---

## Files to Create

```
~/.claude/hooks/
├── enforce-safe-commit.py    # Block git commit
├── enforce-safe-destroy.py   # Block destructive commands
├── enforce-branch-prefix.py  # Verify mriley/ prefix
├── session-context.sh        # Session start context
├── auto-format.py            # Post-edit formatting
└── protect-files.py          # Sensitive file protection
```

---

## Settings.json Structure

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "uv run ~/.claude/hooks/enforce-safe-commit.py"},
          {"type": "command", "command": "uv run ~/.claude/hooks/enforce-safe-destroy.py"},
          {"type": "command", "command": "uv run ~/.claude/hooks/enforce-branch-prefix.py"}
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {"type": "command", "command": "uv run ~/.claude/hooks/protect-files.py"}
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {"type": "command", "command": "uv run ~/.claude/hooks/auto-format.py"}
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {"type": "command", "command": "~/.claude/hooks/session-context.sh"}
        ]
      }
    ]
  }
}
```

---

## User Decisions

- **Scope:** Tier 1 + Tier 2 (All hooks)
- **Strictness:** Hard block (exit 2) - must use skills
- **Location:** User settings (~/.claude/settings.json)
- **Formatters:** prettier (TS/JS), gofmt (Go), black (Python)
- **Protected files:** .env*, .git/, *-lock.json, *.lock

---

## Implementation Plan

### Files to Create (6 scripts)

1. `~/.claude/hooks/enforce-safe-commit.py` - Block `git commit`
2. `~/.claude/hooks/enforce-safe-destroy.py` - Block destructive commands
3. `~/.claude/hooks/enforce-branch-prefix.py` - Require `mriley/` prefix
4. `~/.claude/hooks/session-context.sh` - Inject git context at start
5. `~/.claude/hooks/auto-format.py` - Format after edits
6. `~/.claude/hooks/protect-files.py` - Block sensitive file edits

### Settings to Update

Update `~/.claude/settings.json` with hooks configuration.

### Execution Order

1. Create `~/.claude/hooks/` directory
2. Create all 6 hook scripts
3. Make scripts executable
4. Update settings.json with hooks config
5. Test each hook

---

## Trade-offs

### Pros
- **Deterministic enforcement** - Skills can't be bypassed
- **Reduced cognitive load** - System enforces policies
- **Better security** - Protected files, blocked destructive commands
- **Consistency** - Auto-formatting, branch naming

### Cons
- **Maintenance** - Hook scripts need updating
- **Complexity** - More moving parts
- **False positives** - May block legitimate edge cases
- **Debugging** - Hook failures need investigation

---

## Alternative: No Hooks

Continue relying on:
- CLAUDE.md skill guards (LLM-enforced)
- User discipline
- Post-commit reviews

This is simpler but less deterministic.
