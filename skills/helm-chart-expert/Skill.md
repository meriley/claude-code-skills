---
name: helm-chart-expert
description: Master Helm workflow orchestrator for comprehensive chart development, review, ArgoCD integration, and production deployment. Use for complex Helm tasks or when you need guidance on which Helm skill to apply.
version: 1.0.0
---

# Helm Chart Expert - Master Orchestrator

## Purpose
This skill serves as the master orchestrator for all Helm-related workflows, helping you determine which specialized Helm skill to use and providing comprehensive guidance across the entire Helm chart lifecycle.

## When to Use This Skill
- You need help with Helm but aren't sure which specific skill to use
- You're working on a complete Helm workflow (create → review → deploy)
- You need an overview of Helm best practices and capabilities
- You're planning a complex Helm implementation

## Available Helm Skills

Claude has access to four specialized Helm skills, each focused on a specific area:

### 1. helm-chart-writing
**Use when:** Creating or modifying Helm charts

**Covers:**
- Chart structure and scaffolding
- Chart.yaml configuration
- values.yaml organization
- Template helpers and patterns
- Deployment templates
- Chart validation

**Typical scenarios:**
- `helm create` a new chart
- Configure Chart.yaml metadata
- Organize values files
- Write template helpers
- Validate chart structure

---

### 2. helm-chart-review
**Use when:** Reviewing charts or preparing for release

**Covers:**
- Security review checklists
- Structure validation
- Template quality checks
- Testing requirements
- Documentation standards
- CI/CD quality gates

**Typical scenarios:**
- Review PR with chart changes
- Pre-release chart audit
- Security scanning
- Quality validation
- Production readiness check

---

### 3. helm-argocd-gitops
**Use when:** Setting up GitOps workflows

**Covers:**
- ArgoCD Application configuration
- ApplicationSets for multi-environment
- Sync policies and strategies
- Sync waves and hooks
- GitOps repository structure
- Monitoring and troubleshooting

**Typical scenarios:**
- Create ArgoCD Application
- Setup multi-environment deployment
- Configure sync policies
- Implement App of Apps pattern
- Troubleshoot sync issues

---

### 4. helm-production-patterns
**Use when:** Deploying to production

**Covers:**
- Secrets management
- Testing strategies (unit, integration)
- Blue-green deployments
- Canary releases
- Upgrade and rollback procedures
- Monitoring and observability

**Typical scenarios:**
- Configure secrets management
- Setup deployment strategies
- Implement testing
- Plan upgrades
- Configure monitoring

---

## Decision Tree: Which Skill Should You Use?

Use this decision tree to determine which skill is most appropriate:

```
Your Task:
│
├─> Creating NEW chart?
│   └─> Use: helm-chart-writing
│
├─> Reviewing EXISTING chart?
│   └─> Use: helm-chart-review
│
├─> Setting up ArgoCD/GitOps?
│   └─> Use: helm-argocd-gitops
│
├─> Deploying to PRODUCTION?
│   └─> Use: helm-production-patterns
│
└─> Not sure / Complex workflow?
    └─> Continue with this skill (helm-chart-expert)
```

## Complete Helm Workflow

For a complete Helm implementation, follow this workflow:

### Phase 1: Chart Development
**Use skill:** helm-chart-writing

```bash
# 1. Create chart structure
helm create mychart

# 2. Configure Chart.yaml and values.yaml
# (Use helm-chart-writing skill for patterns)

# 3. Validate locally
helm lint ./mychart
helm template ./mychart --debug
```

### Phase 2: Quality Assurance
**Use skill:** helm-chart-review

```bash
# 1. Run comprehensive checks
helm lint ./mychart
helm unittest ./mychart

# 2. Security scan
helm template ./mychart | kubesec scan -

# 3. Review checklists
# (Use helm-chart-review skill for checklists)
```

### Phase 3: GitOps Setup
**Use skill:** helm-argocd-gitops

```yaml
# 1. Create ArgoCD Application
# (Use helm-argocd-gitops skill for manifests)

# 2. Configure sync policies

# 3. Setup multi-environment
# (Use ApplicationSets)
```

### Phase 4: Production Deployment
**Use skill:** helm-production-patterns

```bash
# 1. Configure secrets management

# 2. Run pre-deployment checks

# 3. Deploy with safeguards
helm upgrade myrelease ./mychart \
  --wait --atomic --timeout 10m

# 4. Verify deployment
helm test myrelease
```

## Quick Reference Commands

### Chart Development
```bash
# Create chart
helm create mychart

# Validate structure
helm lint ./mychart

# Test rendering
helm template ./mychart --debug

# Dry run
helm install test ./mychart --dry-run --debug
```

### Chart Management
```bash
# Install chart
helm install myrelease ./mychart

# Upgrade chart
helm upgrade myrelease ./mychart --wait --atomic

# Rollback
helm rollback myrelease

# View history
helm history myrelease

# Uninstall
helm uninstall myrelease
```

### Testing
```bash
# Unit tests
helm unittest ./mychart

# Integration tests
helm test myrelease

# Security scan
helm template ./mychart | kubesec scan -
```

### ArgoCD
```bash
# Create application
argocd app create myapp --repo https://... --path charts/myapp

# Sync application
argocd app sync myapp

# Get status
argocd app get myapp

# View diff
argocd app diff myapp
```

## Common Patterns Quick Reference

### Security Context (Production Ready)
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
```

### Resource Limits (Production Ready)
```yaml
resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 250m
    memory: 128Mi
```

### Liveness/Readiness Probes
```yaml
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
```

## Integration: Skills Working Together

Claude can automatically use multiple Helm skills together based on your task. For example:

**Task:** "Create a new Helm chart and prepare it for production"

Claude will automatically:
1. Use **helm-chart-writing** to scaffold and configure
2. Use **helm-chart-review** to validate and audit
3. Suggest **helm-argocd-gitops** for deployment setup
4. Reference **helm-production-patterns** for production considerations

## Best Practices Summary

### Chart Writing
- ✅ Follow SemVer2 for versioning
- ✅ Document all values with comments
- ✅ Use camelCase naming
- ✅ Set secure defaults
- ✅ Truncate names to 63 characters

### Security
- ✅ Never hardcode secrets
- ✅ Use specific image tags (not :latest)
- ✅ Define restrictive security contexts
- ✅ Set resource limits
- ✅ Use RBAC with least privilege

### Production
- ✅ Implement liveness/readiness probes
- ✅ Configure pod disruption budgets
- ✅ Use rolling updates wisely
- ✅ Test in staging first
- ✅ Have rollback procedures

### GitOps
- ✅ Use ApplicationSets for multi-env
- ✅ Configure appropriate sync policies
- ✅ Use sync waves for ordering
- ✅ Implement health checks
- ✅ Monitor sync status

## Getting Help

If you're unsure which skill to use or need comprehensive help:

1. **Ask Claude directly:** "I need to [your task] with Helm"
2. **Be specific about your goal:** Creating, reviewing, deploying, troubleshooting
3. **Mention your environment:** Dev, staging, production
4. **Claude will automatically select the appropriate skill(s)**

## Resources

- [Official Helm Documentation](https://helm.sh/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**Note:** This master skill provides overview and guidance. For detailed, hands-on workflows, Claude will automatically invoke the appropriate specialized skill based on your task.
