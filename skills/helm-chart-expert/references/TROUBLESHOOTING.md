# Helm Chart Troubleshooting & Advanced Techniques

Common issues, solutions, and advanced Helm techniques. Load when debugging charts or implementing complex patterns.

---

## Common Issues and Solutions

### Issue: Nil Pointer Errors

**Problem:**

```yaml
# ❌ Bad - can cause nil pointer
{ { .Values.nested.value } }
```

**Causes:**

- Value not defined in values.yaml
- Nested object doesn't exist
- Typo in value path

**Solutions:**

```yaml
# ✅ Good - safe navigation with default
{{ .Values.nested.value | default "default" }}

# ✅ Better - with existence check
{{- if .Values.nested }}
  {{- if .Values.nested.value }}
    {{ .Values.nested.value }}
  {{- end }}
{{- end }}

# ✅ Best - using `with` for nested paths
{{- with .Values.nested }}
  {{- if .value }}
    {{ .value }}
  {{- end }}
{{- end }}
```

---

### Issue: ConfigMap/Secret Changes Not Triggering Pod Restart

**Problem:**
Updated ConfigMap or Secret but pods aren't restarting automatically.

**Solution:**
Add checksum annotations to pod template:

```yaml
# deployment.yaml
metadata:
  annotations:
    checksum/config:
      {
        { include (print $.Template.BasePath "/configmap.yaml") . | sha256sum },
      }
    checksum/secret:
      { { include (print $.Template.BasePath "/secret.yaml") . | sha256sum } }
```

**How it works:**

- Helm recalculates checksums on every render
- Changed ConfigMap/Secret = different checksum
- Different annotation = pod restart triggered

---

### Issue: Long Resource Names Exceeding 63 Characters

**Problem:**

```
Error: release name too long: "my-very-long-release-name-deployment"
```

**Solution:**
Use truncation in helper functions:

```yaml
{{- define "mychart.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
```

**Best practices:**

- Always truncate to 63 characters (Kubernetes limit)
- Remove trailing dashes
- Use `fullnameOverride` for manual control

---

### Issue: Template Rendering Whitespace Issues

**Problem:**

```yaml
# Extra blank lines in output
spec:
  containers:
    - name: app
```

**Solution:**
Use `{{-` and `-}}` to control whitespace:

```yaml
# Remove whitespace before
{{- if .Values.enabled }}
spec:
{{- end }}

# Remove whitespace after
{{ .Values.name -}}
:value

# Remove both
{{- .Values.name -}}
```

---

### Issue: Values Not Merging Correctly

**Problem:**
Multiple values files not merging as expected.

**Solution:**

```bash
# Helm merges values in order (last wins)
helm install myapp . \
  -f values.yaml \
  -f values-dev.yaml \
  -f values-override.yaml
```

**Merge behavior:**

- Scalars: Last value wins
- Lists: Last list replaces (no append)
- Maps: Deep merge

**For list appending:**

```yaml
# values.yaml
env:
  - name: VAR1
    value: value1

# values-dev.yaml
env: # This REPLACES, not appends
  - name: VAR2
    value: value2

# Solution: Use separate keys or merge manually
additionalEnv:
  - name: VAR2
    value: value2
```

---

### Issue: Helm Hooks Not Executing

**Problem:**
Pre/post-install hooks not running.

**Debugging:**

```bash
# Check hook status
helm get hooks myrelease

# View hook logs
kubectl logs job/my-hook -n namespace

# Check hook annotations
kubectl get job my-hook -n namespace -o yaml | grep helm.sh/hook
```

**Common causes:**

1. Missing `helm.sh/hook` annotation
2. Incorrect hook weight
3. Hook job failed
4. Delete policy removed job too quickly

**Solution:**

```yaml
metadata:
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
```

---

### Issue: Dependencies Not Updating

**Problem:**
Helm not pulling latest dependency versions.

**Solution:**

```bash
# Update dependencies
helm dependency update ./mychart

# Build dependencies
helm dependency build ./mychart

# Force re-download
rm -rf charts/*.tgz charts/*/
helm dependency update ./mychart
```

**Check dependency status:**

```bash
helm dependency list ./mychart
```

---

### Issue: Release Failed, Can't Delete

**Problem:**

```
Error: uninstall: Release not loaded: myrelease: release: not found
```

**Solution:**

```bash
# List all releases (including failed)
helm list --all-namespaces

# Force delete
helm delete myrelease --no-hooks

# If still stuck, delete from Kubernetes directly
kubectl delete secret sh.helm.release.v1.myrelease.v1 -n namespace
```

---

## Advanced Techniques

### Dynamic Resource Generation

**Generate multiple ConfigMaps from values:**

```yaml
{{- range $key, $value := .Values.configMaps }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "mychart.fullname" $ }}-{{ $key }}
  labels:
    {{- include "mychart.labels" $ | nindent 4 }}
data:
  {{- toYaml $value | nindent 2 }}
{{- end }}
```

**values.yaml:**

```yaml
configMaps:
  app-config:
    server.port: "8080"
    log.level: "info"
  feature-flags:
    enable_beta: "true"
    new_ui: "false"
```

---

### Conditional Dependencies

**Load dependencies based on values:**

```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    version: ~12.0.0
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
  - name: redis
    version: ~17.0.0
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
```

**values.yaml:**

```yaml
postgresql:
  enabled: true
  auth:
    password: secret

redis:
  enabled: false
```

---

### Environment-Specific Logic

```yaml
{{- if eq .Values.environment "production" }}
  replicas: {{ .Values.productionReplicas | default 3 }}
  resources:
    limits:
      cpu: 2000m
      memory: 4Gi
{{- else if eq .Values.environment "staging" }}
  replicas: {{ .Values.stagingReplicas | default 2 }}
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
{{- else }}
  replicas: 1
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
{{- end }}
```

---

### Named Templates with Parameters

```yaml
{{/*
Create environment variables with parameters
*/}}
{{- define "mychart.envVars" -}}
{{- $root := index . 0 }}
{{- $component := index . 1 }}
env:
  - name: COMPONENT
    value: {{ $component }}
  - name: ENVIRONMENT
    value: {{ $root.Values.environment }}
  - name: LOG_LEVEL
    value: {{ $root.Values.logLevel }}
{{- end }}

# Usage
{{ include "mychart.envVars" (list . "api") | nindent 8 }}
```

---

### Complex Conditionals with `and`, `or`, `not`

```yaml
{{- if and .Values.ingress.enabled .Values.ingress.tls }}
# Ingress with TLS
{{- else if and .Values.ingress.enabled (not .Values.ingress.tls) }}
# Ingress without TLS
{{- else }}
# No ingress
{{- end }}

{{- if or (eq .Values.environment "prod") (eq .Values.environment "staging") }}
# Production-like environment
{{- end }}

{{- if not .Values.debug }}
# Non-debug mode
{{- end }}
```

---

### Loop with Index

```yaml
{{- range $index, $replica := .Values.replicas }}
---
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "mychart.fullname" $ }}-{{ $index }}
  labels:
    replica-index: "{{ $index }}"
{{- end }}
```

---

### Required Values

**Force user to provide values:**

```yaml
# Fail if value not provided
{{ required "A valid .Values.database.host is required!" .Values.database.host }}

# With custom error message
{{ .Values.apiKey | required "API key must be set in values.yaml" }}
```

---

### File Inclusion

**Include external files:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "mychart.fullname" . }}-config
data:
  # Include file contents
  config.json: |
    {{ .Files.Get "files/config.json" | indent 4 }}

  # Include and template file
  templated.yaml: |
    {{ tpl (.Files.Get "files/template.yaml") . | indent 4 }}
```

---

### Glob File Patterns

```yaml
{{- range $path, $_ := .Files.Glob "config/**/*.yaml" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ printf "%s-%s" (include "mychart.fullname" $) ($path | base | trimSuffix ".yaml") }}
data:
  config.yaml: |
    {{ $.Files.Get $path | indent 4 }}
{{- end }}
```

---

### JSON Path and Base64

```yaml
# Encode to base64
{{ .Values.secret | b64enc }}

# Decode from base64
{{ .Values.encodedSecret | b64dec }}

# JSON path
{{ .Values.config | toJson }}
{{ .Values.config | toPrettyJson }}

# YAML conversion
{{ .Values.config | toYaml | nindent 2 }}
```

---

## Debugging Commands

### Template Rendering

```bash
# Render templates without installing
helm template myrelease ./mychart

# Render with values
helm template myrelease ./mychart -f values-dev.yaml

# Render specific template
helm template myrelease ./mychart -s templates/deployment.yaml

# Debug mode (shows computed values)
helm template myrelease ./mychart --debug

# Dry run (validates against cluster)
helm install myrelease ./mychart --dry-run --debug
```

### Value Inspection

```bash
# Show computed values
helm get values myrelease

# Show all values (including defaults)
helm get values myrelease --all

# Show values for specific revision
helm get values myrelease --revision 2
```

### Release Investigation

```bash
# Show release manifest
helm get manifest myrelease

# Show release hooks
helm get hooks myrelease

# Show release metadata
helm get metadata myrelease

# Show full release info
helm get all myrelease
```

### Diff Before Upgrade

```bash
# Install helm-diff plugin
helm plugin install https://github.com/databus23/helm-diff

# Show diff
helm diff upgrade myrelease ./mychart -f values-prod.yaml
```

---

## Performance Optimization

### Reduce Template Complexity

**Bad:**

```yaml
# Recalculating same helper multiple times
{{ include "mychart.fullname" . }}-deployment
{{ include "mychart.fullname" . }}-service
{{ include "mychart.fullname" . }}-configmap
```

**Good:**

```yaml
# Calculate once, use multiple times
{{- $fullname := include "mychart.fullname" . }}
{{ $fullname }}-deployment
{{ $fullname }}-service
{{ $fullname }}-configmap
```

### Cache Expensive Operations

```yaml
{{- $labels := include "mychart.labels" . | fromYaml }}
{{- $selectorLabels := include "mychart.selectorLabels" . | fromYaml }}

# Reuse cached values
labels:
  {{- toYaml $labels | nindent 4 }}
selector:
  matchLabels:
    {{- toYaml $selectorLabels | nindent 6 }}
```

---

## Security Best Practices

### Image Pull Secrets from External Secrets

```yaml
{{- if .Values.imagePullSecrets.external.enabled }}
imagePullSecrets:
  - name: {{ .Values.imagePullSecrets.external.secretName }}
{{- else if .Values.imagePullSecrets.create }}
imagePullSecrets:
  - name: {{ include "mychart.fullname" . }}-registry
{{- end }}
```

### Network Policies

```yaml
{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "mychart.fullname" . }}
spec:
  podSelector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              {{- toYaml .Values.networkPolicy.ingress.podLabels | nindent 14 }}
      ports:
        - protocol: TCP
          port: {{ .Values.service.port }}
  egress:
    {{- toYaml .Values.networkPolicy.egress | nindent 4 }}
{{- end }}
```

---

## References

- [Helm Template Language](https://helm.sh/docs/chart_template_guide/)
- [Go Template Documentation](https://pkg.go.dev/text/template)
- [Sprig Function Library](http://masterminds.github.io/sprig/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
