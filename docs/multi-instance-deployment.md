# Multi-Instance Deployment

You can run multiple named instances of any framework service on different ports. This is useful for:

- **Environment isolation**: run a `staging` context-service alongside the `default` one
- **Load testing**: run multiple runtime-host instances
- **Multi-tenancy simulation**: different client configurations on different ports
- **CI/CD**: run isolated service sets per test environment

---

## Running a Second Instance

Every service instance has a **name** and a **port**. The `default` instance maps to the canonical ports (18001, 18091, 18110). Additional instances require an explicit name and port:

```bash
# Start a staging context-service on port 18002
darta services start --service context-service --instance staging --port 18002

# Start another runtime-host on port 18092
darta services start --service runtime-host --instance staging --port 18092
```

View all running instances:

```bash
darta services ps
# SERVICE           INSTANCE  PID    PORT   STATUS
# context-service   default   12345  18001  running
# context-service   staging   12346  18002  running
# runtime-host      default   12347  18091  running
# runtime-host      staging   12348  18092  running
```

---

## Pointing runtime-host at a Non-Default context-service

When running a non-default runtime-host, tell it which context-service to use:

```bash
# Set the context-service URL for the staging runtime-host instance
darta extend config --service runtime-host --key context_service_url --value http://127.0.0.1:18002

# Then start the staging runtime-host
darta services start --service runtime-host --instance staging --port 18092
```

The override is written to `.appdarta-local.yaml` and picked up at service start.

---

## Targeting a Non-Default context-service from CLI Commands

Most `darta tank` commands accept `--host` and `--port` to target a specific context-service instance:

```bash
darta tank state export --host 127.0.0.1 --port 18002 --out staging-backup.json
darta tank status --host 127.0.0.1 --port 18002 --name my-tank
darta tank manifest prune --host 127.0.0.1 --port 18002 --name my-tank --keep-last 3
```

---

## Stopping a Specific Instance

```bash
darta services stop --service context-service --instance staging
```

Stop all instances of all services:

```bash
darta services stop --all
# or:
darta stack down
```

---

## Logs per Instance

Each instance writes to its own log file:

```
.logs/context-service.default.log
.logs/context-service.staging.log
.logs/runtime-host.default.log
.logs/runtime-host.staging.log
```

View logs for a specific instance:

```bash
darta services logs --service context-service --instance staging --follow
```

---

## Default Instance Convention

The instance named `default` always maps to the canonical framework ports:

| Service | Default Port |
|---|---|
| context-service | 18001 |
| runtime-host | 18091 |
| gateway | 18110 |

All other instance names require an explicit `--port`. Instance names are arbitrary strings — use names that match your workflow (`staging`, `ci`, `client-a`, etc.).

---

## Container Mode

Container mode does not support named instances — it delegates to `docker compose`:

```bash
darta stack up --mode container
darta stack down --mode container
```

For multi-instance in containers, use a custom `docker-compose.override.yml`.
