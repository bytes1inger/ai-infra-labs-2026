# AI Infrastructure Lab 2026

**78 AKS AI infrastructure labs · 45 weeks · 2026 build-in-public program. GPU serving, RAG, autoscaling, chaos, FinOps — one concept per lab, fully instrumented, all open source.**

Live at: [gideonwarui.com/blog](https://gideonwarui.com/blog)

---

## Structure

```
ai-infra-labs-2026/
├── blog/posts/          ← blog posts (synced to gideonwarui.com automatically)
├── terraform/aks/       ← cluster + nodepool configs
├── helm-values/         ← Helm value overrides per lab
├── dashboards/grafana/  ← Grafana dashboard JSON exports
├── load-tests/locust/   ← Locust load test fixtures
├── scripts/             ← cluster lifecycle scripts
└── results/baselines/   ← L06 baseline measurements (never deleted)
```

## Curriculum

Full lab curriculum: [CURRICULUM.md](./CURRICULUM.md)

## Lab Baseline Numbers

| Lab | Metric | Value |
|-----|--------|-------|
| L01 | Prometheus scrape interval | 30s |
| L06 | vLLM throughput baseline | *TBD after L06 runs* |

---

## Publishing workflow

Posts in `blog/posts/` are automatically synced to `gideonwarui.com` on every push via GitHub Actions.
No manual Astro edits needed. Push markdown → site updates within ~3 minutes.

## Stack

AKS · GPU nodepools (T4/A100) · vLLM · Triton · Qdrant · pgvector · KEDA · Prometheus · Grafana · Loki · Terraform · Helm
