# Framework Capabilities for Vertical Teams

> For vertical developers, product managers, QA leads, and solution architects evaluating AppDarta.

---

## The Short Answer

AppDarta gives you a framework-owned control plane for agentic products.

Your team focuses on business workflows and domain logic. The framework provides:

- lifecycle structure and spec contracts
- gateway runtime with policy, async, and approval flows
- agent runtime isolation (WASM, HTTP, gRPC, process)
- tank-backed governed knowledge retrieval
- AI/provider governance and token accounting
- operator-facing execution visibility

The framework carries the technical lifting that otherwise slows agentic product teams. You build the functional piece; AppDarta makes it governable, extensible, and production-shaped.

---

## The Two Boxes

```
┌─────────────────────────────────────────────────┐
│  FRAMEWORK BOX  (you install, not you build)     │
│                                                  │
│  • Typed lifecycle specs and CLI workflow        │
│  • Gateway: pipelines, routing, async/approval   │
│  • Runtime: WASM isolation and dispatch          │
│  • Policy: evaluation, escalation, checkpoints   │
│  • Data Tanks: ingest, hydrate, search           │
│  • AI governance: registry, roles, accounting    │
│  • Operator UI: shell, artifacts, visibility     │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  VERTICAL BOX  (your team writes)                │
│                                                  │
│  • Domain use cases and designs                  │
│  • Business agents, flows, policies              │
│  • Domain tanks and data sources                 │
│  • Business runtime modules                      │
│  • Business UI modules and operator language     │
│  • Approval paths and thresholds                 │
└─────────────────────────────────────────────────┘
```

That split means you are not rebuilding the platform for every new healthcare, finance, legal, or operations workflow.

---

## What the Framework Already Enables

### Policy-Aware Gateway

A separate gateway runtime that:
- validates and transforms requests
- runs pre/post pipeline handlers
- attaches policy checks at invocation boundaries
- supports async callback and human approval flows

**For product managers**: creates a real control point for regulated or high-risk workflows.
**For QA**: gives a testable surface for approvals, retries, and failure behavior.

### Agent Execution Patterns

Not limited to single-agent demos. The framework supports:

- isolated single-agent execution
- declarative multi-agent handoff and routing
- parallel fan-out and gather
- approval and resume checkpoints mid-execution

Start simple. Grow into richer patterns without rewriting the platform.

### Data Tanks

A governed knowledge layer for your vertical:

- attach public reference material, enterprise knowledge, or client-scoped documents
- build, ingest, search, and hydrate paths managed by the framework
- runtime tank access inside agent execution (WASM host function)
- freshness tracking and storage visibility

AppDarta becomes a knowledge-governed operating layer for business decisions — not just an LLM app.

### AI Governance

Framework manages provider choices so they stay visible and centrally controlled:

- model registry and role bindings (`ModelRegistrySpec`, `ModelRoleBindingSpec`)
- fallback chains
- token and cost accounting
- budget visibility

**For engineering leads**: reduces uncontrolled provider sprawl.
**For QA/operators**: provides an attribution path when a workflow needs review.

Your vertical declares *where* AI is needed and *what role* to use. The framework resolves the provider, handles fallback, and records the usage.

---

## What Your Vertical Can Extend

You are not boxed in. AppDarta is opinionated about control-plane ownership, not your business strategy.

A vertical can extend:

| What | How |
|---|---|
| Policy logic and thresholds | Write `PolicySpec` YAML |
| Gateway orchestration | Write `OrchestrationSpec` YAML |
| Agent definitions | Write `AgentSpec` YAML (WASM, HTTP, gRPC, process) |
| Multi-agent flows | Write `FlowSpec` YAML |
| Domain knowledge | Write `DataTankSpec` YAML, ingest documents |
| Approval paths | Declare in `OrchestrationSpec` + `PolicySpec` |
| AI role usage | Declare in `AgentSpec` + `ModelRoleBindingSpec` |

All extensions go through framework contracts — not random one-off glue.

---

## Enterprise Registry and Team Workflows

AppDarta is designed for teams building multiple vertical products inside an organisation, not just individual projects.

The enterprise registry (`darta enterprise init`) tracks:
- registered vertical projects and their git URLs
- shared common services available across projects
- shared agents and tanks reusable across verticals

Two modes:

**Local mode** (default) — everything stays on the developer's machine. Best for solo exploration or early-stage single-developer work.

**Distributed mode** — for teams:
- the enterprise manifest is backed by a shared git repo; any team member can clone it with `darta enterprise onboard`
- tank data is backed by a shared external Postgres instance instead of each machine running its own
- `darta enterprise sync` keeps the local registry current with the team's shared state

Developer onboarding in distributed mode:
```bash
darta enterprise onboard
# → enter the enterprise git URL
# → CLI clones registry, displays registered projects
# → tests shared Postgres connection
# → optionally clones project repos locally
```

For product managers: the enterprise registry makes the "what does this team own" question answerable — all projects, shared services, and shared knowledge assets are declared in one manifest.

For architects: the Design phase AI assessment reads the enterprise registry and surfaces which agents and tanks are already available for reuse, before any implementation work starts.

---

## The Real Differentiator

Many teams can demo an agent. Few can show:

- how the workflow is governed
- where policy applies
- what data shaped the answer
- how operator approval works
- how additional agents join the path
- how runtime behavior stays consistent across verticals

That is the AppDarta claim: not just an agent runtime, but a framework for building vertical agentic products with structure, visibility, and room to scale.

---

<div align="center">
  <p><strong>Currently available for trial use.</strong></p>
  <p>For production rollout or commercial discussions, contact <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a>.</p>
</div>
