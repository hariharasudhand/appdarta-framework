# Lifecycle

AppDarta verticals move through signed and inspectable stages.

```mermaid
flowchart LR
    A["analyze"] --> B["design"]
    B --> C["codegen"]
    C --> D["build"]
    D --> E["data-test"]
    E --> F["data-live"]
    F --> G["run"]
    G --> H["test"]
    H --> I["deploy"]
    I --> J["operate"]
```

## Root lifecycle specs

- `UseCaseSpec`
- `UseCaseClarificationReport`
- `SolutionDesignSpec`

These stay at project root and are signed off before build-time slices are materialized.

## Build-time slices

Design decides:

- project modules
- commons
- tanks
- policies
- orchestration
- UI/runtime assets

Build implements them.
