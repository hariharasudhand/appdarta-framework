# Multi-Agent Gateway

The Darta gateway supports multi-agent coordination patterns as declarative YAML policy — no custom routing code inside agents.

---

## The Design Principle

Every multi-agent decision lives in `specs/orchestration/*.yaml` and `specs/policies/*.yaml`. The gateway loads those at startup and from the `appdarta-policies` tank at runtime. You never write coordination logic inside an agent.

---

## Policy Types

Declare `multi-agent-policies` in your `OrchestrationSpec`:

```yaml
multi-agent-policies:
  - type: validator      # compliance agent checks primary output
  - type: critique       # self-critique or peer review
  - type: consensus      # quorum agreement before escalation
  - type: supervisor     # oversight agent that can intervene at any hop
```

### validator

A compliance or review agent evaluates the primary agent's output. Use when you need a mandatory gate before a decision proceeds.

```yaml
- type: validator
  agent-ref: compliance-review-agent@1.0.0
  trigger-on: always
  fail-action: block        # "block" | "warn" | "escalate"
```

### critique

The agent critiques its own output (or a peer does). Use when output quality varies and you want automatic retry on low-confidence results.

```yaml
- type: critique
  agent-ref: self
  trigger-on: on-metadata
  metadata-key: confidence_score
  match-value: "low"
  fail-action: retry
  max-retries: 1
```

### consensus

A quorum of agents must agree before the chain proceeds. Use for high-value or high-risk decisions that need multiple reviewers.

```yaml
- type: consensus
  trigger-on: on-metadata
  metadata-key: amount_usd
  match-value: "50000"
  quorum-of:
    - fraud-review-agent@1.0.0
    - fraud-evidence-agent@1.0.0
  threshold: 2              # both must agree
  fail-action: escalate
```

### supervisor

A supervisor agent receives a copy of every hop and can signal intervention. Use for high-stakes domains (finance, healthcare) where an oversight layer is required.

---

## Async Handlers

Handlers that are not on the critical path should be declared async:

```yaml
pipelines:
  - type: in
    handlers:
      - ref: auth-handler
        async: false
        continue-on-error: false    # hard gate — abort if auth fails

      - ref: tank-enrichment-handler
        async: true                 # fires in background
        continue-on-error: true     # enrichment failure never blocks request

  - type: out
    handlers:
      - ref: audit-log-handler
        async: true                 # fire-and-forget
        continue-on-error: true
```

`async: true` means the handler is dispatched as a goroutine and the pipeline does not wait for it. `continue-on-error: true` means a handler failure is logged but the pipeline continues.

**Rule of thumb:** Auth and validation handlers — sync, not continue-on-error. Enrichment, audit, and metrics handlers — async, continue-on-error.

---

## MaxHops

`max-hops` caps the number of agent-to-agent handoffs in a single invocation chain:

```yaml
spec:
  max-hops: 3
```

When the hop count reaches the limit, the executor returns the current output rather than continuing. Prevents runaway recursive delegation. Set to `0` to disable.

---

## Policy Sync

Policies are loaded from two sources:
1. **YAML** (`specs/policies/*.yaml`) — loaded at gateway start
2. **Tank** (`appdarta-policies`) — loaded at runtime; tank version wins

Keep them in sync:

```bash
darta policy sync --domain finance          # one-shot sync
darta policy sync --domain finance --watch  # sync on file changes (dev mode)
```

---

## Full Example — Fraud Review

```yaml
apiVersion: appdarta.io/v1
kind: OrchestrationSpec
metadata:
  name: finance-review-gateway
  version: 2.0.0
spec:
  mode: sync
  max-hops: 3

  target:
    kind: agent
    ref: fraud-detection-agent@1.0.0
    timeout: 45s

  pipelines:
    - type: in
      handlers:
        - ref: auth-handler
          async: false
          continue-on-error: false
        - ref: tank-enrichment-handler
          async: true
          continue-on-error: true

    - type: out
      handlers:
        - ref: result-validator-handler
          async: false
          continue-on-error: false
        - ref: audit-log-handler
          async: true
          continue-on-error: true

  multi-agent-policies:
    - type: validator
      agent-ref: fraud-review-agent@1.0.0
      trigger-on: always
      fail-action: block

    - type: critique
      agent-ref: self
      trigger-on: on-metadata
      metadata-key: confidence_score
      match-value: "low"
      fail-action: retry
      max-retries: 1

    - type: consensus
      trigger-on: on-metadata
      metadata-key: amount_usd
      match-value: "50000"
      quorum-of:
        - fraud-review-agent@1.0.0
        - fraud-evidence-agent@1.0.0
      threshold: 2
      fail-action: escalate
```
