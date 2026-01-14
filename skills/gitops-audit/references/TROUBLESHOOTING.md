# GitOps Audit Troubleshooting

Common issues, solutions, and test scenarios for gitops-audit skill.

## Common Issues & Solutions

### Issue: Too Many False Positives

**Symptom:** Audit reports drift for resources that shouldn't be in git

**Solution:**

- Update `exclude_resource_types` configuration
- Add namespaces to `exclude_namespaces`
- Document exceptions in configuration

**Example Configuration:**

```yaml
exclude_resource_types:
  - Event
  - EndpointSlice
  - Lease
  - Pod # Pods are ephemeral, managed by Deployments

exclude_namespaces:
  - kube-system
  - kube-public
  - monitoring # Third-party tools manage their own resources
```

---

### Issue: Operator Resources Flagged

**Symptom:** Operator-created resources flagged as hardcoded violations

**Solution:**

- Add operator paths to `allowed_hardcoded` configuration
- Verify operator CRDs are in git
- Document operator patterns

**Example Configuration:**

```yaml
allowed_hardcoded:
  - pattern: "src/operator/**/*.go"
    reason: "Kubernetes operators create resources dynamically"
  - pattern: "pkg/controller/**/*.go"
    reason: "Controller reconciliation logic"
```

**Verification Checklist:**

- [ ] Operator CRD is tracked in GitOps repo
- [ ] Operator deployment manifest is in git
- [ ] Operator creates resources from CRs (not hardcoded)
- [ ] Operator has proper RBAC for resource creation

---

### Issue: Test Resources Flagged

**Symptom:** Test fixtures and E2E setup code flagged

**Solution:**

- Add test paths to `code_scan_exclude`
- Add test patterns to `allowed_hardcoded`
- Clearly separate test code from production code

**Example Configuration:**

```yaml
code_scan_exclude:
  - tests/
  - e2e/
  - **/*_test.go
  - **/*_test.py
  - **/*.test.ts

allowed_hardcoded:
  - pattern: "tests/**/*"
    reason: "Test fixtures and setup code"
  - pattern: "e2e/**/*"
    reason: "E2E test setup"
```

---

### Issue: Slow Audit Performance

**Symptom:** Audit takes too long on large clusters

**Solutions:**

1. **Limit namespaces in configuration:**

   ```yaml
   namespaces:
     - production # Only audit critical namespaces
     - staging
   ```

2. **Exclude resource types you don't care about:**

   ```yaml
   exclude_resource_types:
     - Event
     - EndpointSlice
     - Pod
     - ReplicaSet # Managed by Deployments
   ```

3. **Run checks separately:**

   ```bash
   /gitops-audit --check cluster-drift  # Fast check
   /gitops-audit --check spec-drift     # Slower check
   /gitops-audit --check code-violations  # Separate scan
   ```

4. **Use namespace filtering:**
   ```bash
   /gitops-audit --namespace production
   ```

---

### Issue: HPA/VPA Managed Resources Show Drift

**Symptom:** Resources managed by HPA/VPA constantly show replica drift

**Solution:**

Add exceptions for auto-scaled resources:

```yaml
allowed_exceptions:
  - resource: "Deployment/*"
    namespace: "production"
    field: "spec.replicas"
    reason: "Auto-scaled by HPA, drift expected"

  - resource: "Deployment/api-service"
    namespace: "production"
    field: "spec.template.spec.containers[*].resources"
    reason: "Managed by VPA"
    expires: "2024-12-31" # Review annually
```

**Alternative:** Omit replicas from Deployment manifests when using HPA

---

### Issue: ArgoCD/Flux Managed Annotations Flagged

**Symptom:** Sync annotations added by ArgoCD/Flux show as drift

**Solution:**

Ignore GitOps tool annotations:

```yaml
ignore_annotations:
  - argocd.argoproj.io/*
  - flux.weave.works/*
  - kubectl.kubernetes.io/last-applied-configuration
```

---

### Issue: Secrets Content Drift (SealedSecrets/ExternalSecrets)

**Symptom:** Secrets managed by SealedSecrets or ExternalSecrets show drift

**Solution:**

1. **Exclude Secrets from spec drift:**

   ```yaml
   exclude_resource_types:
     - Secret # Managed externally
   ```

2. **Verify SealedSecret/ExternalSecret manifests ARE in git:**
   - Check for SealedSecret resources
   - Check for ExternalSecret resources
   - Ensure Secret creation mechanism is tracked

3. **Focus on the management resources:**
   ```yaml
   track_resource_types:
     - SealedSecret
     - ExternalSecret
     - ClusterSecretStore
   ```

---

### Issue: CRDs Not Detected

**Symptom:** Custom Resource Definitions not being audited

**Solution:**

1. **Ensure CRDs are in GitOps repo:**

   ```bash
   find gitops-repo -name "*crd*.yaml"
   ```

2. **Include CRDs in resource type list:**

   ```yaml
   track_resource_types:
     - CustomResourceDefinition
     - YourCustomResource
   ```

3. **Check kubectl can access CRDs:**
   ```bash
   kubectl get crds
   kubectl api-resources | grep <your-crd>
   ```

---

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

---

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

---

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

---

## Edge Cases

### Edge Case 1: Multi-Cluster Environments

**Challenge:** Auditing multiple clusters with shared GitOps repo

**Approach:**

1. Run audit per-cluster with context:

   ```bash
   /gitops-audit --cluster production-us-west
   /gitops-audit --cluster production-eu-central
   ```

2. Use cluster-specific value files:
   ```yaml
   gitops_repos:
     - path: /path/to/gitops-repo
       clusters:
         - name: prod-us-west
           values: values-prod-us-west.yaml
         - name: prod-eu
           values: values-prod-eu.yaml
   ```

---

### Edge Case 2: Blue-Green Deployments

**Challenge:** Temporary drift during blue-green switchover

**Approach:**

1. Document blue-green pattern:

   ```yaml
   allowed_exceptions:
     - pattern: "Deployment/*-blue"
       reason: "Blue-green deployment, temporary duplicate"
       max_age: "1h" # Alert if older than 1 hour
   ```

2. Audit before and after switchover:

   ```bash
   # Before switchover
   /gitops-audit

   # After switchover (should be clean)
   /gitops-audit --expect-clean
   ```

---

### Edge Case 3: Canary Deployments with Progressive Delivery

**Challenge:** Argo Rollouts/Flagger create temporary resources

**Approach:**

1. Exclude progressive delivery resources:

   ```yaml
   exclude_resource_types:
     - Rollout
     - Canary
     - AnalysisRun
     - AnalysisTemplate
   ```

2. Verify base manifests are in git:
   - Rollout definition (in git)
   - Service mesh config (in git)
   - Analysis templates (in git)

---

### Edge Case 4: Disaster Recovery Testing

**Challenge:** DR tests create out-of-band resources

**Approach:**

1. Use dedicated DR namespace:

   ```yaml
   exclude_namespaces:
     - disaster-recovery-test
   ```

2. Or run audit with DR mode:

   ```bash
   /gitops-audit --mode dr-test --expect-drift
   ```

3. Document and clean up after test:
   ```bash
   # After DR test
   kubectl delete namespace disaster-recovery-test
   /gitops-audit  # Verify cleanup
   ```

---

## Best Practices for Debugging

### 1. Verbose Mode

Run audit with detailed output:

```bash
/gitops-audit --verbose
```

**Provides:**

- Full kubectl commands executed
- Git search paths checked
- Resources scanned count
- Excluded resources list

---

### 2. Dry Run Mode

Preview what audit will check:

```bash
/gitops-audit --dry-run
```

**Shows:**

- Namespaces to be audited
- Resource types to be checked
- Git repositories to be searched
- No actual audit performed

---

### 3. Single Resource Debug

Audit specific resource:

```bash
/gitops-audit --resource Deployment/api-service --namespace production
```

**Useful for:**

- Investigating specific drift
- Testing configuration changes
- Focused troubleshooting

---

### 4. Compare Git Branches

Audit against different git branch:

```bash
/gitops-audit --git-branch feature/new-config
```

**Use case:**

- Preview drift before merging
- Validate feature branch configuration
- Test configuration changes
