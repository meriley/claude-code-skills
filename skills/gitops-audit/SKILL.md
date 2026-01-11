# GitOps Audit Skill

## Purpose

Comprehensive GitOps compliance verification that detects configuration drift and policy violations through three audit types:

1. **Cluster Drift**: Resources in cluster not tracked in git
2. **Spec Drift**: Differences between git manifests and cluster state
3. **Code Violations**: Hardcoded Kubernetes configs in application code

## When to Use

### Automatic Invocation (Code Review)

This skill is **automatically triggered** when code review detects:

- Changes to files matching: `*.yaml`, `*.yml` in `charts/`, `manifests/`, `k8s/`, `kubernetes/`
- Changes to deployment scripts: `deploy.sh`, `*.deploy.sh`, `Makefile`
- Changes to Helm charts: `charts/**/*`, `values*.yaml`, `Chart.yaml`
- Changes to Kustomize: `kustomization.yaml`, `kustomization.yml`
- Imports of Kubernetes client libraries:
  - Go: `k8s.io/client-go`, `k8s.io/api`, `k8s.io/apimachinery`
  - Python: `kubernetes`, `kubernetes.client`
  - Node.js: `@kubernetes/client-node`, `kubernetes-client`
  - TypeScript: Same as Node.js

### Manual Invocation

```bash
/gitops-audit
```

Use manually when:

- Investigating cluster drift
- Auditing GitOps compliance
- Before production deployments
- Troubleshooting sync issues
- Regular compliance checks (weekly/monthly)

## Three Audit Types

### Audit Type 1: Cluster Drift Detection

**What it detects:**

- Kubernetes resources in cluster that don't exist in GitOps manifests
- Resources created via manual kubectl (bypassed GitOps)
- Configuration drift (cluster diverged from source of truth)

**How it works:**

```bash
# Step 1: Get all resources in target namespaces
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl get --show-kind --ignore-not-found -o name -n <namespace>

# Step 2: For each resource, search git for corresponding manifest
find <gitops-repo> -name "*.yaml" -o -name "*.yml" | \
  xargs grep -l "kind: <ResourceType>" | \
  xargs grep -l "name: <resource-name>"

# Step 3: Report resources not found in git
```

**Example Output:**

```
🚨 CRITICAL: Resources in cluster NOT tracked in git

Namespace: production
- Deployment/debug-pod (created manually)
  Age: 2 days
  Created by: kubectl (not ArgoCD)
  Action: Delete OR add manifest to gitops-repo/production/

- ConfigMap/temp-config (no manifest found)
  Age: 5 hours
  Contains: database connection overrides
  Action: Delete OR formalize in charts/app/config/

Namespace: staging
- Service/test-service (missing from git)
  Age: 1 day
  Type: LoadBalancer (costs money!)
  Action: Remove from cluster OR add to gitops-repo/staging/
```

### Audit Type 2: Spec Drift Analysis

**What it detects:**

- Resources exist in both git and cluster but specs differ
- Manual modifications to live resources
- Configuration drift (someone edited live)
- Incomplete sync or failed ArgoCD/Flux updates

**How it works:**

```bash
# Step 1: For each manifest in git, render it
helm template <chart> -f <values.yaml>  # For Helm
# OR
kustomize build <path>  # For Kustomize
# OR
cat <manifest.yaml>  # For plain YAML

# Step 2: Get live resource from cluster
kubectl get <resource-type> <name> -n <namespace> -o yaml

# Step 3: Diff rendered manifest vs live resource
kubectl diff -f <rendered-manifest>
# OR use yq/jq to compare specific fields
```

**Example Output:**

```
⚠️  WARNING: Spec drift detected (git ≠ cluster)

Deployment/api-service (production):
  Git manifest (charts/api-service/values-prod.yaml):
    replicas: 3
    image.tag: v2.1.0
    resources.requests.memory: 512Mi

  Cluster state:
    replicas: 5  ← DRIFT DETECTED
    image.tag: v2.1.0
    resources.requests.memory: 512Mi

  Likely cause: Manual kubectl scale (bypassed GitOps)
  Action: Reconcile via GitOps - update values-prod.yaml OR revert cluster
  Command: kubectl scale deployment api-service --replicas=3 -n production

ConfigMap/app-config (staging):
  Git manifest (charts/app/templates/configmap.yaml):
    data:
      LOG_LEVEL: info
      API_TIMEOUT: 30s

  Cluster state:
    data:
      LOG_LEVEL: debug  ← DRIFT
      API_TIMEOUT: 30s
      DEBUG_MODE: true  ← EXTRA KEY (not in git)

  Likely cause: Manual kubectl edit
  Action: Update git OR revert cluster to git state

Ingress/api (production):
  Git: cert-manager.io/cluster-issuer=letsencrypt
  Cluster: cert-manager.io/cluster-issuer=letsencrypt-staging  ← DRIFT

  Action: Update git to use letsencrypt-staging OR sync cluster to git
```

### Audit Type 3: Code Violations

**What it detects:**

- Inline Kubernetes YAML in application code
- kubectl commands in scripts/CI/CD
- Hardcoded resource definitions instead of GitOps manifests
- Bypassing GitOps workflow in automation

**How it works:**

```bash
# Step 1: Scan for inline Kubernetes YAML
grep -r -E "(apiVersion|kind:.*Deployment|kind:.*Service)" \
  --include="*.py" --include="*.go" --include="*.js" --include="*.ts" \
  --include="*.sh" --include="*.bash" \
  --exclude-dir=tests --exclude-dir=e2e --exclude-dir=node_modules

# Step 2: Scan for kubectl commands in code
grep -r -E "kubectl\s+(apply|create|delete|patch|edit)" \
  --include="*.sh" --include="*.py" --include="*.js" --include="*.go" \
  --include="*.yml" --include="*.yaml" \
  --exclude-dir=tests --exclude-dir=.github/workflows

# Step 3: Scan for hardcoded resource creation (Go)
grep -r -E "(CreateDeployment|CreateService|client\.Create\()" \
  --include="*.go" --exclude-dir=vendor

# Step 4: Scan for hardcoded resource creation (Python)
grep -r -E "(create_namespaced_deployment|create_namespaced_service)" \
  --include="*.py"
```

**Example Output:**

```
❌ CRITICAL: Hardcoded Kubernetes configs in application code

scripts/deploy.sh:45
  kubectl apply -f - <<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app
    spec:
      replicas: 3
      ...
  EOF

  Issue: Inline YAML in deployment script
  Severity: CRITICAL
  Action: Move to GitOps repo → charts/my-app/templates/deployment.yaml
  Why: Changes bypass git history, peer review, and rollback capability

src/operator/reconcile.go:128
  deployment := &appsv1.Deployment{
    ObjectMeta: metav1.ObjectMeta{Name: "my-app"},
    Spec: appsv1.DeploymentSpec{
      Replicas: int32Ptr(3),
      ...
    }
  }
  err := r.Client.Create(ctx, deployment)

  Issue: Hardcoded Deployment definition
  Severity: WARNING (exception for operators)
  Action: Verify this is a Kubernetes operator/controller
  Exception: OK if this is operator reconciliation logic
  Note: Ensure the operator CRD is in git

tests/integration/setup.py:67
  os.system("kubectl create namespace test-ns")

  Issue: kubectl command in test setup
  Severity: INFO (exception for tests)
  Exception: OK for test fixtures (not production code)
  Note: Ensure test namespace is cleaned up

.github/workflows/deploy.yml:34
  - name: Deploy to production
    run: kubectl apply -f k8s/production/

  Issue: kubectl in CI/CD workflow
  Severity: CRITICAL
  Action: Replace with ArgoCD CLI or git commit trigger
  Better approach:
    - Commit changes to gitops-repo
    - Let ArgoCD sync automatically
    - Or use: argocd app sync my-app
```

## Workflow

### Step 1: Detect GitOps Repository

**Check common locations:**

```bash
# Check environment variables
echo $GITOPS_REPO_PATH

# Check common paths
ls -d ~/gitops-repo ~/projects/gitops ~/k8s-manifests 2>/dev/null

# Check git remotes for gitops-related repos
git remote -v | grep -E "(gitops|k8s|kubernetes|manifests)"
```

**Ask user if not found:**

```
GitOps repository not automatically detected.

Please provide the path to your GitOps repository:
- Local path: /path/to/gitops-repo
- Or I can clone it: git@github.com:org/gitops-repo.git
```

**Detect repository structure:**

```bash
# Helm-based
if [ -d "charts/" ]; then
  TYPE="helm"
  VALUES_FILES=$(find charts/ -name "values*.yaml")
fi

# Kustomize-based
if [ -f "kustomization.yaml" ] || [ -d "base/" ]; then
  TYPE="kustomize"
fi

# Plain YAML
if [ -d "manifests/" ] || [ -d "k8s/" ]; then
  TYPE="plain-yaml"
fi
```

### Step 2: Run Cluster Drift Check

**For each configured namespace:**

```bash
# Get all resources in namespace
RESOURCES=$(kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl get --show-kind --ignore-not-found -o name -n $NAMESPACE)

# For each resource
for RESOURCE in $RESOURCES; do
  KIND=$(echo $RESOURCE | cut -d'/' -f1)
  NAME=$(echo $RESOURCE | cut -d'/' -f2)

  # Search git for manifest
  FOUND=$(find $GITOPS_REPO -name "*.yaml" -o -name "*.yml" | \
    xargs grep -l "kind: $KIND" | \
    xargs grep -l "name: $NAME")

  if [ -z "$FOUND" ]; then
    echo "DRIFT: $RESOURCE not in git"
  fi
done
```

**Report findings:**

```
Cluster Drift Check - Namespace: production

✅ Tracked Resources (in git):
- Deployment/api-service
- Service/api-service
- ConfigMap/app-config
- Secret/db-credentials (sealed secret)

❌ Untracked Resources (NOT in git):
- Deployment/debug-pod (CRITICAL)
- ConfigMap/temp-config (CRITICAL)

Summary: 2 untracked resources found
```

### Step 3: Run Spec Drift Analysis

**For each manifest in git:**

```bash
# Render manifest
if [ "$TYPE" = "helm" ]; then
  RENDERED=$(helm template $CHART -f $VALUES_FILE)
elif [ "$TYPE" = "kustomize" ]; then
  RENDERED=$(kustomize build $PATH)
else
  RENDERED=$(cat $MANIFEST)
fi

# Get live resource
LIVE=$(kubectl get $KIND $NAME -n $NAMESPACE -o yaml)

# Diff them
DIFF=$(kubectl diff -f <(echo "$RENDERED") 2>&1)

if [ -n "$DIFF" ]; then
  echo "SPEC DRIFT: $KIND/$NAME"
  echo "$DIFF"
fi
```

**Report findings:**

```
Spec Drift Analysis

✅ Synced Resources (git = cluster):
- Deployment/api-service
- Service/api-service

⚠️  Drift Detected (git ≠ cluster):
- Deployment/worker (replicas: git=2, cluster=5)
- ConfigMap/app-config (extra key in cluster: DEBUG_MODE)
- Ingress/api (annotation mismatch)

Summary: 3 resources with spec drift
```

### Step 4: Run Code Violations Scan

**Scan application code:**

```bash
# Scan for inline YAML
INLINE_YAML=$(grep -r -n -E "(apiVersion|kind:.*Deployment)" \
  --include="*.py" --include="*.go" --include="*.js" --include="*.ts" \
  --include="*.sh" --exclude-dir=tests --exclude-dir=node_modules)

# Scan for kubectl commands
KUBECTL_CMDS=$(grep -r -n -E "kubectl\s+(apply|create|delete)" \
  --include="*.sh" --include="*.py" --include="*.js" \
  --exclude-dir=tests)

# Scan for hardcoded resources (Go)
GO_RESOURCES=$(grep -r -n -E "client\.Create\(|CreateDeployment|CreateService" \
  --include="*.go" --exclude-dir=vendor)
```

**Report findings:**

```
Code Violations Scan

❌ CRITICAL Issues:
- scripts/deploy.sh:45 - Inline Kubernetes YAML
- scripts/scale.sh:23 - kubectl scale command

⚠️  WARNING Issues:
- src/operator/controller.go:128 - Hardcoded Deployment
  (Exception: OK if this is an operator)

✅ INFO:
- tests/e2e/setup.py:67 - kubectl in tests
  (Exception: OK for test fixtures)

Summary: 2 CRITICAL, 1 WARNING, 1 INFO
```

### Step 5: Generate Comprehensive Report

**Combine all findings:**

````markdown
# GitOps Audit Report

**Status:** ❌ FAILED (3 CRITICAL, 5 WARNING issues)
**Date:** 2024-01-16 14:30:25 UTC
**Repository:** /home/user/gitops-repo
**Namespaces Audited:** production, staging

## Summary

| Check           | Status  | Critical | Warning | Info  |
| --------------- | ------- | -------- | ------- | ----- |
| Cluster drift   | ❌ FAIL | 2        | 0       | 0     |
| Spec drift      | ⚠️ WARN | 0        | 5       | 0     |
| Code violations | ❌ FAIL | 1        | 1       | 1     |
| **TOTAL**       | ❌ FAIL | **3**    | **6**   | **1** |

---

## 🚨 CRITICAL Issues (Must Fix)

### Cluster Drift (2 issues)

#### 1. Deployment/debug-pod (production)

- **Age:** 2 days
- **Not tracked in git**
- **Created:** manual kubectl
- **Action:** Delete OR add manifest to gitops-repo/production/
- **Command:** `kubectl delete deployment debug-pod -n production`

#### 2. ConfigMap/temp-config (staging)

- **Age:** 5 hours
- **No corresponding manifest**
- **Contains:** database connection overrides
- **Action:** Delete OR formalize in charts/app/config/
- **Command:** `kubectl delete configmap temp-config -n staging`

### Code Violations (1 issue)

#### 3. scripts/deploy.sh:45

```bash
kubectl apply -f - <<EOF
  apiVersion: apps/v1
  kind: Deployment
  ...
EOF
```
````

- **Issue:** Inline Kubernetes YAML
- **Bypasses:** GitOps workflow, git history, peer review
- **Action:** Move to charts/app/templates/deployment.yaml
- **Migration:**
  1. Extract YAML to manifest file
  2. Add to gitops-repo
  3. Commit via safe-commit skill
  4. Update script to use ArgoCD sync or git commit trigger

---

## ⚠️ WARNING Issues (Should Fix)

### Spec Drift (5 issues)

#### 1. Deployment/api-service (production)

- **Field:** replicas
- **Git:** 3
- **Cluster:** 5
- **Likely cause:** Manual kubectl scale
- **Action:** Update git to 5 OR scale cluster to 3
- **Command:** `kubectl scale deployment api-service --replicas=3 -n production`

#### 2. ConfigMap/app-config (staging)

- **Field:** data.DEBUG_MODE
- **Git:** (not present)
- **Cluster:** "true"
- **Action:** Remove from cluster OR add to git
- **Command:** `kubectl edit configmap app-config -n staging` (then remove DEBUG_MODE)

#### 3. Service/frontend (production)

- **Field:** spec.ports[0].port
- **Git:** 8080
- **Cluster:** 80
- **Action:** Reconcile - likely should be 8080
- **Command:** Update via gitops-apply skill

#### 4. Ingress/api (production)

- **Field:** annotations.cert-manager.io/cluster-issuer
- **Git:** letsencrypt
- **Cluster:** letsencrypt-staging
- **Action:** Determine correct issuer and reconcile
- **Command:** Update via gitops-apply skill

#### 5. HorizontalPodAutoscaler/worker (staging)

- **Field:** spec.minReplicas
- **Git:** 2
- **Cluster:** 1
- **Action:** Sync cluster to git
- **Command:** Update via gitops-apply skill

### Code Violations (1 issue)

#### 6. src/operator/controller.go:128

```go
deployment := &appsv1.Deployment{...}
err := r.Client.Create(ctx, deployment)
```

- **Issue:** Hardcoded Deployment definition
- **Exception:** OK if this is a Kubernetes operator/controller
- **Action:** Verify this is operator reconciliation logic
- **Note:** Ensure the operator CRD itself is tracked in git

---

## ℹ️ INFO Issues (Informational)

### Code Violations (1 issue)

#### 1. tests/integration/setup.py:67

```python
os.system("kubectl create namespace test-ns")
```

- **Issue:** kubectl command in test setup
- **Exception:** OK for test fixtures (not production code)
- **Note:** Ensure proper cleanup in teardown

---

## Remediation Steps

### Immediate Actions (CRITICAL - Do Today)

1. **Review debug-pod in production**
   - Determine if still needed
   - If yes: Create proper manifest in gitops-repo/production/
   - If no: Delete with `kubectl delete deployment debug-pod -n production`

2. **Formalize temp-config**
   - Review configuration overrides
   - Create proper ConfigMap in gitops-repo/staging/
   - Commit via safe-commit skill
   - Delete temp version after ArgoCD sync

3. **Refactor deploy.sh**
   - Extract inline YAML to manifest files
   - Add manifests to gitops-repo
   - Update script to trigger ArgoCD sync:
     ```bash
     # Instead of kubectl apply
     git add charts/app/
     git commit -m "feat(app): update deployment config"
     git push
     # ArgoCD will sync automatically
     ```

### Recommended Actions (WARNING - This Week)

1. **Reconcile all spec drift**
   - Review each drift finding
   - Determine correct state (git or cluster)
   - Update git manifests OR use gitops-apply skill
   - Let ArgoCD sync changes

2. **Document manual changes**
   - Why were replicas scaled to 5?
   - Why is DEBUG_MODE needed in staging?
   - Create follow-up tickets for proper solutions

3. **Educate team on GitOps workflow**
   - Share gitops-apply skill documentation
   - Remind about kubectl mutation blocking hook
   - Review GitOps benefits (audit trail, rollback, etc.)

### Prevention (Ongoing)

1. **Enforce kubectl mutation blocking**
   - Verify enforce-gitops-kubectl.py hook is active
   - Check settings.json includes hook configuration

2. **Enable ArgoCD auto-sync**
   - Set sync policies to automatic for non-prod
   - Use manual sync for production (with approval)

3. **Regular drift audits**
   - Run /gitops-audit weekly
   - Monitor ArgoCD sync status dashboard
   - Set up alerts for OutOfSync applications

4. **Monitor ArgoCD sync status**
   - Check ArgoCD UI: https://argocd.example.com
   - CLI: `argocd app list`
   - Slack/email alerts for failed syncs

---

## Next Steps

**Priority 1 (Today):**

- [ ] Delete or formalize debug-pod
- [ ] Delete or formalize temp-config
- [ ] Refactor deploy.sh to use GitOps

**Priority 2 (This Week):**

- [ ] Reconcile api-service replicas drift
- [ ] Remove DEBUG_MODE from app-config OR add to git
- [ ] Fix frontend service port drift
- [ ] Reconcile Ingress cert-manager annotation
- [ ] Fix HPA minReplicas drift

**Priority 3 (Ongoing):**

- [ ] Review operator code for proper CRD tracking
- [ ] Document exceptions and special cases
- [ ] Set up weekly gitops-audit cron job
- [ ] Enable ArgoCD Slack notifications

````

## Configuration

### Default Configuration

```yaml
# GitOps repository configuration
gitops_repos:
  - path: /path/to/gitops-repo
    type: helm  # helm | kustomize | plain-yaml
    environments:
      - production
      - staging
      - dev

# Namespaces to audit
namespaces:
  - production
  - staging
  - dev

# Exclusions
exclude_namespaces:
  - kube-system
  - kube-public
  - kube-node-lease
  - default
  - argocd
  - flux-system

exclude_resource_types:
  - Event
  - EndpointSlice
  - Lease
  - Node
  - ComponentStatus

# Code scan paths
code_scan_paths:
  - src/
  - scripts/
  - .github/
  - cmd/
  - pkg/

code_scan_exclude:
  - tests/
  - e2e/
  - vendor/
  - node_modules/
  - .git/
  - dist/
  - build/

# Allowed hardcoded resources (exceptions)
allowed_hardcoded:
  # Operators creating resources is OK
  - pattern: "src/operator/**/*.go"
    reason: "Kubernetes operators create resources dynamically"
  - pattern: "pkg/controller/**/*.go"
    reason: "Controller reconciliation logic"
  # Test fixtures are OK
  - pattern: "tests/**/*"
    reason: "Test fixtures and setup code"
  - pattern: "e2e/**/*"
    reason: "E2E test setup"
```

### Configuration Detection

**Skill attempts to detect configuration automatically:**

1. **GitOps Repo Detection:**
   - Check environment variable: `GITOPS_REPO_PATH`
   - Search common locations: `~/gitops-repo`, `~/projects/gitops`, `~/k8s-manifests`
   - Parse git remotes for gitops-related repositories
   - Ask user if not found

2. **Namespace Detection:**
   - Query cluster: `kubectl get namespaces`
   - Filter out system namespaces automatically
   - Focus on application namespaces

3. **Repository Type Detection:**
   - Check for `charts/` directory → Helm
   - Check for `kustomization.yaml` → Kustomize
   - Check for `manifests/` or `k8s/` → Plain YAML
   - Support mixed approaches

## Severity Classification

### CRITICAL (Block Commit/PR)

**Must be fixed immediately:**

- Resources in cluster not tracked in git
- Hardcoded kubectl mutations in production code
- Inline Kubernetes YAML in application code (not tests)
- Secrets not encrypted in git
- Missing RBAC policies for sensitive operations

**Why CRITICAL:**

- Breaks GitOps single source of truth
- Prevents rollback capability
- No audit trail
- No peer review

### WARNING (Report But Don't Block)

**Should be fixed soon:**

- Spec drift (minor differences between git and cluster)
- Missing resource requests/limits
- Non-critical annotation differences
- ConfigMap/Secret content drift
- Hardcoded resources in operator code (verify it's an operator)

**Why WARNING:**

- Doesn't break GitOps entirely
- May be temporary/experimental
- Has valid exceptions
- Can be deferred for planning

### INFO (Informational)

**No action required, informational only:**

- Resources in git not deployed to cluster (expected if feature-flagged)
- Test fixture resources
- Development namespace resources
- kubectl commands in test code
- Properly documented exceptions

**Why INFO:**

- Expected behavior
- Documented exceptions
- No compliance risk

## Integration with Other Skills

### Code Review Workflow

**Automatic Invocation:**

When code review detects K8s-related changes, this skill runs automatically:

```
Code Review Process:
1. User requests code review or creates PR
2. Review skill detects K8s file changes:
   - *.yaml in charts/, manifests/, k8s/
   - values*.yaml files
   - kustomization.yaml
   - Kubernetes client library imports
3. Automatically invokes gitops-audit skill
4. Includes audit report in review findings
5. Blocks PR if CRITICAL issues found
```

### create-pr Skill Integration

**Before creating PR:**

```
create-pr workflow:
1. Run gitops-audit
2. If CRITICAL issues:
   - Block PR creation
   - Report findings to user
   - Suggest remediation
3. If only WARNING issues:
   - Include in PR description
   - Allow PR creation with warnings documented
4. If clean:
   - Proceed with PR creation
```

### gitops-apply Skill Integration

**After applying changes via GitOps:**

```
gitops-apply workflow:
1. Modify manifest
2. Commit via safe-commit
3. Push to git
4. Wait for ArgoCD/Flux sync
5. Run gitops-audit to verify:
   - Cluster state matches git
   - No spec drift introduced
   - Change properly applied
```

## Dependencies & Tools

### Required Tools

- `kubectl` - Cluster access (REQUIRED)
- `git` - GitOps repository access (REQUIRED)

### Optional Tools (Enhanced Functionality)

- `helm` - For Helm-based GitOps repos
- `kustomize` - For Kustomize-based repos
- `yq` or `jq` - YAML/JSON parsing and diffing
- `argocd` CLI - For ArgoCD integration
- `flux` CLI - For Flux integration

### Tool Detection

**Check for tools before use:**

```bash
# Required
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl not found - required for cluster access"
    exit 1
fi

# Optional but recommended
if ! command -v helm &> /dev/null; then
    echo "WARNING: helm not found - Helm-based repos will use basic YAML parsing"
fi

if ! command -v argocd &> /dev/null; then
    echo "INFO: argocd CLI not found - using kubectl for ArgoCD checks"
fi
```

### Fallback Strategies

**If ArgoCD/Flux CLI not available:**

- Use kubectl to check Applications: `kubectl get applications -n argocd`
- Use kubectl to check Kustomizations: `kubectl get kustomizations -n flux-system`

**If helm not available:**

- Parse Chart.yaml and values.yaml as plain YAML
- Use template placeholders for basic rendering

**If yq/jq not available:**

- Use grep/awk for basic field extraction
- Less precise diffing but still functional

## Test Scenarios

### Test Scenario 1: Cluster Drift Detection

**Setup:**

```bash
# Create test namespace
kubectl create namespace test-audit

# Create resource without git manifest
kubectl create deployment test-app --image=nginx -n test-audit

# Create ConfigMap manually
kubectl create configmap test-config --from-literal=foo=bar -n test-audit
```

**Run Audit:**

```bash
/gitops-audit
```

**Expected Output:**

```
🚨 CRITICAL: Resources in cluster NOT tracked in git

Namespace: test-audit
- Deployment/test-app (created manually)
- ConfigMap/test-config (no manifest found)

Action: Either add to GitOps repo OR delete from cluster
```

**Cleanup:**

```bash
kubectl delete namespace test-audit
```

### Test Scenario 2: Spec Drift Detection

**Setup:**

```bash
# Assume app deployed via GitOps with replicas=3 in git
# Manually scale deployment
kubectl scale deployment api-service --replicas=5 -n production

# Manually edit ConfigMap
kubectl edit configmap app-config -n production
# Add: DEBUG_MODE: "true"
```

**Run Audit:**

```bash
/gitops-audit
```

**Expected Output:**

```
⚠️  WARNING: Spec drift detected (git ≠ cluster)

Deployment/api-service (production):
  Git: replicas=3
  Cluster: replicas=5
  Action: Reconcile via gitops-apply skill

ConfigMap/app-config (production):
  Git: (no DEBUG_MODE key)
  Cluster: DEBUG_MODE=true
  Action: Remove from cluster OR add to git
```

**Cleanup:**

```bash
# Revert to git state
kubectl scale deployment api-service --replicas=3 -n production
kubectl edit configmap app-config -n production  # Remove DEBUG_MODE
```

### Test Scenario 3: Code Violations

**Setup:**

Create test file with inline YAML:

```bash
cat > scripts/test-deploy.sh <<'EOF'
#!/bin/bash
kubectl apply -f - <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: test
data:
  foo: bar
YAML
EOF
```

**Run Audit:**

```bash
/gitops-audit
```

**Expected Output:**

```
❌ CRITICAL: Hardcoded Kubernetes configs in application code

scripts/test-deploy.sh:2
  kubectl apply -f - <<YAML
    apiVersion: v1
    kind: ConfigMap
    ...
  YAML

  Issue: Inline YAML in deployment script
  Action: Move to GitOps repo

Summary: 1 CRITICAL code violation
```

**Cleanup:**

```bash
rm scripts/test-deploy.sh
```

## Best Practices

### 1. Run Regularly

**Recommended Schedule:**

- Weekly: Production namespaces
- Daily: Staging/dev namespaces
- On-demand: Before major deployments

### 2. Act on CRITICAL Issues Immediately

**CRITICAL issues must be resolved before:**

- Merging PRs
- Deploying to production
- Closing sprint/iteration

### 3. Plan for WARNING Issues

**WARNING issues should:**

- Be documented in tracking system
- Have remediation plan
- Be reviewed in sprint planning

### 4. Document Exceptions

**If allowing spec drift or hardcoded resources:**

```yaml
# In gitops-audit config
allowed_exceptions:
  - resource: "Deployment/feature-flag-service"
    namespace: "production"
    field: "replicas"
    reason: "Auto-scaled by HPA, drift expected"
    expires: "2024-03-01"
```

### 5. Monitor ArgoCD/Flux Sync Status

**Complement audit with sync monitoring:**

- Check ArgoCD dashboard regularly
- Set up Slack/email alerts for OutOfSync
- Review sync history for patterns

### 6. Educate Team on GitOps

**Use audit findings as teaching moments:**

- Why was this resource created manually?
- What problem were you trying to solve?
- How can we solve it via GitOps?

## Common Issues & Solutions

### Issue: Too Many False Positives

**Symptom:** Audit reports drift for resources that shouldn't be in git

**Solution:**

- Update `exclude_resource_types` configuration
- Add namespaces to `exclude_namespaces`
- Document exceptions in configuration

### Issue: Operator Resources Flagged

**Symptom:** Operator-created resources flagged as hardcoded violations

**Solution:**

- Add operator paths to `allowed_hardcoded` configuration
- Verify operator CRDs are in git
- Document operator patterns

### Issue: Test Resources Flagged

**Symptom:** Test fixtures and E2E setup code flagged

**Solution:**

- Add test paths to `code_scan_exclude`
- Add test patterns to `allowed_hardcoded`
- Clearly separate test code from production code

### Issue: Slow Audit Performance

**Symptom:** Audit takes too long on large clusters

**Solution:**

- Limit namespaces in configuration
- Exclude resource types you don't care about
- Run cluster drift check separately from spec drift
- Use namespace filtering: `/gitops-audit --namespace production`

## Related Skills

- **gitops-apply**: Apply changes via GitOps workflow (use instead of kubectl)
- **helm-chart-writing**: Create Helm charts for GitOps
- **helm-argocd-gitops**: Configure ArgoCD Applications
- **safe-commit**: Commit GitOps manifest changes safely
- **create-pr**: Create PRs for GitOps changes

## Emergency Override

**If user explicitly states "I acknowledge these drift findings":**

1. Document the acknowledgment
2. Include findings in PR description
3. Create follow-up tickets for remediation
4. Set reminders for cleanup

**This should be RARE - GitOps compliance is not optional.**
````
