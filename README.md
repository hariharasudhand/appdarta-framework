# AppDarta Framework

AppDarta Framework is the public product surface for the AppDarta binary.

This repository is intentionally product-facing:

- installation and release notes
- tutorials and sample flows
- vertical bootstrap guidance
- links to versioned framework releases

It is not the private source-of-truth repository.

## What You Install

The AppDarta framework binary is the product. A framework release contains:

- `darta`
- `appdarta-spec`
- `wasmtime-host`
- framework UI shell
- schemas and docs
- framework config such as model registry

Install a release, then work from inside a vertical project.

## Quickstart

1. Download a framework release from GitHub Releases.
2. Install it under `APPDARTA_HOME`.
3. Add `APPDARTA_HOME/bin` to `PATH`.
4. Start from the public `appdarta-vertical-template`.
5. Run:

```bash
darta project bootstrap
darta analyze inspect
darta design inspect
```

Then continue through the lifecycle:

- `codegen`
- `build`
- `run`
- `test`
- `deploy`

## Public Repositories

- `appdarta-framework`: framework product and release docs
- `appdarta-vertical-template`: public starter vertical

## Install

See [docs/install.md](docs/install.md).

## Vertical Workflow

See [docs/vertical-workflow.md](docs/vertical-workflow.md).
