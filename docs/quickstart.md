<div align="center">
  <p>
    <a href="https://www.dhruvialabs.com/">
      <img src="https://raw.githubusercontent.com/hariharasudhand/appdarta-vertical-template/master/logo_dhruvialabs.png" alt="Dhruvia Labs" width="260">
    </a>
  </p>
  <p><strong>A framework from <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a></strong></p>
</div>

# External Vertical Quickstart

This is the public getting-started path for teams adopting AppDarta from released binaries and the public vertical template.

## What You Install

Install the AppDarta Engine once, then build your vertical on top of it.

The engine gives you:

- `darta`
- `appdarta-spec`
- `wasmtime-host`
- framework UI shell assets
- schemas, docs, and release metadata

Your team then works inside a separate vertical repo. That repo owns the business workflow. AppDarta carries the technical lifting around gateway, runtime isolation, policy hooks, tank integration, and AI/provider control.

## Fast Path

Use this when you want the shortest realistic public flow:

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"

bash scripts/install_framework.sh

git clone https://github.com/hariharasudhand/appdarta-vertical-template.git
cd appdarta-vertical-template

darta version
darta run-wizard
darta doctor --skip-stack
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

If you want a real vertical validation scenario rather than a generic quickstart, use the healthcare walkthrough in the public template repo:

- [Healthcare Validation Runbook](https://github.com/hariharasudhand/appdarta-vertical-template/blob/master/docs/healthcare-validation-runbook.md)

## Recommended Day-One Commands

```bash
darta run-wizard
darta doctor --skip-stack
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

## UI-Driven Wizard

All lifecycle phases are also accessible through the browser-based wizard:

```bash
darta ui serve
```

The wizard covers: Setup → Use Cases → Clarify → Design → Build → Deploy.

Each phase mirrors the corresponding CLI commands and writes to the same YAML spec files. The Design panel additionally provides AI self-assessment of enterprise reuse, sequence diagram generation (inline SVG, saved as `.swim` files), and per-component build prompts.

---

<div align="center">
  <p><strong>Currently available for trial use.</strong></p>
  <p>For production rollout, commercial discussions, or framework adoption support, contact Dhruvia Labs.</p>
  <p>We support flexible pricing and can structure outcome-based engagements where that fits better than heavy fixed pricing.</p>
</div>
