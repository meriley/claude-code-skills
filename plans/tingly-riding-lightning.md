# Plan: Consolidate Planning System with Implementation Status Tracking

## Summary

Update the SPARC skill and CLAUDE.md to use a consistent `.plan/<feature>/` folder structure for implementation planning, with a comprehensive status tracker including tasks, SPARC phases, and metrics.

**Scope**: Claude Code's built-in plan mode (`/plan` command) remains unchanged at `.claude/plans/` for temporary planning. Only SPARC skill output changes.

## Changes Required

### 1. Update .gitignore (Global)

**File**: `/home/mriley/.claude/.gitignore`

Add singular `.plan/` pattern (currently only has `.plans/` plural):

```gitignore
# Plans and prompts (per CLAUDE.md instructions)
docs/**/.plans/
docs/**/.prompts/
**/.plans/
**/.prompts/
**/.plan/   # ADD THIS - singular for per-project plans
```

### 2. Update SPARC Skill Step 12

**File**: `/home/mriley/.claude/skills/sparc-plan/SKILL.md`

Change output location from `docs/planning/<feature>/` to `.plan/<feature>/`:

```markdown
### Step 12: Document and Present Plan

Save all planning documents to disk (don't commit - gitignored):

```
Create directory: .plan/<feature-name>/
Files:
- STATUS.md              # NEW: Implementation status tracker
- specification.md
- pseudocode.md
- architecture.md
- refinement-plan.md
- completion-checklist.md
- task-list.md
- security-plan.md
- performance-plan.md
```
```

### 3. Create STATUS.md Template (New)

**Add to SPARC skill**: Template for implementation status tracking

```markdown
# Implementation Status: <Feature Name>

## Overview
- **Feature**: <name>
- **Started**: <date>
- **Target Completion**: <date>
- **Current Phase**: <Specification|Pseudocode|Architecture|Refinement|Completion>

## SPARC Phase Progress

| Phase | Status | Progress | Notes |
|-------|--------|----------|-------|
| Specification | ✅ Complete | 100% | Requirements documented |
| Pseudocode | 🔄 In Progress | 60% | Core algorithms done |
| Architecture | ⏳ Pending | 0% | Waiting on pseudocode |
| Refinement | ⏳ Pending | 0% | - |
| Completion | ⏳ Pending | 0% | - |

## Task Checklist

### Phase 1: Foundation (X/Y complete)
- [x] Task 1 description
- [ ] Task 2 description
- [ ] Task 3 description

### Phase 2: Core Logic (X/Y complete)
- [ ] Task 4 description
- [ ] Task 5 description

## Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Unit Test Coverage | 90% | 0% | ⏳ |
| E2E Tests Passing | 100% | 0% | ⏳ |
| Linter Issues | 0 | - | ⏳ |
| Security Scan | Pass | - | ⏳ |

## Blockers & Risks

| Risk | Severity | Status | Mitigation |
|------|----------|--------|------------|
| None yet | - | - | - |

## History

| Date | Update | By |
|------|--------|-----|
| YYYY-MM-DD | Initial plan created | Pedro |
```

### 4. Update CLAUDE.md Documentation

**File**: `/home/mriley/.claude/CLAUDE.md` (global) and project CLAUDE.md

Add section explaining the planning structure:

```markdown
## Planning Structure

### Claude Code Built-in Plan Mode
- **Location**: `~/.claude/plans/` (auto-generated names)
- **Purpose**: Temporary conversation-level planning
- **Persistence**: Session-only, not committed

### SPARC Implementation Plans
- **Location**: `.plan/<feature-name>/` at project root
- **Purpose**: Comprehensive feature planning with status tracking
- **Persistence**: Gitignored but persistent locally
- **Invoke**: Use `sparc-plan` skill

### Finding Plans
When starting work on a feature:
1. Check `.plan/` folder for existing plans
2. Look for `STATUS.md` to understand current progress
3. Review task-list.md for pending work
```

### 5. Add SPARC Skill Instructions to Look for Existing Plans

**File**: `/home/mriley/.claude/skills/sparc-plan/SKILL.md`

Add step at beginning of workflow:

```markdown
### Step 0: Check for Existing Plans

Before creating a new plan, check if one exists:

```bash
ls -la .plan/
```

If `.plan/<feature>/STATUS.md` exists:
1. Read STATUS.md for current phase and progress
2. Ask user: "Found existing plan at .plan/<feature>/. Resume from current status or start fresh?"
3. If resuming, update STATUS.md rather than recreating all documents
```

## Files to Modify

1. `/home/mriley/.claude/.gitignore` - Add `**/.plan/` pattern
2. `/home/mriley/.claude/skills/sparc-plan/SKILL.md` - Change output path, add Step 0, add STATUS.md
3. `/home/mriley/.claude/CLAUDE.md` - Add Planning Structure section
4. `/home/mriley/CLAUDE.md` (project template) - Add same section

## Implementation Order

1. Update .gitignore first (ensures plans won't be committed)
2. Create STATUS.md template content in SKILL.md
3. Update SPARC skill Step 12 output location
4. Add Step 0 to check existing plans
5. Update CLAUDE.md documentation
6. Test by invoking sparc-plan on a small feature

## Notes

- This does NOT affect Claude Code's built-in `/plan` mode
- The `.plan/` folder is intentionally different from `.plans/` (both are gitignored)
- STATUS.md provides the implementation tracking distinct from a roadmap (roadmap = long-term vision, STATUS.md = current feature progress)
