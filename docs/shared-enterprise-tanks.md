# Shared Enterprise Tanks

AppDarta uses shared enterprise tanks to keep durable cross-vertical state out of hidden framework databases.

For the current release path, the three expected shared enterprise tanks are:

- `enterprise-accounting`
- `enterprise-users`
- `enterprise-common-registry`

## What They Hold

- `enterprise-accounting`
  AI usage, estimated cost, budget burn, and operator-facing accounting events
- `enterprise-users`
  signoff actors, operator identity references, and reusable project membership context
- `enterprise-common-registry`
  shared endpoints, shared tank registrations, and reusable framework discovery state

## Release-Proof Story

The important release claim is not that AppDarta has every possible shared-state feature already.

The important claim is:

- the first vertical can scaffold the shared enterprise tank bindings
- later verticals can reuse those same shared tank bindings
- the framework surfaces show whether those bindings are present, missing, or need deploy review

## First Vertical

On a first enterprise vertical, the wizard and project contract should leave you with shared enterprise tanks bound into the project shape.

Use:

```bash
darta run-wizard
darta project inspect --file .
darta doctor --skip-stack
```

You should see:

- a shared tank profile
- shared tank entries for accounting, users, and common-registry
- no hidden framework-private persistence assumption

## Second Vertical

On a later vertical in the same enterprise, the goal is reuse rather than creating a new copy of the same cross-vertical state.

Use:

```bash
darta project inspect --file .
darta doctor --skip-stack
darta deploy plan --project .
```

You should be able to confirm:

- the same shared tank names appear
- they show `bound` or `scaffolded`, not `missing`
- deploy planning reflects the same shared storage profile
- higher-environment rollout warnings point at shared storage choices rather than pretending the framework owns an internal database

## How To Read The Surfaces

`project inspect` should tell you:

- the shared tank profile
- the shared tank classes and status markers
- module reuse policy for shared versus project-local tanks

`doctor` should tell you:

- whether shared enterprise tanks are configured
- whether the backing profile is mixed, missing, or healthy enough for the current project shape

`deploy plan` should tell you:

- whether shared storage is still embedded
- whether deploy readiness is blocked or review-only
- whether the shared tank profile is suitable for higher environments

## What This Means For The June Release

The June release does not need a huge standalone shared-state product narrative.

It needs a believable one:

- durable cross-vertical state belongs in shared enterprise tanks
- those tanks are explicit framework concepts
- their presence is visible in supported operator flows
- finance and healthcare can both sit on the same framework shape without pretending every vertical is isolated from enterprise context
