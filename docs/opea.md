# OPEA Compatibility

Darta agents are **OPEA-compatible**.

[OPEA (Open Platform for Enterprise AI)](https://opea-project.org) is an open standard for building composable AI microservices that work together in larger enterprise systems (megaservices). It is language-agnostic — the standard specifies required HTTP endpoints, health check shapes, tracing headers, and Kubernetes packaging. The GenAIComps Python library is the reference implementation, not a requirement.

Darta implements the OPEA service interface so agents can be used as OPEA components without modification to your agent code.

---

## What this means in practice

- Darta agents export OPEA-compatible wrappers automatically via `darta export opea`
- L1 (PoC) and L2 (Production) compliance passes automatically for any agent, regardless of implementation language
- Exported agents can be composed with other OPEA components — LLM services, retrieval, reranking, guardrails — in a megaservice pipeline
- The choice of Go, Python, Rust, Spring Boot, Java, or WASM is yours; the export adapts to each

---

## OPEA service types Darta implements

| OPEA Service | How Darta maps it | Status |
|---|---|---|
| LLM | Domain agents via Dhil routing (`/v1/chat/completions`) | Live |
| EMBEDDING | Context service ML layer (`/v1/embeddings`) | Live |
| RETRIEVAL | Data Tank hydration (`/v1/retrieval`) | Live |
| RERANKING | Tank hybrid retrieval (`/v1/reranking`) | Live |
| DATAPREP | Tank ingestion (`/v1/dataprep`) | Live |
| GUARDRAILS | PolicySpec evaluation (`/v1/guardrails`) | Live |
| ASR / TTS | — | Not implemented |

---

## Export

```bash
# Basic export — wrapper + Dockerfile.opea + opea-component.yaml
darta export opea --agent specs/agents/my-agent.yaml

# With Kubernetes Helm chart
darta export opea --agent specs/agents/my-agent.yaml --helm

# With GMC pipeline CRD for megaservice wiring
darta export opea --agent specs/agents/my-agent.yaml --helm --gmc

# Target a specific OPEA version
darta export opea --agent specs/agents/my-agent.yaml --version 1.5
```

Output is written to `{agent-dir}/opea/`:

```
opea/
  wrapper/           (main.go, service.py, main.rs, or OpeaController.java)
  Dockerfile.opea    (FROM your existing agent image)
  opea-component.yaml
  helm/              (if --helm)
  gmc-pipeline.yaml  (if --gmc)
```

---

## Compliance tiers

| Tier | Scope | Darta status |
|---|---|---|
| **L1 (PoC)** | Health check, containerisation, env-var config, basic throughput | Automatic |
| **L2 (Production)** | OpenAI-compat endpoint, Helm chart, pod security, tracing, rate limiting, auth | Automatic |
| **L3 (Enterprise)** | Full certification audit, SLA guarantees, OPEA catalogue registration | Future — Dhruvia Labs working with OPEA project on certification path |

---

## How Darta's domain model maps to OPEA

Darta's GUARDRAILS endpoint (`/v1/guardrails`) runs the full OPA 3-layer PolicySpec evaluation — platform base policy, enterprise policy, and use-case policy. This is a stronger guarantee than typical guardrail layers: every invocation goes through the same policy pipeline that governs runtime execution.

The RETRIEVAL endpoint returns context hydrated from Data Tanks, enriched by the OntologySpec graph. An OPEA megaservice that calls a Darta RETRIEVAL service gets not just matching documents but entity-linked context from the declared domain model.
