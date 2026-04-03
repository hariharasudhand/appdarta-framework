# Vertical Workflow

A public vertical should depend on an AppDarta Engine release, not on framework source.

Each vertical carries:

- `appdarta.project.yaml`
- `appdarta.framework.yaml`
- root lifecycle specs
- business modules and runtime code

Typical flow:

```bash
darta run-wizard
darta project inspect --file .
darta analyze inspect
darta design inspect
darta design compare
darta codegen plan --project .
darta build project
darta test project
darta run project
```

The central framework owns:

- schemas
- gateway
- centralized UI shell
- model registry and codegen control plane
- policy/orchestration/tank contracts
- deterministic coordination semantics for multi-step execution

The vertical owns:

- business specs
- business runtime assets
- business UI modules
- business demo inputs and fixtures
