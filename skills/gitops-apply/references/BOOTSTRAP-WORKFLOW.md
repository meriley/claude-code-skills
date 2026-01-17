# Bootstrap Workflow Reference

## Why Bootstrap is Different

ArgoCD cannot sync itself - this creates a chicken-and-egg problem:

1. ArgoCD reads manifests from git
2. ArgoCD applies manifests to cluster
3. But ArgoCD must already be running to do this

**Solution:** Bootstrap scripts that run via kubectl to install ArgoCD, then GitOps takes over for everything else.

## Bootstrap vs GitOps Decision Tree

```
Is this change for ArgoCD itself?
├── NO → Use standard GitOps workflow (gitops-apply skill)
└── YES → Bootstrap exception applies
          │
          Is this a one-off operation?
          ├── YES (debugging, temp, won't repeat)
          │   └── Proceed with kubectl directly
          │       Say "one-off bootstrap" to override
          │
          └── NO (new clusters, DR, repeatable)
              └── MUST add to bootstrap scripts first
                  1. Update scripts/bootstrap.sh
                  2. Update scripts/bootstrap-idempotent.sh
                  3. Commit changes
                  4. Say "bootstrap updated" to proceed
```

## Bootstrap Script Types

### bootstrap.sh - Initial Setup

Run **once** when creating a new cluster. Can fail on re-run.

```bash
#!/bin/bash
set -e

echo "=== ArgoCD Bootstrap ==="

# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for server
kubectl wait --for=condition=available deployment/argocd-server \
  -n argocd --timeout=300s

# Get initial admin password
echo "Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo ""

# Apply root application (App of Apps pattern)
kubectl apply -f argocd/applications/root-app.yaml

echo "=== Bootstrap Complete ==="
```

### bootstrap-idempotent.sh - Safe to Re-run

Safe to run multiple times. Use for disaster recovery, verification, or updates.

```bash
#!/bin/bash
# Idempotent - safe to re-run anytime

echo "=== ArgoCD Bootstrap (Idempotent) ==="

# Create namespace (ignore if exists)
kubectl create namespace argocd 2>/dev/null || true

# Install/update ArgoCD
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for server (with timeout, don't fail if already ready)
kubectl wait --for=condition=available deployment/argocd-server \
  -n argocd --timeout=300s || true

# Apply root application
kubectl apply -f argocd/applications/root-app.yaml || true

echo "=== Bootstrap Complete ==="
```

## Idempotency Patterns

### Pattern 1: Ignore Existing Resources

```bash
kubectl create namespace argocd 2>/dev/null || true
```

### Pattern 2: Apply is Idempotent

```bash
# apply creates if missing, updates if exists
kubectl apply -f manifest.yaml
```

### Pattern 3: Conditional Wait

```bash
# Don't fail if already available
kubectl wait --for=condition=available deployment/name --timeout=60s || true
```

### Pattern 4: Delete Before Create (Dangerous)

```bash
# Only use when apply doesn't work (rare)
kubectl delete -f manifest.yaml --ignore-not-found
kubectl apply -f manifest.yaml
```

## ArgoCD-Specific Resources

### What Triggers Bootstrap Detection

The hook detects ArgoCD commands via:

| Pattern                       | Example                                |
| ----------------------------- | -------------------------------------- |
| `-n argocd`                   | `kubectl apply -n argocd -f app.yaml`  |
| `--namespace=argocd`          | `kubectl create --namespace=argocd`    |
| `applications.argoproj.io`    | `kubectl get applications.argoproj.io` |
| `applicationsets.argoproj.io` | CRD operations                         |
| `appprojects.argoproj.io`     | CRD operations                         |
| `argocd/` path                | `kubectl apply -f argocd/install.yaml` |

### ArgoCD Resources That Need Bootstrap

| Resource            | Why Bootstrap                      |
| ------------------- | ---------------------------------- |
| ArgoCD installation | Must exist before it can sync      |
| CRDs                | Required for Applications to exist |
| Root Application    | App-of-Apps pattern entry point    |
| Initial secrets     | Admin credentials, repo secrets    |
| RBAC                | ArgoCD service account permissions |

### Resources That Can Use GitOps

Once ArgoCD is running, these can be GitOps-managed:

| Resource              | Location                  |
| --------------------- | ------------------------- |
| Child Applications    | `argocd/applications/`    |
| AppProjects           | `argocd/projects/`        |
| Repositories          | ArgoCD UI or declarative  |
| Application workloads | Standard manifests/charts |

## Recovery Scenarios

### Scenario 1: New Cluster Setup

```bash
# 1. Clone infrastructure repo
git clone git@github.com:org/infrastructure.git
cd infrastructure

# 2. Run bootstrap
./scripts/bootstrap.sh

# 3. ArgoCD syncs everything else automatically
```

### Scenario 2: ArgoCD Corrupted/Deleted

```bash
# 1. Run idempotent bootstrap
./scripts/bootstrap-idempotent.sh

# 2. Force ArgoCD to re-sync
kubectl -n argocd delete pod -l app.kubernetes.io/name=argocd-server
```

### Scenario 3: Upgrading ArgoCD

```bash
# 1. Update version in bootstrap scripts
# 2. Run idempotent bootstrap
./scripts/bootstrap-idempotent.sh

# OR update via GitOps if ArgoCD manages itself (advanced)
```

## Example Directory Structure

```
infrastructure/
├── scripts/
│   ├── bootstrap.sh              # Initial setup
│   └── bootstrap-idempotent.sh   # Recovery/update
├── argocd/
│   ├── install.yaml              # ArgoCD installation manifest
│   ├── applications/
│   │   ├── root-app.yaml         # App of Apps entry
│   │   ├── app-platform.yaml     # Platform services
│   │   └── app-workloads.yaml    # Application workloads
│   └── projects/
│       ├── platform.yaml         # Platform AppProject
│       └── workloads.yaml        # Workloads AppProject
└── manifests/
    └── ...                       # GitOps-managed manifests
```

## Common Mistakes

### Mistake 1: Not Committing Bootstrap Changes

```bash
# BAD: Run kubectl without updating bootstrap
kubectl apply -n argocd -f new-app.yaml

# GOOD: Update bootstrap first, then run
vim scripts/bootstrap-idempotent.sh  # Add the command
git add scripts/bootstrap-idempotent.sh
git commit -m "feat(argocd): add new-app to bootstrap"
kubectl apply -n argocd -f new-app.yaml
```

### Mistake 2: Non-Idempotent Commands in Idempotent Script

```bash
# BAD: Will fail on re-run
kubectl create namespace argocd

# GOOD: Idempotent
kubectl create namespace argocd 2>/dev/null || true
```

### Mistake 3: Missing Waits

```bash
# BAD: May apply before server ready
kubectl apply -n argocd -f install.yaml
kubectl apply -f applications/root-app.yaml

# GOOD: Wait for dependencies
kubectl apply -n argocd -f install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd
kubectl apply -f applications/root-app.yaml
```

## Override Commands

When the hook blocks ArgoCD commands, respond with:

| Response            | Effect                           |
| ------------------- | -------------------------------- |
| "one-off bootstrap" | Proceed without updating scripts |
| "bootstrap updated" | Proceed after updating scripts   |

**Use "one-off bootstrap" sparingly** - if you need it again, it should have been in the bootstrap script.
