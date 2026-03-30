# AppDarta Framework

AppDarta Framework is the public product surface for the AppDarta binary.

This repository is intentionally product-facing:

- installation and release notes
- tutorials and sample flows
- vertical bootstrap guidance
- links to versioned framework releases

It is not the private source-of-truth repository.

## What AppDarta Is

AppDarta is a framework for building vertical agentic applications with:

- signed-off lifecycle specs
- framework-managed gateway, UI, and runtime contracts
- centrally managed AI/codegen controls
- business-scoped vertical implementations

The framework binary is the product. Vertical projects consume framework releases and carry only business-scoped code and instance specs.

## What You Install

The AppDarta framework binary is the product. A framework release contains:

- `darta`
- `appdarta-spec`
- `wasmtime-host`
- framework UI shell
- schemas and docs
- framework config such as model registry

Install a release, then work from inside a vertical project.

## Start Here

If you want to try AppDarta quickly:

1. install a framework release from this repo
2. create a new project from [`appdarta-vertical-template`](https://github.com/hariharasudhand/appdarta-vertical-template)
3. bootstrap the project against the required framework version
4. move through `analyze`, `design`, `codegen`, `build`, and `run`

## Quickstart

1. Download a framework release from GitHub Releases.
2. Install it under `APPDARTA_HOME`.
3. Add `APPDARTA_HOME/bin` to `PATH`.
4. Start from the public `appdarta-vertical-template`.
5. Run:

```bash
darta project bootstrap
darta doctor --skip-stack
darta analyze inspect
darta design inspect
darta design compare
```

Then continue through the lifecycle:

- `codegen`
- `build`
- `run`
- `test`
- `deploy`

## Why Developers Should Try It

AppDarta is useful when you want:

- a real framework binary instead of ad hoc prompts
- clear separation between framework control plane and vertical business scope
- operator visibility into policies, decisions, orchestration, and runtime
- one lifecycle from business use case to executable vertical project

## Public Repositories

- `appdarta-framework`: framework product and release docs
- `appdarta-vertical-template`: public starter vertical

## Install

See [docs/install.md](docs/install.md).

## Vertical Workflow

See [docs/vertical-workflow.md](docs/vertical-workflow.md).
