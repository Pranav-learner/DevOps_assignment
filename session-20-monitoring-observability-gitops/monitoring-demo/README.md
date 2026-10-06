# Task 1: Monitoring Demo — Metrics, Structured Logs, Alerts & Application Health

## 1. Overview

This demo implements and validates all core monitoring dimensions on a live Kubernetes cluster using the `PulseWatch Observability API` microservice:
1. **Metrics**: Real-time Prometheus metrics exported at `/metrics`.
2. **Structured Logs**: Timestamped JSON logs emitted to stdout with injected `trace_id` correlation.
3. **Alerts**: Declarative Prometheus Alerting Rules for CPU, memory, errors, and health degradation.
4. **CPU Utilization**: Live workload generation and CPU monitoring via `kubectl top pods`.
5. **Memory Utilization**: Memory heap tracking and RSS threshold surveillance.
6. **Application Health**: Automated Kubernetes Liveness and Readiness probes monitoring `/healthz`.

---

## 2. Architecture & Components

```
Client / Synthetic Load Generator
      │
      ▼
[ Kubernetes Service: pulsewatch-service (Port 80) ]
      │
      ▼
[ Kubernetes Pod: pulsewatch-api (Replicas: 2) ]
      ├── /healthz            --> Liveness & Readiness Probes (Status: UP, 200 OK)
      ├── /metrics            --> Prometheus Metric Scraper (Counters, Gauges)
      ├── /simulate/load      --> High CPU math & Memory allocation
      ├── /simulate/error     --> Synthetic 500 error & Critical alert injection
      └── stdout              --> Structured JSON Logs
```

---

## 3. Metrics Demonstration (`/metrics`)

The application exports Prometheus-formatted metrics:

```
# HELP pulsewatch_uptime_seconds Total application uptime in seconds
# TYPE pulsewatch_uptime_seconds gauge
pulsewatch_uptime_seconds 45

# HELP pulsewatch_memory_rss_bytes Resident Set Size memory usage in bytes
# TYPE pulsewatch_memory_rss_bytes gauge
pulsewatch_memory_rss_bytes 67428352

# HELP pulsewatch_memory_heap_bytes Memory heap used in bytes
# TYPE pulsewatch_memory_heap_bytes gauge
pulsewatch_memory_heap_bytes 7985296

# HELP pulsewatch_http_requests_total Cumulative count of HTTP requests handled
# TYPE pulsewatch_http_requests_total counter
pulsewatch_http_requests_total{method="GET",path="/"} 1
pulsewatch_http_requests_total{method="GET",path="/healthz"} 12
pulsewatch_http_requests_total{method="GET",path="/metrics"} 4
pulsewatch_http_requests_total{method="POST",path="/simulate/load"} 2
pulsewatch_http_requests_total{method="POST",path="/simulate/error"} 1

# HELP pulsewatch_http_errors_total Cumulative HTTP 5xx errors encountered
# TYPE pulsewatch_http_errors_total counter
pulsewatch_http_errors_total 1

# HELP pulsewatch_alerts_triggered_total Count of high threshold alerts fired
# TYPE pulsewatch_alerts_triggered_total counter
pulsewatch_alerts_triggered_total 1
```

---

## 4. Structured JSON Logging Demonstration

Logs are emitted to stdout in structured JSON format with distributed `trace_id` correlation:

```json
{"timestamp":"2026-10-06T20:57:35.415Z","level":"INFO","trace_id":"421b104a-b192-4380-a3f4-9206db6357d5","method":"GET","path":"/healthz","status":200,"duration_ms":2.56,"client_ip":"10.244.0.1"}
{"timestamp":"2026-10-06T20:57:43.369Z","level":"INFO","trace_id":"dc3d38ec-6402-4968-ba93-489de1be92e8","method":"POST","path":"/simulate/load","status":200,"duration_ms":86.16,"client_ip":"127.0.0.1"}
{"timestamp":"2026-10-06T20:57:43.580Z","level":"CRITICAL","trace_id":"6def49b3-a537-4eb6-9b70-4541daf0e40d","error":"DatabaseConnectionTimeout","message":"Simulated downstream connection timeout triggering HighErrorRate alert"}
{"timestamp":"2026-10-06T20:57:43.581Z","level":"ERROR","trace_id":"6def49b3-a537-4eb6-9b70-4541daf0e40d","method":"POST","path":"/simulate/error","status":500,"duration_ms":1.42,"client_ip":"127.0.0.1"}
```

---

## 5. Application Health & Probes (`/healthz`)

The endpoint returns detailed runtime vitals for Kubernetes probe decisions:

```json
{
  "status": "UP",
  "timestamp": "2026-10-06T20:57:15.957Z",
  "uptime_seconds": 19,
  "system": {
    "hostname": "pulsewatch-api-5585f7bbc9-24lkp",
    "load_avg_1m": "1.42",
    "cpu_count": 12,
    "free_mem_mb": "6247.64"
  },
  "process_memory": {
    "rss_mb": 64.3,
    "heap_used_mb": 7.54
  }
}
```

---

## 6. CPU & Memory Utilization Surveillance

Monitored in real-time via `kubectl top`:

```bash
$ kubectl top pods -n observability-demo
NAME                              CPU(cores)   MEMORY(bytes)   
pulsewatch-api-5585f7bbc9-24lkp   6m           54Mi            
pulsewatch-api-5585f7bbc9-klgnm   6m           73Mi            
```

---

## 7. Declarative Alerting Rules (`alert-rules.yaml`)

Defines 4 production alert specifications:
- **`HighCPUUtilization`**: Fires warning if container CPU > 80% for > 1 minute.
- **`HighMemoryUtilization`**: Fires critical alert if memory working set > 80% of limit (256Mi).
- **`ApplicationHealthDegraded`**: Fires critical alert if `/healthz` probe fails for > 30 seconds.
- **`HighHttpErrorRate`**: Fires warning if HTTP 5xx errors exceed 5% of total traffic.
