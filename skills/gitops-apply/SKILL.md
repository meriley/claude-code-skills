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

### Step 1: Understand the Desired Change

**Ask clarifying questions:**

```
What resource do you want to modify?
- Deployment name and namespace?
- What specific change? (image tag, replicas, env vars, etc.)
- Is this for dev, staging, or prod?
```

**Example user request:**

> "Scale the api-service deployment to 5 replicas in production"

**Clarify:**

```
Confirming:
- Resource: Deployment/api-service
- Namespace: production (or specific namespace?)
- Change: spec.replicas = 5
- Environment: prod

Is this correct?
```

### Step 2: Locate Existing Manifest

**Search git repository for the manifest:**

```bash
# Find the manifest file
find /path/to/gitops/repo -name "*api-service*" -type f

# Common locations:
# - apps/production/api-service.yaml
# - charts/api-service/values-prod.yaml
# - kubernetes/deployments/api-service.yaml
# - argocd/applications/api-service/
```

**If Helm chart:**

```bash
# Find values file for environment
find /path/to/charts -name "values-prod.yaml"

# Chart structure:
# charts/api-service/
# ├── values.yaml              (base)
# ├── values-prod.yaml          (production overrides)
# └── templates/
#     └── deployment.yaml
```

**If plain YAML:**

```bash
# Find deployment manifest
find /path/to/kubernetes -name "*.yaml" -exec grep -l "name: api-service" {} \;
```

**If ApplicationSet (ArgoCD):**

```bash
# Find ApplicationSet or Application
find /path/to/argocd -name "*.yaml" -exec grep -l "api-service" {} \;
```

### Step 3: Show Current vs Desired State

**Read current manifest:**

```bash
# For Helm values
cat charts/api-service/values-prod.yaml | grep -A5 "replicaCount"

# For plain YAML
cat kubernetes/deployments/api-service.yaml | grep -A5 "replicas"
```

**Present to user:**

```
Current state (in git):
  spec.replicas: 3

Desired state:
  spec.replicas: 5

Files to modify:
  - charts/api-service/values-prod.yaml
  or
  - kubernetes/deployments/api-service.yaml

Proceed with this change?
```

### Step 4: Modify Manifest (Declarative)

**For Helm values file:**

Use Edit tool to update:

```yaml
# values-prod.yaml
replicaCount: 5 # Changed from 3
```

**For plain Kubernetes YAML:**

Use Edit tool to update:

```yaml
# deployment.yaml
spec:
  replicas: 5 # Changed from 3
```

**Validation:**

```bash
# For Helm, validate template rendering
helm template charts/api-service -f charts/api-service/values-prod.yaml

# For plain YAML, validate syntax
kubectl apply --dry-run=client -f kubernetes/deployments/api-service.yaml

# Check diff against cluster
kubectl diff -f kubernetes/deployments/api-service.yaml
```

### Step 5: Commit Change with Conventional Format

**Use safe-commit skill (MANDATORY):**

Do NOT commit manually. Invoke safe-commit skill which will:

- Run security-scan (check for secrets)
- Run quality-check (YAML linting)
- Run tests (manifest validation)
- Get user approval
- Create properly formatted commit

**Commit message format:**

```
feat(k8s/api-service): scale production replicas to 5

Increase production capacity to handle increased traffic.

- Update values-prod.yaml: replicaCount 3 → 5
- Validated with helm template
- Verified with kubectl diff
```

**Scope conventions:**

- `k8s/<service-name>` for plain YAML
- `helm/<chart-name>` for Helm charts
- `argocd/<app-name>` for ArgoCD configs

### Step 6: Push to Remote (If PR Not Needed)

**For direct changes (dev/staging):**

```bash
git push origin main
```

**For pull request (production):**

Use create-pr skill (MANDATORY):

```
Invoke create-pr skill which will:
- Create branch with mriley/ prefix
- Push changes
- Create GitHub PR with proper description
- Link related issues
```

### Step 7: Monitor ArgoCD/Flux Sync

**For ArgoCD:**

```bash
# Check if ArgoCD detects change
argocd app get api-service

# If OutOfSync, sync manually (or wait for auto-sync)
argocd app sync api-service

# Monitor sync progress
argocd app wait api-service --health

# View sync history
argocd app history api-service
```

**For Flux:**

```bash
# Force reconciliation (if auto-sync slow)
flux reconcile source git gitops-repo
flux reconcile kustomization api-service

# Check status
flux get kustomizations

# View events
kubectl -n flux-system logs deployment/kustomize-controller
```

### Step 8: Verify Change Applied

**Check cluster state:**

```bash
# Verify deployment updated
kubectl get deployment api-service -n production -o jsonpath='{.spec.replicas}'

# Check rollout status
kubectl rollout status deployment/api-service -n production

# Verify pods scaling
kubectl get pods -n production -l app=api-service
```

**Report to user:**

```
✅ GitOps workflow completed successfully

1. Manifest updated in git
2. Committed: feat(k8s/api-service): scale production replicas to 5
3. Pushed to remote: main branch
4. ArgoCD synced in 45 seconds
5. Deployment scaled: 3 → 5 replicas
6. All pods healthy: 5/5 ready

Audit trail:
- Git commit: a1b2c3d4
- GitHub: https://github.com/org/repo/commit/a1b2c3d4
- ArgoCD: https://argocd.example.com/applications/api-service
```

## Common Scenarios

### Scenario: Update Container Image Tag

**User request:**

> "Update api-service to version v2.1.0"

**Workflow:**

1. Locate manifest (Helm values or YAML)
2. Update image tag:
   ```yaml
   image:
     tag: v2.1.0 # from v2.0.5
   ```
3. Validate with `helm template` or `kubectl diff`
4. Commit: `feat(k8s/api-service): update to v2.1.0`
5. Push and sync
6. Verify rollout

### Scenario: Add Environment Variable

**User request:**

> "Add LOG_LEVEL=debug to api-service"

**Workflow:**

1. Locate deployment manifest
2. Add to env section:
   ```yaml
   env:
     - name: LOG_LEVEL
       value: debug
   ```
3. Validate
4. Commit: `feat(k8s/api-service): add LOG_LEVEL env var`
5. Push and sync
6. Verify pods restarted with new env

### Scenario: Delete Resource

**User request:**

> "Delete the old-service deployment"

**Workflow:**

1. Locate manifest: `kubernetes/deployments/old-service.yaml`
2. Remove file (or comment out in kustomization.yaml)
3. Validate that ArgoCD/Flux will delete resource
4. Commit: `feat(k8s): remove deprecated old-service`
5. Push and sync
6. Verify resource deleted from cluster

### Scenario: Scale to Zero (Maintenance)

**User request:**

> "Take down api-service for maintenance"

**Workflow:**

1. Update replicas to 0
2. Commit: `ops(k8s/api-service): scale to zero for maintenance`
3. Push and sync
4. Verify pods terminated
5. When ready to restore:
   - Revert commit: `git revert <commit-sha>`
   - Push and sync
   - Verify pods restored

## Integration with helm-argocd-gitops Skill

**When to invoke helm-argocd-gitops:**

- Setting up new ArgoCD Application
- Configuring ApplicationSet
- Modifying sync policies
- Adding sync waves or hooks

**This skill vs helm-argocd-gitops:**

| Skill              | Purpose                                                   |
| ------------------ | --------------------------------------------------------- |
| gitops-apply       | **Change application state** (scale, update image, etc.)  |
| helm-argocd-gitops | **Configure ArgoCD itself** (Applications, sync policies) |

**Example:**

```
User: "Update api-service replicas"
→ Use gitops-apply (modifying app manifest)

User: "Make api-service auto-sync in ArgoCD"
→ Use helm-argocd-gitops (modifying ArgoCD Application)
```

## Repository Structure Examples

### Helm-based GitOps

```
gitops-repo/
├── charts/
│   ├── api-service/
│   │   ├── values.yaml
│   │   ├── values-dev.yaml
│   │   ├── values-staging.yaml
│   │   ├── values-prod.yaml
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       └── ingress.yaml
│   └── worker-service/
│       └── ...
└── argocd/
    └── applications/
        ├── api-service-dev.yaml
        ├── api-service-staging.yaml
        └── api-service-prod.yaml
```

### Plain YAML GitOps

```
gitops-repo/
├── base/
│   ├── api-service/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── worker-service/
│       └── ...
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    ├── staging/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

### ApplicationSet Structure

```
argocd-repo/
├── applicationsets/
│   └── services.yaml  # Generates apps from git directories
└── apps/
    ├── api-service/
    │   ├── deployment.yaml
    │   └── service.yaml
    ├── worker-service/
    │   └── ...
    └── ...
```

## Rollback Procedure

**If change causes issues:**

### Option 1: Git Revert (Recommended)

```bash
# Find the problematic commit
git log --oneline -10

# Revert it (creates new commit)
git revert a1b2c3d4

# Push revert
git push origin main

# ArgoCD/Flux will auto-sync revert
argocd app sync api-service
```

### Option 2: ArgoCD Rollback

```bash
# View history
argocd app history api-service

# Rollback to previous version
argocd app rollback api-service <revision-number>

# IMPORTANT: Also revert git commit to stay in sync
git revert <commit-sha>
git push origin main
```

### Option 3: Emergency kubectl (LAST RESORT)

**ONLY if:**

- Production is down
- GitOps sync failing
- Need immediate fix

**Procedure:**

1. Fix with kubectl (emergency)
2. IMMEDIATELY update git to match
3. Commit with `fix(k8s): emergency rollback of <change>`
4. Document incident

**Never leave cluster state != git state**

## Troubleshooting

### Issue: ArgoCD Shows OutOfSync but Won't Sync

**Diagnosis:**

```bash
argocd app diff api-service
```

**Common causes:**

1. Resource field managed by controller (HPA, PDB)
   - Solution: Add to `ignoreDifferences` in Application
2. Helm template error
   - Solution: Run `helm template` locally to debug
3. Invalid YAML syntax
   - Solution: Run `kubectl apply --dry-run=client`

### Issue: Flux Not Detecting Changes

**Diagnosis:**

```bash
flux get sources git
flux get kustomizations
```

**Common causes:**

1. Git poll interval not reached
   - Solution: `flux reconcile source git <name>`
2. Kustomization path incorrect
   - Solution: Check `spec.path` in Kustomization
3. Branch mismatch
   - Solution: Verify `spec.ref.branch`

### Issue: Change Applied but Pods Not Updating

**Diagnosis:**

```bash
kubectl get deployment api-service -o yaml | grep -A10 "spec:"
kubectl describe deployment api-service
```

**Common causes:**

1. Deployment strategy (RollingUpdate slow)
   - Solution: Adjust `maxSurge`, `maxUnavailable`
2. PodDisruptionBudget blocking
   - Solution: Temporarily relax PDB
3. Resource limits preventing scheduling
   - Solution: Check `kubectl describe nodes`

## Best Practices

1. **Always validate before commit**
   - `helm template` for Helm charts
   - `kubectl diff` for plain YAML
   - `kubectl apply --dry-run=client`

2. **Use conventional commit format**
   - Enables automatic changelog generation
   - Clear audit trail
   - Easy to filter by scope

3. **Small, atomic changes**
   - One logical change per commit
   - Easier to review
   - Easier to rollback

4. **Test in lower environments first**
   - dev → staging → prod
   - Catch issues early
   - Validate rollout strategy

5. **Monitor after every change**
   - Check ArgoCD/Flux sync
   - Verify pod health
   - Watch application metrics
   - Check logs for errors

6. **Document WHY in commit body**
   - "scale to 5" ← bad (what)
   - "scale to 5 to handle increased traffic from marketing campaign" ← good (why)

## Emergency Override

**NEVER use kubectl mutations directly.**

**If absolutely necessary (production down):**

1. Use gitops-apply for emergency fix
2. If sync too slow:
   - Apply with kubectl
   - IMMEDIATELY update git to match
   - Commit: `fix(k8s): emergency fix for <incident>`
3. Create incident report
4. Document in post-mortem

**The goal is ALWAYS cluster state = git state.**

## Quick Reference

**User tries kubectl mutation:**

1. Blocked by enforce-gitops-kubectl hook
2. User says "use gitops-apply"
3. You invoke gitops-apply skill (this)
4. Workflow:
   - Understand change
   - Locate manifest
   - Show diff
   - Modify declaratively
   - Invoke safe-commit skill
   - Push to git
   - Monitor sync
   - Verify applied

**Remember:** GitOps is declarative (describe desired state), not imperative (issue commands).

---

## Related Skills

- **safe-commit** - MANDATORY for committing manifest changes
- **create-pr** - MANDATORY for production changes requiring review
- **helm-argocd-gitops** - Configure ArgoCD Applications and sync policies
- **helm-chart-writing** - Create new Helm charts
- **check-history** - Review git history before making changes
