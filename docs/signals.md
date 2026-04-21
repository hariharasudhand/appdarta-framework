# SignalSpec

SignalSpec is a **first-class YAML spec** (`kind: SignalSpec`) for declaring a named domain signal, its **payload schema**, its **transport binding**, and optional **retention** rules. It is validated by **appdarta-spec** against `specs/core/SignalSpec.schema.json`, the same contract used by `darta signal validate`.

Signals let a vertical define operational events in a stable, inspectable form before they are emitted at runtime. That keeps event naming, payload shape, and retention policy explicit instead of scattering them across ad hoc code paths.

---

## YAML shape (field reference)

| Path | Purpose |
|------|---------|
| `apiVersion` | Must be `appdarta.io/v1` |
| `kind` | Must be `SignalSpec` |
| `metadata.name` / `metadata.domain` / `metadata.version` | Identity and semver |
| `metadata.description` | Optional operator-facing description |
| `spec.schema.fields[]` | Payload fields: `name`, `type`, `required`, optional `values` |
| `spec.transport.backend` | Current backend, for example `redis` |
| `spec.transport.channel` | Channel or topic name used to emit the signal |
| `spec.transport.ttl` | Time-to-live for transport-layer storage, in seconds |
| `spec.retention.store` | Whether signal history should be retained |
| `spec.retention.duration` | Retention window, for example `24h` |

**Minimal example:**

```yaml
apiVersion: appdarta.io/v1
kind: SignalSpec
metadata:
  name: fraud-review-requested
  domain: finance
  version: 0.1.0
  description: Raised when a transaction is sent for analyst review.
spec:
  schema:
    fields:
      - name: transaction_id
        type: string
        required: true
      - name: risk_level
        type: string
        required: true
        values: [low, medium, high]
  transport:
    backend: redis
    channel: appdarta:signals:finance:fraud-review-requested
    ttl: 3600
  retention:
    store: true
    duration: 24h
```

---

## CLI

| Command | Purpose |
|---------|---------|
| `darta signal init [--name …] [--domain …]` | Scaffold `specs/signals/<name>.yaml` |
| `darta signal validate --file <path>` | Validate SignalSpec YAML via `appdarta-spec` |
| `darta signal emit --name <name> --domain <domain> --payload <json>` | Emit a runtime signal through context-service |
| `darta signal emit --name <name> --spec <path> --payload <json>` | Emit using `metadata.domain` from a SignalSpec |
| `darta signal list [--domain …]` | List signals known to context-service |
| `darta signal history --name <name> --domain <domain> [--last N]` | Read retained signal history |

`emit`, `list`, and `history` depend on the context-service endpoints being available. `validate` does not; it is safe to run in CI as a pure contract check.

---

## Runtime model

SignalSpec separates two concerns:

1. **Contract**: what fields a signal carries and how it is named.
2. **Transport**: where it is published and how long it should remain inspectable.

That means a vertical can review and version its event model in Git before wiring it into agent, flow, or policy execution.

---

## Getting started

1. Scaffold a signal: `darta signal init --name fraud-review-requested --domain finance`
2. Validate it: `darta signal validate --file specs/signals/fraud-review-requested.yaml`
3. Emit a sample event:

```bash
darta signal emit \
  --name fraud-review-requested \
  --domain finance \
  --payload '{"transaction_id":"txn-42","risk_level":"high"}'
```

4. Inspect retained events:

```bash
darta signal history --name fraud-review-requested --domain finance --last 10
```
