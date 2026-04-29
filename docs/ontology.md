# OntologySpec

## Why ontology — what it enables for agents

Most agent platforms let you connect data sources. The agent reasons over whatever it retrieves. The problem: agents don't know what they don't know. Without a declared domain model, an agent answering a question about a patient can only search by text similarity — it cannot ask "what appointments, medications, and alerts are related to this patient?" That relationship graph lives nowhere.

OntologySpec is the answer. It declares your domain entities, relationships, and rules (`Patient → has-appointments → Appointment → prescribed → Medication`). The context service uses this graph to expand retrieval beyond matching documents to matching *context* — related entities, linked records, and structured domain facts.

More importantly, OntologySpec is how you design agent capabilities from domain thinking. Before writing an AgentSpec, you declare what entities the agent works with and what relationships matter. The capabilities follow from the domain, not the other way around. This is what "domain-first" means in practice.

> Without ontology, your agents retrieve documents. With it, they reason over your domain.

---

## What is OntologySpec

OntologySpec is a **first-class YAML spec** (`kind: OntologySpec`) that describes domain **entity types**, **relationships**, optional **actors**, **rules**, and **extraction** settings. It is validated by **appdarta-spec** against `specs/core/OntologySpec.schema.json` (same contract as the `darta ontology validate` command).

It complements the **dictionary** (field vocabulary) and **BDD** scenarios: the dictionary says *what fields exist*; BDD says *how behaviour is triggered*; OntologySpec says *which business objects exist and how they relate* — the graph RAG layer reasons over that model.

---

## Derivation chain (Dictionary + BDD → Ontology)

```
┌─────────────────────┐     ┌─────────────────────┐
│ Domain dictionary   │     │ BDD records         │
│ specs/analysis/     │     │ wizard-bdd.db       │
│ <domain>-dictionary │     │ (Given / When /     │
│ .yaml               │     │  Then scenarios)    │
└──────────┬──────────┘     └──────────┬──────────┘
           │                            │
           └────────────┬───────────────┘
                        ▼
              ┌─────────────────────┐
              │ Wizard / Dhil       │
              │ blueprint role      │
              │ (preview only)      │
              └──────────┬──────────┘
                        ▼
              ┌─────────────────────┐
              │ OntologySpec YAML   │
              │ specs/ontology/*.yaml │
              └──────────┬──────────┘
                        ▼
              ┌─────────────────────┐
              │ darta ontology       │
              │ ingest → context-svc │
              └─────────────────────┘
```

The CLI and wizard **do not silently overwrite** production ontologies: `ingest` posts to the context service; `POST /api/ontology/generate` returns YAML for **preview** only.

---

## YAML shape (field reference)

| Path | Purpose |
|------|---------|
| `apiVersion` | Must be `appdarta.io/v1` |
| `kind` | Must be `OntologySpec` |
| `metadata.name` / `metadata.domain` / `metadata.version` | Identity and semver |
| `spec.entity-types[]` | Each type has `name`, `description`, `fields[]` |
| `spec.entity-types[].fields[]` | `name`, `type`, `identifier`, `required`, optional `values` for enums |
| `spec.relationships[]` | `name`, `from`, `to`, optional `cardinality`, `description` |
| `spec.extraction.confidence-threshold` | 0–1 for graph extraction pipelines |

**Healthcare-style excerpt** (abbreviated; see `config/playbooks/healthcare-clinic.yaml` → `ontology-seed` for a fuller seed):

```yaml
apiVersion: appdarta.io/v1
kind: OntologySpec
metadata:
  name: healthcare-clinic
  domain: healthcare-clinic
  version: 0.1.0
spec:
  entity-types:
    - name: Patient
      fields:
        - { name: patient_id, type: string, identifier: true }
        - { name: name, type: string }
  relationships:
    - { name: has-appointment, from: Patient, to: Appointment, cardinality: one-to-many }
  extraction:
    confidence-threshold: 0.75
```

---

## CLI

| Command | Purpose |
|---------|---------|
| `darta ontology init [--domain …] [--playbook …]` | Scaffold `specs/ontology/<domain>.yaml`; optional merge from `config/playbooks/<name>.yaml` |
| `darta ontology validate --file <path>` | JSON schema + semantic checks via appdarta-spec |
| `darta ontology ingest --spec <path>` | POST to context service `/ontology/ingest` |
| `darta ontology show --domain <name>` | GET stored ontology |

---

## Graph RAG

Once an ontology is **ingested** and graph extraction is enabled for a tank, chunks can be linked to **entity and relationship** rows (see internal planning docs). Retrieval can combine **vector similarity**, **full-text**, and **graph neighbourhood** expansion. The OntologySpec is the schema contract those rows must respect.

---

## Getting started

1. **Validate the contract**: `darta ontology validate --file specs/ontology/<your>.yaml`
2. **Ingest** when the context service route is available: `darta ontology ingest --spec specs/ontology/<your>.yaml`
3. **Iterate** with dictionary + BDD changes, then re-run validate before ingest.

For a vertical starting point, use **`config/playbooks/*.yaml`** (`VerticalPlaybook`) with `darta ontology init --playbook <name>`.
