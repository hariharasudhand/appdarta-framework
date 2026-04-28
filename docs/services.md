# Framework Services

AppDarta provides three framework-managed runtime services. As a vertical developer, you do not write code for these services — you interact with them exclusively through the `darta` CLI and through your YAML spec declarations.

---

## Services at a Glance

| Service | Role | Default Port |
|---|---|---|
| **context-service** | Stores and retrieves tank data (embeddings, documents, episodic memory) | 18001 |
| **context-service/memory** | Episodic memory REST API — observations, session summaries, context builder | 18001 |
| **runtime-host** | Executes WASM agent modules in isolation | 18091 |
| **gateway** | Routes task invocations through your orchestration plan | 18110 |

These services are framework-owned. `runtime-host` and `gateway` are shipped with Darta Platform. `context-service` is a framework-managed companion service and is started through the supported Darta service workflow rather than implemented inside your vertical repo.

---

## Starting the Stack

Start all three services in the correct dependency order:

```bash
darta stack up
```

Stop them all:

```bash
darta stack down
```

Check their status:

```bash
darta services ps
# SERVICE           INSTANCE  PID    PORT   STATUS   STARTED   LOG
# context-service   default   12345  18001  running  10:00:05  .logs/context-service.default.log
# runtime-host      default   12346  18091  running  10:00:08  .logs/runtime-host.default.log
# gateway           default   12347  18110  running  10:00:11  .logs/gateway.default.log
```

Run a health probe:

```bash
darta services health
```

---

## Default Configuration

All service defaults can be viewed with:

```bash
darta extend config
```

Example output:
```
context-service
  host:                          127.0.0.1   [default]
  port:                          18001       [default]
  log_dir:                       .logs       [default]

runtime-host
  host:                          127.0.0.1   [default]
  port:                          18091       [default]
  context_service_url:           http://127.0.0.1:18001  [default]

gateway
  listen:                        127.0.0.1:18110  [default]
  log_dir:                       .logs       [default]
```

All values shown as `[default]` are framework defaults. Override any value with:

```bash
darta extend config --service gateway --key listen --value 0.0.0.0:18110
```

Overrides are saved to `.appdarta-local.yaml` and applied on next service start.

---

## Starting Individual Services

Start a specific service:

```bash
darta services start --service context-service
darta services start --service runtime-host
darta services start --service gateway
```

Stop a specific service:

```bash
darta services stop --service context-service
```

---

## Viewing Logs

```bash
darta services logs                              # all services
darta services logs --service context-service   # specific service
darta services logs --service gateway --follow  # follow in real time
darta services logs --grep hydrate              # filter by keyword
```

---

## Running the Gateway for Your Project

The gateway requires your project's orchestration spec. Run it from your project directory:

```bash
cd /path/to/your-vertical-project
darta services start --service gateway
# or equivalently:
darta gateway serve
```

The gateway discovers your orchestration spec from `specs/orchestration/` automatically.

---

## Health Checks

`darta doctor` probes all three services as part of its stack health check:

```bash
darta doctor
```

To skip stack probes (when services are not running locally):

```bash
darta doctor --skip-stack
```

---

## Episodic Memory Service

The `context-service/memory` subsystem provides persistent agent memory across sessions. It runs as part of the context-service.

### Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/memory/observations` | POST | Record an observation for an agent session |
| `/memory/observations` | GET | List recent observations (`?agent_id=&limit=`) |
| `/memory/context/{agent_id}` | GET | Return the assembled Layer 0 memory context block |
| `/memory/compress` | POST | Compress a session's observations into a `SessionSummary` |
| `/memory/summaries/{agent_id}` | GET | List session summaries for an agent |

### How It Works

1. At the end of each agent session, `POST /memory/compress` distils observations into a `SessionSummary` via Dhil (`role: memory/compress` — routes to Ollama L1 first, Haiku L2 fallback).
2. At the start of the next session, `GET /memory/context/{agent_id}` returns a Markdown block (Recent Observations → Details → Latest Session Summary).
3. That block is prepended to the prompt as **Layer 0** before Dhil routing — enriching the agent's context without any code in the vertical.

The memory service uses the same Postgres instance as the rest of the context-service when running in distributed mode. In local mode it uses SQLite.

## When You Need Multiple Instances

For advanced scenarios (staging environment, load testing, multi-tenancy simulation), see:
[Multi-Instance Deployment](./multi-instance-deployment.md)
