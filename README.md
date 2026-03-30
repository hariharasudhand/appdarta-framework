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

## What AppDarta Is

AppDarta is a framework for building vertical agentic applications with:

- signed-off lifecycle specs
- framework-managed gateway, UI, and runtime contracts
- centrally managed AI/codegen controls
- business-scoped vertical implementations

Vertical projects consume AppDarta Engine releases and carry only business-scoped code and instance specs.

## Start Here

1. Install an AppDarta Engine release from GitHub Releases.
2. Create a new project from [`appdarta-vertical-template`](https://github.com/hariharasudhand/appdarta-vertical-template).
3. Bootstrap the vertical against the required framework version.
4. Move through `analyze`, `design`, `codegen`, `build`, and `run`.

## Quickstart

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"

darta framework install --package /path/to/appdarta-framework

cd /path/to/your-vertical
darta project bootstrap
darta doctor --skip-stack
darta analyze inspect
darta design inspect
darta design compare
```

Then continue through:

- `darta codegen plan --project .`
- `darta build project`
- `darta run project`

## Why Try It

AppDarta is useful when you want:

- a real installable engine instead of ad hoc prompt scripts
- clear separation between framework control plane and vertical business scope
- operator visibility into policies, decisions, orchestration, and runtime
- one lifecycle from business use case to executable vertical project

## Architecture

See [docs/architecture.md](docs/architecture.md).

## Lifecycle

See [docs/lifecycle.md](docs/lifecycle.md).

## Tech Stack

See [docs/tech-stack.md](docs/tech-stack.md).

## Data Tanks

See [docs/data-tanks.md](docs/data-tanks.md).

## Install

See [docs/install.md](docs/install.md).

## Vertical Workflow

See [docs/vertical-workflow.md](docs/vertical-workflow.md).
