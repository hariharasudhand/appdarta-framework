# Showcase Walkthroughs

These are the two release showcase verticals for the public AppDarta drop.

They use the same framework-owned operator path:

```bash
darta project inspect --file .
darta doctor --skip-stack
darta build project --project .
darta test project --project .
darta run project --project .
darta deploy plan --project .
```

That path matters more than the domain itself. The release story is that the same framework lifecycle, runtime, deploy evidence, and UI shell can carry two different business workflows.

For either vertical, you can also inspect the release-minimum AI control plane with:

```bash
darta project inspect --file .
darta token-usage --period daily
darta token-usage --period daily --by provider
```

## Finance

Finance is the primary CLI and operator-console proof.

It demonstrates:

- a fraud-review task that hydrates domain context from finance documents
- a policy-visible escalation path
- operator-facing runtime evidence before deploy planning
- a mounted review console inside the framework shell
- an explicit tank build/ingest/status path before project execution

Expected artifacts:

- `demo/artifacts/finance-reference-run.json`
- `demo/artifacts/finance-reference-run-runtime-handoff.md`
- `demo/artifacts/finance-reference-run-verification-brief.md`
- `demo/artifacts/finance-reference-result.json`

The runtime result should recommend a high-risk escalation backed by tank evidence.

## Healthcare

Healthcare is the second proof that the framework is reusable across domains.

It demonstrates:

- a medication-review task that hydrates healthcare guidance from client documents
- a clinically cautious recommendation instead of a finance-style escalation
- the same runtime evidence and deploy-readiness path as finance
- a second mounted operator console in the same framework shell contract
- an explicit tank build/ingest/status path before project execution

Expected artifacts:

- `demo/artifacts/healthcare-reference-run.json`
- `demo/artifacts/healthcare-reference-run-runtime-handoff.md`
- `demo/artifacts/healthcare-reference-run-verification-brief.md`
- `demo/artifacts/healthcare-reference-result.json`

The runtime result should recommend reviewing kidney function and medication timing before contrast dye exposure when metformin guidance is present.

## What The Two Vertical Pair Proves

Together, finance and healthcare should show:

- the framework owns lifecycle gating, runtime orchestration, deploy evidence, and the UI shell
- verticals own business specs, business data, business runtime assets, and business review surfaces
- tanks and shared enterprise assets are framework-supported primitives, not one-off demo wiring
- AppDarta is not a finance-only product and not just a collection of prompt scripts
