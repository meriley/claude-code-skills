# Skill Mapping Reference

Use this reference to map implementation tasks to the appropriate skills.

## E-Commerce (Vendure)

| Task Type           | Primary Skill              | Supporting Skills            |
| ------------------- | -------------------------- | ---------------------------- |
| Database entities   | `vendure-entity-writing`   | `vendure-entity-reviewing`   |
| GraphQL APIs        | `vendure-graphql-writing`  | `vendure-graphql-reviewing`  |
| Admin UI extensions | `vendure-admin-ui-writing` | `vendure-admin-ui-reviewing` |
| Plugins             | `vendure-plugin-writing`   | `vendure-plugin-reviewing`   |
| Delivery/Shipping   | `vendure-delivery-plugin`  | -                            |

**Agent:** `vendure-expert` - Coordinates all Vendure skills

---

## Testing

| Task Type              | Primary Skill        | Supporting Skills      |
| ---------------------- | -------------------- | ---------------------- |
| E2E Tests (Playwright) | `playwright-writing` | `playwright-reviewing` |
| Unit/Integration Tests | `run-tests`          | -                      |

**Agent:** `playwright-e2e-expert` - For complex test scenarios

---

## Infrastructure (Helm/Kubernetes)

| Task Type             | Primary Skill              | Supporting Skills   |
| --------------------- | -------------------------- | ------------------- |
| Helm Charts           | `helm-chart-writing`       | `helm-chart-review` |
| ArgoCD/GitOps         | `helm-argocd-gitops`       | -                   |
| Production Deployment | `helm-production-patterns` | -                   |

**Agent:** `helm-kubernetes-expert` - Coordinates all Helm skills

---

## OBS Plugins

| Task Type             | Primary Skill              | Supporting Skills      |
| --------------------- | -------------------------- | ---------------------- |
| Audio Filters/Sources | `obs-audio-plugin-writing` | `obs-plugin-reviewing` |
| Cross-Compilation     | `obs-cross-compiling`      | -                      |
| Windows Builds        | `obs-windows-building`     | -                      |
| Qt/C++ UI             | `obs-cpp-qt-patterns`      | -                      |

**Agent:** `obs-plugin-expert` - Coordinates all OBS skills

---

## UI Components

| Task Type          | Primary Skill        | Supporting Skills   |
| ------------------ | -------------------- | ------------------- |
| Mantine Components | `mantine-developing` | `mantine-reviewing` |

**Agent:** `mantine-ui-expert` - For complex UI patterns

---

## Code Quality

| Language   | Primary Skills                               | Purpose                   |
| ---------- | -------------------------------------------- | ------------------------- |
| Go         | `control-flow-check`, `error-handling-audit` | Flow, error patterns      |
| TypeScript | `type-safety-audit`, `n-plus-one-detection`  | Types, query optimization |
| All        | `security-scan`, `quality-check`             | Security, linting         |

**Agents:** `go-code-reviewer`, `hermes-code-reviewer`

---

## Documentation

| Task Type         | Primary Skill            | Supporting Skills          |
| ----------------- | ------------------------ | -------------------------- |
| API Documentation | `api-doc-writer`         | `api-documentation-verify` |
| Migration Guides  | `migration-guide-writer` | -                          |
| Tutorials         | `tutorial-writer`        | -                          |
| Technical Specs   | `technical-spec-writing` | `technical-spec-reviewing` |
| Feature Specs     | `feature-spec-writing`   | `feature-spec-reviewing`   |

**Agent:** `documentation-coordinator` - Coordinates doc skills

---

## Specifications

| Task Type            | Primary Skill                 | Supporting Skills          |
| -------------------- | ----------------------------- | -------------------------- |
| PRD Writing          | `prd-writing`                 | `prd-reviewing`            |
| Feature Specs        | `feature-spec-writing`        | `feature-spec-reviewing`   |
| Technical Specs      | `technical-spec-writing`      | `technical-spec-reviewing` |
| Implementation Plans | `prd-implementation-planning` | -                          |
| SPARC Plans          | `sparc-planning`              | -                          |

**Agent:** `specification-architect` - Coordinates all spec skills

---

## Git Operations

| Task Type         | Primary Skill   | Notes                            |
| ----------------- | --------------- | -------------------------------- |
| Starting tasks    | `check-history` | MANDATORY first                  |
| Committing        | `safe-commit`   | MANDATORY for commits            |
| Creating PRs      | `create-pr`     | Auto-commits allowed             |
| Destructive ops   | `safe-destroy`  | MANDATORY for dangerous commands |
| Branch management | `manage-branch` | Creates mriley/ prefix           |

---

## Authorization

| Task Type        | Primary Skill         | Purpose          |
| ---------------- | --------------------- | ---------------- |
| Casbin RBAC/ABAC | `implementing-casbin` | Go authorization |

**Agent:** `uac-permissions-expert` - UAC integration

---

## Grafana/Monitoring

| Task Type       | Primary Skill             | Purpose          |
| --------------- | ------------------------- | ---------------- |
| TRON Dashboards | `tron-dashboard-creating` | Consumer metrics |

**Agent:** `grafana-telemetry-expert` - Dashboard patterns

---

## Cursor IDE

| Task Type         | Primary Skill          | Supporting Skills     |
| ----------------- | ---------------------- | --------------------- |
| Rule Files (.mdc) | `cursor-rules-writing` | `cursor-rules-review` |

---

## Quick Lookup by File Extension

| Extension         | Likely Domain    | Primary Skills                               |
| ----------------- | ---------------- | -------------------------------------------- |
| `.ts`, `.tsx`     | TypeScript/React | `mantine-developing`, `type-safety-audit`    |
| `.go`             | Go               | `control-flow-check`, `error-handling-audit` |
| `.c`, `.h`        | OBS Plugin       | `obs-audio-plugin-writing`                   |
| `.spec.ts`        | Playwright       | `playwright-writing`                         |
| `.yaml` (charts/) | Helm             | `helm-chart-writing`                         |
| `.md` (specs/)    | Documentation    | `technical-spec-writing`                     |
| `.mdc`            | Cursor Rules     | `cursor-rules-writing`                       |
