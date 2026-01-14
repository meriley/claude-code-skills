# Kubernetes Resources Configuration

Detailed configuration options, resource type handling, and GitOps repository structure guidance.

## Default Configuration

```yaml
# GitOps repository configuration
gitops_repos:
  - path: /path/to/gitops-repo
    type: helm # helm | kustomize | plain-yaml
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

---

## Configuration Detection

The skill attempts to detect configuration automatically:

### 1. GitOps Repo Detection

**Automatic Detection Methods:**

- Check environment variable: `GITOPS_REPO_PATH`
- Search common locations:
  - `~/gitops-repo`
  - `~/projects/gitops`
  - `~/k8s-manifests`
  - `../gitops-repo` (sibling directory)
- Parse git remotes for gitops-related repositories:
  ```bash
  git remote -v | grep -E "(gitops|k8s|kubernetes|manifests)"
  ```

**User Prompt if Not Found:**

```
GitOps repository not automatically detected.

Please provide the path to your GitOps repository:
- Local path: /path/to/gitops-repo
- Or I can clone it: git@github.com:org/gitops-repo.git
```

---

### 2. Namespace Detection

**Automatic Detection:**

```bash
# Query cluster for all namespaces
kubectl get namespaces -o name

# Filter out system namespaces
grep -vE "(kube-system|kube-public|kube-node-lease|default)"

# Focus on application namespaces
```

**Result:**

```
Detected namespaces for audit:
- production
- staging
- dev
- feature-branch-xyz

Excluded system namespaces:
- kube-system
- kube-public
- default
```

---

### 3. Repository Type Detection

**Detection Logic:**

```bash
# Check for Helm
if [ -d "charts/" ]; then
  TYPE="helm"
  VALUES_FILES=$(find charts/ -name "values*.yaml")
  echo "Detected: Helm-based GitOps repository"
fi

# Check for Kustomize
if [ -f "kustomization.yaml" ] || [ -d "base/" ] || [ -d "overlays/" ]; then
  TYPE="kustomize"
  echo "Detected: Kustomize-based GitOps repository"
fi

# Check for Plain YAML
if [ -d "manifests/" ] || [ -d "k8s/" ] || [ -d "kubernetes/" ]; then
  TYPE="plain-yaml"
  echo "Detected: Plain YAML GitOps repository"
fi

# Support mixed approaches
if [ "$TYPE" == "helm" ] && [ -f "kustomization.yaml" ]; then
  echo "Note: Mixed Helm + Kustomize detected"
fi
```

---

## Resource Type Handling

### Core Application Resources (Always Audit)

```yaml
core_resource_types:
  - Deployment
  - StatefulSet
  - DaemonSet
  - Service
  - Ingress
  - ConfigMap
  - Secret
  - PersistentVolumeClaim
  - HorizontalPodAutoscaler
  - VerticalPodAutoscaler
```

---

### Networking Resources

```yaml
networking_resource_types:
  - NetworkPolicy
  - IngressClass
  - Gateway
  - HTTPRoute
  - TCPRoute
  - GRPCRoute
```

---

### Security & RBAC

```yaml
security_resource_types:
  - ServiceAccount
  - Role
  - RoleBinding
  - ClusterRole
  - ClusterRoleBinding
  - PodSecurityPolicy
  - SecurityContext
```

---

### Storage

```yaml
storage_resource_types:
  - PersistentVolume
  - PersistentVolumeClaim
  - StorageClass
  - VolumeSnapshot
  - VolumeSnapshotClass
```

---

### Batch & Jobs

```yaml
batch_resource_types:
  - Job
  - CronJob
```

---

### Custom Resources (CRDs)

**Detection:**

```bash
# List all CRDs in cluster
kubectl get crds -o name

# Check which CRDs have instances in audited namespaces
kubectl api-resources --namespaced --verbs=list -o name | \
  xargs -I {} kubectl get {} -n production --ignore-not-found
```

**Common Third-Party CRDs:**

```yaml
common_crds:
  # ArgoCD
  - Application
  - AppProject
  - ApplicationSet

  # Flux
  - Kustomization
  - HelmRelease
  - GitRepository
  - HelmRepository

  # Cert-Manager
  - Certificate
  - CertificateRequest
  - Issuer
  - ClusterIssuer

  # External Secrets
  - ExternalSecret
  - SecretStore
  - ClusterSecretStore

  # Sealed Secrets
  - SealedSecret

  # Prometheus
  - Prometheus
  - ServiceMonitor
  - PrometheusRule
  - Alertmanager

  # Istio
  - VirtualService
  - DestinationRule
  - Gateway
  - ServiceEntry
```

---

## GitOps Repository Structures

### Structure 1: Helm-based

```
gitops-repo/
├── charts/
│   ├── api-service/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   ├── values-production.yaml
│   │   ├── values-staging.yaml
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── ingress.yaml
│   │       └── configmap.yaml
│   ├── worker-service/
│   │   └── ...
│   └── frontend/
│       └── ...
└── argocd/
    ├── applications/
    │   ├── api-service-prod.yaml
    │   └── api-service-staging.yaml
    └── app-of-apps.yaml
```

**Audit Approach:**

```bash
# For each chart
helm template api-service charts/api-service/ -f charts/api-service/values-production.yaml

# Compare rendered output to cluster
kubectl diff -f <(helm template ...)
```

---

### Structure 2: Kustomize-based

```
gitops-repo/
├── base/
│   ├── api-service/
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   └── worker-service/
│       └── ...
└── overlays/
    ├── production/
    │   ├── kustomization.yaml
    │   └── patches/
    │       └── api-service-replicas.yaml
    └── staging/
        └── kustomization.yaml
```

**Audit Approach:**

```bash
# Build each overlay
kustomize build overlays/production/

# Compare to cluster
kubectl diff -k overlays/production/
```

---

### Structure 3: Plain YAML

```
gitops-repo/
├── production/
│   ├── api-service/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── worker-service/
│       └── ...
└── staging/
    └── ...
```

**Audit Approach:**

```bash
# For each manifest
kubectl diff -f production/api-service/
```

---

### Structure 4: Mixed (Helm + Kustomize)

```
gitops-repo/
├── charts/  # Helm charts for complex apps
│   └── api-service/
└── manifests/  # Plain YAML for simple resources
    ├── production/
    │   ├── kustomization.yaml  # Optional Kustomize overlay
    │   └── namespaces/
    └── staging/
```

**Audit Approach:**

- Detect type per directory
- Apply appropriate rendering method
- Combine results for comprehensive audit

---

## Exclusion Patterns

### System Namespaces (Default Exclusions)

```yaml
exclude_namespaces:
  - kube-system # Kubernetes core
  - kube-public # Public cluster info
  - kube-node-lease # Node heartbeats
  - default # Avoid using default namespace
  - local-path-storage # Local storage provisioner
```

---

### GitOps Tool Namespaces

```yaml
gitops_tool_namespaces:
  - argocd # ArgoCD itself
  - argocd-system # ArgoCD alternative namespace
  - flux-system # Flux v2
  - fluxcd # Flux alternative
  - tekton-pipelines # Tekton
  - jenkins # Jenkins (if self-hosted)
```

**Reasoning:** GitOps tools may create resources dynamically (e.g., Argo Rollouts, Flux Kustomizations). These should be excluded from drift detection but their **configuration** should be in git.

---

### Monitoring & Observability

```yaml
monitoring_namespaces:
  - monitoring # Prometheus/Grafana
  - observability # Alternative name
  - logging # ELK/Loki
  - tracing # Jaeger/Tempo
```

**Decision:** Exclude from drift detection IF monitoring is managed separately (e.g., Helm operator). Include if monitoring config is in main GitOps repo.

---

### Ephemeral Resources (Always Exclude)

```yaml
exclude_resource_types:
  - Event # Kubernetes events (ephemeral)
  - EndpointSlice # Auto-generated from Service
  - Lease # Leader election, node heartbeats
  - Pod # Managed by Deployment/StatefulSet
  - ReplicaSet # Managed by Deployment
  - ControllerRevision # StatefulSet/DaemonSet history
  - ComponentStatus # Cluster component health
```

---

## Allowed Exceptions

### Operators & Controllers

```yaml
operator_exceptions:
  # Operators create resources programmatically
  - pattern: "src/operator/**/*.go"
    reason: "Operator reconciliation loop"
    verify: "Ensure operator CRD is in git"

  - pattern: "pkg/controller/**/*.go"
    reason: "Controller logic"
    verify: "Ensure controller deployment is in git"

  # Specific operators
  - pattern: "src/cert-manager-operator/**/*"
    reason: "Manages Certificate resources dynamically"

  - pattern: "src/autoscaler/**/*"
    reason: "Creates/deletes Pods based on metrics"
```

---

### Test & Development

```yaml
test_exceptions:
  - pattern: "tests/**/*"
    reason: "Test fixtures"
    severity: INFO

  - pattern: "e2e/**/*"
    reason: "E2E test setup"
    severity: INFO

  - pattern: "scripts/local-dev-setup.sh"
    reason: "Local development environment"
    severity: INFO
```

---

### CI/CD Pipelines

```yaml
cicd_exceptions:
  # Build/test namespaces
  - namespace: "ci-*"
    reason: "Ephemeral CI build environments"
    max_age: "2h"

  - namespace: "pr-*"
    reason: "Pull request preview environments"
    max_age: "24h"

  # Allowed kubectl in CI for specific actions
  - pattern: ".github/workflows/integration-test.yml"
    allow_kubectl:
      - "create namespace"
      - "delete namespace"
      - "wait"
      - "get"
    reason: "Test namespace lifecycle only"
```

---

## Best Practices

### 1. Version Control Everything

**What MUST be in git:**

- All application manifests (Deployment, Service, etc.)
- Helm charts and values files
- Kustomize base and overlays
- Operator/controller CRDs
- RBAC policies
- NetworkPolicies
- PodSecurityPolicies/PodSecurityStandards
- ArgoCD Application definitions
- Flux Kustomization/HelmRelease definitions

**What can be excluded:**

- Secrets (use SealedSecrets/ExternalSecrets instead)
- Ephemeral test namespaces
- Operator-generated resources (if operator CRD is tracked)
- HPA-scaled Pods (base Deployment is tracked)

---

### 2. Use Encrypted Secrets

**Instead of plain Secrets in git:**

```yaml
# ❌ BAD: Plain Secret
apiVersion: v1
kind: Secret
metadata:
  name: db-password
data:
  password: cGFzc3dvcmQxMjM= # Base64 is not encryption!
```

**Use SealedSecrets:**

```yaml
# ✅ GOOD: SealedSecret
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: db-password
spec:
  encryptedData:
    password: AgBQxK7... # Actually encrypted
```

**Or ExternalSecrets:**

```yaml
# ✅ GOOD: ExternalSecret
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-password
spec:
  secretStoreRef:
    name: vault-backend
  target:
    name: db-password
  data:
    - secretKey: password
      remoteRef:
        key: database/password
```

---

### 3. Document Exceptions

```yaml
# In your gitops-audit config or README.md
documented_exceptions:
  - resource: "Deployment/autoscaler"
    reason: "Replicas managed by HPA, drift expected"
    reviewed: "2024-01-15"
    reviewer: "ops-team"

  - code: "src/operator/controller.go:128"
    reason: "Operator creates Pods dynamically"
    verified: "Operator CRD is tracked in charts/my-operator/"
```

---

### 4. Regular Audits

**Recommended Schedule:**

- **Production:** Weekly (automated)
- **Staging:** Daily (automated)
- **Development:** On-demand
- **Before Production Deploy:** Always

**Automation Example:**

```yaml
# .github/workflows/gitops-audit.yml
name: Weekly GitOps Audit
on:
  schedule:
    - cron: "0 9 * * 1" # Every Monday at 9 AM
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run GitOps Audit
        run: |
          claude-code --skill gitops-audit
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: gitops-audit-report
          path: audit-report.md
```
