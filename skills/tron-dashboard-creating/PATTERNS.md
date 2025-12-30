# TRON Dashboard Patterns

Dashboard patterns with complete code examples. Each pattern incorporates Grafana best practices.

---

## Table of Contents

1. [Health Overview Pattern](#health-overview-pattern) - KubeCon: instant triage
2. [Consumer Dashboard Pattern](#consumer-dashboard-pattern) - USE Method: saturation
3. [Latency Graph Pattern](#latency-graph-pattern) - RED Method: duration
4. [Volume Graph Pattern](#volume-graph-pattern) - RED Method: rate
5. [Kafka Lag Pattern](#kafka-lag-pattern) - USE Method: saturation
6. [HPA Replica Pattern](#hpa-replica-pattern) - KubeCon: normalization
7. [Internal vs Customer Pattern](#internal-vs-customer-pattern) - Template variables
8. [Color Conventions](#color-conventions)

---

## Health Overview Pattern

**Best Practice Source:** KubeCon blog - "Foolproof K8s Dashboards for Sleep-Deprived On-Calls"

Creates 6 stat panels + timeline for instant on-call triage.

### Complete Implementation

```python
from grafanalib.core import Threshold
from axon_helpers.graph_helpers import AxonGraph, AxonSingleStat, UNITS

# SLO Thresholds (define at top of file)
CUSTOMER_LATENCY_WARNING_MS = 120000   # 2 minutes
CUSTOMER_LATENCY_CRITICAL_MS = 300000  # 5 minutes
CUSTOMER_LAG_WARNING = 2500
CUSTOMER_LAG_CRITICAL = 5000
DLQ_WARNING = 5
DLQ_CRITICAL = 10

# Runbook and logging URLs
RUNBOOK_URL = "https://axon.quip.com/AB9eAgqaW6rm/Task-Metadata-Service-runbook"
SPLUNK_URL = "https://splunk.farm.va.main.ag1.axon.us/..."

def health_stat(title, description, expr, unit, thresholds, span=2):
    """Create a stat panel showing current metric value with thresholds.

    Links: Runbook and Splunk are appended to description.
    """
    desc_with_links = f"{description}\n\n[Runbook]({RUNBOOK_URL}) | [Splunk Logs]({SPLUNK_URL})"
    return AxonSingleStat(
        title=title,
        description=desc_with_links,
        expressions=[{"expr": expr, "legendFormat": title}],
        thresholds=thresholds,
        reduceCalc="lastNotNull",
        graphMode="area",
        format=unit,
        decimals=1,
        span=span,
    )

def generate_health_overview_panels():
    """Generate health overview panels for instant on-call triage."""
    return [
        # 1. Overall Health (percentage based on lag)
        health_stat(
            title="Overall Health",
            description="Health score 0-100%: Based on Kafka lag vs threshold",
            expr='(1 - clamp_max((sum(kafka_consumergroup_group_topic_sum_lag{topic="task-events-public",group=~"$consumer_group",group!~".*-dlq"}) or vector(0)) / ' + str(CUSTOMER_LAG_CRITICAL) + ', 1)) * 100',
            unit="percent",
            thresholds=[
                Threshold("red", 0, 0.0),
                Threshold("orange", 1, 50.0),
                Threshold("green", 2, 90.0),
            ],
        ),
        # 2. Max Latency (minutes)
        health_stat(
            title="Max Latency",
            description="Max consumer latency in minutes",
            expr='max(rms_taskmetadatasvc_task_event_consumer_read_latency{axon_cluster=~"$axon_cluster", is_dlq!="true", service=~"$deployment_type"}) / 60000',
            unit="m",
            thresholds=[
                Threshold("green", 0, 0.0),
                Threshold("orange", 1, 2.0),
                Threshold("red", 2, 5.0),
            ],
        ),
        # 3. Consumer Lag (messages)
        health_stat(
            title="Consumer Lag",
            description="Total Kafka consumer group lag (messages)",
            expr='sum(kafka_consumergroup_group_topic_sum_lag{topic="task-events-public",group=~".*taskmetadatasvc-task-event-consumer.*",group!~".*-dlq"}) or vector(0)',
            unit="short",
            thresholds=[
                Threshold("green", 0, 0.0),
                Threshold("orange", 1, float(CUSTOMER_LAG_WARNING)),
                Threshold("red", 2, float(CUSTOMER_LAG_CRITICAL)),
            ],
        ),
        # 4. DLQ Rate (5 minute window)
        health_stat(
            title="DLQ Rate (5m)",
            description="Messages sent to DLQ in last 5 minutes",
            expr='sum(increase(rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count{axon_cluster=~"$axon_cluster", service=~"$deployment_type"}[5m])) or vector(0)',
            unit="short",
            thresholds=[
                Threshold("green", 0, 0.0),
                Threshold("orange", 1, float(DLQ_WARNING)),
                Threshold("red", 2, float(DLQ_CRITICAL)),
            ],
        ),
        # 5. Throughput (messages per second)
        health_stat(
            title="Throughput",
            description="Messages processed per second",
            expr='sum(rate(rms_taskmetadatasvc_task_event_consumer_processed_count{axon_cluster=~"$axon_cluster", is_dlq!="true", service=~"$deployment_type"}[5m])) or vector(0)',
            unit="cps",
            thresholds=[
                Threshold("green", 0, 0.0),  # Any throughput is good
            ],
        ),
    ]

def generate_status_timeline_panel():
    """Generate Kafka lag timeline as a time series graph."""
    return AxonGraph(
        title="Kafka Lag Timeline",
        description=f"Kafka lag over time (lower is better)\n\n[Runbook]({RUNBOOK_URL})",
        expressions=[{
            "expr": 'sum(kafka_consumergroup_group_topic_sum_lag{topic="task-events-public",group=~".*taskmetadatasvc-task-event-consumer.*",group!~".*-dlq"})',
            "legendFormat": "Total Consumer Lag",
        }],
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, float(CUSTOMER_LAG_WARNING)),
            Threshold("red", 2, float(CUSTOMER_LAG_CRITICAL)),
        ],
        thresholdsStyleMode="line+area",
        span=12,
        unit=UNITS.SHORT,
    )

# Assemble into row
rows = {
    "Health Overview": generate_health_overview_panels() + [generate_status_timeline_panel()],
}
```

---

## Consumer Dashboard Pattern

**Best Practice Source:** USE Method - saturation (queue depth)

Use `ConsumerMetrics` class for consistent consumer dashboards.

### Complete Implementation

```python
from axon_helpers.rms_helpers import ConsumerMetrics, Query
from axon_helpers.utils import flatten

# Filter tags
isInternalServiceTag = ', service=~".*-internal.*"'
isCustomerServiceTag = ', service!~".*-internal.*"'
isNotDLQTag = ', is_dlq!="true"'

# Internal consumer section
internal_consumer_graphs = flatten(
    ConsumerMetrics(
        service_name="Task Metadata Consumer (Internal)",
        container_name="taskmetadatasvc-task-event-consumer-internal",
        consumer_group=".*taskmetadatasvc-task-event-consumer-internal",
        fetch_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_read_latency",
            additional_expressions=isNotDLQTag + isInternalServiceTag,
        ),
        process_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_sync_latency",
            additional_expressions=isNotDLQTag + isInternalServiceTag,
        ),
        completion_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_processed",
            additional_expressions=isNotDLQTag + isInternalServiceTag,
        ),
        dlq_submitted_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count",
            additional_expressions=isNotDLQTag + isInternalServiceTag,
        ),
        message_volume_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_processed_count",
            additional_expressions=isNotDLQTag + isInternalServiceTag,
        ),
    ).generate_consumer_graphs()
)

# Customer consumer section (separate row)
customer_consumer_graphs = flatten(
    ConsumerMetrics(
        service_name="Task Metadata Consumer (Customer)",
        container_name="taskmetadatasvc-task-event-consumer-customer",
        consumer_group=".*taskmetadatasvc-task-event-consumer",
        fetch_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_read_latency",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
        # ... other queries with isCustomerServiceTag
    ).generate_consumer_graphs()
)

rows = {
    "TASK Events: Task Metadata Consumer (Internal)": internal_consumer_graphs,
    "TASK Events: Task Metadata Consumer (Customer)": customer_consumer_graphs,
}
```

---

## Latency Graph Pattern

**Best Practice Source:** RED Method - Duration

Show p50/p90/p99 percentiles using histogram_quantile.

### Complete Implementation

```python
from axon_helpers.graph_helpers import AxonGraph, UNITS

def histogram_latency_graph(title, histogram_metric, perc, query_dlq_processors=False, event_type="all"):
    """Generate a latency graph for a specific percentile."""
    filters = []

    # Always filter by cluster
    filters.append('axon_cluster=~"$axon_cluster"')

    # Deployment type filter
    filters.append('service=~"$deployment_type"')

    # Event type filter
    if query_dlq_processors:
        filters.append('service=~".*dlq.*"')
    elif event_type == "task":
        filters.append('service!~".*entity.*"')
    elif event_type == "entity":
        filters.append('service=~".*entity.*"')
    else:
        filters.append('service!~".*dlq.*"')

    filter_str = ', '.join(filters)

    return AxonGraph(
        title=title,
        expressions=[{
            "expr": f'histogram_quantile({perc}, sum by (service, le) (rate({histogram_metric}{{{filter_str}}}[$__rate_interval])))',
            "legendFormat": "{{service}}",
        }],
        maxDataPoints=1000,
        span=4,
        spanNulls=True,
        unit=UNITS.SECONDS,
    )

# Generate percentile graphs
percentiles = [0.50, 0.90, 0.99]
latency_metric = "rq_rules_manager_consumer_task_event_freshness_bucket"

latency_graphs = []
for perc in percentiles:
    latency_graphs.append(
        histogram_latency_graph(
            f"Task Event Freshness ({int(perc * 100)}th percentile)",
            latency_metric,
            perc,
            event_type="task",
        )
    )
```

---

## Volume Graph Pattern

**Best Practice Source:** RED Method - Rate

Use bars for message counts with increase().

### Complete Implementation

```python
from axon_helpers.graph_helpers import AxonGraph, UNITS

def message_volume_graph(title, counter_metrics, query_dlq_processors=False, event_type="all"):
    """Generate a volume graph for message counts."""
    filters = []
    filters.append('axon_cluster=~"$axon_cluster"')
    filters.append('service=~"$deployment_type"')

    if query_dlq_processors:
        filters.append('service=~".*dlq.*"')
    elif event_type == "task":
        filters.append('service!~".*entity.*"')
    elif event_type == "entity":
        filters.append('service=~".*entity.*"')
    else:
        filters.append('service!~".*dlq.*"')

    filter_str = ', '.join(filters)

    expressions = []
    for counter_metric in counter_metrics:
        expressions.append({
            "expr": f'sum by (service) (increase({counter_metric}{{{filter_str}}}[$__rate_interval]))',
            "legendFormat": "{{service}}",
        })

    return AxonGraph(
        title=title,
        bars=True,
        lines=False,
        expressions=expressions,
        maxDataPoints=1000,
        span=4,
        spanNulls=True,
        unit=UNITS.SHORT,
    )

# Usage
volume_graph = message_volume_graph(
    "Task Messages Successfully Processed",
    ["rq_rules_manager_consumer_task_event_evaluation_latency_count"],
    event_type="task",
)
```

---

## Kafka Lag Pattern

**Best Practice Source:** USE Method - Saturation

**Important:** Kafka metrics don't have `axon_cluster` label - use explicit group patterns.

### Complete Implementation

```python
from axon_helpers.graph_helpers import AxonGraph

def consumer_group_lag_graph(query_dlq_processors=False, event_type="all"):
    """Generate consumer group lag graph.

    Note: Kafka metrics come from Kafka exporter, NOT app metrics.
    They don't have axon_cluster label, so we use group patterns.
    """
    filters = []

    # Consumer group filter (uses template variable)
    filters.append('group=~"$consumer_group"')

    # Topic filter based on event type
    if query_dlq_processors:
        filters.append('topic=~"rq-rules-manager-dlq|rq-rules-manager-entity-event-dlq"')
    elif event_type == "task":
        filters.append('topic="task-events-public"')
    elif event_type == "entity":
        filters.append('topic="entity-events-public"')
    else:
        filters.append('topic=~"task-events-public|entity-events-public"')

    filter_str = ', '.join(filters)

    return AxonGraph(
        title="Consumer Group Lag",
        expressions=[{
            "expr": f"sum by (group) (kafka_consumergroup_group_topic_sum_lag{{ {filter_str}}})",
            "legendFormat": "{{group}}",
        }],
        lines=True,
        type="count",
    )
```

---

## HPA Replica Pattern

**Best Practice Source:** KubeCon blog - normalization

Track HPA current/desired/min/max replicas.

### Complete Implementation

```python
from axon_helpers.graph_helpers import AxonGraph, UNITS

def consumer_replica_graph(consumer_name, hpa_name):
    """Generate pod replica count graph for a consumer with HPA.

    Note: HPA names include deployment type suffix (e.g., -internal, -customer).
    """
    # Filter that respects deployment_type dropdown
    hpa_filter = f'horizontalpodautoscaler="{hpa_name}",horizontalpodautoscaler=~"$deployment_type"'

    return AxonGraph(
        title=f"{consumer_name} Replicas",
        bars=False,
        lines=True,
        expressions=[
            {
                "expr": f'sum(kube_horizontalpodautoscaler_status_current_replicas{{axon_cluster=~"$axon_cluster",{hpa_filter}}})',
                "legendFormat": "Current",
            },
            {
                "expr": f'sum(kube_horizontalpodautoscaler_status_desired_replicas{{axon_cluster=~"$axon_cluster",{hpa_filter}}})',
                "legendFormat": "Desired",
            },
            {
                "expr": f'sum(kube_horizontalpodautoscaler_spec_min_replicas{{axon_cluster=~"$axon_cluster",{hpa_filter}}})',
                "legendFormat": "Min",
            },
            {
                "expr": f'sum(kube_horizontalpodautoscaler_spec_max_replicas{{axon_cluster=~"$axon_cluster",{hpa_filter}}})',
                "legendFormat": "Max",
            },
        ],
        span=4,
        spanNulls=True,
        unit=UNITS.SHORT,
    )

# Usage
replica_panels = [
    consumer_replica_graph("RQ Rules Manager Consumer (Internal)", "rq-rules-manager-consumer-internal"),
    consumer_replica_graph("RQ Rules Manager Consumer (Customer)", "rq-rules-manager-consumer-customer"),
    consumer_replica_graph("Task Metadata Consumer (Internal)", "taskmetadatasvc-task-event-consumer-internal"),
    consumer_replica_graph("Task Metadata Consumer (Customer)", "taskmetadatasvc-task-event-consumer-customer"),
]
```

---

## Internal vs Customer Pattern

**Best Practice Source:** Grafana docs - Template variables prevent dashboard sprawl

### Template Variable Setup

```python
from grafanalib.core import Template

deployment_type_template = Template(
    name="deployment_type",
    label="Deployment Type",
    type="custom",
    default="All",
    includeAll=False,
    query="All : .*,Internal : .*-internal.*,Customer : .*-customer.*",
    options=[
        {"selected": True, "text": "All", "value": ".*"},
        {"selected": False, "text": "Internal", "value": ".*-internal.*"},
        {"selected": False, "text": "Customer", "value": ".*-customer.*"},
    ],
)
```

### Filter Tags

```python
# Use in Query additional_expressions
isInternalServiceTag = ', service=~".*-internal.*"'
isCustomerServiceTag = ', service!~".*-internal.*"'

# Use in PromQL filter strings
filters.append('service=~"$deployment_type"')
```

### Separate Rows (Preferred)

```python
rows = {
    # Separate rows for internal and customer - cleaner, no overlap
    "TASK Events: Task Metadata Consumer (Internal)": internal_graphs,
    "TASK Events: Task Metadata Consumer (Customer)": customer_graphs,
}
```

---

## Color Conventions

**Best Practice Source:** Grafana docs + 3 Tips blog

### Standard Color Scheme

| Status | Color | Threshold Usage |
|--------|-------|-----------------|
| Healthy/Success | Green | 0% - 50% of limit |
| Warning | Orange | 50% - 80% of limit |
| Critical/Error | Red | 80%+ of limit |

### Threshold Examples

```python
from grafanalib.core import Threshold

# For metrics where lower is better (lag, latency)
lower_is_better = [
    Threshold("green", 0, 0.0),      # 0-2500: green
    Threshold("orange", 1, 2500),    # 2500-5000: orange
    Threshold("red", 2, 5000),       # 5000+: red
]

# For health percentages (higher is better)
higher_is_better = [
    Threshold("red", 0, 0.0),        # 0-50%: red
    Threshold("orange", 1, 50.0),    # 50-90%: orange
    Threshold("green", 2, 90.0),     # 90%+: green
]

# For throughput (any is good)
throughput_thresholds = [
    Threshold("green", 0, 0.0),      # Any throughput is fine
]
```

### Series Override Colors

```python
seriesOverrides=[
    # Faults in red
    {
        "matcher": {"id": "byName", "options": "fault"},
        "properties": [{"id": "color", "value": {"fixedColor": "red", "mode": "fixed"}}],
    },
    # Errors in gray (less severe than faults)
    {
        "matcher": {"id": "byName", "options": "error"},
        "properties": [{"id": "color", "value": {"fixedColor": "rgba(82, 90, 80, 1)", "mode": "fixed"}}],
    },
]
```

### Accessibility Note

From 3 Tips blog: "Approximately 8% of men experience color blindness."

**Best Practice:**
- Always include numeric values (not just colors)
- Use threshold markers on graphs
- Consider using patterns/labels alongside colors
