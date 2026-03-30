# Tech Stack

AppDarta is intentionally mixed-stack.

## Control plane

- Go: CLI, gateway, orchestration control plane
- Rust + Wasmtime: secure WASM execution boundary
- Web UI: centralized framework shell
- Python: optional adapters or services where appropriate

## Agent runtime types

Per agent/component:

- `wasm`
- `http`
- `grpc`
- `subprocess`

This means one vertical can mix runtime types safely under the same framework contract.
