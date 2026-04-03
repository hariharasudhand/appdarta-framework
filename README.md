<div align="center">
  <p>
    <a href="https://www.dhruvialabs.com/">
      <img src="https://raw.githubusercontent.com/hariharasudhand/appdarta-vertical-template/master/logo_dhruvialabs.png" alt="Dhruvia Labs" width="260">
    </a>
  </p>
  <p><strong>A framework from <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a></strong></p>
</div>

# AppDarta Framework

> **Beta**  
> AppDarta is in active development. Early trials and feedback are welcome, but do not expect every workflow or command to be complete or production-ready yet.

AppDarta Framework is the public product surface for AppDarta.

The installable product is the **AppDarta Engine**:

- `darta`
- `appdarta-spec`
- `wasmtime-host`
- framework UI shell
- schemas, docs, and central config

This repository is intentionally product-facing:

- install and release docs
- architecture and lifecycle guides
- vertical bootstrap guidance
- links to versioned releases

It is not the private source-of-truth repository.

## Start Here

If you are evaluating or adopting AppDarta, use this path:

1. install AppDarta Engine
2. create a project from `appdarta-vertical-template`
3. run the wizard to personalize the vertical
4. inspect the project
5. configure AI roles and business specs
6. build and run the vertical

Recommended first commands:

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"

bash scripts/install_framework.sh

cd /path/to/your-vertical
darta version
darta run-wizard
darta doctor --skip-stack
darta project inspect
```

Then continue with:

```bash
darta analyze inspect
darta design inspect
darta design compare
darta codegen plan --project .
darta build project
darta run project
```

If you want the shortest release-oriented overview first, read [docs/release-start.md](docs/release-start.md).

If you want the vertical starter flow, go to [`appdarta-vertical-template`](https://github.com/hariharasudhand/appdarta-vertical-template).

## What AppDarta Is

AppDarta is a framework for building vertical agentic applications with:

- signed-off lifecycle specs
- framework-managed gateway, UI, and runtime contracts
- centrally managed AI/codegen controls
- business-scoped vertical implementations

Vertical projects consume AppDarta Engine releases and carry only business-scoped code and instance specs.

The simplest way to understand the product is:

- your team builds the functional business workflow
- AppDarta carries the technical lifting required to make that workflow governable, extensible, and production-shaped

That technical lifting includes:

- gateway runtime behavior
- orchestration and routing
- runtime isolation
- policy attachment points
- knowledge/tank integration
- AI/provider controls
- execution visibility for operators

If you want the fastest product-facing explanation of the framework box and what a vertical team can extend, read [Framework Capabilities For Vertical Teams](docs/framework-capabilities-for-teams.md).

## Why Try It

AppDarta is useful when you want:

- a real installable engine instead of ad hoc prompt scripts
- clear separation between framework control plane and vertical business scope
- operator visibility into policies, decisions, orchestration, and runtime
- one lifecycle from business use case to executable vertical project

It is especially useful for teams that want to sell or ship a domain workflow quickly without separately building:

- an agent gateway
- a policy and approval layer
- a multi-agent routing model
- a governed knowledge plane
- a runtime accounting and operator story

## Where AI Is Configured

AppDarta does not expect each vertical to hardcode provider calls inside business code.

Use the framework-managed AI configuration surfaces:

- `ModelRegistrySpec`
  This is where available providers, model families, and framework-visible routing options are defined.

- `ModelRoleBindingSpec`
  This is where a vertical binds business phases such as build-time generation or runtime reasoning to approved framework-managed roles.

- project/design specs
  This is where your vertical declares which modules or business phases use AI.

What the framework handles:

- provider and role resolution
- fallback routing
- token and cost accounting
- budget visibility
- policy checkpoints

What the vertical handles:

- which business workflows use AI
- which role should be attached to which business module
- domain prompts, policies, and approval requirements

For a deeper external explanation, see [docs/ai-governance.md](docs/ai-governance.md).

## Architecture

See [docs/architecture.md](docs/architecture.md).

## Lifecycle

See [docs/lifecycle.md](docs/lifecycle.md).

## Tech Stack

See [docs/tech-stack.md](docs/tech-stack.md).

## Data Tanks

See [docs/data-tanks.md](docs/data-tanks.md).

## Shared Enterprise Tanks

See [docs/shared-enterprise-tanks.md](docs/shared-enterprise-tanks.md).

## AI Governance

See [docs/ai-governance.md](docs/ai-governance.md).

## Install

See [docs/install.md](docs/install.md).

## Vertical Workflow

See [docs/vertical-workflow.md](docs/vertical-workflow.md).

## Release Showcases

See [docs/showcase-walkthroughs.md](docs/showcase-walkthroughs.md).

---

<div align="center">
  <p><strong>Currently available for trial use.</strong></p>
  <p>Contact Dhruvia Labs for production rollout, adoption support, and commercial planning.</p>
  <p>We support flexible pricing, including outcome-aligned engagement models where they fit better than heavy upfront pricing.</p>
</div>
