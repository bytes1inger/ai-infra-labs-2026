---
title: "Prometheus ServiceMonitor: The CRD Nobody Reads Until Something Doesn't Scrape"
description: "How ServiceMonitor wiring actually works in kube-prometheus-stack, why scrape targets go missing, and the three fields that control everything."
pubDate: 2026-02-25
type: infra
tags: ["prometheus", "kubernetes", "observability"]
lab: "L01"
draft: false
---

Before you deploy a single GPU workload, your observability stack needs to actually work.
This post is about the thing that makes Prometheus discover your services — the `ServiceMonitor` CRD —
and specifically about the two hours you'll lose if you misconfigure it.

## What a ServiceMonitor actually does

The `kube-prometheus-stack` Helm chart installs the Prometheus Operator alongside Prometheus.
The Operator watches for `ServiceMonitor` custom resources and dynamically configures Prometheus
scrape targets based on what it finds.

The flow:

```
ServiceMonitor CR  →  Prometheus Operator  →  Prometheus scrape config
```

Without the Operator, you'd manage `prometheus.yml` manually. With it, you add a `ServiceMonitor`
and Prometheus finds your service within 30 seconds.

## The CRD anatomy

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  namespace: my-namespace   # ← where the ServiceMonitor lives
  labels:
    release: kube-prometheus-stack  # ← THIS must match the Operator's selector
spec:
  selector:
    matchLabels:
      app: my-app            # ← must match your Service's labels
  namespaceSelector:
    matchNames:
      - my-namespace         # ← where the Service lives
  endpoints:
    - port: metrics          # ← must match the port NAME in your Service
      path: /metrics
      interval: 30s
```

Three fields control whether this works or silently fails.

## The three failure modes

**1. Label mismatch on the ServiceMonitor itself**

The Prometheus Operator has a selector that controls which `ServiceMonitor` resources it pays
attention to. In `kube-prometheus-stack`, this is configured at install time:

```bash
helm show values prometheus-community/kube-prometheus-stack \
  | grep -A5 serviceMonitorSelector
```

The default:
```yaml
serviceMonitorSelector:
  matchLabels:
    release: kube-prometheus-stack
```

Your `ServiceMonitor` needs `labels.release: kube-prometheus-stack` — or the Operator ignores it
entirely. No error. No warning. Just silence.

**2. Port name mismatch**

Your Service must name the metrics port. A port number in the `ServiceMonitor` won't work.

```yaml
# ✅ Correct — named port
apiVersion: v1
kind: Service
spec:
  ports:
    - name: metrics     # ← name matches ServiceMonitor endpoint.port
      port: 8080
      targetPort: 8080

# ❌ Wrong — unnamed port
spec:
  ports:
    - port: 8080
      targetPort: 8080
```

**3. Namespace RBAC**

If your `ServiceMonitor` is in a different namespace from your `Service`, the Prometheus Operator
needs RBAC to reach across. The `namespaceSelector` field tells Prometheus *where to scrape*, but
the Operator itself needs permission:

```yaml
# ClusterRole for Prometheus to scrape across namespaces
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-scraper
rules:
  - apiGroups: [""]
    resources: ["services", "endpoints", "pods"]
    verbs: ["get", "list", "watch"]
```

`kube-prometheus-stack` creates this automatically if you use `--namespace monitoring` and set
`prometheus.prometheusSpec.serviceMonitorNamespaceSelector: {}` (empty = all namespaces).

## Validating it works

```bash
# Check if Prometheus found your target
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring

# Then open: localhost:9090/targets
# Your service should appear under "serviceMonitor/my-namespace/my-app"
```

If it doesn't appear after 60 seconds, check Operator logs first:

```bash
kubectl logs -n monitoring \
  -l app.kubernetes.io/name=prometheus-operator \
  --tail=50 | grep -i "error\|warn\|servicemonitor"
```

## What I set up in Lab 01

For Lab 01, I deployed `go-httpbin` as a dummy target and wired a `ServiceMonitor` to confirm
the stack was healthy before touching any GPU workloads.

Real output from `curl localhost:9090/api/v1/targets`:

```json
{
  "labels": {
    "job": "my-app",
    "namespace": "lab01-baseline",
    "service": "go-httpbin"
  },
  "health": "up",
  "lastScrape": "2026-02-25T09:12:04Z",
  "scrapeInterval": "30s"
}
```

Three panels in Grafana — request rate, latency histogram, error rate — all live within 5 minutes.

## The production rule

*Never deploy a new service without a `ServiceMonitor` in the same PR. If it's not in Prometheus, it doesn't exist.*
