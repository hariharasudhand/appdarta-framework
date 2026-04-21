# EvalSpec

EvalSpec is a **weighted criteria** document for judging agent or flow outputs with an **LLM-as-judge** pattern. It is validated by **appdarta-spec** against `specs/core/EvalSpec.schema.json`. Semantic rules enforce that **criterion weights sum to 1.0** (±0.001) and that **`fail-fast-on`** IDs reference real criteria.

---

## YAML shape (field reference)

| Path | Purpose |
|------|---------|
| `apiVersion` | `appdarta.io/v1` |
| `kind` | `EvalSpec` |
| `metadata.name` / `metadata.domain` / `metadata.version` | Identity |
| `spec.criteria[]` | Each: `id`, `name`, `weight`, `scoring` (`binary` \| `1-5` \| `0-10`), optional `description`, `rubric` |
| `spec.thresholds.pass-score` | 0–1 aggregate bar |
| `spec.thresholds.fail-fast-on` | List of criterion `id` values that fail the whole run if they fail |

**Minimal example:**

```yaml
apiVersion: appdarta.io/v1
kind: EvalSpec
metadata:
  name: flow-quality
  domain: example
  version: 0.1.0
spec:
  criteria:
    - { id: c1, name: Clarity, weight: 0.5, scoring: "1-5", description: Clear and actionable }
    - { id: c2, name: Safety, weight: 0.5, scoring: binary, description: No unsafe instructions }
  thresholds:
    pass-score: 0.7
    fail-fast-on: []
```

---

## CLI

| Command | Purpose |
|---------|---------|
| `darta eval init [--name …]` | Scaffold `specs/evals/<name>.yaml` |
| `darta eval run --spec <path> [--input <json>]` | Validate spec, produce report under `specs/evals/reports/` |
| `darta eval report --spec <path>` | Print latest report for that basename |

The `run` implementation may use Dhil **review** (or equivalent) per criterion when configured; until then a **stub report** documents pending wiring — still useful in CI to prove the spec validates.

---

## Example report (JSON)

Reports are written as `specs/evals/reports/<eval-name>-<unix>.json` with rows per criterion:

```json
{
  "eval": "flow-quality",
  "generated": "2026-04-21T12:00:00Z",
  "criteria": [
    { "id": "c1", "name": "Clarity", "result": "pass", "score": 0.82, "reason": "…" }
  ],
  "weighted": 0.82,
  "overall": "pass"
}
```

---

## CI / CD gate

Add a job step after a flow or agent produces an artifact:

```bash
darta eval run --spec specs/evals/<name>.yaml --input build/output.json
```

Fail the pipeline if the report’s `overall` is `fail` or if **exit status** is non-zero once Dhil-backed scoring is enabled. Today, **`darta validate --file`** on the EvalSpec should always run in CI even when judge execution is stubbed.
