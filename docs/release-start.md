# Release Start

This is the fastest way to understand the June public AppDarta drop.

## What Ships In The Public Drop

AppDarta ships as an installable framework product:

- `darta`
- `appdarta-spec`
- `wasmtime-host`
- framework UI shell
- framework schemas, docs, and central config

You use that framework product from inside a separate vertical project.

## What The Release Proves

The release is built around two showcase verticals:

- finance: fraud review
- healthcare: medication review

The point is not just that the two examples run. The point is that they run through the same framework-owned path:

- lifecycle inspection
- tank-backed context
- runtime evidence
- deploy planning
- operator-facing UI shell

The repo also carries named validation paths for the two public showcase tracks:

- `make validate-showcase-multi-agent`
- `make validate-healthcare-showcase`

The first validates the current lead multi-agent showcase path. Today that showcase scenario is finance, but the framework capability is intentionally vertical-agnostic.

## Start Path

1. Install AppDarta Engine.
2. Create a project from the AppDarta vertical template.
3. Run `darta run-wizard`.
4. Move through inspect, analyze, design, build, test, run, and deploy planning.

Core commands:

```bash
darta version
darta run-wizard
darta doctor --skip-stack
darta project inspect --file .
darta analyze inspect --project .
darta design inspect --project .
darta design compare --project .
darta build project --project .
darta test project --project .
darta run project --project .
darta deploy plan --project .
```

## What The Framework Owns

- CLI
- UI shell
- schemas
- gateway and orchestration contracts
- runtime dispatch boundary
- AI role/provider routing
- budget and usage visibility
- shared tank and shared-agent contracts

## What A Vertical Owns

- business specs
- business tanks and policies
- business runtime assets
- business UI modules
- demo inputs, fixtures, and review surfaces

## Why Finance And Healthcare

Finance proves:

- escalation-oriented decision support
- explicit handoff and bounded parallel evidence gathering
- operator-visible approval checkpoints before higher-risk outcomes
- policy-visible operator review
- high-risk recommendation flow

Healthcare proves:

- a second domain with different business semantics
- evidence-backed medication guidance
- the same framework lifecycle and runtime path

Together they show AppDarta is a reusable vertical framework, not a one-domain demo.

## What Is Real Now

- binary-first framework install path
- wizard-first vertical onboarding
- inspect/doctor/build/test/run/deploy-plan lifecycle
- execution evidence and verification briefs
- mounted operator views in the framework shell
- AI usage and budget visibility
- shared enterprise tank visibility through inspect, doctor, and deploy plan
- deterministic coordination support for multi-step runtime flows
- framework-visible approval checkpoints in result artifacts, inspect output, doctor guidance, and deploy planning
- a minimal `darta project approve` path to clear or reject a pending human-review checkpoint, plus `--resume` when the operator wants to continue execution immediately
- packaging for the framework plus finance and healthcare examples

## What Is Still Intentionally Early

- richer enterprise AI governance
- deeper shared-enterprise tank demonstrations and local search UX
- broader multi-agent orchestration semantics beyond the current deterministic release support
- third-vertical expansion

The release is meant to prove that the framework path is real and coherent now, while leaving the broader roadmap explicit.
