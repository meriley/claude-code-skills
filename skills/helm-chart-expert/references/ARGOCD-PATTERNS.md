# ArgoCD Integration Patterns

Comprehensive ArgoCD Application and ApplicationSet patterns for GitOps-based Helm deployments. Load when integrating Helm charts with ArgoCD or setting up multi-environment workflows.

---

## Basic Application Template

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: { { .Values.appName } }
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: { { .Values.project | default "default" } }
  source:
    repoURL: { { .Values.repoURL } }
    targetRevision: { { .Values.targetRevision } }
    path: { { .Values.path } }
    helm:
      releaseName: { { .Values.releaseName } }
      valueFiles:
        - values.yaml
        - values-{{ .Values.environment }}.yaml
      parameters:
        - name: image.tag
          value: { { .Values.imageTag } }
  destination:
    server: { { .Values.server | default "https://kubernetes.default.svc" } }
    namespace: { { .Values.namespace } }
  syncPolicy:
    automated:
      prune: { { .Values.autoPrune | default false } }
      selfHeal: { { .Values.autoHeal | default false } }
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

---

## ApplicationSet for Multi-Environment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: myapp-environments
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            cluster: https://dev.k8s.local
            namespace: myapp-dev
            autoPrune: true
            autoHeal: true
          - env: staging
            cluster: https://staging.k8s.local
            namespace: myapp-staging
            autoPrune: true
            autoHeal: true
          - env: prod
            cluster: https://prod.k8s.local
            namespace: myapp-prod
            autoPrune: false
            autoHeal: false
  template:
    metadata:
      name: "myapp-{{env}}"
      labels:
        environment: "{{env}}"
    spec:
      project: default
      source:
        repoURL: https://github.com/myorg/charts
        targetRevision: main
        path: charts/myapp
        helm:
          valueFiles:
            - values.yaml
            - environments/{{env}}/values.yaml
      destination:
        server: "{{cluster}}"
        namespace: "{{namespace}}"
      syncPolicy:
        automated:
          prune: "{{autoPrune}}"
          selfHeal: "{{autoHeal}}"
        syncOptions:
          - CreateNamespace=true
```

---

## Git Generator Pattern

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: myapp-clusters
  namespace: argocd
spec:
  generators:
    - git:
        repoURL: https://github.com/myorg/gitops-config
        revision: HEAD
        directories:
          - path: clusters/*
  template:
    metadata:
      name: "myapp-{{path.basename}}"
    spec:
      project: default
      source:
        repoURL: https://github.com/myorg/charts
        targetRevision: main
        path: charts/myapp
        helm:
          valueFiles:
            - values.yaml
            - "{{path}}/values.yaml"
      destination:
        server: "{{path.basename}}"
        namespace: myapp
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

---

## Matrix Generator for Multi-Tenant

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: tenant-apps
  namespace: argocd
spec:
  generators:
    - matrix:
        generators:
          - list:
              elements:
                - tenant: acme
                  contact: acme@example.com
                - tenant: widgets
                  contact: widgets@example.com
          - list:
              elements:
                - env: dev
                  cluster: https://dev.k8s.local
                - env: prod
                  cluster: https://prod.k8s.local
  template:
    metadata:
      name: "{{tenant}}-{{env}}"
      annotations:
        notifications.argoproj.io/subscribe.on-sync-succeeded: "{{contact}}"
    spec:
      project: "{{tenant}}"
      source:
        repoURL: https://github.com/myorg/charts
        targetRevision: main
        path: charts/app
        helm:
          valueFiles:
            - values.yaml
            - tenants/{{tenant}}/{{env}}.yaml
      destination:
        server: "{{cluster}}"
        namespace: "{{tenant}}-{{env}}"
```

---

## Progressive Rollout Pattern

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-prod
  namespace: argocd
spec:
  project: production
  source:
    repoURL: https://github.com/myorg/charts
    targetRevision: v1.2.3
    path: charts/myapp
    helm:
      valueFiles:
        - values-prod.yaml
  destination:
    server: https://prod.k8s.local
    namespace: myapp-prod
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
    syncOptions:
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true
    retry:
      limit: 2
  # Manual sync required for production
  # Use progressive delivery with Argo Rollouts
  syncPolicy:
    syncOptions:
      - RespectIgnoreDifferences=true
```

---

## Health Assessment Customization

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  # ... source/destination config ...
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas
    - group: autoscaling
      kind: HorizontalPodAutoscaler
      jqPathExpressions:
        - .spec.metrics[]?.resource.target.averageUtilization
  info:
    - name: "Chart Version"
      value: "{{ .Chart.Version }}"
    - name: "Image Tag"
      value: "{{ .Values.image.tag }}"
```

---

## Sync Waves and Hooks

```yaml
# Pre-sync database migration job
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/sync-wave: "-5"
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: migrate
          image: myapp:{{ .Values.image.tag }}
          command: ["./migrate"]
---
# Main deployment (sync wave 0 by default)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  # ... deployment config ...
---
# Post-sync smoke test
apiVersion: batch/v1
kind: Job
metadata:
  name: smoke-test
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/sync-wave: "5"
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: test
          image: curlimages/curl:latest
          command: ["curl", "-f", "http://myapp/healthz"]
```

---

## Resource Tracking Modes

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
  annotations:
    # Use annotation tracking (default)
    argocd.argoproj.io/tracking-method: annotation

    # Or use label tracking
    # argocd.argoproj.io/tracking-method: label

    # Or use annotation+label tracking
    # argocd.argoproj.io/tracking-method: annotation+label
spec:
  # ... config ...
```

---

## Notification Templates

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
  annotations:
    # Subscribe to deployment notifications
    notifications.argoproj.io/subscribe.on-deployed.slack: my-channel
    notifications.argoproj.io/subscribe.on-health-degraded.pagerduty: oncall
    notifications.argoproj.io/subscribe.on-sync-failed.email: team@example.com
spec:
  # ... config ...
```

---

## Best Practices

### 1. Environment-Specific Configurations

**Structure:**

```
gitops-repo/
├── applications/
│   ├── dev/
│   │   └── myapp.yaml       # ArgoCD Application for dev
│   ├── staging/
│   │   └── myapp.yaml       # ArgoCD Application for staging
│   └── prod/
│       └── myapp.yaml       # ArgoCD Application for prod
└── charts/
    └── myapp/
        ├── values.yaml      # Default values
        ├── values-dev.yaml
        ├── values-staging.yaml
        └── values-prod.yaml
```

### 2. Progressive Delivery Strategy

- **Dev**: Automated sync with prune and self-heal
- **Staging**: Automated sync, manual prune
- **Prod**: Manual sync only

### 3. Sync Options

- **CreateNamespace=true**: Auto-create target namespace
- **PruneLast=true**: Delete resources last (prevents downtime)
- **ApplyOutOfSyncOnly=true**: Only sync changed resources
- **ServerSideApply=true**: Use server-side apply

### 4. Project Isolation

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: Production applications
  sourceRepos:
    - "https://github.com/myorg/charts"
  destinations:
    - namespace: "*"
      server: https://prod.k8s.local
  clusterResourceWhitelist:
    - group: ""
      kind: Namespace
    - group: "rbac.authorization.k8s.io"
      kind: ClusterRole
  namespaceResourceBlacklist:
    - group: ""
      kind: ResourceQuota
```

---

## Troubleshooting

### Application Stuck in Progressing

**Check sync waves:**

```bash
kubectl get application myapp -n argocd -o yaml | grep sync-wave
```

**Force sync:**

```bash
argocd app sync myapp --force
```

### Resources Not Pruning

**Check prune policy:**

```bash
argocd app get myapp | grep -i prune
```

**Manual prune:**

```bash
argocd app sync myapp --prune
```

### Sync Hooks Failing

**View hook status:**

```bash
argocd app get myapp --show-operation
```

**Delete failed hook:**

```bash
kubectl delete job db-migration -n target-namespace
argocd app sync myapp
```
