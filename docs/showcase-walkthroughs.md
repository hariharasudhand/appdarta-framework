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

For release rehearsal and regression safety, the repo also exposes two named validation harnesses:

```bash
make validate-showcase-multi-agent
make validate-healthcare-showcase
make validate-showcase-pair
```

The first validates the current lead multi-agent showcase path. Today that showcase scenario is finance, but the framework capability is not finance-specific. The second keeps the healthcare path solid as an independent proof that the framework holds up across domains.
`make validate-showcase-pair` runs both showcase suites plus the framework-owned coordination regression lane as one release-shaped checkpoint.

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
- explicit multi-agent coordination with `hydrate -> triage + evidence -> review`
- a policy-visible escalation path
- a human approval checkpoint when the decision trace requires operator review
- operator-facing runtime evidence before deploy planning
- a mounted review console inside the framework shell
- an explicit tank build/ingest/status path before project execution

Expected artifacts:

- `demo/artifacts/finance-reference-run.json`
- `demo/artifacts/finance-reference-run-runtime-handoff.md`
- `demo/artifacts/finance-reference-run-verification-brief.md`
- `demo/artifacts/finance-reference-result.json`
- `demo/artifacts/finance-reference-recovery-result.json` for degraded-path rehearsal
- `demo/artifacts/finance-reference-rerouted-result.json` for denied-branch reroute rehearsal
- `demo/artifacts/finance-reference-resumed-result.json` for approved-and-resumed rehearsal

The primary runtime result should recommend a high-risk escalation backed by tank evidence. The recovery rehearsal artifact should also show a retrying evidence branch, a degraded review outcome, a failed escalation step, and a `pending-human-review` checkpoint. The rerouted rehearsal artifact should show a policy-denied evidence branch that is marked `denied` and `rerouted` while the review path continues. The resumed rehearsal artifact should show the same flow continuing after approval with explicit `resume` metadata.

The CLI run summary for the lead showcase now also prints the framework vocabulary directly:

- policy summary statuses, layers, and components
- guardrail checkpoints, statuses, next action, and next command
- coordination branches, merges, states, and recovery

Validation path:

- `make validate-showcase-multi-agent`
- `make validate-showcase-pair`
- `darta project approve --project . --name <reviewer> --resolution <approve|clear|reject>` when the result artifact is paused at `pending-human-review`
- `darta project approve --project . --name <reviewer> --resolution approve --resume` when you want the operator approval to trigger an immediate prepared-bundle rerun

## Healthcare

Healthcare is the second proof that the framework is reusable across domains.

It demonstrates:

- a medication-review task that hydrates healthcare guidance from client documents
- a clinically cautious recommendation instead of a finance-style escalation
- the same runtime evidence and deploy-readiness path as finance
- a second mounted operator console in the same framework shell contract
- an explicit tank build/ingest/status path before project execution
- a separately validated showcase path that keeps the framework from collapsing into a one-domain demo

Expected artifacts:

- `demo/artifacts/healthcare-reference-run.json`
- `demo/artifacts/healthcare-reference-run-runtime-handoff.md`
- `demo/artifacts/healthcare-reference-run-verification-brief.md`
- `demo/artifacts/healthcare-reference-result.json`
- `demo/artifacts/healthcare-reference-recovery-result.json` for degraded-path rehearsal

The runtime result should recommend reviewing kidney function and medication timing before contrast dye exposure when metformin guidance is present. The recovery rehearsal artifact should show a retrying review step, a degraded clinical fallback outcome, and a manual clinician-review decision without drifting into finance-style escalation language.

The healthcare path uses the same framework-led CLI summary contract, so the terminal output still exposes coordination, policy, and guardrail vocabulary even though the business recommendation is different.

Validation path:

- `make validate-healthcare-showcase`
- `make validate-showcase-pair`

## What The Two Vertical Pair Proves

Together, finance and healthcare should show:

- the framework owns lifecycle gating, runtime orchestration, deploy evidence, and the UI shell
- the framework can expose bounded coordination, approval checkpoints, and operator-visible traces without becoming domain-locked
- verticals own business specs, business data, business runtime assets, and business review surfaces
- tanks and shared enterprise assets are framework-supported primitives, not one-off demo wiring
- AppDarta is not a finance-only product and not just a collection of prompt scripts
