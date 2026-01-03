# Implementation Planning Templates

Copy these templates when creating implementation plans for PRDs.

---

## Full Implementation Plan Section

```markdown
---

## Implementation Plan

> **Added by:** `prd-implementation-planning` skill
> **Date:** YYYY-MM-DD

### Skill Requirements

| Domain | Skills Required | Purpose |
|--------|-----------------|---------|
| [Domain] | `[skill-name]` | [What it's used for] |
| [Domain] | `[skill-name]` | [What it's used for] |

### Implementation Tasks

| # | Task | User Story | Skill | Priority | Dependencies | Est. |
|---|------|------------|-------|----------|--------------|------|
| 1 | [Task description] | US-1 | `[skill-name]` | P0 | None | M |
| 2 | [Task description] | US-1 | `[skill-name]` | P0 | 1 | L |
| 3 | [Task description] | US-2 | `[skill-name]` | P1 | 2 | M |

### Implementation Notes

- [Any prerequisites or blockers]
- [Technology decisions]
- [Integration requirements]

---

## Implementation Progress

| #   | Task               | Status  | Started | Completed | Commit |
| --- | ------------------ | ------- | ------- | --------- | ------ |
| 1   | [Task description] | Pending | -       | -         | -      |
| 2   | [Task description] | Pending | -       | -         | -      |
| 3   | [Task description] | Pending | -       | -         | -      |

### Progress Summary

- **Total Tasks:** 3
- **Completed:** 0 (0%)
- **In Progress:** 0
- **Blocked:** 0
- **Pending:** 3
- **Last Updated:** YYYY-MM-DD

### Blockers

| Task # | Blocker Description | Owner | Resolution ETA |
| ------ | ------------------- | ----- | -------------- |
| -      | None                | -     | -              |
```

---

## Minimal Implementation Plan

For simpler PRDs with fewer tasks:

```markdown
---

## Implementation Plan

### Tasks

| #   | Task   | Skill     | Priority | Est. |
| --- | ------ | --------- | -------- | ---- |
| 1   | [Task] | `[skill]` | P0       | M    |
| 2   | [Task] | `[skill]` | P1       | L    |

### Progress

| #   | Status  | Completed | Commit |
| --- | ------- | --------- | ------ |
| 1   | Pending | -         | -      |
| 2   | Pending | -         | -      |

**Last Updated:** YYYY-MM-DD
```

---

## Status Updates

When updating task progress:

### Mark Task In Progress

```markdown
| 2 | Add API endpoint | In Progress | 2024-01-15 | - | - |
```

### Mark Task Done

```markdown
| 2 | Add API endpoint | Done | 2024-01-15 | 2024-01-16 | `abc1234` |
```

### Mark Task Blocked

```markdown
| 3 | Build UI component | Blocked | 2024-01-15 | - | - |
```

Add to Blockers table:

```markdown
| 3 | Waiting for design mockups | @designer | 2024-01-18 |
```

---

## Progress Summary Update

After each status change, update the summary:

```markdown
### Progress Summary

- **Total Tasks:** 5
- **Completed:** 2 (40%)
- **In Progress:** 1
- **Blocked:** 1
- **Pending:** 1
- **Last Updated:** 2024-01-16
```

---

## Effort Estimates

| Size | Time      | When to Use                         |
| ---- | --------- | ----------------------------------- |
| XS   | < 1 hour  | Trivial changes, config tweaks      |
| S    | 1-2 hours | Simple features, single file        |
| M    | 2-4 hours | Standard features, few files        |
| L    | 4-8 hours | Complex features, multiple files    |
| XL   | 8+ hours  | Should be broken into smaller tasks |

---

## Priority Levels

| Priority | Meaning       | Action                             |
| -------- | ------------- | ---------------------------------- |
| P0       | Critical path | Must complete for feature to work  |
| P1       | High priority | Important for quality/completeness |
| P2       | Nice to have  | Can defer if needed                |

---

## Commit Message Format

Include task reference for auto-tracking:

```
<type>(<scope>): <description> [PRD Task N]
```

Examples:

```
feat(orders): create Order entity [PRD Task 1]
feat(api): add createOrder mutation [PRD Task 2]
test(orders): add order flow E2E tests [PRD Task 4]
```
