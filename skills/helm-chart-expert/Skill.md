---
name: Helm Chart Expert
description: Comprehensive guide for writing production-ready Helm charts and conducting thorough chart reviews. Covers ArgoCD integration, GitOps workflows, security best practices, and deployment patterns.
version: 1.0.0
---

# ⚠️ MANDATORY: Helm Chart Expert Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Creating new Helm charts for services
2. Reviewing existing Helm charts
3. Setting up ArgoCD integration
4. Implementing GitOps workflows
5. Preparing charts for production deployment

**This skill is MANDATORY because:**
- Ensures charts are production-ready (CRITICAL)
- Prevents common Helm mistakes and anti-patterns
- Enforces security best practices
- Enables consistent GitOps workflows
- Reduces deployment issues

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Missing security controls (RBAC, network policies, secrets management)
- Hardcoded credentials or secrets
- Missing resource limits
- No health checks or readiness probes
- Insecure default configurations

**P1 Violations (High - Quality Failure):**
- Missing input validation for values
- Incomplete error handling
- Poor documentation
- Missing monitoring/observability setup
- No backup/restore strategy

**P2 Violations (Medium - Efficiency Loss):**
- Inconsistent naming conventions
- Unclear value descriptions
- Missing examples

**Blocking Conditions:**
- Charts must be validated before use (helm lint)
- All security requirements must be met
- Resource limits must be set
- Health checks must be configured

---

## Purpose

Comprehensive guide for writing production-ready Helm charts and conducting thorough chart reviews. Covers ArgoCD integration, GitOps workflows, security best practices, and deployment patterns.

## Core Requirements

### Chart Structure
```
chart-name/
├── Chart.yaml
├── values.yaml
├── values-prod.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── ingress.yaml
│   ├── serviceaccount.yaml
│   ├── role.yaml
│   ├── rolebinding.yaml
│   └── _helpers.tpl
├── tests/
│   └── helm-test.yaml
└── README.md
```

### Required Configuration
- RBAC (ServiceAccount, Role, RoleBinding)
- Resource limits (CPU, memory)
- Health checks (liveness, readiness probes)
- Security context (runAsNonRoot, read-only filesystem)
- Network policies
- PodDisruptionBudget
- Monitoring (ServiceMonitor)
- Secrets management

### Values Best Practices
- Explicit default values
- Detailed descriptions for each value
- Environment-specific overrides
- No hardcoded credentials
- Input validation helpers

## Helm Lint Checklist

```bash
helm lint chart-name
helm template chart-name
helm lint chart-name --strict
```

Must pass:
- ✅ Syntax validation
- ✅ Schema validation
- ✅ Template rendering
- ✅ No hardcoded values
- ✅ Required fields present

## ArgoCD Integration

- Application CRD setup
- ApplicationSet for multi-env
- Sync policies
- Health assessment rules
- Notification configuration

## Testing Strategy

- helm template validation
- helm lint strict mode
- Unit tests (helm-unittest)
- Integration tests (real cluster)
- Smoke tests post-deployment

## Security Checklist

- ✅ RBAC properly configured
- ✅ No hardcoded secrets
- ✅ Network policies defined
- ✅ Pod security policies
- ✅ Resource limits set
- ✅ Security context configured
- ✅ Service account with minimal permissions

## Anti-Patterns

### ❌ Anti-Pattern: Hardcoded Secrets

**Wrong:**
```yaml
env:
- name: DATABASE_PASSWORD
  value: "secret123" # ❌ Hardcoded!
```

**Correct:**
```yaml
env:
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "app.fullname" . }}-db-secret
      key: password
```

---

## Integration Points

Used for:
- Production Kubernetes deployments
- GitOps workflows with ArgoCD
- Multi-environment configuration management

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - helm-chart-expert)
- Helm best practices
- CNCF guidelines

**Related skills:**
- `quality-check` - Can validate Helm charts
