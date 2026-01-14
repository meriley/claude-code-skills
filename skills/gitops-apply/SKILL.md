---
name: gitops-apply
description: Guide proper GitOps workflow for Kubernetes changes instead of direct kubectl mutations. Identifies resources, locates/creates manifests, commits to git, and syncs via ArgoCD/Flux. Use when kubectl mutation is blocked.
version: 1.0.0
---

# GitOps Apply Skill

## Purpose

Guide users through proper GitOps workflow when they attempt to mutate Kubernetes resources with kubectl. Replaces imperative kubectl commands with declarative manifests in git, ensuring all cluster changes are auditable, reviewable, and recoverable.

## Why GitOps Over kubectl

**kubectl apply/create/delete:**

- ❌ No audit trail of who changed what
- ❌ No peer review process
- ❌ Difficult rollback (manual undo)
- ❌ Configuration drift (cluster != git)
- ❌ No disaster recovery story
- ❌ Imperative (how), not declarative (what)

**GitOps workflow:**

- ✅ Full audit trail in git log
- ✅ Peer review via pull requests
- ✅ Easy rollback via git revert
- ✅ Single source of truth (git)
- ✅ Disaster recovery via git clone
- ✅ Declarative manifests (desired state)
- ✅ Automatic sync via ArgoCD/Flux
- ✅ Drift detection and correction

## Workflow Steps

### Quick GitOps Workflow

1. **Identify Resource** - Determine K8s resource to modify
2. **Locate Manifest** - Find YAML in git (charts/, manifests/, k8s/)
3. **Edit Manifest** - Update YAML file
4. **Commit Changes** - Use conventional commits
5. **Sync via GitOps** - ArgoCD/Flux syncs automatically OR trigger manually

**For detailed step-by-step workflow with commands, verification, and examples, see `references/WORKFLOW-STEPS.md`.**

- **check-history** - Review git history before making changes
