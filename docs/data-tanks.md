# Data Tanks

Data Tanks are one of the defining ideas of AppDarta.

Think of a Data Tank as a named domain knowledge asset, not just a vector store.

Typical sections can include:

- vector-backed knowledge
- plain text knowledge
- structured table-like sections
- live or scheduled refresh pipelines

They fit the AppDarta brand well:

- `darta`
- `dart`
- `Data Tank`

The framework centrally manages tank contracts and capabilities. Verticals bind business data sources and partitions.

## What A Release User Should Expect

For the public release, tanks are used in a simple, inspectable pattern:

1. build a tank from a vertical-owned `DataTankSpec`
2. ingest one or more sample documents into a named partition
3. verify tank health and freshness
4. run the vertical build/test/run flow that hydrates context from the tank

The primary supported commands are:

```bash
darta tank build --spec ./specs/tanks/<tank>.yaml
darta tank ingest --tank <tank-name> --partition <partition> --file <document>
darta tank status --name <tank-name>
```

`darta tank search` is currently a marketplace tank-pack discovery command, not a local content-query command against your running project tanks.

For the June release, local tank proof comes from:

- successful build/test/run hydration
- prepared bundle contents
- runtime result evidence
- doctor and deploy-plan visibility into shared tank topology

After that, the normal vertical path continues:

```bash
darta build project --project .
darta test project --project .
darta run project --project .
```

## Finance Reference

The finance showcase uses a domain tank to support fraud-review evidence.

Typical path:

```bash
darta tank build --spec ./specs/tanks/finance-knowledge-tank.yaml
darta tank ingest --tank finance-knowledge-tank --partition client-data --file ./demo/sample-docs/high-risk-wire-transfer.txt --client-id client-oak
darta tank ingest --tank finance-knowledge-tank --partition client-data --file ./demo/sample-docs/crypto-escalation-note.txt --client-id client-oak
darta tank status --name finance-knowledge-tank

darta build project --project .
darta test project --project .
darta run project --project .
```

That path should end with:

- a prepared bundle at `demo/artifacts/finance-reference-run.json`
- a runtime result at `demo/artifacts/finance-reference-result.json`

The finance result should show a high-risk escalation backed by tank evidence.

## Healthcare Reference

The healthcare showcase uses a domain tank to support medication-review guidance.

Typical path:

```bash
darta tank build --spec ./specs/tanks/healthcare-standards-tank.yaml
darta tank ingest --tank healthcare-standards-tank --partition client-documents --file ./demo/sample-docs/patient-medication-guidance.txt --client-id client-oak
darta tank ingest --tank healthcare-standards-tank --partition client-documents --file ./demo/sample-docs/contrast-dye-alert.txt --client-id client-oak
darta tank status --name healthcare-standards-tank

darta build project --project .
darta test project --project .
darta run project --project .
```

That path should end with:

- a prepared bundle at `demo/artifacts/healthcare-reference-run.json`
- a runtime result at `demo/artifacts/healthcare-reference-result.json`

The healthcare result should recommend reviewing kidney function and medication timing before contrast dye exposure when the guidance documents are present.

## Shared Enterprise Tanks

Release verticals may also bind shared enterprise tanks through project configuration.

The important distinction is:

- framework/shared tanks provide reusable enterprise context
- vertical tanks provide business-specific project context

The three shared enterprise tanks expected by the current framework path are:

- `enterprise-accounting`
- `enterprise-users`
- `enterprise-common-registry`

Those tanks are visible through the project and operator surfaces rather than through a separate hidden framework database.

Release-facing proof path:

```bash
darta project inspect --file .
darta doctor --skip-stack
darta deploy plan --project .
```

Those commands should make it clear:

- whether shared tanks are bound or missing
- which shared storage profile is active
- whether rollout still depends on embedded storage
- whether higher-environment deploy review is needed

For the June release, the main credibility bar is not advanced tank topology or local semantic search UX. It is that both showcase verticals can build, fill, inspect, and use project tanks while also surfacing shared enterprise tank bindings through supported framework commands.
