# Architecture

AppDarta separates the central control plane from business-scoped vertical implementations.

```mermaid
flowchart LR
    A["Architect / Operator"] --> B["darta CLI"]
    A --> C["Framework UI Shell"]
    B --> D["AppDarta Gateway"]
    C --> D
    D --> E["Orchestrator Control Plane"]
    E --> F["Runtime Dispatch"]
    F --> G["WASM Agent Runtime"]
    F --> H["HTTP / gRPC / Subprocess Agents"]
    E --> I["Context Service"]
    I --> J["Data Tanks"]
    K["Vertical Project"] --> E
    K --> I
    K --> C
```

## Control Plane

Framework-owned:

- CLI
- UI shell
- gateway
- orchestration and policy engine
- model registry and codegen controls
- runtime dispatch contract
- central schemas and validation

## Vertical Plane

Vertical-owned:

- use case and design instance specs
- business modules
- business runtime code
- business UI modules
- business data bindings

The framework remains centralized. Verticals stay business-scoped.
