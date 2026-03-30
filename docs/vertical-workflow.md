# Vertical Workflow

A public vertical should depend on a framework release, not on framework source.

Each vertical carries:

- `appdarta.project.yaml`
- `appdarta.framework.yaml`
- root lifecycle specs
- business modules and runtime code

Typical flow:

```bash
darta project bootstrap
darta analyze inspect
darta design inspect
darta design compare
darta codegen plan --project .
darta build project
darta run project
```

The framework binary owns:

- schemas
- gateway
- centralized UI shell
- model registry and codegen control plane
- policy/orchestration/tank contracts
