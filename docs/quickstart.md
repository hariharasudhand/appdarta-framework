<div align="center">
  <p>
    <a href="https://www.dhruvialabs.com/">
      <img src="https://raw.githubusercontent.com/hariharasudhand/appdarta-vertical-template/master/logo_dhruvialabs.png" alt="Dhruvia Labs" width="260">
    </a>
  </p>
  <p><strong>A framework from <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a></strong></p>
</div>

# External Vertical Quickstart

This is the public getting-started path for teams adopting Darta from released binaries and the public vertical template.

## What You Install

Install the Darta Platform once, then build your vertical on top of it.

The platform gives you:

- `darta`
- `appdarta-spec`
- `wasmtime-host`
- framework UI shell assets
- schemas, docs, and release metadata

Your team then works inside a separate vertical repo. That repo owns the business workflow. AppDarta carries the technical lifting around gateway, runtime isolation, policy hooks, tank integration, and AI/provider control.

## Fast Path

Use this when you want the shortest realistic public flow.

**Recommended entry:** clone the public vertical template → `darta run-wizard`.  
**Alternate:** `darta project init --name … --domain …` (same skeleton, no clone).

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"

bash scripts/install_framework.sh

git clone https://github.com/hariharasudhand/appdarta-vertical-template.git my-vertical
cd my-vertical

darta version
darta run-wizard
darta doctor --skip-stack
# optional: darta accelerators apply --domain healthcare
darta project inspect --file .
darta validate --project .
darta build project --project .
darta run project --project .
```

That path proves:

- the framework install is usable
- the template is personalized correctly
- the project contracts validate
- the vertical can build and run through the framework lifecycle

MCP for Cursor/Codex: [`ai-agents-mcp-setup.md`](ai-agents-mcp-setup.md). Full CLI: `darta help --all`.

## DHIL-DT Server

Darta routes AI work through three endpoints on a DHIL-DT server:

- `--dt` — DHIL-DT design-time routing server. Used by `darta dhil-dt policy` and the UI wizard's AI routing panel.
- `--l1` — Layer-1 model endpoint (Ollama-compatible). Used for cheap first-pass routing, classification, and local drafting.
- `--litellm` — LiteLLM proxy endpoint for cloud/provider model calls.

### Connect to a public shared server

```bash
darta framework set-server public \
  --dt http://<server-ip>:8080 \
  --l1 http://<server-ip>:11435 \
  --litellm http://<server-ip>:4000

darta framework use public
darta framework status
darta dhil-dt policy
```

### Step 2 — L1 authentication (shared servers)

Protected L1 endpoints require a per-developer API key. Your server admin creates one on the L1 host:

```bash
# On the L1 Ubuntu server (as root):
darta dhil l1 keys create --dev <your-name>
```

Configure your machine with the issued key:

```bash
darta dhil l1 configure --key <key-from-admin>
darta dhil l1 test
```

Or pass the key when setting the server URL:

```bash
darta framework set-server public --l1 http://<server-ip>:11435 --l1-key <key>
```

You can also configure the key in the UI: **AI Settings → Routing → L1 authentication**.

Contact Dhruvia Labs for the current public server address.

### Run DHIL-DT locally instead

```bash
darta dhil-dt serve --port 8080
export DHIL_DT_SERVER=http://127.0.0.1:8080

darta dhil-dt policy
```

---

## When To Start Local Services

Some vertical flows only need validation, build, and run. Others also need local framework services.

Start the stack when your vertical needs tank access, WASM runtime execution, or gateway routing:

```bash
darta stack up
darta services ps
darta services health
```

Use per-service control when you need a more manual setup:

```bash
darta services start --service context-service
darta services start --service runtime-host
darta services start --service gateway
```

View defaults and override them locally with:

```bash
darta extend config
darta extend config --service gateway --key listen --value 0.0.0.0:18110
```

Overrides are written to `.appdarta-local.yaml`.

## What A Vertical Team Configures

Your repo defines the business layer:

- use case and design specs
- agents and flows
- policies
- tanks and sources
- orchestration bindings
- runtime modules
- demo data and fixtures

The framework handles the reusable platform layer:

- lifecycle commands
- gateway and routing contracts
- runtime-host execution model
- tank service integration
- AI/provider control plane
- operator-facing visibility and health surfaces

## Where AI And LLM Usage Is Controlled

AppDarta keeps provider wiring in framework-managed configuration rather than scattering it through app code.

In practice:

- business intent lives in project and design specs
- approved provider/model roles live in framework-managed AI configuration
- runtime usage, token accounting, and policy checkpoints stay visible to operators

That lets product teams move quickly without rebuilding the AI control plane from scratch.

## Concrete Validation Path

If you want a real vertical validation scenario rather than a generic quickstart:

- [Vertical Developer Handbook](https://github.com/hariharasudhand/appdarta-vertical-template/blob/master/docs/vertical-developer-handbook.md) — **start here**
- [Healthcare Validation Runbook](https://github.com/hariharasudhand/appdarta-vertical-template/blob/master/docs/healthcare-validation-runbook.md) — healthcare drill

## Recommended Day-One Commands

```bash
darta run-wizard
darta doctor --skip-stack
darta framework status
darta dhil-dt policy
darta project inspect --file .
darta analyze inspect --project .
darta design inspect --project .
darta validate --project .
darta build project --project .
darta stack up
darta run project --project .
```

---

## Enterprise Setup

If you are working as part of a team, setting up an enterprise registry lets multiple developers share project metadata and tank data.

Create a new enterprise (first time for the team):

```bash
darta enterprise init
```

This asks for organisation name, industry, and whether the team is working in solo or distributed mode.

**Local mode** (default) — all enterprise data stays on your machine. Best for solo exploration or single-developer verticals.

**Distributed mode** — enterprise manifest backed by a shared git repo; tank data backed by a shared Postgres instance. Best for teams. During init you will be prompted for:
- Git registry URL (an empty or existing git repo the team shares)
- Branch (default: `main`)
- Auto-sync on startup toggle
- Shared Postgres DSN and schema

Join an existing enterprise as a new team member:

```bash
darta enterprise onboard
```

This clones the enterprise git registry, displays registered projects, tests the Postgres connection, and optionally clones any registered project repos locally.

Keep your local registry in sync:

```bash
darta enterprise sync
```

List registered enterprises on this machine:

```bash
darta enterprise list
```

---

## Spec coverage and release scope

The wizard **Build** stage shows **Spec coverage** (prompt linkage % and build execution %). At **Clarify**, define vertical-project release scope in `specs/analysis/delivery-scope.yaml` (in-scope vs out-of-scope for this release). After Design, run `darta build scope-sync --project .` to compile `specs/build/build-scope.yaml` with topology `node_ids` and dev assignments. Coverage uses release scope when present (`?view=release` on `/api/wizard/spec-coverage`).

---

## UI-Driven Wizard

All lifecycle phases are also accessible through the browser-based wizard:

```bash
darta ui serve
```

The wizard covers: Setup → Use Cases → Clarify → Design → Build → Deploy.

Each phase mirrors the corresponding CLI commands and writes to the same YAML spec files. The Design panel additionally provides AI self-assessment of enterprise reuse, sequence diagram generation (inline SVG, saved as `.swim` files), and per-component build prompts.

In **Build → Q-Prompt Studio**, set **runtime packaging** (process, Docker, Docker+WASM, or Cloud Run) per topology block before generating. Packaging is injected into prompt text and drives template overlays for connectors and deploy artifacts. Use **Generation routing** in the studio to confirm L1 (Ollama) vs LiteLLM (L2/L3) reachability (`darta framework status`).

### Packaging card (per node)

Each prompt row in Q-Prompt Studio shows a **PACKAGING** chip in the editor toolbar. Open it to set:

| Control | Values | Effect |
|---|---|---|
| **Runtime** | Process, Docker, Docker+WASM, Cloud Run | Chooses runtime overlay templates during generate (for example `agent-runtime-docker-go` vs `agent-runtime-process`) |
| **Port** | Free-form (e.g. `8081`) | Written to `.appdarta/build/packaging.json` and synced into the port registry |
| **Protocol** | HTTP, gRPC, Both | Drives handler and connector constraints in generated prompts |

Changes persist automatically to `.appdarta/build/packaging.json` via `POST /api/build/packaging`. The same runtime choice is appended to prompt text before generation so coding agents inherit deploy constraints.

Use **StrategyPreview** (below the prompt editor) to confirm the CLI-selected template and runtime overlay match what you chose on the packaging card before clicking **Generate**.

### packGroups

When several agents deploy together (same Docker network or shared profile), group them in **packGroups** inside `packaging.json`:

```json
"packGroups": {
  "review-cohort": {
    "members": ["agent:reviewer", "agent:auditor"],
    "runtime": "docker",
    "profile": "pack-review"
  }
}
```

Each member keeps its own port — ports must be distinct within the group. **Apply to group** on the packaging chip copies the active node's runtime/port/protocol to all members. The CLI exposes compose profiles at `GET /api/build/packaging/compose` (one profile per packGroup, shared network name `appdarta-<group>`).

### Port registry

Project-level ports and deploy intent live in `config/project/runtime.yaml`:

```yaml
deployIntent: docker-compose
nginxStrategy: gateway-edge
portRegistry:
  gateway: "8080"
  ui: "3000"
  agents:
    agent:reviewer: "8081"
```

With `nginxStrategy: gateway-edge`, only the **gateway** port is the public edge; UI and agent ports are internal upstreams. Sync from packaging in the UI or via API:

```bash
# equivalent to UI "Sync from packaging"
curl -s -X POST "http://127.0.0.1:8787/api/build/port-registry?project=." \
  -H 'Content-Type: application/json' \
  -d '{"syncFromPackaging": true}'
```

Workspace deploy intent also flows through `build/pattern-selection.yaml` (`deployTarget`) — keep it aligned with `runtime.yaml` `deployIntent`.

### Ask Dhil in prompts

**Ask Dhil** is available from the wizard inspector (tier picker + panel) on every stage, including **Build**. In Q-Prompt Studio, questions can include build context; responses return **action chips** when applicable:

| Question pattern | Action |
|---|---|
| `rewrite prompt` / `improve prompt` | **Apply suggested prompt patch** |
| `@_review` / `review checkpoint` | **Insert review checkpoint row text** |
| `link use case` | **Link suggested use case(s)** |
| `show file` / `fetch artifact` | **Open related build artifact** |

Pass `node_id` and `row_id` when calling `/api/ask` from custom tooling so actions target the correct prompt row. Example:

```bash
curl -s -X POST "http://127.0.0.1:8787/api/ask?project=." \
  -H 'Content-Type: application/json' \
  -d '{"question":"rewrite prompt for grpc handlers","stage":"build","node_id":"agent:reviewer","row_id":"skeleton"}'
```

---

<div align="center">
  <p><strong>Currently available for trial use.</strong></p>
  <p>For production rollout, commercial discussions, or framework adoption support, contact Dhruvia Labs.</p>
  <p>We support flexible pricing and can structure outcome-based engagements where that fits better than heavy fixed pricing.</p>
</div>
