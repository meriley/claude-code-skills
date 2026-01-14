# GitOps Drift Patterns Reference

Detailed examples and patterns for the three audit types: Cluster Drift, Spec Drift, and Code Violations.

## Audit Type 1: Cluster Drift Detection

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

---

## Audit Type 2: Spec Drift Analysis

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

---

## Audit Type 3: Code Violations

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

---

## Pattern Recognition Tips

### Cluster Drift Indicators

- Resources with kubectl creation timestamps
- Resources not found in any manifest files
- Orphaned resources (created manually, forgotten)
- Resources in unexpected namespaces

### Spec Drift Indicators

- Manual scaling events (kubectl scale history)
- Recent kubectl edit/patch commands
- ArgoCD/Flux OutOfSync status
- Replicas/image tags differing from git
- Annotation/label modifications

### Code Violation Patterns

- **Inline YAML**: `kubectl apply -f - <<EOF`
- **Hardcoded manifests**: YAML strings in code
- **Direct kubectl**: `subprocess.run(["kubectl", ...])`
- **Client library abuse**: Proper use in operators is OK
- **CI/CD shortcuts**: Bypassing GitOps for "quick" deploys
