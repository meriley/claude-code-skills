# Production Deployment Patterns

Advanced patterns for production-ready Helm charts including secrets management, testing strategies, deployment patterns, monitoring, and upgrade strategies. Load when preparing charts for production or implementing advanced deployment workflows.

---

## Secrets Management

### Helm Secrets Plugin

```bash
# Install plugin
helm plugin install https://github.com/jkroepke/helm-secrets

# Encrypt secrets
helm secrets enc secrets.yaml

# Install with encrypted secrets
helm secrets install myrelease . -f secrets.yaml

# Upgrade with encrypted secrets
helm secrets upgrade myrelease . -f secrets.yaml

# View decrypted secrets (requires sops key)
helm secrets view secrets.yaml
```

**Example secrets.yaml:**

```yaml
# secrets.yaml (encrypted with sops)
database:
  password: ENC[AES256_GCM,data:...,iv:...,tag:...,type:str]

api:
  key: ENC[AES256_GCM,data:...,iv:...,tag:...,type:str]
```

### External Secrets Operator Pattern

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: {{ .Release.Namespace }}
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "{{ .Values.vault.role }}"
          serviceAccountRef:
            name: {{ include "mychart.serviceAccountName" . }}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ include "mychart.fullname" . }}-secrets
  namespace: {{ .Release.Namespace }}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: {{ include "mychart.fullname" . }}-secrets
    creationPolicy: Owner
  data:
    - secretKey: database-password
      remoteRef:
        key: {{ .Values.environment }}/database
        property: password
    - secretKey: api-key
      remoteRef:
        key: {{ .Values.environment }}/api
        property: key
```

### Sealed Secrets Pattern

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: {{ include "mychart.fullname" . }}-sealed
  namespace: {{ .Release.Namespace }}
spec:
  encryptedData:
    database-password: AgBj3I7qR...  # Encrypted by kubeseal
    api-key: AgCFz9mN...
  template:
    metadata:
      name: {{ include "mychart.fullname" . }}-secrets
      labels:
        {{- include "mychart.labels" . | nindent 8 }}
```

---

## Testing Strategies

### Unit Test Example (helm-unittest)

```yaml
# tests/deployment_test.yaml
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
      - isKind:
          of: Deployment

  - it: should have resource limits
    asserts:
      - exists:
          path: spec.template.spec.containers[0].resources.limits
      - equal:
          path: spec.template.spec.containers[0].resources.limits.cpu
          value: 500m

  - it: should use specific image tag
    set:
      image.tag: "1.2.3"
    asserts:
      - equal:
          path: spec.template.spec.containers[0].image
          value: "myapp:1.2.3"

  - it: should have security context
    asserts:
      - equal:
          path: spec.template.spec.securityContext.runAsNonRoot
          value: true
      - equal:
          path: spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation
          value: false
```

### Integration Test (helm test)

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "mychart.fullname" . }}-test-connection"
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  restartPolicy: Never
  containers:
    - name: wget
      image: busybox:1.35
      command:
        - sh
        - -c
        - |
          echo "Testing service connectivity..."
          wget -O- http://{{ include "mychart.fullname" . }}:{{ .Values.service.port }}/healthz || exit 1
          echo "Service is healthy!"
```

### Smoke Test Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ include "mychart.fullname" . }}-smoke-test"
  annotations:
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-weight": "10"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  backoffLimit: 3
  template:
    metadata:
      name: "{{ include "mychart.fullname" . }}-smoke-test"
    spec:
      restartPolicy: Never
      containers:
        - name: smoke-test
          image: curlimages/curl:latest
          command:
            - sh
            - -c
            - |
              echo "Running smoke tests..."
              curl -f http://{{ include "mychart.fullname" . }}/healthz || exit 1
              curl -f http://{{ include "mychart.fullname" . }}/ready || exit 1
              echo "All smoke tests passed!"
```

---

## Multi-Stage Deployment

### Pre-Install Validation

```yaml
# Pre-install hook to validate prerequisites
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mychart.fullname" . }}-pre-install
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  template:
    spec:
      restartPolicy: Never
      serviceAccountName: {{ include "mychart.serviceAccountName" . }}
      containers:
        - name: validate
          image: bitnami/kubectl:latest
          command:
            - sh
            - -c
            - |
              echo "Validating prerequisites..."
              kubectl get namespace {{ .Values.database.namespace }} || exit 1
              kubectl get secret {{ .Values.database.secretName }} -n {{ .Values.database.namespace }} || exit 1
              echo "Prerequisites validated!"
```

### Database Migration Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mychart.fullname" . }}-migration
  annotations:
    "helm.sh/hook": pre-upgrade,pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      restartPolicy: Never
      initContainers:
        - name: wait-for-db
          image: busybox:1.35
          command:
            - sh
            - -c
            - |
              until nc -z {{ .Values.database.host }} {{ .Values.database.port }}; do
                echo "Waiting for database..."
                sleep 2
              done
      containers:
        - name: migrate
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          command: ["./migrate", "up"]
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: {{ include "mychart.fullname" . }}-secrets
                  key: database-url
```

---

## Blue-Green Deployment

```yaml
{{- if .Values.blueGreen.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mychart.fullname" . }}-production
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
    traffic: production
spec:
  selector:
    {{- include "mychart.selectorLabels" . | nindent 4 }}
    slot: {{ .Values.blueGreen.productionSlot }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mychart.fullname" . }}-staging
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
    traffic: staging
spec:
  selector:
    {{- include "mychart.selectorLabels" . | nindent 4 }}
    slot: {{ .Values.blueGreen.stagingSlot }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
{{- end }}
```

**values.yaml:**

```yaml
blueGreen:
  enabled: true
  productionSlot: blue # or green
  stagingSlot: green # or blue
```

---

## Canary Deployment (Flagger)

```yaml
{{- if .Values.canary.enabled }}
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: {{ include "mychart.fullname" . }}
  namespace: {{ .Release.Namespace }}
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "mychart.fullname" . }}
  progressDeadlineSeconds: 60
  service:
    port: {{ .Values.service.port }}
    targetPort: http
    gateways:
      - {{ .Values.canary.gateway }}
    hosts:
      - {{ .Values.canary.host }}
  analysis:
    interval: {{ .Values.canary.analysis.interval }}
    threshold: {{ .Values.canary.analysis.threshold }}
    maxWeight: {{ .Values.canary.analysis.maxWeight }}
    stepWeight: {{ .Values.canary.analysis.stepWeight }}
    metrics:
      - name: request-success-rate
        thresholdRange:
          min: {{ .Values.canary.metrics.successRateMin }}
        interval: 1m
      - name: request-duration
        thresholdRange:
          max: {{ .Values.canary.metrics.durationMax }}
        interval: 1m
    webhooks:
      - name: load-test
        url: {{ .Values.canary.loadTestUrl }}
        timeout: 5s
        metadata:
          cmd: "hey -z 1m -q 10 -c 2 http://{{ .Values.canary.host }}"
{{- end }}
```

---

## Monitoring and Observability

### ServiceMonitor for Prometheus

```yaml
{{- if .Values.monitoring.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "mychart.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
    {{- with .Values.monitoring.serviceMonitor.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  endpoints:
    - port: metrics
      interval: {{ .Values.monitoring.serviceMonitor.interval }}
      path: {{ .Values.monitoring.serviceMonitor.path }}
      scrapeTimeout: {{ .Values.monitoring.serviceMonitor.scrapeTimeout }}
      {{- with .Values.monitoring.serviceMonitor.relabelings }}
      relabelings:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
```

### PrometheusRule for Alerting

```yaml
{{- if .Values.monitoring.prometheusRule.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "mychart.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
spec:
  groups:
    - name: {{ include "mychart.fullname" . }}.rules
      interval: 30s
      rules:
        - alert: HighErrorRate
          expr: |
            rate(http_requests_total{job="{{ include "mychart.fullname" . }}", status=~"5.."}[5m]) > 0.05
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "High error rate detected"
            description: "Error rate is above 5% for the last 5 minutes"

        - alert: PodCrashLooping
          expr: |
            rate(kube_pod_container_status_restarts_total{pod=~"{{ include "mychart.fullname" . }}.*"}[15m]) > 0
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Pod is crash looping"
            description: "Pod {{ "{{" }} $labels.pod {{ "}}" }} is restarting frequently"
{{- end }}
```

### Grafana Dashboard ConfigMap

```yaml
{{- if .Values.monitoring.grafana.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "mychart.fullname" . }}-dashboard
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
    grafana_dashboard: "1"
data:
  {{ include "mychart.name" . }}-dashboard.json: |-
    {{ .Files.Get "dashboards/application.json" | indent 4 }}
{{- end }}
```

---

## Upgrade Strategies

### Rolling Update Configuration

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: { { .Values.rollingUpdate.maxSurge | default "25%" } }
    maxUnavailable: { { .Values.rollingUpdate.maxUnavailable | default "0" } }
```

**values.yaml:**

```yaml
rollingUpdate:
  maxSurge: "50%" # Allow 50% extra pods during update
  maxUnavailable: "0" # Zero downtime deployment
```

### Pre-Upgrade Backup Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mychart.fullname" . }}-backup
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "-15"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: backup
          image: postgres:14-alpine
          command:
            - sh
            - -c
            - |
              echo "Creating database backup..."
              pg_dump $DATABASE_URL > /backup/db-$(date +%Y%m%d-%H%M%S).sql
              echo "Backup completed!"
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: {{ include "mychart.fullname" . }}-secrets
                  key: database-url
          volumeMounts:
            - name: backup
              mountPath: /backup
      volumes:
        - name: backup
          persistentVolumeClaim:
            claimName: {{ include "mychart.fullname" . }}-backup
```

### Post-Upgrade Verification

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mychart.fullname" . }}-post-upgrade
  annotations:
    "helm.sh/hook": post-upgrade
    "helm.sh/hook-weight": "5"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: verify
          image: curlimages/curl:latest
          command:
            - sh
            - -c
            - |
              echo "Verifying deployment..."
              for i in $(seq 1 30); do
                if curl -f http://{{ include "mychart.fullname" . }}/healthz; then
                  echo "Deployment verified successfully!"
                  exit 0
                fi
                echo "Waiting for application... ($i/30)"
                sleep 10
              done
              echo "Deployment verification failed!"
              exit 1
```

---

## Quality Gates

### Pre-Commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/norwoodj/helm-docs
    rev: v1.11.0
    hooks:
      - id: helm-docs
        args:
          - --chart-search-root=charts

  - repo: https://github.com/gruntwork-io/pre-commit
    rev: v0.1.17
    hooks:
      - id: helmlint
        args: ["--strict"]

  - repo: local
    hooks:
      - id: helm-unittest
        name: helm unittest
        entry: helm unittest
        language: system
        pass_filenames: false
        args: ["./charts/*/"]
```

### CI/CD Pipeline

```yaml
# .github/workflows/helm.yml
name: Helm Chart CI

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/setup-helm@v3
        with:
          version: "v3.12.0"

      - name: Helm Lint
        run: helm lint ./charts/*

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/setup-helm@v3

      - name: Install helm-unittest
        run: helm plugin install https://github.com/helm-unittest/helm-unittest

      - name: Run Unit Tests
        run: helm unittest ./charts/*

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/setup-helm@v3

      - name: Template Charts
        run: helm template ./charts/* > manifests.yaml

      - name: Security Scan
        uses: controlplaneio/kubesec-action@v0.0.2
        with:
          input: manifests.yaml

  package:
    needs: [lint, test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: azure/setup-helm@v3

      - name: Package Charts
        run: |
          helm package ./charts/*
          helm repo index .

      - name: Publish to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: .
```

---

## Best Practices Summary

1. **Secrets**: Use External Secrets Operator or Sealed Secrets, never plain Kubernetes Secrets in charts
2. **Testing**: Include unit tests (helm-unittest), integration tests (helm test), and smoke tests
3. **Hooks**: Use pre/post-install/upgrade hooks for migrations, backups, and verification
4. **Monitoring**: Include ServiceMonitor, PrometheusRule, and Grafana dashboards
5. **Rollback**: Always test rollback procedure: `helm rollback <release> <revision>`
6. **Progressive Delivery**: Use canary or blue-green deployments for production
7. **Validation**: Run security scans, linting, and tests in CI/CD
8. **Documentation**: Document upgrade procedures, breaking changes, and rollback steps
