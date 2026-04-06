# Architecture

AppDarta separates the framework-owned control plane from vertical-owned domain logic. Your team never touches the control plane — you configure it through specs and CLI flags.

---

## System Overview

```mermaid
flowchart TB
    subgraph operator["Operator / Developer"]
        CLI["darta CLI"]
        UI["Framework UI Shell"]
    end

    subgraph framework["Framework Control Plane (binary)"]
        GW["Gateway\n:18110"]
        RH["runtime-host\n:18091"]
        CS["context-service\n:18001"]
    end

    subgraph vertical["Your Vertical (source + specs)"]
        direction TB
        SPECS["YAML Specs\nagents · flows · policies\ntanks · orchestration"]
        WASM["WASM Modules\n(compiled agent logic)"]
        DOCS["Tank Documents\n(domain knowledge)"]
    end

    CLI -->|lifecycle, validate, build, deploy| GW
    CLI -->|tank ops, service management| CS
    UI -->|operator views| GW

    GW -->|invoke agent| RH
    GW -->|evaluate policy| GW
    GW -->|enrich context| CS
    RH -->|tank read| CS

    SPECS -->|loaded at runtime| GW
    WASM -->|executed by| RH
    DOCS -->|ingested into| CS
```

---

## Request Flow Through the Gateway

When a task is submitted to the gateway:

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant PolicyEngine
    participant ContextService
    participant RuntimeHost
    participant Agent

    Client->>Gateway: POST /invoke {task}
    Gateway->>Gateway: auth-handler (validate token/signature)
    Gateway->>ContextService: tank-enrichment-handler (fetch context chunks)
    Gateway->>PolicyEngine: policy check (pre-execution)
    alt policy blocks
        Gateway-->>Client: 403 / escalation response
    end
    Gateway->>RuntimeHost: invoke agent (WASM) or route to endpoint (HTTP/gRPC)
    RuntimeHost->>Agent: execute with injected host functions
    Agent-->>RuntimeHost: result
    RuntimeHost-->>Gateway: execution output
    Gateway->>Gateway: result-validator-handler
    Gateway->>Gateway: audit-log-handler
    Gateway-->>Client: response
```

For async invocations, the gateway queues the task and returns an invocation ID immediately. The client polls `/invocations/{id}` or receives a callback.

---

## Component Ownership

```mermaid
block-beta
  columns 2
  block:fw["Framework (binary)"]
    columns 1
    a["appdarta / darta\nCLI + gateway"]
    b["appdarta-spec\nSpec validator"]
    c["wasmtime-host\nWASM runtime host"]
    d["context-service\nTank storage"]
    e["Core schemas\n31 JSON schemas"]
  end
  block:vt["Your Vertical (source)"]
    columns 1
    f["AgentSpec YAML\nwho your agents are"]
    g["FlowSpec YAML\nhow they coordinate"]
    h["PolicySpec YAML\ndecision rules"]
    i["DataTankSpec YAML\nknowledge sources"]
    j["OrchestrationSpec YAML\ngateway execution plan"]
    k["WASM modules\ncompiled agent logic"]
  end
```

The framework reads your vertical's specs and WASM at runtime. Nothing in your vertical is compiled into a framework binary.

---

## Multi-Instance Topology

Each framework service can run as multiple independent named instances. This supports staging environments, multi-tenancy, and load distribution without any framework changes.

```mermaid
flowchart LR
    subgraph instances["Running Instances  (darta services ps)"]
        GW1["gateway:default\n:18110 → finance-vertical"]
        GW2["gateway:healthcare\n:18111 → healthcare-vertical"]
        RH1["runtime-host:default\n:18091"]
        RH2["runtime-host:isolated\n:18092"]
        CS1["context-service:default\n:18001"]
        CS2["context-service:staging\n:18002"]
    end

    GW1 --> RH1 --> CS1
    GW2 --> RH2 --> CS2
```

Start additional instances with:

```bash
darta services start --service context-service --instance staging --port 18002
darta services start --service runtime-host --instance isolated --port 18092
darta gateway serve --listen 127.0.0.1:18111 --project ./healthcare-vertical
```

---

## Policy Model

AppDarta uses a layered policy model:

```mermaid
flowchart TB
    FB["Framework Base Policy\n(framework-owned defaults and guardrails)"]
    EP["Enterprise Extension Policy\n(org-level overlays, declared in vertical)"]
    UC["Use-Case Policy\n(task-specific thresholds and approval rules)"]

    FB --> EP --> UC

    UC -->|evaluated at gateway| Decision{Decision}
    Decision -->|pass| Execution
    Decision -->|escalate| HumanApproval["Human Approval\nPOST /callbacks/approve"]
    Decision -->|block| Rejection
```

Your vertical writes `PolicySpec` files that contribute to the enterprise and use-case layers. The framework evaluates them at every gateway invocation. Framework-base policy is binary-owned and not overridable.

---

## Enterprise Registry

AppDarta supports both solo and team development through the enterprise registry.

| Mode | Manifest | Tank data |
|---|---|---|
| Local (default) | `~/.appdarta/enterprises/{slug}/` on each machine | local-embedded or local-dockerized |
| Distributed | same path, but is a git working tree | external Postgres (shared DSN) |

In distributed mode, the enterprise directory is a git working tree linked to a shared registry remote. `darta enterprise sync` pulls the latest manifest. `darta enterprise onboard` lets a new team member clone the registry and any registered project repos in one step.

API keys always remain local in `~/.appdarta/config` regardless of mode.

```mermaid
flowchart LR
    subgraph local["Developer machine"]
        EM["~/.appdarta/enterprises/{slug}/\n(enterprise.yaml + specs)"]
        APK["~/.appdarta/config\n(API keys — always local)"]
    end

    subgraph shared["Shared (distributed mode only)"]
        GR["Git Registry\n(manifest + common specs)"]
        PG["External Postgres\n(shared tank data)"]
    end

    EM <-->|git pull / push| GR
    EM -->|tank writes| PG
```

---

## AI Governance Model

```mermaid
flowchart LR
    MR["ModelRegistrySpec\n(framework config)"]
    RB["ModelRoleBindingSpec\n(vertical declaration)"]
    AS["AgentSpec\n(role reference)"]

    MR -->|available providers + models| RB
    RB -->|role → provider mapping| AS
    AS -->|runtime: appdarta_ai_complete| RH["wasmtime-host\n(host function)"]
    RH -->|token accounting + fallback| Provider["AI Provider"]
```

Vertical developers declare which business phases need AI and which framework role to use. The framework handles provider resolution, fallback chains, token accounting, and cost visibility. Provider SDK calls never appear in vertical business code.
