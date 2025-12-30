# TRON Dashboard Alert Patterns

Alert annotation patterns for TRON dashboards. **This is a PRIMARY FEATURE** because alert annotations are critical for on-call triage but often done incorrectly.

---

## Table of Contents

1. [Why Service-Specific Patterns](#why-service-specific-patterns)
2. [TRON Alert Patterns](#tron-alert-patterns)
3. [Environment Filtering](#environment-filtering)
4. [Alert Annotation Configuration](#alert-annotation-configuration)
5. [Threshold Integration](#threshold-integration)
6. [Alert-Dashboard Linking](#alert-dashboard-linking)
7. [Common TRON Alert Names](#common-tron-alert-names)

---

## Why Service-Specific Patterns

### The Problem with Generic Patterns

**NEVER use generic alert patterns like:**
```python
# WRONG - matches 90+ alerts, creates solid annotation blocks
ALERT_PATTERN = ".*[Ll]ag.*"
ALERT_PATTERN = ".*[Cc]onsumer.*"
ALERT_PATTERN = ".*RMS.*"
```

**Why this is bad:**
1. Matches alerts from unrelated teams (EIS, Agency, Analytics, etc.)
2. Creates solid orange/red blocks that obscure actual data
3. Makes it impossible to identify which alerts are relevant
4. Adds noise that slows down on-call triage

### The Solution: Service-Specific Patterns

```python
# CORRECT - matches only TRON service alerts
SERVICE_ALERT_PATTERN = (
    "RMS.*TaskMetadataSvc.*|"
    "RMS.*RQ.*Rule.*Manager.*|"
    "RMS.*RuleManager.*"
)
```

**Benefits:**
- Only shows alerts for YOUR service
- Clean, sparse annotation markers
- Immediately identify when YOUR alerts fire
- Directed browsing from alert to dashboard

---

## TRON Alert Patterns

### TaskMetadataSvc Alerts

**Pattern:** `RMS.*TaskMetadataSvc.*`

**Matches:**
- `RMSTaskMetadataSvcTaskEventConsumerHighKafkaBacklog`
- `RMSTaskMetadataSvcTaskEventConsumerHighKafkaBacklogWarning`
- `RMSTaskMetadataSvcTaskEventConsumerLatencyHighWarning`
- `RMSTaskMetadataSvcTaskEventConsumerMessagesAddedToDLQ`

### RQ Rules Manager Alerts

**Pattern:** `RMS.*RQ.*Rule.*Manager.*`

**Matches:**
- `RMSRQRulesManagerConsumerHighKafkaBacklog`
- `RMSRQRulesManagerConsumerLatencyHigh`
- `RMSRQRulesManagerConsumerMessagesAddedToDLQ`
- `RMSRQRulesManagerEntityEventConsumerHighKafkaBacklog`

### Legacy RuleManager Alerts

**Pattern:** `RMS.*RuleManager.*`

**Matches:**
- `RMSRuleManagerDLQLogSizeTooLarge`
- `RMSRuleManagerConsumerHighKafkaBacklog`

### Combined Pattern

```python
SERVICE_ALERT_PATTERN = (
    "RMS.*TaskMetadataSvc.*|"      # Task metadata consumer alerts
    "RMS.*RQ.*Rule.*Manager.*|"    # RQ rules manager alerts
    "RMS.*RuleManager.*"           # Legacy rule manager alerts
)
```

---

## Environment Filtering

### Always Filter by axon_cluster

**CRITICAL:** Include `axon_cluster=~"$axon_cluster"` to show only alerts for the current environment.

```python
expr = f'ALERTS{{alertname=~"{SERVICE_ALERT_PATTERN}", alertstate="firing", axon_cluster=~"$axon_cluster"}}'
```

**Why:**
- Without this, you see alerts from ALL environments
- US1 dashboard showing AG1 alerts is confusing
- Matches the dashboard's environment context

### Full Expression

```python
alert_expr = f'''ALERTS{{
    alertname=~"{SERVICE_ALERT_PATTERN}",
    alertstate="firing",
    axon_cluster=~"$axon_cluster"
}}'''
```

---

## Alert Annotation Configuration

### Complete Implementation

```python
import grafanalib.core as G

# Service-specific alert pattern
SERVICE_ALERT_PATTERN = (
    "RMS.*TaskMetadataSvc.*|"
    "RMS.*RQ.*Rule.*Manager.*|"
    "RMS.*RuleManager.*"
)

alert_annotations = G.Annotations(
    list=[
        {
            "builtIn": 0,
            "datasource": {"type": "prometheus", "uid": "${DataSource}"},
            "enable": True,
            "expr": f'ALERTS{{alertname=~"{SERVICE_ALERT_PATTERN}", alertstate="firing", axon_cluster=~"$axon_cluster"}}',
            "hide": False,
            "iconColor": "rgba(255, 120, 50, 0.25)",  # Orange with 25% opacity
            "name": "Service Alerts",
            "titleFormat": "{{alertname}}",
            "useValueForTime": False,
        },
    ]
)

# Apply to dashboard
dashboard = GenDashboard(
    title="RMS TRON Consumer Dashboard",
    # ... other config
    annotations=alert_annotations,
)
```

### Icon Color Options

| Color | RGBA | Use For |
|-------|------|---------|
| Orange (subtle) | `rgba(255, 120, 50, 0.25)` | Default - visible but not overwhelming |
| Red (critical) | `rgba(255, 50, 50, 0.25)` | Critical alerts only |
| Blue (info) | `rgba(50, 120, 255, 0.25)` | Informational alerts |

**Best Practice:** Use 25% opacity for subtle background that doesn't obscure graph data.

### Multiple Annotation Types

```python
alert_annotations = G.Annotations(
    list=[
        # Critical alerts (more prominent)
        {
            "builtIn": 0,
            "datasource": {"type": "prometheus", "uid": "${DataSource}"},
            "enable": True,
            "expr": f'ALERTS{{alertname=~"{SERVICE_ALERT_PATTERN}", alertstate="firing", severity="critical", axon_cluster=~"$axon_cluster"}}',
            "iconColor": "rgba(255, 50, 50, 0.35)",  # Red, slightly more visible
            "name": "Critical Alerts",
            "titleFormat": "CRITICAL: {{alertname}}",
        },
        # Warning alerts (subtle)
        {
            "builtIn": 0,
            "datasource": {"type": "prometheus", "uid": "${DataSource}"},
            "enable": True,
            "expr": f'ALERTS{{alertname=~"{SERVICE_ALERT_PATTERN}", alertstate="firing", severity="warning", axon_cluster=~"$axon_cluster"}}',
            "iconColor": "rgba(255, 180, 50, 0.25)",  # Yellow/orange
            "name": "Warning Alerts",
            "titleFormat": "WARNING: {{alertname}}",
        },
    ]
)
```

---

## Threshold Integration

### Matching Graph Thresholds with Alert Thresholds

Ensure your dashboard thresholds match alert thresholds for consistency.

**Example: Kafka Lag**

```yaml
# From rms_tron_kafka_alerts.yaml
- alert: RMSTaskMetadataSvcTaskEventConsumerHighKafkaBacklog
  expr: kafka_consumergroup_group_topic_sum_lag{group=~".*taskmetadatasvc-task-event-consumer"} > 5000
  for: 5m
  labels:
    severity: warning
```

```python
# In dashboard - USE SAME THRESHOLD (5000)
CUSTOMER_LAG_CRITICAL = 5000  # Match alert threshold

health_stat(
    title="Consumer Lag",
    expr='...',
    thresholds=[
        Threshold("green", 0, 0.0),
        Threshold("orange", 1, 2500),       # 50% of alert threshold
        Threshold("red", 2, 5000),          # Match alert threshold exactly
    ],
)

timeline = AxonGraph(
    title="Kafka Lag Timeline",
    thresholds=[
        Threshold("green", 0, 0.0),
        Threshold("orange", 1, 2500),
        Threshold("red", 2, 5000),          # Match alert threshold
    ],
    thresholdsStyleMode="line+area",        # Show threshold line on graph
)
```

**Benefits:**
- When lag crosses threshold on graph, alert fires simultaneously
- Visual alignment between dashboard and alerts
- Easier to understand when investigating

---

## Alert-Dashboard Linking

### Grafana Best Practice: Directed Browsing

From Grafana docs: "Most dashboards should be linked to by alerts"

**Why:**
- On-call engineer gets paged
- Alert includes dashboard link
- Engineer lands on relevant dashboard
- Immediately sees context for the alert

### Adding Dashboard Links to Alerts

In your alert rules (rms_tron_kafka_alerts.yaml):

```yaml
- alert: RMSTaskMetadataSvcTaskEventConsumerHighKafkaBacklog
  expr: kafka_consumergroup_group_topic_sum_lag{...} > 5000
  for: 5m
  annotations:
    dashboard: https://grafana.axon.com/d/rms-tron-consumer-dashboard-v2
    runbook: https://axon.quip.com/AB9eAgqaW6rm/Task-Metadata-Service-runbook
```

### Dashboard UID for Stable Links

```python
dashboard = GenDashboard(
    title="RMS TRON Consumer Dashboard V2",
    uid="rms-tron-consumer-dashboard-v2",  # Stable UID for links
    # ...
)
```

**Note:** Use stable UIDs so alert links don't break when dashboard is modified.

---

## Common TRON Alert Names

### Task Metadata Service Alerts

| Alert Name | Severity | Condition |
|------------|----------|-----------|
| `RMSTaskMetadataSvcTaskEventConsumerHighKafkaBacklog` | warning | lag > 5000 |
| `RMSTaskMetadataSvcTaskEventConsumerHighKafkaBacklogWarning` | info | lag > 2500 |
| `RMSTaskMetadataSvcTaskEventConsumerLatencyHighWarning` | warning | latency > 5min |
| `RMSTaskMetadataSvcTaskEventConsumerMessagesAddedToDLQ` | critical | DLQ > 10 |

### RQ Rules Manager Alerts

| Alert Name | Severity | Condition |
|------------|----------|-----------|
| `RMSRQRulesManagerConsumerHighKafkaBacklog` | warning | lag > 5000 |
| `RMSRQRulesManagerConsumerLatencyHigh` | warning | latency > 5min |
| `RMSRQRulesManagerConsumerMessagesAddedToDLQ` | warning | DLQ > 20 |
| `RMSRQRulesManagerEntityEventConsumerHighKafkaBacklog` | warning | entity lag > 5000 |

### DLQ Alerts

| Alert Name | Severity | Condition |
|------------|----------|-----------|
| `RMSRuleManagerDLQLogSizeTooLarge` | warning | DLQ size > threshold |
| `RMSTaskMetadataSvcDLQTooLarge` | warning | DLQ size > threshold |

---

## Common Issues

### Issue: Alert annotations create solid blocks

**Cause:** Generic alert pattern matching too many alerts

**Diagnosis:**
```promql
# Check how many alerts match your pattern
count(ALERTS{alertname=~".*[Ll]ag.*", alertstate="firing"})
```

**Solution:** Use service-specific pattern

### Issue: Alerts not showing on dashboard

**Cause:** Missing environment filter or wrong datasource

**Solution:**
1. Check `axon_cluster=~"$axon_cluster"` is included
2. Verify datasource UID matches: `"uid": "${DataSource}"`
3. Ensure alerts are actually firing in prometheus

### Issue: Alerts from wrong environment

**Cause:** Missing `axon_cluster` filter

**Solution:** Add `axon_cluster=~"$axon_cluster"` to expression

---

## Quick Reference

```python
# Minimal alert annotation setup
import grafanalib.core as G

SERVICE_ALERT_PATTERN = (
    "RMS.*TaskMetadataSvc.*|"
    "RMS.*RQ.*Rule.*Manager.*|"
    "RMS.*RuleManager.*"
)

alert_annotations = G.Annotations(
    list=[{
        "builtIn": 0,
        "datasource": {"type": "prometheus", "uid": "${DataSource}"},
        "enable": True,
        "expr": f'ALERTS{{alertname=~"{SERVICE_ALERT_PATTERN}", alertstate="firing", axon_cluster=~"$axon_cluster"}}',
        "iconColor": "rgba(255, 120, 50, 0.25)",
        "name": "Service Alerts",
        "titleFormat": "{{alertname}}",
    }]
)
```
