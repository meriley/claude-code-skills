# TRON Dashboard Examples

Complete, production-ready examples for TRON Grafana dashboards.

---

## Table of Contents

1. [Complete Consumer Dashboard](#complete-consumer-dashboard)
2. [Health Overview Only Dashboard](#health-overview-only-dashboard)
3. [Task Metadata Consumer Section](#task-metadata-consumer-section)
4. [Alert Annotation Example](#alert-annotation-example)
5. [Minimal Starter Dashboard](#minimal-starter-dashboard)

---

## Complete Consumer Dashboard

A full-featured TRON consumer dashboard with health overview, Kafka infrastructure, and consumer-specific sections.

```python
"""
RMS TRON Consumer Dashboard V2

Health overview for on-call triage with detailed consumer metrics.
"""
from grafanalib.core import Template, Threshold, Templating
import grafanalib.core as G

from axon_helpers.graph_helpers import (
    AxonGraph,
    AxonSingleStat,
    AxonBarGauge,
    GenDashboard,
    UNITS,
)
from axon_helpers.rms_helpers import (
    ConsumerMetrics,
    Query,
    generate_dashboard_template_values,
)
from axon_helpers.utils import flatten

# =============================================================================
# CONSTANTS - SLO Thresholds (match alert thresholds)
# =============================================================================
CUSTOMER_LATENCY_WARNING_MS = 120000   # 2 minutes
CUSTOMER_LATENCY_CRITICAL_MS = 300000  # 5 minutes
CUSTOMER_LAG_WARNING = 2500
CUSTOMER_LAG_CRITICAL = 5000
DLQ_WARNING = 5
DLQ_CRITICAL = 10

# Filter tags for deployment types
isInternalServiceTag = ', service=~".*-internal.*"'
isCustomerServiceTag = ', service!~".*-internal.*"'
isNotDLQTag = ', is_dlq!="true"'
isDLQTrueTag = ', is_dlq="true"'

# Service-specific alert pattern (NOT generic)
SERVICE_ALERT_PATTERN = (
    "RMS.*TaskMetadataSvc.*|"
    "RMS.*RQ.*Rule.*Manager.*|"
    "RMS.*RuleManager.*"
)

# =============================================================================
# TEMPLATE VARIABLES
# =============================================================================
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

consumer_group_template = Template(
    name="consumer_group",
    label="Consumer Group",
    type="custom",
    default="All",
    includeAll=False,
    query="All,Task Metadata,RQ Rules Manager",
    options=[
        {"selected": True, "text": "All", "value": ".*"},
        {"selected": False, "text": "Task Metadata", "value": ".*taskmetadatasvc-task-event-consumer.*"},
        {"selected": False, "text": "RQ Rules Manager", "value": ".*rq-rules-manager-consumer.*"},
    ],
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
def health_stat(title, description, expr, unit, thresholds, span=2):
    """Create a stat panel for health overview."""
    return AxonSingleStat(
        title=title,
        description=description,
        expressions=[{"expr": expr, "legendFormat": title}],
        thresholds=thresholds,
        reduceCalc="lastNotNull",
        graphMode="area",
        format=unit,
        decimals=1,
        span=span,
    )


def histogram_latency_graph(title, metric_name, additional_filters="", span=4):
    """Create a latency graph with p50/p90/p99 percentiles."""
    base_filter = f'{{axon_cluster=~"$axon_cluster"{additional_filters}}}'
    return AxonGraph(
        title=title,
        expressions=[
            {
                "expr": f'histogram_quantile(0.50, sum by (le) (rate({metric_name}_bucket{base_filter}[$__rate_interval])))',
                "legendFormat": "p50",
            },
            {
                "expr": f'histogram_quantile(0.90, sum by (le) (rate({metric_name}_bucket{base_filter}[$__rate_interval])))',
                "legendFormat": "p90",
            },
            {
                "expr": f'histogram_quantile(0.99, sum by (le) (rate({metric_name}_bucket{base_filter}[$__rate_interval])))',
                "legendFormat": "p99",
            },
        ],
        unit=UNITS.SECONDS,
        span=span,
        spanNulls=True,
    )


def consumer_group_lag_graph(title, group_pattern, span=6):
    """Create a Kafka lag graph for consumer groups."""
    return AxonGraph(
        title=title,
        expressions=[{
            "expr": f'sum by (group) (kafka_consumergroup_group_topic_sum_lag{{group=~"{group_pattern}"}})',
            "legendFormat": "{{group}}",
        }],
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, float(CUSTOMER_LAG_WARNING)),
            Threshold("red", 2, float(CUSTOMER_LAG_CRITICAL)),
        ],
        thresholdsStyleMode="line+area",
        unit=UNITS.SHORT,
        span=span,
    )

# =============================================================================
# ALERT ANNOTATIONS
# =============================================================================
alert_annotations = G.Annotations(
    list=[
        {
            "builtIn": 0,
            "datasource": {"type": "prometheus", "uid": "${DataSource}"},
            "enable": True,
            "expr": f'ALERTS{{alertname=~"{SERVICE_ALERT_PATTERN}", alertstate="firing", axon_cluster=~"$axon_cluster"}}',
            "hide": False,
            "iconColor": "rgba(255, 120, 50, 0.25)",
            "name": "Service Alerts",
            "titleFormat": "{{alertname}}",
            "useValueForTime": False,
        },
    ]
)

# =============================================================================
# HEALTH OVERVIEW PANELS
# =============================================================================
health_panels = [
    # Overall Health Score
    health_stat(
        title="Overall Health",
        description="Health score 0-100% based on Kafka lag relative to SLO threshold",
        expr=f'''(1 - clamp_max(
            sum(kafka_consumergroup_group_topic_sum_lag{{
                topic="task-events-public",
                group=~".*taskmetadatasvc-task-event-consumer.*"
            }}) / {CUSTOMER_LAG_CRITICAL},
            1
        )) * 100''',
        unit="percent",
        thresholds=[
            Threshold("red", 0, 0.0),
            Threshold("orange", 1, 50.0),
            Threshold("green", 2, 90.0),
        ],
    ),
    # Max Latency
    health_stat(
        title="Max Latency",
        description="Maximum consumer latency in minutes",
        expr=f'''max(rms_taskmetadatasvc_task_event_consumer_read_latency{{
            axon_cluster=~"$axon_cluster",
            is_dlq!="true",
            service=~"$deployment_type"
        }}) / 60000''',
        unit="m",
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, 2.0),
            Threshold("red", 2, 5.0),
        ],
    ),
    # Consumer Lag
    health_stat(
        title="Consumer Lag",
        description="Total Kafka consumer lag (messages behind)",
        expr='''sum(kafka_consumergroup_group_topic_sum_lag{
            topic="task-events-public",
            group=~".*taskmetadatasvc-task-event-consumer.*"
        })''',
        unit="short",
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, float(CUSTOMER_LAG_WARNING)),
            Threshold("red", 2, float(CUSTOMER_LAG_CRITICAL)),
        ],
    ),
    # DLQ Rate
    health_stat(
        title="DLQ Rate",
        description="Messages sent to Dead Letter Queue per minute",
        expr=f'''sum(rate(rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count{{
            axon_cluster=~"$axon_cluster",
            is_dlq!="true"
        }}[$__rate_interval])) * 60''',
        unit="short",
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, float(DLQ_WARNING)),
            Threshold("red", 2, float(DLQ_CRITICAL)),
        ],
    ),
    # Throughput
    health_stat(
        title="Throughput",
        description="Messages processed per second",
        expr=f'''sum(rate(rms_taskmetadatasvc_task_event_consumer_processed_count{{
            axon_cluster=~"$axon_cluster",
            is_dlq!="true"
        }}[$__rate_interval]))''',
        unit="cps",
        thresholds=[
            Threshold("red", 0, 0.0),
            Threshold("orange", 1, 10.0),
            Threshold("green", 2, 100.0),
        ],
    ),
    # Active Pods
    health_stat(
        title="Active Pods",
        description="Number of running consumer pods",
        expr='''count(up{
            job="kubernetes-pods",
            container=~".*taskmetadatasvc-task-event-consumer.*"
        } == 1)''',
        unit="short",
        thresholds=[
            Threshold("red", 0, 0.0),
            Threshold("orange", 1, 1.0),
            Threshold("green", 2, 2.0),
        ],
    ),
]

# Timeline graph for health overview
health_timeline = AxonGraph(
    title="Kafka Lag Timeline",
    description="Historical view of consumer lag with SLO thresholds",
    expressions=[{
        "expr": '''sum(kafka_consumergroup_group_topic_sum_lag{
            topic="task-events-public",
            group=~".*taskmetadatasvc-task-event-consumer.*"
        })''',
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

# =============================================================================
# KAFKA INFRASTRUCTURE PANELS
# =============================================================================
kafka_panels = [
    consumer_group_lag_graph(
        title="Consumer Group Lag",
        group_pattern=".*taskmetadatasvc.*|.*rq-rules-manager.*",
        span=6,
    ),
    AxonBarGauge(
        title="Top 10 Consumer Groups by Lag",
        expressions=[{
            "expr": '''topk(10, sum by (group) (
                kafka_consumergroup_group_topic_sum_lag{
                    group=~".*taskmetadatasvc.*|.*rq-rules-manager.*"
                }
            ))''',
            "legendFormat": "{{group}}",
        }],
        orientation="horizontal",
        displayMode="lcd",
        span=6,
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, float(CUSTOMER_LAG_WARNING)),
            Threshold("red", 2, float(CUSTOMER_LAG_CRITICAL)),
        ],
    ),
]

# =============================================================================
# CONSUMER SECTIONS (Using ConsumerMetrics)
# =============================================================================
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

customer_consumer_graphs = flatten(
    ConsumerMetrics(
        service_name="Task Metadata Consumer (Customer)",
        container_name="taskmetadatasvc-task-event-consumer-customer",
        consumer_group=".*taskmetadatasvc-task-event-consumer-customer",
        fetch_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_read_latency",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
        process_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_sync_latency",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
        dlq_submitted_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
        message_volume_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_processed_count",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
    ).generate_consumer_graphs()
)

# =============================================================================
# DASHBOARD ASSEMBLY
# =============================================================================
rows = {
    # TIER 1: Health Overview - NOT collapsed (on-call triage)
    "Health Overview": health_panels + [health_timeline],

    # TIER 2: Infrastructure - Collapsed by default
    "Overview: Kafka Infrastructure": kafka_panels,

    # TIER 3: Service-specific - Collapsed by default
    "TASK Events: Task Metadata Consumer (Internal)": internal_consumer_graphs,
    "TASK Events: Task Metadata Consumer (Customer)": customer_consumer_graphs,
}

dashboard = GenDashboard(
    title="RMS TRON Consumer Dashboard V2",
    uid="rms-tron-consumer-dashboard-v2",
    templating=generate_dashboard_template_values(
        additional_templates_list=[deployment_type_template, consumer_group_template]
    ),
    rows=rows,
    rows_to_collapse_by_title={
        "Overview: Kafka Infrastructure",
        "TASK Events: Task Metadata Consumer (Internal)",
        "TASK Events: Task Metadata Consumer (Customer)",
    },
    annotations=alert_annotations,
    tags=["rms", "tron", "consumer", "kafka"],
)
```

---

## Health Overview Only Dashboard

A minimal dashboard focused on on-call triage - just health stats and timeline.

```python
"""
RMS TRON Health Dashboard

Minimal dashboard for quick on-call triage.
"""
from grafanalib.core import Threshold
import grafanalib.core as G

from axon_helpers.graph_helpers import AxonGraph, AxonSingleStat, GenDashboard, UNITS
from axon_helpers.rms_helpers import generate_dashboard_template_values

# SLO Thresholds
LAG_WARNING = 2500
LAG_CRITICAL = 5000

def health_stat(title, expr, unit, thresholds, span=2):
    return AxonSingleStat(
        title=title,
        expressions=[{"expr": expr}],
        thresholds=thresholds,
        reduceCalc="lastNotNull",
        graphMode="area",
        format=unit,
        span=span,
    )

health_panels = [
    health_stat(
        title="Health Score",
        expr=f'(1 - clamp_max(sum(kafka_consumergroup_group_topic_sum_lag{{group=~".*taskmetadatasvc.*"}}) / {LAG_CRITICAL}, 1)) * 100',
        unit="percent",
        thresholds=[
            Threshold("red", 0, 0.0),
            Threshold("orange", 1, 50.0),
            Threshold("green", 2, 90.0),
        ],
    ),
    health_stat(
        title="Consumer Lag",
        expr='sum(kafka_consumergroup_group_topic_sum_lag{group=~".*taskmetadatasvc.*"})',
        unit="short",
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, LAG_WARNING),
            Threshold("red", 2, LAG_CRITICAL),
        ],
    ),
    health_stat(
        title="DLQ Rate",
        expr='sum(rate(rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count{is_dlq!="true"}[$__rate_interval])) * 60',
        unit="short",
        thresholds=[
            Threshold("green", 0, 0.0),
            Threshold("orange", 1, 5.0),
            Threshold("red", 2, 10.0),
        ],
    ),
]

timeline = AxonGraph(
    title="Lag Timeline",
    expressions=[{
        "expr": 'sum(kafka_consumergroup_group_topic_sum_lag{group=~".*taskmetadatasvc.*"})',
        "legendFormat": "Total Lag",
    }],
    thresholds=[
        Threshold("green", 0, 0.0),
        Threshold("orange", 1, LAG_WARNING),
        Threshold("red", 2, LAG_CRITICAL),
    ],
    thresholdsStyleMode="line+area",
    span=12,
    unit=UNITS.SHORT,
)

dashboard = GenDashboard(
    title="RMS TRON Health Dashboard",
    uid="rms-tron-health",
    templating=generate_dashboard_template_values(),
    rows={"Health Overview": health_panels + [timeline]},
)
```

---

## Task Metadata Consumer Section

Standalone section for Task Metadata Consumer with internal/customer split.

```python
"""
Task Metadata Consumer section using ConsumerMetrics class.
"""
from axon_helpers.rms_helpers import ConsumerMetrics, Query
from axon_helpers.utils import flatten

# Filter tags
isInternalServiceTag = ', service=~".*-internal.*"'
isCustomerServiceTag = ', service!~".*-internal.*"'
isNotDLQTag = ', is_dlq!="true"'

# Internal Consumer
internal_graphs = flatten(
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

# Customer Consumer
customer_graphs = flatten(
    ConsumerMetrics(
        service_name="Task Metadata Consumer (Customer)",
        container_name="taskmetadatasvc-task-event-consumer-customer",
        consumer_group=".*taskmetadatasvc-task-event-consumer-customer",
        fetch_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_read_latency",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
        process_latency_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_sync_latency",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
        dlq_submitted_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
        message_volume_query=Query(
            "rms_taskmetadatasvc_task_event_consumer_processed_count",
            additional_expressions=isNotDLQTag + isCustomerServiceTag,
        ),
    ).generate_consumer_graphs()
)

# Add to dashboard rows
rows = {
    "Task Metadata Consumer (Internal)": internal_graphs,
    "Task Metadata Consumer (Customer)": customer_graphs,
}
```

---

## Alert Annotation Example

Complete example of service-specific alert annotations.

```python
"""
Alert Annotation Configuration

CRITICAL: Use service-specific patterns, NOT generic patterns.
"""
import grafanalib.core as G

# =============================================================================
# WRONG - Generic patterns match 90+ alerts
# =============================================================================
# WRONG_PATTERN = ".*[Ll]ag.*"           # Matches EIS, Agency, Analytics alerts
# WRONG_PATTERN = ".*[Cc]onsumer.*"       # Too broad
# WRONG_PATTERN = ".*RMS.*"               # Still too broad

# =============================================================================
# CORRECT - Service-specific patterns
# =============================================================================
SERVICE_ALERT_PATTERN = (
    "RMS.*TaskMetadataSvc.*|"      # Task metadata consumer alerts
    "RMS.*RQ.*Rule.*Manager.*|"    # RQ rules manager alerts
    "RMS.*RuleManager.*"           # Legacy rule manager alerts
)

# Single annotation for all service alerts
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

# Multiple annotations by severity
severity_annotations = G.Annotations(
    list=[
        # Critical alerts (more prominent)
        {
            "builtIn": 0,
            "datasource": {"type": "prometheus", "uid": "${DataSource}"},
            "enable": True,
            "expr": f'ALERTS{{alertname=~"{SERVICE_ALERT_PATTERN}", alertstate="firing", severity="critical", axon_cluster=~"$axon_cluster"}}',
            "iconColor": "rgba(255, 50, 50, 0.35)",  # Red, more visible
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

# Apply to dashboard
from axon_helpers.graph_helpers import GenDashboard

dashboard = GenDashboard(
    title="My Dashboard",
    uid="my-dashboard",
    rows={"Health": health_panels},
    annotations=alert_annotations,  # or severity_annotations
)
```

---

## Minimal Starter Dashboard

The simplest possible TRON dashboard to get started.

```python
"""
Minimal TRON Consumer Dashboard Starter

Copy this template and customize for your service.
"""
from grafanalib.core import Threshold
from axon_helpers.graph_helpers import AxonGraph, AxonSingleStat, GenDashboard, UNITS
from axon_helpers.rms_helpers import generate_dashboard_template_values

# Single stat panel showing consumer lag
lag_stat = AxonSingleStat(
    title="Consumer Lag",
    expressions=[{
        "expr": 'sum(kafka_consumergroup_group_topic_sum_lag{group=~".*your-consumer-group.*"})',
    }],
    thresholds=[
        Threshold("green", 0, 0.0),
        Threshold("orange", 1, 2500),
        Threshold("red", 2, 5000),
    ],
    reduceCalc="lastNotNull",
    graphMode="area",
    format="short",
    span=4,
)

# Timeline showing lag over time
lag_timeline = AxonGraph(
    title="Lag Timeline",
    expressions=[{
        "expr": 'sum(kafka_consumergroup_group_topic_sum_lag{group=~".*your-consumer-group.*"})',
        "legendFormat": "Total Lag",
    }],
    span=8,
    unit=UNITS.SHORT,
)

# Assemble dashboard
dashboard = GenDashboard(
    title="My TRON Consumer Dashboard",
    uid="my-tron-consumer-dashboard",
    templating=generate_dashboard_template_values(),
    rows={
        "Health": [lag_stat, lag_timeline],
    },
)
```

---

## Customization Checklist

When adapting these examples:

- [ ] Update consumer group patterns to match your service
- [ ] Update metric names for your service
- [ ] Adjust thresholds to match your SLOs
- [ ] Update alert patterns for your service alerts
- [ ] Add/remove template variables as needed
- [ ] Set appropriate dashboard UID for stable URLs
- [ ] Configure collapsed rows for detailed sections
