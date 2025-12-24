---
name: Helm Chart Expert
description: Comprehensive guide for writing production-ready Helm charts and conducting thorough chart reviews. Covers ArgoCD integration, GitOps workflows, security best practices, and deployment patterns.
version: 1.0.0
---

# Helm Chart Expert Skill

## Purpose

Provide comprehensive guidance for creating production-ready Helm charts and conducting thorough chart reviews. This skill covers Helm chart best practices, ArgoCD/GitOps integration, security patterns, testing strategies, and production deployment patterns.

## When to Use This Skill

- **Creating new Helm charts** - Use templates and best practices
- **Reviewing Helm charts** - Follow comprehensive checklist
- **ArgoCD integration** - Application and ApplicationSet patterns
- **GitOps workflows** - Multi-environment deployment strategies
- **Troubleshooting charts** - Common issues and solutions
- **Security hardening** - Secrets management and security contexts
- **Production deployments** - Blue-green, canary, and rolling updates
- **Chart testing** - Unit tests, integration tests, and helm test hooks

## Quick Start Checklist

### New Chart Creation
```bash
# 1. Create chart structure
helm create mychart

# 2. Validate structure
helm lint ./mychart

# 3. Test rendering
helm template ./mychart --debug

# 4. Dry run
helm install test ./mychart --dry-run --debug
```

## Chart Writing Guidelines

### 1. Chart.yaml Essentials
```yaml
apiVersion: v2
name: mychart
description: A production-ready Helm chart
type: application
version: 1.0.0  # Chart version (SemVer2)
appVersion: "1.16.0"  # Application version
keywords:
  - mychart
  - kubernetes
home: https://github.com/myorg/mychart
sources:
  - https://github.com/myorg/mychart
maintainers:
  - name: Your Name
    email: your.email@example.com
dependencies:
  - name: postgresql
    version: ~12.1.0
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
```

### 2. Values.yaml Template
```yaml
# Default values for mychart
# This is a YAML-formatted file

# replicaCount is the number of pod replicas
replicaCount: 2

# image contains the container image configuration
image:
  repository: myapp
  pullPolicy: IfNotPresent
  tag: ""  # Overrides the image tag (default is appVersion)

# imagePullSecrets for private registries
imagePullSecrets: []

# nameOverride replaces the name of the chart
nameOverride: ""

# fullnameOverride replaces the generated name
fullnameOverride: ""

# serviceAccount configuration
serviceAccount:
  create: true
  annotations: {}
  name: ""

# podAnnotations to add to pods
podAnnotations: {}

# podSecurityContext for pod-level security
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

# securityContext for container-level security
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false

# service configuration
service:
  type: ClusterIP
  port: 80
  targetPort: http
  annotations: {}

# ingress configuration
ingress:
  enabled: false
  className: "nginx"
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

# resources for container resource limits
resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 250m
    memory: 128Mi

# autoscaling configuration
autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

# nodeSelector for pod assignment
nodeSelector: {}

# tolerations for pod assignment
tolerations: []

# affinity for pod assignment
affinity: {}

# podDisruptionBudget configuration
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# monitoring configuration
monitoring:
  enabled: false
  serviceMonitor:
    enabled: false
    interval: 30s
    path: /metrics

# rbac configuration
rbac:
  create: true
  rules: []
```

### 3. Template Helpers (_helpers.tpl)
```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mychart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mychart.labels" -}}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mychart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mychart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mychart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
```

### 4. Deployment Template
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "mychart.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "mychart.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            - name: config
              mountPath: /etc/config
              readOnly: true
      volumes:
        - name: config
          configMap:
            name: {{ include "mychart.fullname" . }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

## Chart Review Checklist

### Security Review
- [ ] **No hardcoded secrets** in values.yaml or templates
- [ ] **Image tags are specific** (no `latest`)
- [ ] **Security contexts** are defined and restrictive
- [ ] **RBAC is properly configured** with least privilege
- [ ] **Network policies** are defined where applicable
- [ ] **Pod Security Standards** are enforced
- [ ] **Resource limits** are set for all containers

### Structure Review
- [ ] **Chart.yaml** has all required fields
- [ ] **Version follows SemVer2** format
- [ ] **Dependencies** use version ranges (~)
- [ ] **One resource per file** in templates/
- [ ] **Template helpers** are properly namespaced
- [ ] **File naming** follows conventions (lowercase, dashes)

### Values Review
- [ ] **All values are documented** with clear comments
- [ ] **Naming is consistent** (camelCase)
- [ ] **Types are explicit** (strings are quoted)
- [ ] **Flat structure** preferred where possible
- [ ] **Defaults are secure** and production-ready
- [ ] **Environment-specific values** are separated

### Template Review
- [ ] **Labels are consistent** and follow k8s recommendations
- [ ] **Nil checks** for nested values
- [ ] **Whitespace is properly managed** ({{- and -}})
- [ ] **Helper functions** are used for repeated logic
- [ ] **Conditionals** are properly structured
- [ ] **Resources can be disabled** via values

### Testing Review
- [ ] **helm lint** passes without errors
- [ ] **helm template** renders correctly
- [ ] **Dry run** succeeds
- [ ] **Unit tests** exist and pass
- [ ] **Integration tests** for critical paths
- [ ] **Helm test** hooks are defined

### Documentation Review
- [ ] **README.md** exists with usage examples
- [ ] **CHANGELOG.md** tracks versions
- [ ] **values.yaml** is fully documented
- [ ] **Examples** for common scenarios
- [ ] **Upgrade notes** for breaking changes
- [ ] **Dependencies** are documented

## ArgoCD Integration

### Application Template
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .Values.appName }}
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: {{ .Values.project | default "default" }}
  source:
    repoURL: {{ .Values.repoURL }}
    targetRevision: {{ .Values.targetRevision }}
    path: {{ .Values.path }}
    helm:
      releaseName: {{ .Values.releaseName }}
      valueFiles:
        - values.yaml
        - values-{{ .Values.environment }}.yaml
      parameters:
        - name: image.tag
          value: {{ .Values.imageTag }}
  destination:
    server: {{ .Values.server | default "https://kubernetes.default.svc" }}
    namespace: {{ .Values.namespace }}
  syncPolicy:
    automated:
      prune: {{ .Values.autoPrune | default false }}
      selfHeal: {{ .Values.autoHeal | default false }}
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

### ApplicationSet for Multi-Environment
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
      - env: staging
        cluster: https://staging.k8s.local
        namespace: myapp-staging
      - env: prod
        cluster: https://prod.k8s.local
        namespace: myapp-prod
  template:
    metadata:
      name: 'myapp-{{env}}'
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
        server: '{{cluster}}'
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: '{{env != "prod"}}'
          selfHeal: '{{env != "prod"}}'
```

## Secrets Management

### Using Helm Secrets Plugin
```bash
# Install plugin
helm plugin install https://github.com/jkroepke/helm-secrets

# Encrypt secrets
helm secrets enc secrets.yaml

# Install with encrypted secrets
helm secrets install myrelease . -f secrets.yaml

# Upgrade with encrypted secrets
helm secrets upgrade myrelease . -f secrets.yaml
```

### External Secrets Operator Pattern
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "myapp"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: myapp-secrets
spec:
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: myapp-secrets
  data:
    - secretKey: database-password
      remoteRef:
        key: myapp/database
        property: password
```

## Testing Templates

### Unit Test Example (helm-unittest)
```yaml
suite: test deployment
templates:
  - deployment.yaml
tests:
  - it: should create deployment with correct replicas
    set:
      replicaCount: 3
    asserts:
      - equal:
          path: spec.replicas
          value: 3

  - it: should have resource limits
    asserts:
      - exists:
          path: spec.template.spec.containers[0].resources.limits

  - it: should use specific image tag
    set:
      image.tag: "1.2.3"
    asserts:
      - equal:
          path: spec.template.spec.containers[0].image
          value: "myapp:1.2.3"
```

### Integration Test (helm test)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "mychart.fullname" . }}-test"
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  restartPolicy: Never
  containers:
    - name: test
      image: busybox:1.35
      command:
        - sh
        - -c
        - |
          echo "Testing service connectivity..."
          wget -O- http://{{ include "mychart.fullname" . }}:{{ .Values.service.port }}/healthz
```

## Production Patterns

### Multi-Stage Deployment
```yaml
# Stage 1: Database Migration Job
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mychart.fullname" . }}-migration
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: migration
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          command: ["./migrate"]
```

### Blue-Green Deployment Support
```yaml
{{- if .Values.blueGreen.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mychart.fullname" . }}-{{ .Values.blueGreen.productionSlot }}
  labels:
    slot: {{ .Values.blueGreen.productionSlot }}
spec:
  selector:
    {{- include "mychart.selectorLabels" . | nindent 4 }}
    slot: {{ .Values.blueGreen.productionSlot }}
  ports:
    - port: {{ .Values.service.port }}
{{- end }}
```

### Canary Deployment Support
```yaml
{{- if .Values.canary.enabled }}
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: {{ include "mychart.fullname" . }}
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "mychart.fullname" . }}
  progressDeadlineSeconds: 60
  service:
    port: {{ .Values.service.port }}
  analysis:
    interval: 30s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
      - name: request-success-rate
        thresholdRange:
          min: 99
        interval: 1m
{{- end }}
```

## Common Issues and Solutions

### Issue: Nil Pointer Errors
```yaml
# ❌ Bad - can cause nil pointer
{{ .Values.nested.value }}

# ✅ Good - safe navigation
{{ .Values.nested.value | default "default" }}

# ✅ Better - with existence check
{{- if .Values.nested }}
  {{- if .Values.nested.value }}
    {{ .Values.nested.value }}
  {{- end }}
{{- end }}
```

### Issue: ConfigMap/Secret Changes Not Triggering Pod Restart
```yaml
# Solution: Add checksum annotation
metadata:
  annotations:
    checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

### Issue: Long Resource Names
```yaml
# Use truncation helper
{{- define "mychart.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
```

## Advanced Techniques

### Dynamic Resource Generation
```yaml
{{- range $key, $value := .Values.configMaps }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "mychart.fullname" $ }}-{{ $key }}
data:
  {{- toYaml $value | nindent 2 }}
{{- end }}
```

### Conditional Dependencies
```yaml
{{- if .Values.postgresql.enabled }}
dependencies:
  - name: postgresql
    version: ~11.0.0
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
{{- end }}
```

### Environment-Specific Logic
```yaml
{{- if eq .Values.environment "production" }}
  replicas: {{ .Values.productionReplicas | default 3 }}
{{- else }}
  replicas: {{ .Values.replicaCount | default 1 }}
{{- end }}
```

## Quality Gates

### Pre-Commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/norwoodj/helm-docs
    rev: v1.11.0
    hooks:
      - id: helm-docs
  - repo: https://github.com/gruntwork-io/pre-commit
    rev: v0.1.17
    hooks:
      - id: helmlint
```

### CI/CD Pipeline
```yaml
# .gitlab-ci.yml or .github/workflows/helm.yml
helm-lint:
  stage: test
  script:
    - helm lint ./charts/*

helm-test:
  stage: test
  script:
    - helm unittest ./charts/*

helm-security-scan:
  stage: test
  script:
    - helm template ./charts/* | kubesec scan -

helm-package:
  stage: build
  script:
    - helm package ./charts/*
    - helm repo index .
```

## Monitoring and Observability

### ServiceMonitor for Prometheus
```yaml
{{- if .Values.monitoring.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "mychart.fullname" . }}
spec:
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  endpoints:
    - port: metrics
      interval: {{ .Values.monitoring.serviceMonitor.interval }}
      path: {{ .Values.monitoring.serviceMonitor.path }}
{{- end }}
```

### Grafana Dashboard ConfigMap
```yaml
{{- if .Values.monitoring.grafana.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "mychart.fullname" . }}-dashboard
  labels:
    grafana_dashboard: "1"
data:
  dashboard.json: |
    {{ .Files.Get "files/grafana-dashboard.json" | indent 4 }}
{{- end }}
```

## Upgrade Strategies

### Rolling Update Configuration
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: {{ .Values.rollingUpdate.maxSurge | default "25%" }}
    maxUnavailable: {{ .Values.rollingUpdate.maxUnavailable | default "25%" }}
```

### Pre-Upgrade Backup Job
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "-10"
spec:
  template:
    spec:
      containers:
        - name: backup
          image: backup-tool:latest
          command: ["./backup.sh"]
```

## Final Review Checklist

### Before Release
- [ ] All tests pass (lint, unit, integration)
- [ ] Security scanning completed
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Version bumped appropriately
- [ ] Tested in staging environment
- [ ] Rollback procedure documented
- [ ] Resource quotas validated
- [ ] Network policies tested
- [ ] Monitoring/alerting configured

### After Release
- [ ] Smoke tests pass
- [ ] Metrics flowing
- [ ] Logs accessible
- [ ] Alerts configured
- [ ] Documentation published
- [ ] Team notified

## Integration with Other Skills

### Works With:
- **security-scan** - Scan rendered Helm templates for hardcoded secrets
- **quality-check** - Lint YAML files for formatting issues
- Manual invocation for Helm-specific work

### Invokes:
- None (standalone reference skill)

### Invoked By:
- User (manual invocation when working with Helm)

## Example Usage

```bash
# Manual invocation
/skill helm-chart-expert

# User requests
User: "Help me create a production-ready Helm chart"
User: "Review this Helm chart for security issues"
User: "Show me how to integrate with ArgoCD"
User: "How do I handle secrets in Helm?"
```

## References

- [Official Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
- [SemVer 2.0](https://semver.org)
- [Helm Security](https://helm.sh/docs/topics/security/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)

---

**Maintained by**: DevOps team
**Review Schedule**: Quarterly
**Last Updated**: 2025-01-12

---

## Related Agent

For comprehensive Helm/Kubernetes guidance that coordinates this and other Helm skills, use the **`helm-kubernetes-expert`** agent.
