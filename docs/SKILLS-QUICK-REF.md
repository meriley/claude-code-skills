# Skills Quick Reference

All skills have full documentation in `~/.claude/skills/[skill-name]/SKILL.md`

## Core Git Skills (MANDATORY)

| Skill           | When to Use                 | Auto-invoked         |
| --------------- | --------------------------- | -------------------- |
| `check-history` | Start of EVERY task         | No - invoke first    |
| `safe-commit`   | User says "commit"          | No - invoke manually |
| `create-pr`     | User says "raise/create PR" | No - invoke manually |
| `safe-destroy`  | Before destructive commands | No - invoke manually |
| `manage-branch` | Branch create/switch        | No - invoke manually |

## Quality & Security (Auto-invoked by safe-commit)

| Skill           | Purpose                              |
| --------------- | ------------------------------------ |
| `security-scan` | Secrets, vulnerabilities, injection  |
| `quality-check` | Linting, formatting, static analysis |
| `run-tests`     | Unit (90%+), integration, E2E (100%) |

## Language-Specific Quality

| Skill                      | Language           | Focus                        |
| -------------------------- | ------------------ | ---------------------------- |
| `control-flow-check`       | Go                 | Early returns, nesting depth |
| `error-handling-audit`     | Go                 | Error wrapping, propagation  |
| `n-plus-one-detection`     | TypeScript/GraphQL | DataLoader, batching         |
| `type-safety-audit`        | TypeScript         | No `any`, branded types      |
| `api-documentation-verify` | All                | Verify docs match code       |

## Language Setup

| Skill          | Language                         |
| -------------- | -------------------------------- |
| `setup-go`     | Go (golangci-lint, go mod)       |
| `setup-python` | Python (uv, ruff, pytest)        |
| `setup-node`   | Node.js (ESLint, Prettier, Jest) |

## E2E Testing

| Skill                  | Purpose                            |
| ---------------------- | ---------------------------------- |
| `playwright-writing`   | Write tests (locators, assertions) |
| `playwright-reviewing` | Review tests (violations audit)    |

## OBS Plugin Development

| Skill                      | When to Use                         |
| -------------------------- | ----------------------------------- |
| `obs-audio-plugin-writing` | Audio filters, sources              |
| `obs-cross-compiling`      | Linux→Windows, CI/CD, CMake presets |
| `obs-windows-building`     | MSVC, MinGW, .def files             |
| `obs-cpp-qt-patterns`      | Qt dialogs, frontend API            |
| `obs-plugin-reviewing`     | Code review, thread safety          |
| `obs-plugin-developing`    | Getting started, overview           |

**Agent:** `obs-plugin-expert` - Coordinates all OBS skills

## Vendure E-commerce

| Skill                        | Purpose                         |
| ---------------------------- | ------------------------------- |
| `vendure-plugin-writing`     | Create plugins (@VendurePlugin) |
| `vendure-plugin-reviewing`   | Audit plugin code               |
| `vendure-graphql-writing`    | Extend Shop/Admin APIs          |
| `vendure-graphql-reviewing`  | Review resolvers                |
| `vendure-entity-writing`     | Define TypeORM entities         |
| `vendure-entity-reviewing`   | Audit entity patterns           |
| `vendure-admin-ui-writing`   | Build Admin UI extensions       |
| `vendure-admin-ui-reviewing` | Review UI components            |
| `vendure-delivery-plugin`    | Shipping, fulfillment           |

**Agent:** `vendure-expert` - Coordinates all Vendure skills

## Helm & Kubernetes

| Skill                      | Purpose                     |
| -------------------------- | --------------------------- |
| `helm-chart-writing`       | Create Helm charts          |
| `helm-chart-review`        | Audit charts                |
| `helm-argocd-gitops`       | ArgoCD Application patterns |
| `helm-production-patterns` | Blue-green, canary, secrets |

**Agent:** `helm-kubernetes-expert` - Coordinates all Helm skills

## Grafana & Monitoring

| Skill                     | Purpose                  |
| ------------------------- | ------------------------ |
| `tron-dashboard-creating` | TRON consumer dashboards |

**Agent:** `grafana-telemetry-expert` - Coordinates dashboard skills

## Documentation

| Skill                    | Purpose                  |
| ------------------------ | ------------------------ |
| `api-doc-writer`         | API reference (Diátaxis) |
| `migration-guide-writer` | Migration how-to guides  |
| `tutorial-writer`        | Learning tutorials       |
| `technical-spec-writing` | Technical design docs    |
| `feature-spec-writing`   | Feature specifications   |
| `prd-writing`            | Product requirements     |

**Agent:** `documentation-coordinator` - Coordinates doc skills

## Planning & Specs

| Skill                           | Purpose                           |
| ------------------------------- | --------------------------------- |
| `sparc-plan` / `sparc-planning` | SPARC implementation plans        |
| `prd-implementation-planning`   | Map PRD to skills, track progress |
| `technical-spec-reviewing`      | Review tech specs                 |
| `feature-spec-reviewing`        | Review feature specs              |
| `prd-reviewing`                 | Review PRDs                       |

**Agent:** `specification-architect` - Coordinates spec skills

## Mantine UI

| Skill                | Purpose                  |
| -------------------- | ------------------------ |
| `mantine-developing` | Build Mantine components |
| `mantine-reviewing`  | Review Mantine code      |

**Agent:** `mantine-ui-expert` - Coordinates Mantine skills

## Cursor Rules

| Skill                  | Purpose                |
| ---------------------- | ---------------------- |
| `cursor-rules-writing` | Create .mdc rule files |
| `cursor-rules-review`  | Audit rule quality     |

## Code Review Agents

| Agent                  | Focus                         |
| ---------------------- | ----------------------------- |
| `go-code-reviewer`     | Go control flow, errors       |
| `hermes-code-reviewer` | TypeScript/GraphQL N+1, types |

## Utility Commands

| Command           | Purpose                  |
| ----------------- | ------------------------ |
| `/list-skills`    | List all skills          |
| `/quick-status`   | Git status dashboard     |
| `/deps`           | Dependency health check  |
| `/coverage-trend` | Test coverage changes    |
| `/architecture`   | Dependency graph         |
| `/changelog`      | Generate from commits    |
| `/cleanup`        | Safe file/branch cleanup |

## Skill Composition

```
create-pr
  ├─> check-history
  ├─> manage-branch (if needed)
  └─> safe-commit (auto-approve)
       ├─> security-scan
       ├─> quality-check
       │    └─> [language-specific checks]
       └─> run-tests
```
