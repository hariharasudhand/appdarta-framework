# Release Start

The fastest orientation to AppDarta as a product.

---

## What Ships

AppDarta ships as an installable framework engine:

| Binary | Role |
|---|---|
| `darta` / `appdarta` | CLI + gateway execution engine |
| `appdarta-spec` | Spec validator |
| `wasmtime-host` | WASM agent execution host |
| framework UI shell | Operator interface |
| `specs/core/*.schema.json` | 31 spec schemas |
| `config/model-registry.yaml` | AI provider/role config |

`context-service` is a companion service (Python/Docker) started via the CLI — not bundled in the binary archive.

---

## What the Framework Proves

AppDarta ships with two reference showcase verticals:

- **Finance**: fraud review — escalation-driven decision support with policy-visible operator approval checkpoints
- **Healthcare**: medication review — evidence-backed guidance through the same framework lifecycle

They run through the same framework-owned path: lifecycle inspection → tank-backed context → runtime evidence → deploy planning → operator-facing UI shell. The framework capability is vertical-agnostic.

---

## Start Path

```bash
# 1. Install
bash scripts/install_framework.sh

# 2. Create a project from the vertical template
git clone https://github.com/hariharasudhand/appdarta-vertical-template.git my-vertical
cd my-vertical
darta run-wizard

# 3. Move through the lifecycle
darta version
darta doctor --skip-stack
darta project inspect --file .
darta analyze inspect --project .
darta design inspect --project .
darta validate --project .
darta build project --project .
darta stack up
darta run project --project .
darta deploy plan --project .
```

---

## What the Framework Owns

- CLI and project workflow
- UI shell and operator surfaces
- Spec schemas and validation
- Gateway, orchestration, and routing contracts
- Runtime dispatch boundary (WASM, HTTP, gRPC, process)
- AI role/provider routing, accounting, and budget visibility
- Tank and context integration contracts
- Policy evaluation and approval flow

## What Your Vertical Owns

- Business use case and design specs
- Domain agents, flows, and policies
- Domain tanks and data sources
- Business runtime modules (WASM or other)
- Business UI modules
- Domain fixtures, demos, and operator language

---

## Current State

**Proven and working:**
- Binary-first install path
- Wizard-first vertical onboarding
- Full lifecycle: inspect → analyze → design → build → test → run → deploy-plan
- Execution evidence and verification artifacts
- Framework UI shell with mounted operator views
- AI usage and budget visibility
- Shared enterprise tank visibility through inspect, doctor, and deploy plan
- Deterministic multi-agent coordination (sequential, parallel, fan-out/gather, approval/resume)
- Policy-aware approval checkpoints
- `darta project approve` path for clearing or rejecting human-review checkpoints

**Intentionally next:**
- Richer enterprise AI governance surfaces
- Broader multi-agent orchestration beyond deterministic patterns
- Deeper shared-enterprise tank search UX
- Third-vertical expansion beyond finance and healthcare
