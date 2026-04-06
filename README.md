<div align="center">
  <p>
    <a href="https://www.dhruvialabs.com/">
      <img src="https://raw.githubusercontent.com/hariharasudhand/appdarta-vertical-template/master/logo_dhruvialabs.png" alt="Dhruvia Labs" width="260">
    </a>
  </p>
  <p><strong>A framework from <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a></strong></p>
</div>

# AppDarta aka Darta Framework

> **Beta** (** Darling Release ** DR-x.x) — Active development. Early trials and feedback are welcome.

AppDarta is a framework for building **vertical agentic applications** — domain-scoped AI workflows that are governed, extensible, and production-shaped from day one.

---

## The Two Boxes

Everything in AppDarta divides cleanly into two responsibilities:

```
┌──────────────────────────────────────────────────────────┐
│               FRAMEWORK  (binary, you install)           │
│                                                          │
│  appdarta / darta     CLI + gateway execution engine     │
│  appdarta-spec        Spec validator (31 schemas)        │
│  wasmtime-host        WASM agent execution host          │
│  context-service      Tank storage + vector retrieval    │
│                                                          │
│  → you configure it, you do not modify it                │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│            YOUR VERTICAL  (source, you write)            │
│                                                          │
│  specs/agents/        Who your agents are                │
│  specs/flows/         How agents coordinate              │
│  specs/policies/      Decision and approval rules        │
│  specs/tanks/         Domain knowledge sources           │
│  specs/orchestration/ Gateway execution plan             │
│  runtime/*.wasm       Compiled agent logic               │
│                                                          │
│  → framework validates and executes these at runtime     │
└──────────────────────────────────────────────────────────┘
```

The framework binary never changes when you build a new vertical. You extend framework behavior through YAML specs and compiled WASM modules.

---

## What Ships in the Binary Bundle

```
dist/appdarta-framework/
├── bin/
│   ├── appdarta          # CLI + gateway (all framework logic)
│   ├── darta             # shell alias for appdarta
│   ├── appdarta-spec     # spec validator
│   └── wasmtime-host     # WASM execution host
├── specs/core/           # 31 JSON schemas (the spec contract)
├── share/
│   ├── config/
│   │   └── model-registry.yaml
│   ├── ui/
│   │   └── framework-shell/
│   └── docs/
```

`context-service` runs as a Docker container — it is not in the binary bundle. Start it with `darta stack up` or `darta services start --service context-service`.

---

## Getting Started

**1. Install**

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"
bash scripts/install_framework.sh
```

**2. Create a vertical project**

```bash
git clone https://github.com/hariharasudhand/appdarta-vertical-template.git my-vertical
cd my-vertical
darta run-wizard          # personalizes the template for your domain
darta doctor --skip-stack # verify the install is wired up
```

**3. Inspect and validate**

```bash
darta project inspect --file .
darta analyze inspect --project .
darta design inspect --project .
darta validate --project .
```

**4. Build and run**

```bash
darta build project --project .
darta stack up            # starts context-service, runtime-host, gateway
darta run project --project .
```

---

## What Your Vertical Configures

You do not modify framework source. You write specs:

| What you declare | File location | Schema |
|---|---|---|
| An agent and its runtime type | `specs/agents/*.yaml` | `AgentSpec` |
| How agents coordinate | `specs/flows/*.yaml` | `FlowSpec` |
| Decision and approval rules | `specs/policies/*.yaml` | `PolicySpec` |
| Domain knowledge source | `specs/tanks/*.yaml` | `DataTankSpec` |
| Gateway execution plan | `specs/orchestration/*.yaml` | `OrchestrationSpec` |

Validate any spec:

```bash
darta validate --file specs/agents/my-agent.yaml
darta validate --project .    # validate everything
```

---

## Runtime Types

Agents are not limited to WASM. Each agent declares its own runtime mode:

| Mode | What runs | Framework handles |
|---|---|---|
| `wasm` | Compiled `.wasm` module | `wasmtime-host` loads and isolates it |
| `http` | External HTTP service | Gateway routes to declared endpoint |
| `grpc` | External gRPC service | Gateway routes with proto-ref |
| `process` | Local binary | Gateway spawns with declared command |

One vertical can mix runtime types. The framework contract is the same regardless of mode.

---

## Framework Services

Three services run your vertical at runtime:

| Service | Role | Default port |
|---|---|---|
| `context-service` | Tank storage, embeddings, vector search | 18001 |
| `runtime-host` | WASM agent execution | 18091 |
| `gateway` | Orchestration and routing | 18110 |

```bash
darta stack up            # start all three in dependency order
darta services ps         # see all running instances
darta services health     # health probe all services
darta services logs --service gateway --follow
darta stack down
```

See [services.md](docs/services.md) for full reference.

---

## Extension Points

Everything configurable without touching source:

```bash
# Override service ports or hosts
darta extend config --service gateway --key listen --value 0.0.0.0:18110
darta extend config --service runtime-host --key context_service_url --value http://127.0.0.1:18002

# Run multiple isolated instances (staging, multi-tenancy, load testing)
darta services start --service context-service --instance staging --port 18002
darta services start --service runtime-host --instance staging --port 18092
darta gateway serve --listen 127.0.0.1:18111 --project ./other-vertical
```

Configuration overrides are saved to `.appdarta-local.yaml`.

See [multi-instance-deployment.md](docs/multi-instance-deployment.md).

---

## Going to Production

**1. Pin the framework version in your project**

```yaml
# appdarta.framework.yaml
spec:
  required_framework_version: "1.2.3"
  schema_bundle_version: "1.2.3"
```

`darta doctor` checks this binding. Framework updates are explicit, never automatic.

**2. Run the full validation gate**

```bash
darta validate --project .
darta doctor
darta deploy plan --project .
```

**3. Review the deploy plan output**

`darta deploy plan` surfaces:
- framework version match
- spec binding completeness
- tank freshness status
- pending approvals or policy checkpoints
- AI role binding coverage

**4. Bind your storage backends**

```bash
CHROMA_URL=http://your-chromadb:8000
POSTGRES_URL=postgresql://...
REDIS_URL=redis://...
```

**5. Run in container mode**

```bash
darta stack up --mode container
```

Or supply a `docker-compose.override.yml` for your production topology.

---

## Where to Go Next

| Topic | Doc |
|---|---|
| Component model — what's framework, what's yours | [component-model.md](docs/component-model.md) |
| Framework services reference | [services.md](docs/services.md) |
| Multi-instance and tenant isolation | [multi-instance-deployment.md](docs/multi-instance-deployment.md) |
| Data tanks and knowledge retrieval | [data-tanks.md](docs/data-tanks.md) |
| AI governance and model roles | [ai-governance.md](docs/ai-governance.md) |
| Vertical lifecycle walkthrough | [quickstart.md](docs/quickstart.md) |
| Architecture overview | [architecture.md](docs/architecture.md) |

---

<div align="center">
  <p><strong>Currently available for trial use.</strong></p>
  <p>Contact <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a> for production rollout, adoption support, and commercial planning.</p>
</div>
