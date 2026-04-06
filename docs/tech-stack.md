# Tech Stack

AppDarta is a deliberately mixed-language stack. Each language is used for what it is best at.

---

## Framework Binary Components

| Component | Language | Why |
|---|---|---|
| `appdarta` CLI + gateway | Go | Single compiled binary, fast startup, strong concurrency model for gateway pipelines |
| `appdarta-spec` validator | Go | Compiled with the CLI; JSON Schema validation via Go libraries |
| `wasmtime-host` | Rust + Wasmtime | Memory-safe WASM execution, Cranelift JIT, strict isolation boundary |
| `context-service` | Python / FastAPI | Embedding models (sentence-transformers), ChromaDB integration, scientific Python ecosystem |
| Framework UI shell | TypeScript / React | Framework-owned operator interface, mounted into your project |

---

## Agent Runtime Types

A vertical can mix agent runtime types under the same framework contract:

| Runtime mode | What runs | Typical language |
|---|---|---|
| `wasm` | Compiled WebAssembly module | Rust, Go (TinyGo), C, Python (Emscripten) |
| `http` | External HTTP service | Any language with an HTTP server |
| `grpc` | External gRPC service | Any language with gRPC support |
| `process` | Local binary spawned by gateway | Any language |

Runtime mode is declared per agent in `AgentSpec`. The gateway resolves and routes accordingly.

---

## Storage Layer (context-service)

| Storage | Role |
|---|---|
| ChromaDB | Vector store for embeddings and semantic search |
| PostgreSQL | Tank manifests, partition metadata, episodic memory records |
| Redis | Async queue, ephemeral state, callback tracking |

All three are configurable via environment variables. For local development, `darta stack up` starts them as Docker containers.

---

## Spec Contract

Framework specs are JSON Schema (draft-07). The 31 core schemas in `specs/core/` define the full declarative language available to vertical developers. All validation runs through `appdarta-spec` which is compiled with the schemas baked in.

---

## Wire Protocols

| Surface | Protocol |
|---|---|
| Gateway inbound | HTTP/JSON (`POST /invoke`) |
| WASM host functions | Wasmtime-native (in-process) |
| HTTP agent routing | HTTP/JSON (declared endpoint) |
| gRPC agent routing | gRPC (declared endpoint + proto-ref) |
| context-service API | HTTP/JSON (internal) |
| A2A agent handoff | AppDarta envelope over HTTP |
| Async callbacks | HTTP webhook (`POST /callbacks/approve`, `/callbacks/resume`) |
