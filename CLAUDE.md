# CLAUDE.md

## CRITICAL: NO AI ATTRIBUTION - ZERO TOLERANCE

**NEVER add ANY of these to commits, code, or GitHub activity:**

- `Co-authored-by: Claude <noreply@anthropic.com>`
- `Generated with [Claude Code]`
- "Generated with Claude", "AI-suggested", "Claude recommends"
- Any reference to being an AI assistant

**User's name is Pedro.**

---

## CRITICAL: DESTRUCTIVE COMMAND SAFEGUARDS

**NEVER run without explicit user confirmation:**

| Command            | Risk                                  |
| ------------------ | ------------------------------------- |
| `git reset --hard` | Destroys uncommitted changes          |
| `git clean -fd`    | Permanently deletes untracked files   |
| `rm -rf`           | Permanently deletes files/directories |

**Use `safe-destroy` skill before ANY destructive operation.**

---

## CRITICAL: QUALITY CHECK POLICY - ZERO TOLERANCE

**Quality checks ALWAYS run on the ENTIRE repository, not just modified files.**

**Rules:**

1. ANY quality check failure is a blocking error
2. Failures MUST be fixed before committing - NO EXCEPTIONS
3. **Whoever discovers failing quality is responsible for fixing it**
4. This applies even if you didn't introduce the issue
5. Do not pass broken code to future sessions

**Rationale:** Technical debt compounds. Fixing issues when discovered prevents
accumulation and ensures every commit maintains quality standards.

---

## Skill Decision Tree

**Skills are MANDATORY - never execute workflows manually.**

### Core Git Operations

| User Action                 | MANDATORY Skill |
| --------------------------- | --------------- |
| Starting ANY task           | `check-history` |
| User says "commit"          | `safe-commit`   |
| User says "raise/create PR" | `create-pr`     |
| Destructive command needed  | `safe-destroy`  |
| Creating/switching branches | `manage-branch` |

### Language Setup

| Project Type    | Skill                   |
| --------------- | ----------------------- |
| Go project      | `setup-go`              |
| Python project  | `setup-python` (use uv) |
| Node.js project | `setup-node`            |

### Domain Skills

#### OBS Plugin Development

| Request              | Skill/Agent                |
| -------------------- | -------------------------- |
| Audio filter/source  | `obs-audio-plugin-writing` |
| Cross-compile, CI/CD | `obs-cross-compiling`      |
| Windows build, MSVC  | `obs-windows-building`     |
| Qt dialogs, C++      | `obs-cpp-qt-patterns`      |
| Code review          | `obs-plugin-reviewing`     |
| General help         | `obs-plugin-expert` agent  |

#### Vendure E-commerce

| Request            | Skill/Agent                |
| ------------------ | -------------------------- |
| Plugin development | `vendure-plugin-writing`   |
| GraphQL API        | `vendure-graphql-writing`  |
| Database entities  | `vendure-entity-writing`   |
| Admin UI           | `vendure-admin-ui-writing` |
| General help       | `vendure-expert` agent     |

#### Helm & Kubernetes

| Request           | Skill/Agent                    |
| ----------------- | ------------------------------ |
| Create chart      | `helm-chart-writing`           |
| Review chart      | `helm-chart-review`            |
| ArgoCD GitOps     | `helm-argocd-gitops`           |
| kubectl mutations | `gitops-apply`                 |
| GitOps drift      | `gitops-audit`                 |
| General help      | `helm-kubernetes-expert` agent |

#### Testing & Quality

| Request                 | Skill                            |
| ----------------------- | -------------------------------- |
| Write Playwright tests  | `playwright-writing`             |
| Review Playwright tests | `playwright-reviewing`           |
| Grafana dashboards      | `grafana-telemetry-expert` agent |

#### Documentation

| Request         | Skill                    |
| --------------- | ------------------------ |
| API reference   | `api-doc-writer`         |
| Migration guide | `migration-guide-writer` |
| Tutorial        | `tutorial-writer`        |
| Tech spec       | `technical-spec-writing` |

#### Code Review Agents

| Language   | Agent                  | Focus                        |
| ---------- | ---------------------- | ---------------------------- |
| Go         | `go-code-reviewer`     | Control flow, errors         |
| TypeScript | `hermes-code-reviewer` | N+1 queries, types           |
| Python     | `python-code-reviewer` | Async, types, UV enforcement |
| C/C++      | `c-cpp-code-reviewer`  | Memory safety, thread safety |

---

## Standards & Conventions

@docs/CONVENTIONS.md

---

## Skills Reference

@docs/SKILLS-QUICK-REF.md

---

## Best Practices

@docs/PRACTICES.md

---

## Quick Reference

| Item            | Value                                |
| --------------- | ------------------------------------ |
| **User**        | Pedro                                |
| **Branches**    | `mriley/` prefix required            |
| **Attribution** | Never self-identify as AI            |
| **Commits**     | Conventional format with scope       |
| **Auto-commit** | ONLY "raise/create PR"               |
| **Testing**     | 90%+ unit, 100% E2E                  |
| **Quality**     | Zero linter errors                   |
| **Security**    | Never commit secrets                 |
| **Tools**       | Use parallel calls                   |
| **Skills**      | MANDATORY for workflows              |
| **kubectl**     | Mutations blocked - use gitops-apply |

---

## Pre-Action Checklist

Before ANY action:

```
[ ] New task? → check-history skill
[ ] Commit? → safe-commit skill
[ ] PR? → create-pr skill
[ ] Destructive? → safe-destroy skill
[ ] Branch ops? → manage-branch skill
```

**If a skill exists for the workflow, you MUST invoke it.**
