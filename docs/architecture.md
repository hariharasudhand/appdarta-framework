# Architecture

Darta Platform separates the platform-owned control plane from your domain code. You configure the platform through specs and the CLI — you never need to touch what runs underneath.

---

## The Big Picture

```mermaid
flowchart TB
    subgraph you["Your Team"]
        CLI["darta CLI"]
        UI["Wizard UI Shell"]
    end

    subgraph dhil["Darta Dhil — AI Routing"]
        TR["Tool Registry"]
        COS["ContextOS\nGovernance Config"]
    end

    subgraph platform["Darta Platform (binary)"]
        GW["Gateway\n:18110"]
        RH["Runtime Host\n:18091"]
        CS["Context Service\n:18001"]
    end

    subgraph vertical["Your Vertical"]
        SPECS["Specs\nagents · flows · policies · tanks"]
        WASM["Agent Logic\n(WASM / HTTP / gRPC)"]
        DOCS["Domain Knowledge\n(Tank documents)"]
    end

    subgraph forge["Darta Forge — Scanning"]
        SC["Dependency + structure scan"]
    end

    UI -->|wizard actions| TR
    CLI -->|lifecycle + build + deploy| GW
    TR -->|role-based routing| COS
    COS -->|dispatch| aitools["AI Tools\n(Ollama / Claude Code / gateway)"]

    GW -->|run agent| RH
    GW -->|check policy| GW
    GW -->|fetch context| CS
    RH -->|read tank| CS

    SPECS -->|loaded by| GW
    WASM -->|executed by| RH
    DOCS -->|ingested into| CS

    CLI -->|scan| SC
```

---

## How a Request Flows

When a task reaches the gateway:

```mermaid
sequenceDiagram
    participant You
    participant Gateway
    participant ContextService
    participant RuntimeHost
    participant Agent

    You->>Gateway: submit task
    Gateway->>Gateway: authenticate
    Gateway->>ContextService: fetch relevant context from Tank
    Gateway->>Gateway: evaluate policy
    alt policy blocks
        Gateway-->>You: blocked / escalation required
    end
    Gateway->>RuntimeHost: run agent
    RuntimeHost->>Agent: execute
    Agent-->>RuntimeHost: result
    RuntimeHost-->>Gateway: output
    Gateway->>Gateway: validate + audit log
    Gateway-->>You: response
```

Async tasks get an ID immediately. You poll for the result or receive a callback.

---

## What the Platform Owns vs What You Own

```mermaid
block-beta
  columns 2
  block:pw["Darta Platform (binary)"]
    columns 1
    a["darta CLI + gateway"]
    b["appdarta-spec — validator"]
    c["runtime-host — WASM execution"]
    d["context-service — Tank storage"]
    e["Darta Dhil — AI routing"]
    f["Darta Forge — scanning"]
  end
  block:vt["Your Vertical (source)"]
    columns 1
    g["AgentSpec — who your agents are"]
    h["FlowSpec — how they coordinate"]
    i["PolicySpec — decision rules"]
    j["DataTankSpec — knowledge sources"]
    k["OrchestrationSpec — gateway plan"]
    l["Agent logic — WASM / HTTP / gRPC"]
  end
```

The platform reads your vertical's specs and agent logic at runtime. Nothing in your vertical is compiled into a platform binary.

---

## Darta Dhil — AI Routing Layer

Every AI action in the wizard UI and CLI goes through Dhil. Dhil routes the prompt to the right tool based on the role of the task, the tools you have registered, and the active ContextOS config.

```mermaid
flowchart LR
    REQ["AI Request\n(wizard step / CLI)"]
    TR["Tool Registry\ntools.yaml"]
    COS["ContextOS\nActive Config"]
    TOOL["AI Tool\n(cli / http / gateway)"]

    REQ --> TR
    TR -->|role + priority| COS
    COS --> TOOL
```

### Two-level flow

The wizard runs AI in two levels:

1. **Local** — fast local model (e.g. Ollama) generates a first draft.
2. **Enhance with Dhil** — sends the draft to the higher-priority tool for a refined result.

This keeps the UI responsive while giving you full AI quality when you need it.

### ContextOS

ContextOS stores named AI governance configs. Each config maps task roles to specific tools and models. Activate a different config per project or environment — no spec changes needed.

---

## Darta Forge — Scanning Layer

Forge scans your vertical project for dependency issues, structural drift, and quality signals.

Currently: dependency organisation and scan results in the CLI.
Coming: scan results surfaced in the wizard UI, and Forge checks as part of the deploy gate.

---

## Policy Model

```mermaid
flowchart TB
    FB["Platform Base Policy\n(platform defaults and guardrails)"]
    EP["Enterprise Policy\n(org-level overlays)"]
    UC["Use-Case Policy\n(task-specific rules)"]

    FB --> EP --> UC

    UC -->|evaluated at gateway| Decision{Decision}
    Decision -->|pass| Execution
    Decision -->|escalate| HumanApproval["Human Approval\nPOST /callbacks/approve"]
    Decision -->|block| Rejection
```

Your vertical writes `PolicySpec` files for the enterprise and use-case layers. The platform evaluates them at every gateway invocation. Base policy is platform-owned and not overridable.

---

## Enterprise Registry

Darta supports both solo and team development through the enterprise registry.

| Mode | Manifest | Tank data |
|---|---|---|
| Local (default) | `~/.appdarta/enterprises/{slug}/` | local embedded or local Docker |
| Distributed | same path, synced via git | external Postgres (shared DSN) |

In distributed mode, `darta enterprise sync` pulls the latest manifest. `darta enterprise onboard` lets a new team member set up in one step.

```mermaid
flowchart LR
    subgraph local["Your Machine"]
        EM["~/.appdarta/enterprises/{slug}/"]
        APK["~/.appdarta/config\n(API keys — always local)"]
    end

    subgraph shared["Shared (distributed mode)"]
        GR["Git Registry"]
        PG["Shared Postgres\n(tank data)"]
    end

    EM <-->|git pull / push| GR
    EM -->|tank writes| PG
```

---

## AI Governance

```mermaid
flowchart LR
    MR["ModelRegistrySpec\n(platform config)"]
    RB["ModelRoleBindingSpec\n(vertical declaration)"]
    AS["AgentSpec\n(role reference)"]

    MR -->|available providers + models| RB
    RB -->|role → provider mapping| AS
    AS -->|runtime: appdarta_ai_complete| RH["runtime-host"]
    RH -->|token accounting + fallback| Provider["AI Provider"]
```

Your vertical declares which business phases need AI and which platform role to use. The platform handles provider resolution, fallback chains, token accounting, and cost visibility.

See [ai-governance.md](docs/ai-governance.md) for full details.
