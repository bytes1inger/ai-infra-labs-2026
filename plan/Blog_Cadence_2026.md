# Blog Cadence 2026
### 2 posts/week · 1 Infra concept · 1 AI concept · ~45 weeks
**Target: ~90 posts · Minimum 2 pages each · Code-heavy · Screenshot-led**

---

## The Format Rule

Every post fits one of two slots:

| Slot | Type | Voice | Length |
|------|------|-------|--------|
| **Monday** | 🔧 Infra Concept | "Here's how Kubernetes handles X" | 2–4 pages |
| **Thursday** | 🤖 AI Concept | "Here's what vLLM/RAG/LoRA actually does" | 2–6 pages |

**What "2 pages" means in practice:**
- 1 clear concept
- 1 architecture diagram or terminal screenshot
- 1–3 real code blocks (Helm values, PromQL, Python, bash — whatever ran in the lab)
- 1 "what I actually observed" section with real numbers or a Grafana screenshot
- 1 production takeaway sentence

No padding. No "in this post we will…" intros. Start with the thing.

---

## Post Anatomy (both types)

```
Title:   [Specific claim, not topic] 
         ✅ "KEDA's Prometheus Scaler Has a 15-Second Lag Floor You Need to Plan For"
         ❌ "Introduction to KEDA Autoscaling"

Hook:    One sentence. The problem or the surprising finding.

Code/Diagram: The thing itself. Annotated.

What I observed: Real numbers, real Grafana screenshot, real kubectl output.

The tradeoff: What this approach costs you.

One production rule: Italic. Bolded. Memorable.
```

---

## Weekly Pairing Logic

Each week's two posts are **paired to that week's labs**. The infra post covers the Kubernetes/platform mechanic. The AI post covers the model-serving or pipeline concept. They share the same lab namespace and the same Grafana screenshots.

**Example — Week 16 (KEDA + LLM Scaling):**
- 🔧 Monday: *"How to Wire a KEDA ScaledObject to a Prometheus Metric (with the gotchas)"*
- 🤖 Thursday: *"Scaling vLLM on Queue Depth: What KEDA Sees vs What Your GPU Actually Does"*

Same lab. Same data. Two different audiences reading two different angles.

---

## Full Blog Calendar

### PHASE 1 · Foundation (Weeks 1–6)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 01 | Feb 25 – Mar 03 | Prometheus ServiceMonitor: The CRD Nobody Reads Until Something Doesn't Scrape | DCGM Exporter: The 12 GPU Metrics That Actually Matter for LLM Inference |
| 02 | Mar 04 – Mar 10 | Writing Multi-Window Burn Rate Alerts That Don't Cry Wolf | Extracting LLM Latency from Unstructured Logs with Loki's JSON Parser |
| 03 | Mar 11 – Mar 17 | GPU Tolerations and Node Affinity: Why Your Pod is Pending and How to Fix It | vLLM Cold Start on AKS: Where the 3 Minutes Actually Go |
| 04 | Mar 18 – Mar 24 | `nvidia.com/gpu` as an Extended Resource: What the Kubernetes Scheduler Actually Does With It | The vLLM `/metrics` Endpoint: A Field Guide to Every Gauge and Histogram |
| 05 | Mar 25 – Mar 31 | Azure Disk vs Azure File for Model Weight Caching: The PVC Decision You Get Wrong Once | Workload Identity for HuggingFace: No More Tokens in Environment Variables |
| 06 | Apr 01 – Apr 07 | *(Consolidation — catch up if behind)* | *(Consolidation — catch up if behind)* |

---

### PHASE 2 · GPU Serving Internals (Weeks 7–14)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 07 | Apr 08 – Apr 14 | Reading DCGM's Memory Metrics: FB_USED vs FB_FREE vs What vLLM Reports | KV Cache Budget: The Formula Behind `gpu_memory_utilization` |
| 08 | Apr 15 – Apr 21 | Parsing vLLM Scheduler Logs in Loki to See Batch Composition in Real Time | Continuous Batching vs Static Batching: Why the Default Changed Everything |
| 09 | Apr 22 – Apr 28 | Deploying AWQ-Quantized Models on AKS: The Helm Values That Actually Matter | fp16 vs AWQ vs GPTQ on a T4: Real Throughput Numbers, Not Marketing |
| 10 | Apr 29 – May 05 | Prometheus Recording Rules for LLM Workloads: The 5 I Run in Every Cluster | Prefix Caching in vLLM: How Shared System Prompts Become Free GPU Memory |
| 11 | May 06 – May 12 | Scheduling a 2×T4 Pod: Why `nvidia.com/gpu: 2` Isn't Enough | Tensor Parallelism vs Pipeline Parallelism: The Communication Overhead You're Not Measuring |
| 12 | May 13 – May 19 | ResourceQuota for GPU Namespaces: Preventing Noisy Neighbours on Shared Clusters | `max_model_len` Is Not a Safety Net: What Happens When Context Hits the Ceiling |
| 13 | May 20 – May 26 | AKS Nodepool Sizing for GPU SKU Comparison: How to Run a Fair Benchmark | T4 vs A100 for 7B Models: The Cost-per-Token Math Nobody Publishes |
| 14 | Jun 03 – Jun 09 | *(Consolidation)* | *(Consolidation)* |

---

### PHASE 3 · Autoscaling (Weeks 15–22)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 15 | Jun 10 – Jun 16 | HPA v2 Custom Metrics: Wiring Prometheus Adapter Without the YAML Nightmare | Why CPU-based HPA Fails for LLM Pods (and What to Use Instead) |
| 16 | Jun 17 – Jun 23 | KEDA ScaledObject: The Fields That Actually Control Scaling Behavior | Scaling vLLM on `num_requests_waiting`: Trigger Thresholds That Make Sense |
| 17 | Jun 24 – Jun 30 | GPU Node Cold Start on AKS: Every Timestamp in the Provisioning Chain | The Hidden Cost of Scale-to-Zero: What "0 Replicas" Actually Means for Your First Request |
| 18 | Jul 01 – Jul 07 | KEDA `minReplicaCount: 0` in Production: The Config That Breaks Your SLO | Keepalive Patterns for Warm LLM Pods: Fake Requests vs Real Cost Floors |
| 19 | Jul 08 – Jul 14 | Cron-Based KEDA Scalers: Pre-Scaling Before Traffic Arrives | Measuring Autoscaling Lag in 3 Segments: Trigger Lag, Provision Lag, Readiness Lag |
| 20 | Jul 15 – Jul 21 | Redis as a KEDA Scaler Source: Decoupling Client Traffic from GPU Pressure | Scaling the Embedding Tier Independently: Why CPU Pods Should Never Compete With GPU Pods |
| 21 | Jul 22 – Jul 28 | NGINX Rate Limiting for LLM APIs: Token Bucket Config That Protects GPU Pods | Canary Deployments for Model Versions: How to Ship a New Model Without a Rollback Story |
| 22 | Jul 29 – Aug 04 | *(Consolidation)* | *(Consolidation)* |

---

### PHASE 4 · RAG Systems (Weeks 23–30)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 23 | Aug 05 – Aug 11 | Qdrant on AKS: The Helm Values and PVC Setup Nobody Shows You | HNSW Parameters Demystified: `m` and `ef_construction` Are Not Knobs to Ignore |
| 24 | Aug 12 – Aug 18 | Running Embedding Models as a Kubernetes Service: CPU vs GPU Deployment Patterns | all-MiniLM-L6-v2 vs Larger Embedding Models: When Bigger Isn't Worth the GPU Cost |
| 25 | Aug 19 – Aug 25 | Instrumenting a FastAPI RAG Service with Prometheus: Histogram Per Stage | End-to-End RAG Latency: Where the 800ms Actually Goes (With Real Prometheus Data) |
| 26 | Aug 26 – Sep 01 | Qdrant Collection Config for Production: Replication, Sharding, and Persistence | top-K Retrieval Tuning: The Point Where More Context Hurts More Than It Helps |
| 27 | Sep 02 – Sep 08 | pgvector on AKS: Deploying PostgreSQL With the Vector Extension and a Real Index | Qdrant vs pgvector: A Side-by-Side Benchmark on the Same 100K Document Corpus |
| 28 | Sep 09 – Sep 15 | Kubernetes Jobs for Async RAG Ingestion: Bulk Indexing Without Blocking Your API | RAG Under Load: Which Tier Breaks First and How to Know Before It Does |
| 29 | Sep 16 – Sep 22 | NetworkPolicy for RAG Pipelines: Deny-by-Default Between Embedding, DB, and Generation | Cross-Encoder Reranking: The Latency Cost of a 30% Retrieval Quality Improvement |
| 30 | Sep 23 – Sep 29 | *(Consolidation)* | *(Consolidation)* |

---

### PHASE 5 · Advanced Serving (Weeks 31–36)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 31 | Sep 30 – Oct 06 | Kubernetes Secrets for LoRA Adapter Weights: Mounting From Azure Blob Without Credentials in Env | vLLM Multi-LoRA: How `--enable-lora` Partitions GPU Memory Across Adapters |
| 32 | Oct 07 – Oct 13 | Sidecar Routing Service Pattern: Directing Traffic by Header Without a Full Service Mesh | LoRA Hot-Swap Benchmark: 1 Server × 3 Adapters vs 3 Servers × 1 Adapter — The Real Numbers |
| 33 | Oct 14 – Oct 20 | Triton Model Repository on Azure File Share: Structure, Versioning, and Hot Reload | Triton's Python Backend: When You Need Custom Preprocessing Logic Before Inference |
| 34 | Oct 21 – Oct 27 | Triton Ensemble Pipelines: Wiring Models as a DAG With a Single Request Entry Point | vLLM vs Triton for 7B Inference: When the Overhead of Flexibility Costs You Throughput |
| 35 | Oct 28 – Nov 03 | LiteLLM as a Model Gateway on Kubernetes: Multi-Backend Routing With One OpenAI Interface | Model A/B Testing in Production: How to Split Traffic and Attribute Latency Differences |
| 36 | Nov 04 – Nov 10 | *(Consolidation)* | *(Consolidation)* |

---

### PHASE 6 · Reliability & Chaos (Weeks 37–40)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 37 | Nov 11 – Nov 17 | Startup Probes for Slow-Loading Model Servers: The Config That Stops Premature Restarts | PodDisruptionBudget for GPU Workloads: What `minAvailable: 1` Actually Protects You From |
| 38 | Nov 18 – Nov 24 | OOMKilled vs CUDA OOM: Two Different Failure Modes, Two Different Kubernetes Responses | Injecting GPU OOM Into vLLM: How to Trigger It Safely and What Recovery Looks Like |
| 39 | Nov 25 – Dec 01 | `kubectl drain` With GPU Pods: The PDB Interaction Nobody Tests Until Prod | Node Drain Recovery Timeline: GPU Reschedule → Driver Init → Model Load → First Token |
| 40 | Dec 02 – Dec 08 | `tc netem` for Storage Latency Injection on Kubernetes Pods: The Safe Way | Circuit Breakers for Qdrant: Handling Storage Degradation Without Cascading RAG Failures |

---

### PHASE 7 · FinOps (Weeks 41–43)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 41 | Dec 09 – Dec 15 | Azure Cost Management + Kubernetes Labels: How to Get Per-Namespace GPU Spend | Cost Per 1K Tokens on AKS: The Calculation That Includes Idle Time (Most Don't) |
| 42 | Dec 16 – Dec 22 | Azure Spot GPU Nodepools: The Nodepool Config, the Toleration, and the Eviction Handler | Spot Reclaim Recovery Time: Real Measurements of LLM Pod Displacement and Reschedule |
| 43 | Dec 16 – Dec 22 | *(Consolidation)* | *(Consolidation)* |

---

### PHASE 8 · Capstone (Weeks 44–45)

| Week | Dates | 🔧 Infra Post | 🤖 AI Post |
|------|-------|--------------|-----------|
| 44 | Dec 23 – Dec 29 | The Full AKS AI Stack: Every Helm Chart, Every Namespace, Every NetworkPolicy | Production Hardening a vLLM Deployment: The 8 Things Default Config Gets Wrong |
| 45 | Dec 30 – Dec 31 | *(Year wrap — one long post covering infra lessons)* | *(Year wrap — one long post covering AI serving lessons)* |

---

## Total Post Count

| Category | Posts |
|----------|-------|
| 🔧 Infra posts | ~38 |
| 🤖 AI concept posts | ~38 |
| 📝 Consolidation/wrap posts | ~8 |
| **Total** | **~84 posts** |

---

## Content Principles

**Code blocks are the content.** Not descriptions of code. The actual Helm values, the actual PromQL, the actual `kubectl` output. Annotate inline.

```yaml
# This is the line most people miss.
# Without stabilizationWindowSeconds, KEDA scales down 
# the moment queue_depth hits 0 — even mid-request.
behavior:
  scaleDown:
    stabilizationWindowSeconds: 120  # ← this
    policies:
      - type: Pods
        value: 1
        periodSeconds: 60
```

**Screenshots replace paragraphs.** A Grafana panel showing TTFT spiking at concurrency=16 says more than 200 words. Caption it with one sentence.

**Real numbers or don't publish.** Every post has at least one table or inline measurement from the actual lab run. Estimated numbers are labeled as such.

**The title is a claim, not a topic.** Readers click to find out if the claim holds up. They stay for the code.

---

## Platform

Recommend: **Hashnode** (dev audience, good code rendering, SEO, free custom domain) or **Substack** (if you want newsletter growth alongside the blog). GitHub repo README links to every post. Posts link back to the lab's Helm values in the repo.

One post. One concept. Ship it.
