# TRON Metrics Reference

RMS metric naming conventions, standard labels, and PromQL patterns for TRON dashboards.

---

## Table of Contents

1. [Metric Naming Conventions](#metric-naming-conventions)
2. [Standard Labels](#standard-labels)
3. [Deployment Type Patterns](#deployment-type-patterns)
4. [Common PromQL Patterns](#common-promql-patterns)
5. [Kafka Metrics (Special Case)](#kafka-metrics-special-case)
6. [Metric Discovery](#metric-discovery)

---

## Metric Naming Conventions

### RMS Metric Structure

```
rms_<service>_<component>_<metric_type>
```

| Component | Description | Example |
|-----------|-------------|---------|
| `service` | Service name (snake_case) | `taskmetadatasvc` |
| `component` | Component or consumer name | `task_event_consumer` |
| `metric_type` | What's being measured | `read_latency`, `processed_count` |

### Task Metadata Service Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `rms_taskmetadatasvc_task_event_consumer_read_latency` | Histogram | Time to read/fetch messages from Kafka |
| `rms_taskmetadatasvc_task_event_consumer_sync_latency` | Histogram | Time to process messages |
| `rms_taskmetadatasvc_task_event_consumer_processed_count` | Counter | Number of messages processed |
| `rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count` | Counter | Messages sent to dead letter queue |
| `rms_taskmetadatasvc_task_event_consumer_event_freshness` | Histogram | Age of events when consumed |

### RQ Rules Manager Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `rq_rules_manager_consumer_read_latency` | Histogram | Time to read messages |
| `rq_rules_manager_consumer_process_latency` | Histogram | Time to process rules |
| `rq_rules_manager_consumer_processed_count` | Counter | Messages processed |
| `rq_rules_manager_consumer_dlq_submitted_count` | Counter | DLQ submissions |
| `rq_rules_manager_entity_event_consumer_*` | Various | Entity event consumer metrics |

### Stream Processor Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `rms_stream_processors_processed_count` | Counter | Stream processor message count |
| `rms_stream_processors_latency` | Histogram | Processing latency |
| `rms_stream_processors_error_count` | Counter | Processing errors |

### Metric Types

| Suffix | Prometheus Type | PromQL Pattern |
|--------|-----------------|----------------|
| `_count` | Counter | `rate(metric_count{...}[$__rate_interval])` |
| `_total` | Counter | `rate(metric_total{...}[$__rate_interval])` |
| `_latency` | Histogram | `histogram_quantile(0.99, sum by (le) (rate(metric_latency_bucket{...}[$__rate_interval])))` |
| `_bucket` | Histogram bucket | Used with `histogram_quantile()` |
| `_sum` | Histogram sum | `rate(metric_sum{...}[$__rate_interval])` |

---

## Standard Labels

### Core Labels

| Label | Description | Example Values |
|-------|-------------|----------------|
| `axon_cluster` | Environment identifier | `ag1`, `us1`, `us2`, `eu1` |
| `service` | Service name with deployment type | `taskmetadatasvc-internal`, `taskmetadatasvc-customer` |
| `instance` | Pod instance | `pod-name-abc123:8080` |
| `job` | Prometheus job name | `kubernetes-pods` |

### Consumer-Specific Labels

| Label | Description | Example Values |
|-------|-------------|----------------|
| `is_dlq` | DLQ processor flag | `"true"` (present) or absent |
| `topic` | Kafka topic | `task-events-public`, `entity-events` |
| `group` | Consumer group name | `taskmetadatasvc-task-event-consumer-internal` |
| `status` | Processing status | `success`, `fault`, `error` |

### Deployment Type in Service Label

The `service` label encodes deployment type:

```
<service_name>-<deployment_type>
```

| Pattern | Description |
|---------|-------------|
| `*-internal` | Internal/agency-facing services (lenient SLOs) |
| `*-customer` | Customer-facing services (strict SLOs) |
| `*-dlq` | DLQ processor services |

---

## Deployment Type Patterns

### Filter Tags for Queries

```python
# Internal services only
isInternalServiceTag = ', service=~".*-internal.*"'

# Customer services only
isCustomerServiceTag = ', service!~".*-internal.*"'

# Exclude DLQ processors
isNotDLQTag = ', is_dlq!="true"'

# DLQ processors only
isDLQTrueTag = ', is_dlq="true"'
```

### Combined Filters

```python
# Internal, non-DLQ
internal_non_dlq = isNotDLQTag + isInternalServiceTag
# Results in: ', is_dlq!="true", service=~".*-internal.*"'

# Customer, non-DLQ
customer_non_dlq = isNotDLQTag + isCustomerServiceTag
# Results in: ', is_dlq!="true", service!~".*-internal.*"'
```

### Template Variable Integration

```python
# Filter by template variable
deployment_filter = ', service=~"$deployment_type"'

# Where deployment_type template is:
deployment_type_template = Template(
    name="deployment_type",
    options=[
        {"text": "All", "value": ".*"},
        {"text": "Internal", "value": ".*-internal.*"},
        {"text": "Customer", "value": ".*-customer.*"},
    ],
)
```

---

## Common PromQL Patterns

### Volume (Message Count)

```promql
# Rate of messages per second
sum(rate(rms_taskmetadatasvc_task_event_consumer_processed_count{
    service=~"$deployment_type"
}[$__rate_interval]))

# Total messages over time range (for bar charts)
sum(increase(rms_taskmetadatasvc_task_event_consumer_processed_count{
    service=~"$deployment_type"
}[$__rate_interval]))
```

### Latency (Percentiles)

```promql
# p99 latency
histogram_quantile(0.99,
    sum by (le) (
        rate(rms_taskmetadatasvc_task_event_consumer_read_latency_bucket{
            is_dlq!="true",
            service=~"$deployment_type"
        }[$__rate_interval])
    )
)

# p50, p90, p99 (for latency graphs)
histogram_quantile(0.50, sum by (le) (rate(metric_bucket{...}[$__rate_interval])))
histogram_quantile(0.90, sum by (le) (rate(metric_bucket{...}[$__rate_interval])))
histogram_quantile(0.99, sum by (le) (rate(metric_bucket{...}[$__rate_interval])))
```

### Error/Fault Rate

```promql
# DLQ submission rate
sum(rate(rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count{
    is_dlq!="true"
}[$__rate_interval]))

# Error percentage (if status label exists)
sum(rate(metric_count{status="error"}[$__rate_interval]))
/
sum(rate(metric_count{}[$__rate_interval])) * 100
```

### Health Score (Normalized)

```promql
# Health score 0-100% based on lag threshold
(1 - clamp_max(
    sum(kafka_consumergroup_group_topic_sum_lag{
        group=~".*taskmetadatasvc-task-event-consumer.*"
    }) / 5000,  # 5000 = SLO threshold
    1
)) * 100
```

### Max/Min Aggregations

```promql
# Maximum latency across all instances
max(rms_taskmetadatasvc_task_event_consumer_read_latency{
    is_dlq!="true",
    service=~"$deployment_type"
})

# Convert to minutes for display
max(metric{...}) / 60000
```

### By-Group Aggregations

```promql
# Sum by consumer group
sum by (group) (
    kafka_consumergroup_group_topic_sum_lag{
        group=~".*taskmetadatasvc.*|.*rq-rules-manager.*"
    }
)

# Top 10 by value
topk(10, sum by (group) (metric{...}))
```

---

## Kafka Metrics (Special Case)

### CRITICAL: No axon_cluster Label

**Kafka exporter metrics do NOT have the `axon_cluster` label.** You cannot filter by environment using `axon_cluster=~"$axon_cluster"`.

**Solution:** Filter by explicit consumer group patterns instead.

### Kafka Consumer Group Metrics

| Metric | Description |
|--------|-------------|
| `kafka_consumergroup_group_topic_sum_lag` | Total lag for consumer group per topic |
| `kafka_consumergroup_current_offset` | Current offset of consumer group |
| `kafka_consumergroup_lag` | Lag per partition |

### Kafka Lag Queries

```promql
# Total lag for specific consumer groups
sum(kafka_consumergroup_group_topic_sum_lag{
    topic="task-events-public",
    group=~".*taskmetadatasvc-task-event-consumer.*"
})

# Lag by consumer group (for breakdown)
sum by (group) (
    kafka_consumergroup_group_topic_sum_lag{
        group=~".*taskmetadatasvc.*|.*rq-rules-manager.*"
    }
)

# Internal vs Customer lag (using group pattern)
# Internal
sum(kafka_consumergroup_group_topic_sum_lag{
    group=~".*-internal.*"
})

# Customer
sum(kafka_consumergroup_group_topic_sum_lag{
    group=~".*-customer.*"
})
```

### Consumer Group Patterns

| Service | Internal Pattern | Customer Pattern |
|---------|------------------|------------------|
| Task Metadata | `.*taskmetadatasvc-task-event-consumer-internal.*` | `.*taskmetadatasvc-task-event-consumer-customer.*` |
| RQ Rules Manager | `.*rq-rules-manager-consumer-internal.*` | `.*rq-rules-manager-consumer-customer.*` |
| Entity Events | `.*entity-event-consumer-internal.*` | `.*entity-event-consumer-customer.*` |

---

## Metric Discovery

### Finding Available Metrics

```promql
# List all RMS metrics
{__name__=~"rms_.*"}

# List all task metadata consumer metrics
{__name__=~"rms_taskmetadatasvc_task_event_consumer_.*"}

# List all metrics with specific label
{service=~".*taskmetadatasvc.*"}
```

### Checking Label Values

```promql
# Get all service values
label_values(rms_taskmetadatasvc_task_event_consumer_processed_count, service)

# Get all consumer groups
label_values(kafka_consumergroup_group_topic_sum_lag, group)

# Get all topics
label_values(kafka_consumergroup_group_topic_sum_lag, topic)
```

### Dashboard Variable Queries

```python
# Datasource query for service values
Template(
    name="service",
    query='label_values(rms_taskmetadatasvc_task_event_consumer_processed_count, service)',
    dataSource="${DataSource}",
)

# Consumer group dropdown
Template(
    name="consumer_group",
    query='label_values(kafka_consumergroup_group_topic_sum_lag, group)',
    dataSource="${DataSource}",
    regex='.*taskmetadatasvc.*|.*rq-rules-manager.*',  # Filter to TRON groups
)
```

---

## Quick Reference

### Common Filter Combinations

| Use Case | Filter |
|----------|--------|
| All services | (no filter) |
| Internal only | `service=~".*-internal.*"` |
| Customer only | `service!~".*-internal.*"` |
| Non-DLQ only | `is_dlq!="true"` |
| Specific environment | `axon_cluster=~"$axon_cluster"` |
| Kafka lag (no env filter) | `group=~".*consumer-pattern.*"` |

### Rate Interval

**Always use `$__rate_interval`** instead of hardcoded intervals:

```promql
# CORRECT
rate(metric[$__rate_interval])

# WRONG - hardcoded interval
rate(metric[5m])
```

`$__rate_interval` automatically adjusts based on Grafana's time range and scrape interval.

### Unit Conversions

| Original | Display | Conversion |
|----------|---------|------------|
| Milliseconds | Minutes | `/ 60000` |
| Milliseconds | Seconds | `/ 1000` |
| Bytes | KB/MB/GB | Use Grafana unit `bytes` |
| Per-second | Per-minute | `* 60` |
