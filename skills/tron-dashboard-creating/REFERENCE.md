# TRON Dashboard API Reference

This reference documents the axon_helpers classes used in TRON dashboards.

---

## Table of Contents

1. [AxonGraph](#axongraph)
2. [AxonSingleStat](#axonsinglestat)
3. [AxonBarGauge](#axonbargauge)
4. [GenDashboard](#gendashboard)
5. [ConsumerMetrics](#consumermetrics)
6. [Query](#query)
7. [Template Variables](#template-variables)
8. [Series Overrides](#series-overrides)

---

## AxonGraph

Time series visualization (lines, bars, or stacked).

**Location:** `axon_helpers/graph_helpers.py`

### Basic Usage

```python
from axon_helpers.graph_helpers import AxonGraph, UNITS

graph = AxonGraph(
    title="Consumer Lag",
    expressions=[
        {"expr": 'sum(kafka_consumergroup_group_topic_sum_lag{...})', "legendFormat": "{{group}}"},
    ],
    type="count",  # Auto-sets unit to short
    span=4,        # Width (12 = full row)
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | str | required | Panel title |
| `expressions` | List[dict] | required | List of `{"expr": "...", "legendFormat": "..."}` |
| `type` | str | None | `"count"` (short), `"latency"` (seconds), or None (custom) |
| `span` | int | 4 | Panel width (1-12, where 12 = full row) |
| `height` | int | 7 | Panel height |
| `unit` | str | None | Grafana unit (e.g., `UNITS.SECONDS`, `UNITS.SHORT`) |
| `bars` | bool | False | Show bars instead of lines |
| `lines` | bool | True | Show lines |
| `stack` | bool | False | Stack series |
| `spanNulls` | bool | False | Connect lines across null values |
| `maxDataPoints` | int | 1000 | Max data points to query |
| `thresholds` | List[Threshold] | None | Threshold lines on graph |
| `thresholdsStyleMode` | str | None | `"line"`, `"area"`, or `"line+area"` |
| `seriesOverrides` | List[dict] | None | Per-series styling |
| `description` | str | None | Panel description (tooltip) |

### Examples

**Latency Graph (p50/p90/p99):**
```python
AxonGraph(
    title="Event Freshness",
    expressions=[
        {"expr": 'histogram_quantile(0.50, sum by (le) (rate(metric_bucket{...}[$__rate_interval])))', "legendFormat": "p50"},
        {"expr": 'histogram_quantile(0.90, sum by (le) (rate(metric_bucket{...}[$__rate_interval])))', "legendFormat": "p90"},
        {"expr": 'histogram_quantile(0.99, sum by (le) (rate(metric_bucket{...}[$__rate_interval])))', "legendFormat": "p99"},
    ],
    unit=UNITS.SECONDS,
    span=4,
    spanNulls=True,
)
```

**Volume Graph (bars):**
```python
AxonGraph(
    title="Messages Processed",
    bars=True,
    lines=False,
    expressions=[
        {"expr": 'sum by (service) (increase(metric_count{...}[$__rate_interval]))', "legendFormat": "{{service}}"},
    ],
    unit=UNITS.SHORT,
    span=4,
)
```

---

## AxonSingleStat

Single aggregated value with optional sparkline (health overview panels).

**Location:** `axon_helpers/graph_helpers.py`

### Basic Usage

```python
from axon_helpers.graph_helpers import AxonSingleStat
from grafanalib.core import Threshold

stat = AxonSingleStat(
    title="Consumer Lag",
    expressions=[{"expr": "sum(kafka_consumergroup_group_topic_sum_lag{...})"}],
    thresholds=[
        Threshold("green", 0, 0.0),
        Threshold("orange", 1, 2500),
        Threshold("red", 2, 5000),
    ],
    reduceCalc="lastNotNull",
    graphMode="area",
    format="short",
    span=2,
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | str | required | Panel title |
| `expressions` | List[dict] | required | List of `{"expr": "...", "legendFormat": "..."}` |
| `thresholds` | List[Threshold] | None | Color thresholds |
| `reduceCalc` | str | "mean" | `"lastNotNull"`, `"last"`, `"mean"`, `"max"`, `"min"`, `"sum"` |
| `graphMode` | str | "none" | `"area"` (sparkline) or `"none"` |
| `format` | str | None | Grafana unit (e.g., `"short"`, `"percent"`, `"ms"`) |
| `decimals` | int | None | Decimal places to show |
| `span` | int | 4 | Panel width |
| `description` | str | None | Panel description |

### Threshold Colors

```python
from grafanalib.core import Threshold

# Order matters: index determines threshold order (0, 1, 2, ...)
thresholds = [
    Threshold("green", 0, 0.0),      # 0-2500: green
    Threshold("orange", 1, 2500),    # 2500-5000: orange
    Threshold("red", 2, 5000),       # 5000+: red
]
```

---

## AxonBarGauge

Bar gauge for top-K metrics.

**Location:** `axon_helpers/graph_helpers.py`

### Basic Usage

```python
from axon_helpers.graph_helpers import AxonBarGauge

gauge = AxonBarGauge(
    title="Top 10 Consumers by Lag",
    expressions=[{
        "expr": 'topk(10, sum by (group) (kafka_consumergroup_group_topic_sum_lag{...}))',
        "legendFormat": "{{group}}",
    }],
    orientation="horizontal",
    displayMode="lcd",
    span=6,
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | str | required | Panel title |
| `expressions` | List[dict] | required | PromQL expressions |
| `orientation` | str | "horizontal" | `"horizontal"` or `"vertical"` |
| `displayMode` | str | "lcd" | `"lcd"`, `"basic"`, or `"gradient"` |
| `span` | int | 4 | Panel width |
| `thresholds` | List[Threshold] | None | Color thresholds |

---

## GenDashboard

Assembles panels into a complete dashboard.

**Location:** `axon_helpers/graph_helpers.py`

### Basic Usage

```python
from axon_helpers.graph_helpers import GenDashboard
from axon_helpers.rms_helpers import generate_dashboard_template_values

dashboard = GenDashboard(
    title="RMS TRON Consumer Dashboard",
    uid="rms-tron-consumer-dashboard",
    rows={
        "Health Overview": health_panels,
        "Consumer Metrics": consumer_panels,
    },
    templating=generate_dashboard_template_values(),
    rows_to_collapse_by_title={"Consumer Metrics"},
    annotations=alert_annotations,
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | str | required | Dashboard title |
| `uid` | str | None | Dashboard UID (for stable URLs) |
| `rows` | dict | required | `{row_title: [panels], ...}` |
| `templating` | Templating | None | Template variables |
| `annotations` | Annotations | None | Alert annotations |
| `rows_to_collapse_by_title` | set | {} | Rows to collapse by default |
| `refresh` | str | "1m" | Auto-refresh interval |
| `timezone` | str | "Default" | Timezone |
| `tags` | List[str] | [] | Dashboard tags |
| `sharedCrosshair` | bool | True | Share crosshair across panels |

---

## ConsumerMetrics

Generate standard Kafka consumer dashboard sections.

**Location:** `axon_helpers/rms_helpers.py`

### Basic Usage

```python
from axon_helpers.rms_helpers import ConsumerMetrics, Query
from axon_helpers.utils import flatten

graphs = flatten(
    ConsumerMetrics(
        service_name="Task Metadata Consumer",
        container_name="taskmetadatasvc-task-event-consumer",
        consumer_group=".*taskmetadatasvc-task-event-consumer",
        fetch_latency_query=Query("rms_taskmetadatasvc_task_event_consumer_read_latency"),
        process_latency_query=Query("rms_taskmetadatasvc_task_event_consumer_sync_latency"),
        dlq_submitted_query=Query("rms_taskmetadatasvc_task_event_consumer_dlq_submitted_count"),
        message_volume_query=Query("rms_taskmetadatasvc_task_event_consumer_processed_count"),
    ).generate_consumer_graphs()
)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `service_name` | str | Display name for the service |
| `container_name` | str | Kubernetes container name |
| `consumer_group` | str | Kafka consumer group regex pattern |
| `fetch_latency_query` | Query | Metric for fetch/read latency |
| `process_latency_query` | Query | Metric for processing latency |
| `completion_latency_query` | Query | Metric for completion latency (optional) |
| `dlq_submitted_query` | Query | Metric for DLQ submissions |
| `message_volume_query` | Query | Metric for message count |
| `message_size_bytes_query` | Query | Metric for message size (optional) |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `generate_consumer_graphs()` | List[AxonGraph] | Full 9-panel consumer dashboard |
| `generate_summary_consumer_graphs()` | List[AxonGraph] | Compact 3-panel summary |

---

## Query

PromQL query builder with additional filters.

**Location:** `axon_helpers/rms_helpers.py`

### Basic Usage

```python
from axon_helpers.rms_helpers import Query

query = Query(
    query="rms_taskmetadatasvc_task_event_consumer_read_latency",
    additional_expressions=', is_dlq!="true", service=~".*-internal.*"',
    legend_format="{{service}}",
)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | str | Base metric name |
| `additional_expressions` | str | Additional label filters (include leading comma) |
| `legend_format` | str | Legend template (default: "") |
| `aggregations` | List[str] | Aggregation labels (optional) |
| `metric_type` | MetricType | Counter, Timer, or Gauge (optional) |

### Common Filter Patterns

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

---

## Template Variables

### generate_dashboard_template_values()

**Location:** `axon_helpers/rms_helpers.py`

Returns standard RMS template variables:
- `$DataSource` - Prometheus/Cortex datasource
- `$axon_cluster` - Cluster/environment selector

```python
from axon_helpers.rms_helpers import generate_dashboard_template_values

# Basic usage
templating = generate_dashboard_template_values()

# With additional templates
templating = generate_dashboard_template_values(
    additional_templates_list=[deployment_type_template]
)
```

### Custom Template Variables

```python
from grafanalib.core import Template

# Deployment type filter
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

# Consumer group filter
consumer_group_template = Template(
    name="consumer_group",
    label="Consumer Group",
    type="custom",
    default="All",
    includeAll=False,
    query="All,taskmetadatasvc-task-event-consumer,rq-rules-manager-consumer",
    options=[
        {"selected": True, "text": "All", "value": ".*"},
        {"selected": False, "text": "Task Metadata", "value": ".*taskmetadatasvc-task-event-consumer.*"},
        {"selected": False, "text": "RQ Rules Manager", "value": ".*rq-rules-manager-consumer.*"},
    ],
)
```

---

## Series Overrides

Per-series styling for differentiated visualization.

### Basic Usage

```python
AxonGraph(
    title="Faults and Errors",
    expressions=[
        {"expr": "...", "legendFormat": "fault"},
        {"expr": "...", "legendFormat": "error"},
    ],
    seriesOverrides=[
        {
            "matcher": {"id": "byName", "options": "fault"},
            "properties": [
                {"id": "color", "value": {"fixedColor": "red", "mode": "fixed"}},
            ],
        },
        {
            "matcher": {"id": "byName", "options": "error"},
            "properties": [
                {"id": "color", "value": {"fixedColor": "gray", "mode": "fixed"}},
            ],
        },
    ],
)
```

### Matcher Types

| Type | Description | Example |
|------|-------------|---------|
| `byName` | Exact series name | `{"id": "byName", "options": "error"}` |
| `byRegexp` | Regex pattern | `{"id": "byRegexp", "options": ".*error.*"}` |
| `byValue` | Match by value | `{"id": "byValue", "options": {...}}` |

### Common Properties

```python
# Set fixed color
{"id": "color", "value": {"fixedColor": "red", "mode": "fixed"}}

# Set fill opacity (0-100)
{"id": "custom.fillOpacity", "value": 50}

# Set line width
{"id": "custom.lineWidth", "value": 2}

# Hide from legend
{"id": "custom.hideFrom", "value": {"legend": True, "tooltip": False, "viz": False}}
```

---

## Units Reference (UNITS)

**Location:** `axon_helpers/graph_helpers.py`

```python
from axon_helpers.graph_helpers import UNITS

UNITS.SHORT       # "short" - generic numbers
UNITS.SECONDS     # "s" - seconds
UNITS.MILLISECONDS # "ms" - milliseconds
UNITS.BYTES       # "bytes" - bytes
UNITS.PERCENT     # "percent" - 0-100 percentage
```

### Common Grafana Units

| Unit | Format | Use For |
|------|--------|---------|
| `"short"` | 1.5k, 1.2M | Counts, messages |
| `"s"` | 1.5s, 2m | Latency in seconds |
| `"ms"` | 150ms | Latency in milliseconds |
| `"m"` | 2m, 5m | Minutes |
| `"percent"` | 95% | Percentages |
| `"cps"` | 1.5k/s | Counts per second |
| `"bytes"` | 1.5KB, 2.3MB | Byte sizes |
