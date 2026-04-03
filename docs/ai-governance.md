# AI Governance

AppDarta’s release-minimum AI control plane is intentionally small but visible.

The framework owns:

- model registry resolution
- role binding resolution
- provider routing
- framework-level AI policy defaults and checkpoints
- token and cost accounting
- budget visibility
- operator-facing usage summaries

Verticals own:

- which business phases need AI
- which business modules invoke those phases
- which business specs reference the framework-managed roles

Enterprises can add or override policy at the organization layer:

- allowed providers or model families
- budget ceilings
- approval requirements
- sensitive-use restrictions

Use-case implementations should attach and configure those policy components. They should not need custom framework behavior just to express domain-specific controls.

## What To Inspect

From a vertical project root, start with:

```bash
darta project inspect --file .
```

That output should show:

- `AI config`
- `Model registry`
- `Role bindings`
- `Build codegen role`
- `Runtime reasoning role`
- `AI budget`
- `AI policy`

Those fields are the release-facing proof that the vertical is not making ad hoc provider calls without framework attribution.

## What To Report

To inspect usage and burn:

```bash
darta token-usage --period daily
darta token-usage --period daily --by role
darta token-usage --period daily --by provider
darta token-usage --period daily --by module
```

The release expectation is not full enterprise governance. It is that AppDarta can already answer:

- which role was active
- which provider/model family was used
- how many tokens were consumed
- what the daily budget looks like
- which policy checkpoint or approval rule applied when relevant

## UI Surface

The framework shell should reflect the same control-plane concepts:

- build role
- runtime role
- daily AI cost
- daily AI tokens
- budget burn
- provider, role, model, and module breakdowns

That keeps CLI and UI aligned to the same accounting story.

## Release Scope

For the June public drop, the AI control plane claim is:

- the framework owns role and provider routing
- the framework records usage and estimated cost
- the framework exposes daily budget burn to operators
- the framework keeps this separate from business tank data

It does **not** claim a finished enterprise governance platform yet.

Later work can deepen:

- hard budget enforcement
- richer provider fallback policies
- project and country-specific pricing controls
- more explicit runtime attribution across orchestration steps
