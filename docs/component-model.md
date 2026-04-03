# AppDarta Component Model

Understanding what the framework provides and what you build is the foundation of working with AppDarta effectively.

---

## The Core Principle

> **Framework = execution engine (binary). Your vertical = domain logic (source + specs).**

The framework binary never changes when you build a new vertical. You extend framework behavior entirely through YAML specifications and compiled WASM modules that the framework loads at runtime.

---

## Core Blocks — Framework-Provided, Binary

These are compiled and distributed as binaries. You do not have access to their source code. You configure them; you do not modify them.

### `appdarta` / `darta` — CLI and Gateway

The single binary that covers everything:

- **Project lifecycle**: `darta project init`, `darta build project`, `darta test project`, `darta deploy plan`
- **Spec validation**: `darta validate --file`, `--dir`, `--project`
- **Service management**: `darta services start/stop/ps`, `darta stack up/down`
- **Configuration**: `darta extend config`
- **Gateway execution**: `darta gateway serve` — loads your `OrchestrationSpec`, routes agent invocations through your declared pipeline

**What you configure:**
```bash
darta gateway serve --listen 0.0.0.0:18110 --project .
darta gateway serve --listen 0.0.0.0:18111 --project ./other-vertical   # second instance
darta extend config --service gateway --key listen --value 0.0.0.0:18110
```

### `appdarta-spec` — Spec Validator

Validates your YAML spec files against the 31 core framework schemas. Used by `darta validate` under the hood.

**What you configure:** `--file`, `--dir`, `--project`, `--kind`, `--strict`

### `wasmtime-host` — WASM Execution Host

Executes your compiled WASM agent modules in strict isolation. Injects the host functions your WASM code calls:
- `appdarta_tank_read` — reads from your declared tank
- `appdarta_ai_complete` — calls an AI model via your role binding
- `appdarta_log` — structured logging

**What you configure:**
```bash
# Default instance
darta services start --service runtime-host

# Second instance on a different port, pointing to a different context-service
darta services start --service runtime-host --instance isolated --port 18092
darta extend config --service runtime-host --key context_service_url --value http://127.0.0.1:18002
```

Environment variables for capacity tuning:
```bash
APPDARTA_WASMTIME_MAX_CONCURRENT=10   # max parallel WASM executions
APPDARTA_CONTEXT_MAX_CONCURRENT_READS=20
```

### `context-service` — Tank Storage and Retrieval

Manages your data tanks: stores documents, generates embeddings, handles vector search and hydration. Runs as a Docker container.

**Default port**: 18001

**What you configure:**
```bash
darta services start --service context-service               # default
darta services start --service context-service --instance staging --port 18002

# Storage backend overrides (env vars)
CHROMA_URL=http://my-chromadb:8000
POSTGRES_URL=postgresql://...
REDIS_URL=redis://...
```

### Core Schemas (`specs/core/*.schema.json`)

31 JSON schemas defining every spec type the framework supports. Distributed in the framework package. Your YAML spec files are validated against these — they define the contract between your vertical and the framework.

Not editable. The schemas define the language you write your specs in.

---

## Custom Blocks — You Write These

These are the blocks you create for your vertical. The framework reads them at runtime — none of this gets compiled into the framework binary.

### YAML Spec Files (declarative, validated by `appdarta-spec`)

| Block | File Pattern | What It Does |
|---|---|---|
| `AgentSpec` | `specs/agents/*.yaml` | Declares an agent: runtime type (WASM/HTTP/gRPC), capabilities, model role, policy binding |
| `FlowSpec` | `specs/flows/*.yaml` | Multi-agent execution graph: steps, dependencies, parallel waves |
| `PolicySpec` | `specs/policies/*.yaml` | Policy components, evaluation rules, escalation and routing logic |
| `DataTankSpec` | `specs/tanks/*.yaml` | Tank structure: partitions, embedding model, canonical type, freshness rules |
| `OrchestrationSpec` | `specs/orchestration/*.yaml` | Gateway execution plan: target agent/flow, in/out pipeline, concurrency, async mode |
| `UseCaseSpec` | `specs/analysis/*.yaml` | Business problem definition (used in lifecycle gate) |
| `AgentDesignSpec` | `specs/designs/*.yaml` | Solution architecture (used in codegen) |

**Validate all your specs:**
```bash
darta validate --project .      # validate everything
darta validate --dir specs/     # validate a directory
darta validate --file specs/agents/my-agent.yaml   # validate one file
```

### WASM Agent Modules (compiled artifact)

Your agent logic. You write it in any language that compiles to WebAssembly (Rust, Go via TinyGo, C, Python via Emscripten). The framework never sees your source — only the `.wasm` artifact.

```
runtime/
  my-agent.wasm       ← your agent logic, compiled from source
```

The WASM module calls host functions injected by `wasmtime-host`. The framework contract defines what those host functions do — your WASM code calls them, the framework implements them.

### Tank Documents (raw data)

Documents you ingest into your tanks. PDFs, JSON records, clinical notes, financial transactions — anything your domain needs.

```bash
darta tank ingest --tank my-tank --partition my-partition --file ./data/records.json
```

---

## How Custom Blocks Load Into Core Blocks

```
You write:                           Framework loads at runtime:
──────────────────────────────────   ──────────────────────────────────────────
specs/orchestration/plan.yaml    →   darta gateway serve   (builds execution plan)
specs/agents/my-agent.yaml       →   gateway               (resolves agent target)
runtime/my-agent.wasm            →   wasmtime-host         (executes your logic)
specs/tanks/my-tank.yaml         →   context-service       (builds tank)
specs/policies/my-policy.yaml    →   gateway policy engine (evaluates at invocation)
specs/flows/my-flow.yaml         →   gateway executor      (multi-agent graph)
```

You do not recompile any framework binary when your agent logic changes. You recompile your `.wasm` module and redeploy.

---

## Default vs Custom — At a Glance

```
┌─────────────────────────────────────────────────────────────────┐
│                   FRAMEWORK (binary, default)                    │
│                                                                  │
│  ┌──────────────┐  ┌─────────────────┐  ┌────────────────────┐  │
│  │  appdarta    │  │  wasmtime-host  │  │  context-service   │  │
│  │  (CLI+GW)   │  │  (WASM runtime) │  │  (tank storage)    │  │
│  │             │  │                 │  │                    │  │
│  │  default:   │  │  default:       │  │  default:          │  │
│  │  :18110     │  │  :18091         │  │  :18001            │  │
│  └──────────────┘  └─────────────────┘  └────────────────────┘  │
│              ↑ configurable via darta extend config ↑            │
└─────────────────────────────────────────────────────────────────┘
                              ↑ loads at runtime ↑
┌─────────────────────────────────────────────────────────────────┐
│                  YOUR VERTICAL (source, custom)                  │
│                                                                  │
│  specs/agents/       specs/flows/        specs/orchestration/   │
│  specs/policies/     specs/tanks/        runtime/*.wasm          │
│                                                                  │
│  You write these. The framework validates and executes them.     │
└─────────────────────────────────────────────────────────────────┘
```

---

## What Is Fixed vs What You Customize

### Fixed in the framework binary (not configurable by vertical developers)

- Pipeline handler contract (auth, tank-enrichment, audit-log, result-validator)
- A2A message routing protocol
- Policy evaluation model and layer semantics (framework-base / enterprise-extension / use-case)
- WASM host function signatures
- Async queue mechanics and callback protocol
- Core schema types and their field contracts
- Tank hydration and reranking algorithm

### Configurable without changing source

Everything via `darta extend config`, env vars, and spec declarations:
- Service ports and bind addresses (all services)
- Storage backend URLs (context-service)
- WASM concurrency limits (runtime-host)
- Gateway listen address and orchestration spec path
- AI model role bindings (model-registry.yaml override)
- Policy components and evaluation rules (your PolicySpec)
- Concurrency limits per orchestration plan (OrchestrationSpec `max_concurrent_agents`)
- Async mode, callback paths, timeout per plan (OrchestrationSpec)
- Number of running instances (all services support `--instance`)

---

## Running Multiple Instances

Every core binary can run as multiple named instances:

```bash
# Run two independent gateway instances for two verticals
darta gateway serve --listen 127.0.0.1:18110 --project ./healthcare-vertical
darta gateway serve --listen 127.0.0.1:18111 --project ./finance-vertical

# Run two context-service instances (isolated tank namespaces)
darta services start --service context-service --instance default  --port 18001
darta services start --service context-service --instance tenant-b --port 18002

# See everything running
darta services ps
```

See [Multi-Instance Deployment](./multi-instance-deployment.md) for full details.

---

## Framework Version Pinning

Your vertical pins the exact framework version it requires:

```yaml
# appdarta.framework.yaml
spec:
  required_framework_version: "1.2.3"
  schema_bundle_version: "1.2.3"
```

The framework binary version must match. `darta doctor` checks this binding. `darta project bootstrap` installs the correct version.

This means your vertical always runs against a known framework version — framework updates are an explicit, controlled action, not automatic.
