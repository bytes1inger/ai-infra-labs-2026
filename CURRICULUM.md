# AI Infrastructure Lab Curriculum 2026
### Azure AKS · GPU Serving · LLM Systems · RAG · Autoscaling · FinOps · Chaos
**Feb 25 – Dec 31, 2026 · 45 weeks · ~80 labs · 4 hrs/day · 1–2 days per lab**

---

## Ground Rules

- **4 hours/day = 1 lab/day max.** A 1-day lab = 4 hrs. A 2-day lab = 8 hrs (two sessions).
- **2–3 labs/week is the ceiling, not the target.** Some weeks have 2 short labs. Some have 1 deep one.
- **Every 4th week = consolidation.** Write the blog post, clean the repo, rest the GPU budget.
- **Labs are additive.** Metrics from Lab 1 are the control baseline forever.
- **GPU nodepool scales to zero between labs.** Every session starts with `az aks nodepool scale`.
- **One namespace per lab. Always.** Isolation is non-negotiable.

## Pacing Key
| Symbol | Meaning |
|--------|---------|
| 🟢 | 1-day lab (4 hrs) |
| 🟡 | 2-day lab (8 hrs, two sessions) |
| 📝 | Consolidation / blog week (no new infra) |
| 🔵 | Integration lab (connects prior namespaces) |
| 🔴 | Chaos / failure lab |
| 💰 | FinOps-primary lab |

## GPU SKU Reference
| SKU | Use case | Est. cost/hr |
|-----|----------|-------------|
| NC4as T4 v3 (T4 16GB) | Labs 1–50, chaos, FinOps | ~$0.50–$0.90 |
| NC6s v3 (V100 16GB) | Quantization comparisons (optional swap) | ~$1.10–$1.50 |
| NC24ads A100 v4 (A100 80GB) | LoRA, Triton, large models, capstone | ~$3.40–$4.00 |

---

# PHASE 1 — FOUNDATION
## *Instrument everything. Establish baselines. Never optimize blind.*
### Weeks 1–6 · Feb 25 – Apr 07 · 14 labs

The first six weeks produce zero optimization. They produce **precision instruments and clean baselines**. Every number you capture here becomes the control group for the rest of the year.

---

### Week 1 · Feb 25 – Mar 03
**Theme: Observability Stack Validation**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L01 | **The Instrument Panel** | Prometheus ServiceMonitor wiring, Grafana provisioning via ConfigMap, Loki log stream validation | 🟢 | None |
| L02 | **GPU Metrics from Zero** | DCGM Exporter DaemonSet, `DCGM_FI_DEV_*` metric taxonomy, node-level vs pod-level GPU visibility | 🟢 | T4 |

**L01 detail:** Deploy a dummy HTTP server (`go-httpbin`), wire a ServiceMonitor, confirm scrape targets in Prometheus UI, build a 3-panel Grafana dashboard (request rate, latency, error %), ship logs to Loki with namespace label. Proves your observability stack is actually working before any GPU spend.

**L02 detail:** Install DCGM Exporter on GPU node only. Run a GPU stress test (`gpu-burn`). Confirm 12 DCGM metrics are visible in Prometheus. Build GPU panel: utilization, memory used, power draw, temperature, SM clock. This dashboard is reused in every subsequent lab.

---

### Week 2 · Mar 04 – Mar 10
**Theme: Alerting & Log Intelligence**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L03 | **Alert Before It Breaks** | PrometheusRule CRDs, multi-window burn rate alerts, Alertmanager routing | 🟢 | None |
| L04 | **Loki Query Language for LLM Logs** | LogQL aggregations, structured log parsing, latency extraction from vLLM JSON logs | 🟢 | None |

**L03 detail:** Write 5 production-realistic alert rules: GPU memory > 90%, pod restart count > 0, request error rate > 1%, p95 latency > 3s, queue depth > 10. Wire to Alertmanager with group routing. Test each alert by deliberately triggering the condition.

**L04 detail:** Deploy vLLM (no load) and parse its JSON log stream in Loki. Extract TTFT, tokens/sec, request ID, model name from unstructured logs using `json` parser and `line_format`. Build a Loki-native latency panel without needing application-level Prometheus metrics — this is useful when you don't control the exporter.

---

### Week 3 · Mar 11 – Mar 17
**Theme: First LLM Deployment & Baseline**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L05 | **vLLM Standing Up** | vLLM Helm deploy, node affinity + tolerations, model cold start measurement, readiness probe design | 🟡 | T4 |
| L06 | **The Load Test Contract** | Locust concurrency ramp, fixed prompt fixtures, reproducible throughput baseline | 🟢 | T4 |

**L05 detail (2-day):** Day 1: Deploy vLLM with `microsoft/Phi-3-mini-4k-instruct` (3.8B, fits T4 at fp16). Fight with node affinity, tolerations, HuggingFace token secrets. Record cold start time. Day 2: Wire ServiceMonitor for vLLM `/metrics`. Confirm all 8 vLLM Prometheus metrics are streaming. Build the unified GPU + LLM Grafana dashboard that will be reused for the rest of the year.

**L06 detail:** Run controlled Locust ramp: 1 → 4 → 8 → 16 → 32 concurrent users. Fixed: 512-token input, 256-token output, temperature=0. Record tokens/sec, p50/p95/p99 TTFT, queue depth, KV cache % at each stage. **This is your permanent baseline.** Commit the numbers to the repo README.

---

### Week 4 · Mar 18 – Mar 24
**Theme: Kubernetes Internals for GPU Workloads**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L07 | **The Scheduler's View** | GPU resource requests/limits, extended resources (`nvidia.com/gpu`), ResourceQuota per namespace, LimitRange | 🟢 | T4 |
| L08 | **Node Affinity vs Taints vs Topology** | nodeSelector vs nodeAffinity vs taint/toleration precedence, pod placement failure diagnosis | 🟢 | T4 |

**L07 detail:** Deploy 3 pods requesting different GPU fractions. Observe scheduler behavior (GPU is not divisible — all 3 get 1 or fail). Set ResourceQuota on namespace: max 2 GPUs, max 32Gi memory. Prove the quota works by attempting to exceed it. Understand why `requests != limits` on GPUs is dangerous.

**L08 detail:** Deliberately misconfigure nodeAffinity and observe pod `Pending` state with `kubectl describe`. Walk through the scheduler decision log. Understand `preferredDuringSchedulingIgnoredDuringExecution` vs `required`. Set up a dedicated GPU nodepool taint and prove non-GPU workloads cannot land on it.

---

### Week 5 · Mar 25 – Mar 31
**Theme: Storage & Identity for AI Workloads**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L09 | **Model Weights as Infrastructure** | PVC for model cache, Azure Disk vs Azure File for model storage, ReadWriteMany for shared model weights | 🟡 | T4 |
| L10 | **Secrets, Service Accounts & Workload Identity** | Kubernetes Secrets for HuggingFace tokens, Azure Workload Identity, pod identity for Azure Blob model cache | 🟢 | None |

**L09 detail (2-day):** Day 1: Deploy vLLM with emptyDir (baseline) vs Azure Disk PVC (persistent). Measure: cold start time with pre-cached model vs fresh pull. Day 2: Test Azure File (ReadWriteMany) for shared model weights across 2 vLLM replicas. Measure storage IOPS during model load. This directly impacts FinOps — fast storage = shorter GPU spin-up = less idle cost.

**L10 detail:** Replace hardcoded HuggingFace token in Secret with Azure Workload Identity federation. Pod gets token via projected service account volume, not environment variable. Prove no credentials in container env. Foundational security practice for production AI infrastructure.

---

### Week 6 · Apr 01 – Apr 07 — 📝 CONSOLIDATION WEEK

**No new infra this week.**

- Write Blog Post 1: *"Before You Optimize: Building a Production Observability Stack for GPU Inference on AKS"*
- Clean and commit all Helm values to repo (`helm-values/lab01-lab10/`)
- Commit Grafana dashboard JSONs
- Tag repo: `v0.1.0-foundation`
- GPU nodepool to zero
- Review baseline numbers from L06 — these are sacred. Do not lose them.

---

# PHASE 2 — GPU SERVING INTERNALS
## *Understand what the GPU is actually doing. Then tune it.*
### Weeks 7–14 · Apr 08 – Jun 02 · 18 labs

---

### Week 7 · Apr 08 – Apr 14
**Theme: KV Cache Fundamentals**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L11 | **The KV Cache Budget** | `gpu_memory_utilization` parameter, KV block size, relationship between model size + KV cache + available memory | 🟢 | T4 |
| L12 | **Eviction and Swap** | KV cache eviction policy, CPU swap under pressure, `vllm:num_preemptions_total`, latency impact of swap | 🟡 | T4 |

**L11 detail:** Run the L06 load test 3 times with `gpu_memory_utilization` = 0.70 / 0.85 / 0.95. Plot: KV cache blocks available vs throughput vs TTFT. Prove the tradeoff is non-linear — small memory increases unlock disproportionate throughput gains until a cliff.

**L12 detail (2-day):** Force KV cache eviction by running very long sequences that exceed block capacity. Observe `num_preemptions_total` rising in Prometheus. Measure TTFT spike during swap-to-CPU events. Day 2: tune `swap_space` parameter, re-measure. Understand when eviction is preferable to OOM.

---

### Week 8 · Apr 15 – Apr 21
**Theme: Batching & Throughput**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L13 | **Continuous Batching Deep Dive** | vLLM continuous batching vs static batching, `max_num_batched_tokens`, batch composition at runtime | 🟢 | T4 |
| L14 | **Chunked Prefill** | `--enable-chunked-prefill`, TTFT variance at high concurrency, prefill vs decode GPU utilization split | 🟡 | T4 |

**L13 detail:** Use vLLM's scheduler logs (via Loki) to observe batch composition in real time during the L06 load test. Vary `max_num_batched_tokens` (512 / 2048 / 8192). Measure: GPU utilization %, tokens/sec, p95 TTFT at each setting. Show that higher batch token limits improve throughput at cost of TTFT variance.

**L14 detail (2-day):** Day 1: Run mixed workload — 50% short prompts (128 tokens), 50% long prompts (2048 tokens) — without chunked prefill. Record TTFT for short prompts being blocked by long prefills. Day 2: Enable `--enable-chunked-prefill`, re-run. Measure TTFT improvement for short prompts. Quantify the throughput cost of fairer scheduling.

---

### Week 9 · Apr 22 – Apr 28
**Theme: Quantization**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L15 | **fp16 vs AWQ vs GPTQ** | Quantization formats, memory footprint reduction, throughput vs quality tradeoff | 🟡 | T4 |
| L16 | **Fitting Larger Models on Smaller GPUs** | Model selection for T4 16GB: 7B fp16 vs 13B AWQ, KV cache headroom after quantization | 🟢 | T4 |

**L15 detail (2-day):** Deploy the same model (Mistral 7B) in fp16, AWQ int4, and GPTQ int4. Run identical L06 load test on each. Record: GPU memory footprint, tokens/sec, p95 TTFT, and (manually) output quality on 10 fixed prompts. Show the memory-quality-throughput trilemma visually.

**L16 detail:** Take the memory saved from AWQ quantization and use it to serve a 13B model that wouldn't fit in fp16 on a T4. Measure: does 13B AWQ outperform 7B fp16 in quality? What's the throughput cost? This is a direct production decision tree lab.

---

### Week 10 · Apr 29 – May 05
**Theme: Prefix Caching & Speculative Decoding**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L17 | **Prefix Caching** | Automatic prefix caching in vLLM, cache hit rate metric, RAG system prompt reuse pattern | 🟢 | T4 |
| L18 | **Speculative Decoding** | Draft model + target model, `--speculative-model`, acceptance rate, latency vs throughput | 🟡 | T4 |

**L17 detail:** Configure a system prompt (1024 tokens) shared across all requests — simulating a RAG context or agent system prompt. Enable prefix caching. Run load test with and without the shared prefix. Measure: GPU memory freed by cache hits, TTFT reduction on cached prefix requests. This directly applies to RAG (Lab 4 system prompt reuse).

**L18 detail (2-day):** Deploy vLLM with `--speculative-model` (small draft model like Phi-3-mini as draft, Mistral 7B as target). Day 1: Tune speculation length (4 / 8 / 16 tokens). Day 2: Measure acceptance rate by token type (code vs prose vs numbers). Show when speculative decoding helps vs hurts. Understand the memory overhead of carrying two models.

---

### Week 11 · May 06 – May 12
**Theme: Multi-GPU & Tensor Parallelism**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L19 | **Tensor Parallelism on 2xT4** | `--tensor-parallel-size 2`, NVLink vs PCIe bandwidth impact, throughput scaling efficiency | 🟡 | 2×T4 |
| L20 | **Pipeline Parallelism** | `--pipeline-parallel-size 2`, inter-stage latency, pipeline bubble overhead | 🟢 | 2×T4 |

**L19 detail (2-day):** Scale GPU nodepool to 1 node with 2x T4 (Standard_NC8as_T4_v3). Deploy vLLM with tensor parallelism=2. Day 1: Benchmark throughput vs single T4. Day 2: Use DCGM to observe NVLink utilization. Understand why tensor parallelism has a communication overhead floor — it's not linear scaling.

**L20 detail:** Switch to pipeline parallelism on same 2x T4 node. Measure inter-stage activation transfer latency via vLLM logs. Compare throughput and TTFT: tensor parallel vs pipeline parallel vs single GPU. Understand the use case split: tensor parallel = latency, pipeline parallel = memory.

---

### Week 12 · May 13 – May 19
**Theme: Model Serving Configuration**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L21 | **max_model_len Tuning** | Context window vs KV cache memory, request rejection at context limit, client-side vs server-side truncation | 🟢 | T4 |
| L22 | **Throughput vs Latency Mode** | vLLM `--max-num-seqs`, optimizing for batch throughput (offline) vs interactive (online) | 🟢 | T4 |

---

### Week 13 · May 20 – May 26
**Theme: GPU SKU Comparison**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L23 | **T4 vs A100: The Cost-Performance Cliff** | Same model, same load, two GPU SKUs — tokens/sec, TTFT, GPU util %, cost per 1K tokens | 🟡 | T4 + A100 |
| L24 | **Right-sizing GPU SKU for Workload Class** | Decision framework: interactive vs batch, model size vs SKU, cost-efficiency optimization | 🟢 | Both |

**L23 detail (2-day):** Run the exact L06 load test on T4 and A100 with identical config. Record all metrics. Compute cost per 1K tokens on each. Show the A100 is not 4× better at 4× the price for small models — the sweet spot depends on model size and concurrency.

---

### Week 14 · Jun 03 – Jun 09 — 📝 CONSOLIDATION WEEK

- Write Blog Post 2: *"Inside the KV Cache: What vLLM's Memory Model Means for Your Production Latency"*
- Write Blog Post 3 (short): *"fp16 vs AWQ: The Quantization Decision Tree for T4 Deployments"*
- Update repo with all Phase 2 Helm values and Grafana dashboards
- Build the **GPU Serving Reference Dashboard** — single dashboard aggregating all Phase 2 metrics
- Tag repo: `v0.2.0-gpu-internals`

---

# PHASE 3 — AUTOSCALING
## *Scale what needs scaling. Know the cost of every scaling decision.*
### Weeks 15–22 · Jun 10 – Aug 04 · 16 labs

---

### Week 15 · Jun 10 – Jun 16
**Theme: HPA Fundamentals**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L25 | **HPA on CPU Workloads** | HPA v2, `targetAverageUtilization`, scale-up / scale-down stabilization window | 🟢 | None |
| L26 | **HPA on Custom Metrics** | Prometheus Adapter, `PrometheusRule` as HPA metric source, scaling on request rate | 🟢 | None |

---

### Week 16 · Jun 17 – Jun 23
**Theme: KEDA Introduction**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L27 | **KEDA ScaledObject Basics** | KEDA install, `ScaledObject` CRD, Prometheus scaler, trigger thresholds | 🟢 | None |
| L28 | **KEDA on LLM Queue Depth** | Scale vLLM replicas on `vllm:num_requests_waiting`, cooldown periods, flapping prevention | 🟡 | T4 |

**L28 detail (2-day):** Wire KEDA ScaledObject to `vllm:num_requests_waiting > 3`. Day 1: Burst 50 concurrent requests from cold. Observe: KEDA trigger fires, new pod schedules, model loads, traffic routes. Record time-to-serve from trigger. Day 2: Tune polling interval, cooldown, and stabilization window. Show the difference between a well-tuned and poorly-tuned ScaledObject during bursty traffic.

---

### Week 17 · Jun 24 – Jun 30
**Theme: GPU Node Scaling**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L29 | **GPU Node Cold Start: The Full Timeline** | Cluster Autoscaler trigger → VM provision → GPU driver init → pod schedule → model load | 🟡 | T4 |
| L30 | **Warm Pool Strategy** | Pre-provisioned standby nodes, cost of warm pool, node keep-alive patterns | 🟢 | T4 |

**L29 detail (2-day):** Scale GPU nodepool to 0. Send burst traffic. Record every timestamp: Cluster Autoscaler event → node `Ready` → pod `Running` → model loaded → first request served. Total cold start = sum of all segments. Day 2: Identify which segment dominates and what can be optimized (pre-pull images, faster storage, faster model load).

---

### Week 18 · Jul 01 – Jul 07
**Theme: Scale to Zero LLM**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L31 | **Scale to Zero with KEDA** | KEDA minReplicaCount=0, scaleToZeroOnIdle, traffic-triggered wake-up | 🟡 | T4 |
| L32 | **The Warm Replica Floor** | minReplicas=1 cost model, p99 latency SLO vs idle cost, decision framework | 🟢 | T4 |

**L31 detail (2-day):** Configure KEDA with `minReplicaCount: 0`. Idle the system. Observe pod termination, GPU node scale-down. Then send a request: measure total user-perceived latency from first request to first response token. Day 2: Add a "keepalive" sidecar probe pattern (fake requests every N minutes to prevent full scale-to-zero). Measure cost delta.

---

### Week 19 · Jul 08 – Jul 14
**Theme: Scaling Patterns**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L33 | **Predictive vs Reactive Scaling** | Cron-based KEDA scaler, traffic pattern analysis, pre-scale before peak | 🟢 | T4 |
| L34 | **Scaling Lag Measurement** | Define: trigger lag, provision lag, readiness lag. Measure each. Design mitigations. | 🟡 | T4 |

---

### Week 20 · Jul 15 – Jul 21
**Theme: Multi-Tier Scaling**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L35 | **CPU Tier vs GPU Tier Scaling** | Scale embedding pods (CPU) independently from generation pods (GPU), cost efficiency | 🟢 | T4 |
| L36 | **Request Queue Architecture** | Introduce NATS/Redis queue between client and vLLM, KEDA queue scaler, backpressure | 🟡 | T4 |

**L36 detail (2-day):** Insert a Redis queue (via Helm) between Locust and vLLM. Configure KEDA to scale vLLM replicas on Redis queue length. Day 1: Observe queue-based scaling behavior vs direct Prometheus-based scaling. Day 2: Simulate producer spike with queue depth capping. Show how queuing decouples client from inference latency — at the cost of added architecture complexity.

---

### Week 21 · Jul 22 – Jul 28
**Theme: Ingress & Traffic Management**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L37 | **NGINX Ingress for LLM APIs** | Rate limiting at ingress, token bucket per client, upstream keepalive for long inference streams | 🟢 | T4 |
| L38 | **Canary Routing for Model Versions** | NGINX canary annotation, traffic split 90/10 between model versions, observability during rollout | 🟡 | T4 |

---

### Week 22 · Jul 29 – Aug 04 — 📝 CONSOLIDATION WEEK

- Write Blog Post 4: *"KEDA for LLM Inference: Why Scale-to-Zero Breaks Your SLO and What to Do About It"*
- Build the **Autoscaling Decision Matrix**: a reference diagram for the repo documenting when to use HPA vs KEDA vs none, min-replicas=0 vs 1, queue vs direct
- Update all Phase 3 Helm values in repo
- Tag repo: `v0.3.0-autoscaling`

---

# PHASE 4 — RAG SYSTEMS
## *Build the retrieve-augment-generate pipeline. Then understand where the time actually goes.*
### Weeks 23–30 · Aug 05 – Sep 29 · 16 labs

---

### Week 23 · Aug 05 – Aug 11
**Theme: Vector DB Foundation**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L39 | **Qdrant on AKS** | Qdrant Helm deploy, collection creation, HNSW index parameters (`m`, `ef_construction`) | 🟢 | None |
| L40 | **Indexing at Scale** | Index 100K documents, measure indexing throughput, memory footprint, disk usage | 🟡 | None |

---

### Week 24 · Aug 12 – Aug 18
**Theme: Embedding Service**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L41 | **Embedding Service on CPU** | `sentence-transformers` as REST service, `all-MiniLM-L6-v2`, batching, latency | 🟢 | None |
| L42 | **Embedding Service on GPU** | GPU-accelerated embedding, throughput comparison vs CPU, cost per embedding | 🟢 | T4 |

---

### Week 25 · Aug 19 – Aug 25
**Theme: First RAG Pipeline**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L43 | **End-to-End RAG: First Contact** | Wire embedding → Qdrant → vLLM, first RAG query, end-to-end latency measurement | 🟡 | T4 |
| L44 | **RAG Latency Decomposition** | Break total latency into: embed time + search time + prompt build time + generation time | 🟢 | T4 |

**L43 detail (2-day):** Day 1: Write the RAG orchestration service (FastAPI, ~100 lines). Wire: client → embed → Qdrant top-K → build prompt → vLLM → response. Day 2: Instrument every stage with Prometheus histograms. Answer: where does the time actually go in a RAG request?

**L44 detail:** Use the instrumented pipeline from L43. Run 1000 RAG queries. Break total latency into 4 components. For most small-model RAG systems: generation dominates (60–80%), embedding is negligible (5–10%), Qdrant search is fast (2–5%). Prove it with real numbers.

---

### Week 26 · Aug 26 – Sep 01
**Theme: RAG Quality & Tuning**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L45 | **top-K Tuning** | top-K=3 vs 5 vs 10: retrieval quality, context length, GPU memory pressure | 🟢 | T4 |
| L46 | **HNSW Tuning for Recall vs Speed** | `ef` search parameter, recall@K, Qdrant latency vs accuracy tradeoff | 🟢 | None |

---

### Week 27 · Sep 02 – Sep 08
**Theme: Vector DB Comparison**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L47 | **Qdrant vs pgvector** | Deploy pgvector on PostgreSQL, run identical 100K index, compare: query latency, memory, ops complexity | 🟡 | None |
| L48 | **Weaviate for Hybrid Search** | BM25 + vector hybrid search, keyword recall vs semantic recall, when hybrid beats pure vector | 🟢 | None |

---

### Week 28 · Sep 09 – Sep 15
**Theme: RAG at Scale**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L49 | **RAG Under Load** | L06 load test pattern applied to full RAG pipeline, find bottleneck tier | 🟡 | T4 |
| L50 | **RAG + KEDA: Scaling the Right Tier** | Scale embedding (CPU) vs generation (GPU) under load, cost-efficiency comparison | 🟡 | T4 |

---

### Week 29 · Sep 16 – Sep 22
**Theme: Advanced RAG Patterns**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L51 | **Reranking Pipeline** | Add cross-encoder reranker between retrieval and generation, latency vs quality | 🟢 | T4 |
| L52 | **Prefix Caching for RAG System Prompts** | Apply L17 prefix caching to RAG — shared system context, cache hit rate on real workload | 🟢 | T4 |

---

### Week 30 · Sep 23 – Sep 29 — 📝 CONSOLIDATION WEEK

- Write Blog Post 5: *"Where Does RAG Actually Spend Its Time? A Prometheus-Level Latency Breakdown on AKS"*
- Write Blog Post 6 (short): *"Qdrant vs pgvector: The Pragmatic Comparison Nobody Runs to Completion"*
- Build the RAG reference architecture diagram (blog-quality)
- Tag repo: `v0.4.0-rag-systems`

---

# PHASE 5 — ADVANCED SERVING
## *Go deeper into the model server. Understand multi-model, multi-adapter, and ensemble patterns.*
### Weeks 31–36 · Sep 30 – Nov 10 · 12 labs

---

### Week 31 · Sep 30 – Oct 06
**Theme: LoRA Adapters**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L53 | **LoRA Adapters in vLLM** | `--enable-lora`, loading domain adapters, per-adapter routing via request header | 🟢 | A100 |
| L54 | **Multi-LoRA Memory Budget** | `--max-loras`, adapter eviction, GPU memory partitioning across N adapters | 🟡 | A100 |

---

### Week 32 · Oct 07 – Oct 13
**Theme: LoRA Production Patterns**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L55 | **LoRA Hot-Swap Benchmark** | 1 server × 3 adapters vs 3 servers × 1 adapter: cost, latency, resource utilization | 🟡 | A100 |
| L56 | **Adapter Routing Service** | Sidecar that routes requests to adapter by tenant ID, isolates adapter metrics per tenant | 🟢 | A100 |

---

### Week 33 · Oct 14 – Oct 20
**Theme: Triton Introduction**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L57 | **Triton Model Repository** | Triton Helm deploy, model repository structure, Python backend, ONNX backend | 🟡 | A100 |
| L58 | **Triton Dynamic Batching** | Per-model `max_batch_size`, `preferred_batch_size`, batching efficiency vs latency | 🟢 | A100 |

---

### Week 34 · Oct 21 – Oct 27
**Theme: Triton Advanced**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L59 | **Triton Ensemble Pipeline** | Chain embedding + reranker + generation as ensemble, single inference request | 🟡 | A100 |
| L60 | **vLLM vs Triton: Structured Benchmark** | Same model, same load, both servers: when does Triton's overhead justify its flexibility? | 🟢 | A100 |

---

### Week 35 · Oct 28 – Nov 03
**Theme: Inference Gateway & Routing**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L61 | **OpenAI-Compatible Gateway** | Deploy LiteLLM or custom FastAPI gateway, route to multiple backends by model name | 🟢 | T4 |
| L62 | **Model A/B Testing** | Traffic split between model versions via gateway, per-variant latency and quality metrics | 🟡 | T4 |

---

### Week 36 · Nov 04 – Nov 10 — 📝 CONSOLIDATION WEEK

- Write Blog Post 7: *"One GPU, Three Personalities: LoRA Hot-Swapping in Production with vLLM on AKS"*
- Write Blog Post 8 (short): *"vLLM vs Triton: A Serving Infrastructure Decision Framework"*
- Tag repo: `v0.5.0-advanced-serving`

---

# PHASE 6 — RELIABILITY & CHAOS
## *Break it intentionally. Measure the recovery. Build the runbook.*
### Weeks 37–40 · Nov 11 – Dec 08 · 10 labs

---

### Week 37 · Nov 11 – Nov 17
**Theme: Probes & Disruption Budgets**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L63 | **Probe Design for LLM Workloads** | liveness vs readiness vs startup probe for slow-starting model servers, backoff tuning | 🟢 | T4 |
| L64 | **PodDisruptionBudget in Practice** | PDB with `minAvailable=1`, node drain behavior with and without PDB, rolling update safety | 🟢 | T4 |

---

### Week 38 · Nov 18 – Nov 24
**Theme: OOM & CrashLoop**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L65 | **GPU OOM Injection** | Send oversized request, trigger CUDA OOM, observe pod restart, measure TTR | 🟡 🔴 | T4 |
| L66 | **CrashLoopBackOff Simulation** | Inject bad config via ConfigMap, observe exponential backoff, patch config, measure recovery | 🟢 🔴 | T4 |

---

### Week 39 · Nov 25 – Dec 01
**Theme: Node-Level Failures**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L67 | **Node Drain: GPU Pod Rescheduling** | `kubectl drain` GPU node, observe pod rescheduling, GPU nodepool scale-out, measure full recovery | 🟡 🔴 | T4 |
| L68 | **Resource Starvation** | Set memory limit below working set, observe OOMKilled, tune limits based on actual usage | 🟢 🔴 | T4 |

---

### Week 40 · Dec 02 – Dec 08
**Theme: Network & Storage Failures**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L69 | **NetworkPolicy Chaos** | Apply NetworkPolicy that blocks Qdrant access, observe RAG failure mode, verify deny-by-default posture | 🟢 🔴 | T4 |
| L70 | **Storage Latency Injection** | Use `tc netem` to add 500ms to Qdrant storage, measure end-to-end RAG degradation, circuit breaker | 🟡 🔴 | T4 |

---

# PHASE 7 — FINOPS
## *You've built it. Now prove you can run it without burning money on idle GPUs.*
### Weeks 41–43 · Dec 09 – Dec 22 · 7 labs

---

### Week 41 · Dec 09 – Dec 15
**Theme: Cost Attribution**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L71 | **GPU Cost Attribution by Namespace** | Azure Cost Management API + Kubernetes labels, cost per lab namespace, cost per request | 💰 🟡 | Both |
| L72 | **Idle GPU Waste Quantification** | Measure actual idle GPU hours across all prior labs, calculate wasted spend, build idle alert | 💰 🟢 | T4 |

**L71 detail (2-day):** Apply consistent cost labels to all namespaces (`cost-center`, `lab`, `phase`). Use Azure Cost Management to pull namespace-level spend. Cross-reference with Prometheus GPU utilization to compute: cost per useful token, cost per idle GPU-hour, cost efficiency ratio per lab. This becomes the FinOps benchmark.

---

### Week 42 · Dec 16 – Dec 22
**Theme: Spot Instances & Cost Optimization**

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L73 | **Spot GPU Nodepool** | Azure Spot nodepool setup, `--priority Spot`, eviction policy, toleration for spot nodes | 💰 🟡 | T4 |
| L74 | **Spot Reclaim Simulation** | Manually evict spot node, observe: pod displacement, requeue, reschedule, model reload, TTR | 💰 🔴 🟡 | T4 |
| L75 | **Spot vs On-Demand Cost Model** | 100% spot vs 80%/20% hybrid vs 100% on-demand: cost vs p99 availability — real numbers | 💰 🟢 | T4 |

---

### Week 43 · Dec 16 – Dec 22 — 📝 CONSOLIDATION WEEK

*Note: overlaps with holiday period — treat as flexible.*

- Write Blog Post 9: *"GPU Cost Attribution on AKS: What Your Azure Bill Isn't Telling You About LLM Inference"*
- Write Blog Post 10 (short): *"The Spot Instance Gamble: Real Reclaim Times and Availability Numbers for GPU Inference"*
- Build the **FinOps Reference Sheet**: cost per 1K tokens across every lab GPU SKU and config tested
- Tag repo: `v0.6.0-finops`

---

# PHASE 8 — CAPSTONE
## *Assemble everything. Run it clean. Document it completely.*
### Weeks 44–45 · Dec 23 – Dec 31 · 3 labs

---

### Week 44–45 · Dec 23 – Dec 31

| Lab | Name | Concepts | Type | GPU |
|-----|------|----------|------|-----|
| L76 | **The Full Stack: Assembly** | Deploy all components: vLLM + LoRA + RAG + KEDA + NGINX + Qdrant + Observability in one namespace | 🟡 | A100 |
| L77 | **Production Hardening** | NetworkPolicies, PDBs, ResourceQuotas, Workload Identity, PrometheusRules, runbook | 🟡 | A100 |
| L78 | **The Year in Numbers** | Compile all baseline metrics, improvement deltas, cost model, architecture diagram | 📝 | — |

**L76 detail (2-day):** Namespace `lab-capstone`. Deploy the entire stack from scratch using only committed Helm values. No improvisation. Time the full deployment. Run the L06 load test on the full pipeline. Record all 20 key metrics simultaneously. This is the demo-ready, screenshot-ready, blog-ready state.

**L77 detail (2-day):** Apply all hardening from the reliability and security labs. Deny-by-default NetworkPolicies. PDB on vLLM. ResourceQuota on the namespace. Spot + on-demand mixed nodepool. Run the chaos test suite (L65–L70) against the hardened stack. Document what survived and what didn't.

**L78:** Write the capstone blog post. Compile the year's numbers into a single reference table. Final repo tag: `v1.0.0`.

---

# FULL SCHEDULE SUMMARY

| Week | Dates | Labs | Phase | Theme | GPU |
|------|-------|------|-------|-------|-----|
| 01 | Feb 25 – Mar 03 | L01, L02 | Foundation | Observability + GPU metrics | T4 |
| 02 | Mar 04 – Mar 10 | L03, L04 | Foundation | Alerting + Loki | None |
| 03 | Mar 11 – Mar 17 | L05, L06 | Foundation | vLLM deploy + load baseline | T4 |
| 04 | Mar 18 – Mar 24 | L07, L08 | Foundation | K8s scheduler + GPU affinity | T4 |
| 05 | Mar 25 – Mar 31 | L09, L10 | Foundation | Storage + Identity | T4 |
| 06 | Apr 01 – Apr 07 | 📝 | Foundation | Blog + repo cleanup | — |
| 07 | Apr 08 – Apr 14 | L11, L12 | GPU Internals | KV cache budget + eviction | T4 |
| 08 | Apr 15 – Apr 21 | L13, L14 | GPU Internals | Continuous batching + chunked prefill | T4 |
| 09 | Apr 22 – Apr 28 | L15, L16 | GPU Internals | Quantization comparison | T4 |
| 10 | Apr 29 – May 05 | L17, L18 | GPU Internals | Prefix caching + speculative decoding | T4 |
| 11 | May 06 – May 12 | L19, L20 | GPU Internals | Tensor + pipeline parallelism | 2×T4 |
| 12 | May 13 – May 19 | L21, L22 | GPU Internals | Context window + throughput modes | T4 |
| 13 | May 20 – May 26 | L23, L24 | GPU Internals | T4 vs A100 SKU comparison | Both |
| 14 | Jun 03 – Jun 09 | 📝 | GPU Internals | Blog + dashboards | — |
| 15 | Jun 10 – Jun 16 | L25, L26 | Autoscaling | HPA + custom metrics | None |
| 16 | Jun 17 – Jun 23 | L27, L28 | Autoscaling | KEDA intro + LLM queue scaling | T4 |
| 17 | Jun 24 – Jun 30 | L29, L30 | Autoscaling | GPU node cold start + warm pool | T4 |
| 18 | Jul 01 – Jul 07 | L31, L32 | Autoscaling | Scale to zero + warm floor | T4 |
| 19 | Jul 08 – Jul 14 | L33, L34 | Autoscaling | Predictive scaling + lag measurement | T4 |
| 20 | Jul 15 – Jul 21 | L35, L36 | Autoscaling | Multi-tier scaling + Redis queue | T4 |
| 21 | Jul 22 – Jul 28 | L37, L38 | Autoscaling | Ingress rate limiting + canary | T4 |
| 22 | Jul 29 – Aug 04 | 📝 | Autoscaling | Blog + decision matrix | — |
| 23 | Aug 05 – Aug 11 | L39, L40 | RAG | Qdrant deploy + indexing | None |
| 24 | Aug 12 – Aug 18 | L41, L42 | RAG | Embedding CPU vs GPU | T4 |
| 25 | Aug 19 – Aug 25 | L43, L44 | RAG | First RAG pipeline + latency decomp | T4 |
| 26 | Aug 26 – Sep 01 | L45, L46 | RAG | top-K + HNSW tuning | T4 |
| 27 | Sep 02 – Sep 08 | L47, L48 | RAG | Qdrant vs pgvector + hybrid search | None |
| 28 | Sep 09 – Sep 15 | L49, L50 | RAG | RAG under load + multi-tier scale | T4 |
| 29 | Sep 16 – Sep 22 | L51, L52 | RAG | Reranking + prefix cache for RAG | T4 |
| 30 | Sep 23 – Sep 29 | 📝 | RAG | Blog + RAG architecture diagram | — |
| 31 | Sep 30 – Oct 06 | L53, L54 | Adv. Serving | LoRA basics + memory budget | A100 |
| 32 | Oct 07 – Oct 13 | L55, L56 | Adv. Serving | LoRA hot-swap + routing service | A100 |
| 33 | Oct 14 – Oct 20 | L57, L58 | Adv. Serving | Triton repo + dynamic batching | A100 |
| 34 | Oct 21 – Oct 27 | L59, L60 | Adv. Serving | Triton ensemble + vLLM benchmark | A100 |
| 35 | Oct 28 – Nov 03 | L61, L62 | Adv. Serving | Inference gateway + A/B testing | T4 |
| 36 | Nov 04 – Nov 10 | 📝 | Adv. Serving | Blog + serving decision framework | — |
| 37 | Nov 11 – Nov 17 | L63, L64 | Reliability | Probes + PDBs | T4 |
| 38 | Nov 18 – Nov 24 | L65, L66 | Reliability | OOM injection + CrashLoop | T4 |
| 39 | Nov 25 – Dec 01 | L67, L68 | Reliability | Node drain + resource starvation | T4 |
| 40 | Dec 02 – Dec 08 | L69, L70 | Reliability | NetworkPolicy + storage chaos | T4 |
| 41 | Dec 09 – Dec 15 | L71, L72 | FinOps | Cost attribution + idle waste | Both |
| 42 | Dec 16 – Dec 22 | L73, L74, L75 | FinOps | Spot instances + cost model | T4 |
| 43 | Dec 16 – Dec 22 | 📝 | FinOps | Blog + FinOps reference sheet | — |
| 44 | Dec 23 – Dec 29 | L76, L77 | Capstone | Full stack + hardening | A100 |
| 45 | Dec 30 – Dec 31 | L78 | Capstone | Year in numbers + final blog | — |

**Total: 78 labs · 10 blog posts · 8 phases · 45 weeks**

---

# BLOG POST CALENDAR

| # | Publish (approx.) | Title |
|---|-------------------|-------|
| 1 | Early April | *Before You Optimize: Instrumenting GPU Inference on AKS* |
| 2 | Mid June | *Inside the KV Cache: What vLLM's Memory Model Means for Your Latency* |
| 3 | Mid June | *fp16 vs AWQ: The Quantization Decision Tree for T4 Deployments* |
| 4 | Late July | *KEDA for LLM Inference: Why Scale-to-Zero Breaks Your SLO* |
| 5 | Late September | *Where Does RAG Actually Spend Its Time? A Prometheus-Level Breakdown* |
| 6 | Late September | *Qdrant vs pgvector: The Pragmatic Comparison Nobody Finishes* |
| 7 | Early November | *One GPU, Three Personalities: LoRA Hot-Swapping in Production* |
| 8 | Early November | *vLLM vs Triton: A Serving Infrastructure Decision Framework* |
| 9 | Mid December | *GPU Cost Attribution on AKS: What Your Azure Bill Isn't Saying* |
| 10 | Late December | *12 Months, 78 Labs: What I Learned Building LLM Infrastructure on AKS* |

---

# GITHUB REPO STRUCTURE

```
ai-infra-labs-2026/
├── README.md                      # Lab index + baseline numbers table
├── CURRICULUM.md                  # This document
├── terraform/
│   └── aks/                       # Cluster + nodepool configs
├── helm-values/
│   ├── lab01/ ... lab78/          # One folder per lab
├── dashboards/
│   └── grafana/                   # All dashboard JSONs (versioned)
├── load-tests/
│   └── locust/                    # Standard fixtures (reused across labs)
├── scripts/
│   ├── scale-gpu-up.sh
│   ├── scale-gpu-down.sh
│   └── teardown-namespace.sh
├── blog/
│   └── posts/                     # Drafts per phase
└── results/
    └── baselines/                 # L06 baseline numbers — never deleted
```

---

*Curriculum v2.0 · AI Infrastructure Lab Series 2026 · Feb 25 – Dec 31*
*78 labs · 10 blog posts · Azure AKS · GPU-first · FinOps-aware · Blog-ready*
