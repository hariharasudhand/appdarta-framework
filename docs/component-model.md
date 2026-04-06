# Component Model

Understanding what the framework provides and what you build is the foundation of working with AppDarta effectively.

---

## The Core Principle

> **Framework = execution engine (binary). Your vertical = domain logic (specs + WASM).**

The framework binary never changes when you build a new vertical. You extend framework behavior entirely through YAML specs and compiled WASM modules that the framework loads at runtime.

---

## Framework Components (binary, you configure)

These are compiled and distributed. You do not have access to their source. You configure them; you do not modify them.

### `appdarta` / `darta` — CLI and Gateway

One binary that does everything:

- **Project lifecycle**: `darta project init`, `darta build project`, `darta test project`, `darta deploy plan`
- **Spec validation**: `darta validate --file`, `--dir`, `--project`
- **Service management**: `darta services start/stop/ps`, `darta stack up/down`
- **Configuration**: `darta extend config`
- **Gateway execution**: `darta gateway serve` — loads your `OrchestrationSpec` and routes agent invocations

Configure it:

```bash
darta gateway serve --listen 0.0.0.0:18110 --project .
darta extend config --service gateway --key listen --value 0.0.0.0:18110
```

### `appdarta-spec` — Spec Validator

Validates your YAML specs against the 31 core framework schemas. Used by `darta validate` under the hood. Accessible directly for CI use.

```bash
darta validate --project .        # validate everything
darta validate --file my-spec.yaml
darta validate --dir specs/       --strict
```

### `wasmtime-host` — WASM Execution Host

Executes your compiled WASM agent modules in strict isolation. Injects host functions your agent code calls:

| Host function | What it does |
|---|---|
| `appdarta_tank_read` | Reads context chunks from a declared tank |
| `appdarta_ai_complete` | Calls an AI model via your role binding |
| `appdarta_log` | Structured log from inside the WASM sandbox |

Configure it:

```bash
darta services start --service runtime-host
darta services start --service runtime-host --instance isolated --port 18092

# Capacity tuning (env vars)
APPDARTA_WASMTIME_MAX_CONCURRENT=10
APPDARTA_CONTEXT_MAX_CONCURRENT_READS=20
```

### `context-service` — Tank Storage and Retrieval

Manages your data tanks: stores documents, generates embeddings, handles vector search, freshness tracking, and episodic memory. Runs as a Docker container.

Default port: `18001`

```bash
darta services start --service context-service               # local (from source)
darta services start --service context-service --instance staging --port 18002

# Storage backend overrides
CHROMA_URL=http://my-chromadb:8000
POSTGRES_URL=postgresql://...
REDIS_URL=redis://...
```

### Core Schemas

31 JSON schema files in `specs/core/`. They define the full spec language available to vertical developers. Distributed in the framework package — not editable.

---

## Your Vertical Components (source, you write)

These are what you create. The framework reads them at runtime — none of this is compiled into the framework binary.

### YAML Spec Files

| Block | File pattern | What it declares |
|---|---|---|
| `AgentSpec` | `specs/agents/*.yaml` | Agent identity, runtime mode (WASM/HTTP/gRPC/process), capabilities, model role, policy binding |
| `FlowSpec` | `specs/flows/*.yaml` | Multi-agent graph: steps, dependencies, parallel waves, fan-out/gather |
| `PolicySpec` | `specs/policies/*.yaml` | Evaluation components, decision rules, escalation and approval paths |
| `DataTankSpec` | `specs/tanks/*.yaml` | Tank structure: partitions, embedding model, canonical type, freshness rules |
| `OrchestrationSpec` | `specs/orchestration/*.yaml` | Gateway execution plan: target agent or flow, in/out pipeline, concurrency, async mode, callbacks |
| `UseCaseSpec` | `specs/analysis/*.yaml` | Business problem definition (lifecycle gate input) |
| `AgentDesignSpec` | `specs/designs/*.yaml` | Solution architecture (codegen input) |

### WASM Agent Modules

Your agent logic. Write it in any language that compiles to WebAssembly (Rust, Go via TinyGo, C, Python via Emscripten). The framework only sees the compiled `.wasm` — never your source.

```
runtime/
  my-agent.wasm       ← compiled from your source
```

Your WASM calls the host functions injected by `wasmtime-host`. You call them; the framework implements them.

### Tank Documents

Raw documents ingested into your tanks. PDFs, JSON records, clinical notes, transaction logs — whatever your domain requires.

```bash
darta tank ingest --tank my-tank --partition my-partition --file ./data/records.json
```

---

## How Your Specs Load Into the Framework at Runtime

```
You write:                             Framework loads at runtime:
────────────────────────────────────   ──────────────────────────────────────────
specs/orchestration/plan.yaml      →   darta gateway serve   (builds execution plan)
specs/agents/my-agent.yaml         →   gateway               (resolves agent target)
runtime/my-agent.wasm              →   wasmtime-host         (executes in sandbox)
specs/tanks/my-tank.yaml           →   context-service       (builds tank)
specs/policies/my-policy.yaml      →   gateway policy engine (evaluates at invocation)
specs/flows/my-flow.yaml           →   gateway executor      (multi-agent graph)
```

You do not recompile any framework binary when your agent logic changes. You recompile your `.wasm` and redeploy.

---

## What Is Fixed vs What You Configure

### Fixed in the binary (not configurable by vertical developers)

- Pipeline handler contract: auth → tank-enrichment → policy → execution → result-validator → audit-log
- A2A message routing protocol
- Policy evaluation layer semantics (framework-base / enterprise-extension / use-case)
- WASM host function signatures
- Async queue mechanics and callback protocol
- Core schema types and their field contracts
- Tank hydration and reranking algorithm

### Configurable without source changes

Via `darta extend config`, env vars, and spec declarations:

- Service ports and bind addresses (all services)
- Storage backend URLs (context-service)
- WASM concurrency limits (runtime-host)
- Gateway listen address and project path
- AI model role bindings (`model-registry.yaml` overlay)
- Policy components and rules (your `PolicySpec`)
- Concurrency limits per plan (`OrchestrationSpec` `max_concurrent_agents`)
- Async mode, callback paths, timeout per plan
- Multiple named instances (all services support `--instance`)

---

## At a Glance

```
┌─────────────────────────────────────────────────────────────────┐
│                   FRAMEWORK  (binary, installed)                 │
│                                                                  │
│  ┌──────────────┐  ┌─────────────────┐  ┌────────────────────┐  │
│  │  appdarta    │  │  wasmtime-host  │  │  context-service   │  │
│  │  CLI + GW    │  │  WASM runtime   │  │  tank storage      │  │
│  │  :18110      │  │  :18091         │  │  :18001            │  │
│  └──────────────┘  └─────────────────┘  └────────────────────┘  │
│              ↑ configurable via darta extend config ↑            │
└──────────────────────┬──────────────────────────────────────────┘
                       │ loads at runtime
┌──────────────────────▼──────────────────────────────────────────┐
│                  YOUR VERTICAL  (source + specs)                 │
│                                                                  │
│  specs/agents/       specs/flows/        specs/orchestration/   │
│  specs/policies/     specs/tanks/        runtime/*.wasm          │
│                                                                  │
│  You write these. The framework validates and executes them.     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Framework Version Pinning

Your vertical pins the exact framework version it requires:

```yaml
# appdarta.framework.yaml
spec:
  required_framework_version: "1.2.3"
  schema_bundle_version: "1.2.3"
```

`darta doctor` checks this binding. Framework updates are an explicit, controlled action — never automatic. `darta project bootstrap` installs the pinned version.
