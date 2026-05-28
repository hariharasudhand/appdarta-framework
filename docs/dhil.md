# Darta Dhil

Darta Dhil is the AI routing layer built into the Darta Platform. Every AI action in the wizard, CLI, and codegen paths goes through Dhil. You configure which tools you have — Dhil decides which one runs for which task.

---

## Why Dhil Exists

Without a routing layer, every team ends up hardcoding provider calls into their domain code. When the model changes, or you want to try a different tool, you're digging through agent logic. Dhil keeps that out of your vertical entirely.

You register your tools once. Dhil handles the rest — role matching, priority, fallback, compression, and usage recording.

---

## Tool Registry

The registry lives at `~/.appdarta/dhil/tools.yaml`. You manage it via the CLI or the AI Settings panel in the wizard UI.

Three tool types are supported:

| Type | What it runs |
|---|---|
| `cli` | A local binary — output is streamed to the UI (Claude Code, local scripts) |
| `http` | An OpenAI-compatible or Ollama-style HTTP endpoint |
| `gateway` | A downstream AI gateway (LiteLLM or similar BYOK setup) |

Each tool declares which roles it handles and its priority within that role group. Lower number = higher priority.

---

## Roles

Roles describe the kind of task being asked. Built-in roles:

| Role | What it covers |
|---|---|
| `blueprint` | Solution design, architecture drafts, system blueprints |
| `clarify` | Requirement decomposition, clarification analysis |
| `implementation` | Coding, scaffolding, feature work, refactoring |
| `review` | Code review, design critique, feedback |
| `analyze` | Input analysis, entity extraction, risk assessment |
| `local` | Fast local tasks — typically Ollama |
| `backup` | Fallback for any role when the primary is unavailable |

You can add custom roles from the registry.

---

## ContextOS

ContextOS is the governance configuration layer inside Dhil. It stores named configurations that map roles to specific tool and model combinations. Configs are persisted via Tank — local, Docker, or Postgres depending on your setup.

**Use cases:**
- Separate configs for local dev vs. staging vs. production
- Per-project role bindings
- Switching from a local Ollama setup to a cloud gateway without touching specs

From the wizard UI: **AI Settings → ContextOS** — create a named config, assign role bindings, and activate it.

---

## Offline Compression (LLMLingua)

For large context windows or low-bandwidth environments, Dhil supports offline context compression via LLMLingua.

```bash
darta dhil linga install   # install pip dependencies
darta dhil linga start     # start compression service on :7326
```

When the compression service is running, Dhil automatically compresses context before sending it to the AI tool. The wizard UI shows an offline compression status indicator in AI Settings.

---

## Two-Level Flow

The wizard uses a two-level Dhil flow for AI-assisted steps:

1. **Local** — runs the `local` role tool (usually Ollama) to generate a quick first draft.
2. **Enhance with Dhil** — user clicks the Dhil button to send the draft and original context to the higher-priority tool for a refined result.

This keeps the UI responsive. You only pay the cost of the bigger model when you decide you need it.

---

## CLI Reference

```bash
# Setup
darta dhil setup                      # install and verify Dhil
darta dhil setup graphviz             # install Graphviz for diagram generation

# Registry management
darta dhil tools list                 # show all registered tools
darta dhil tools add \
  --name claude \
  --type cli \
  --command "claude -p {{prompt}}" \
  --roles implementation,review       # add a tool
darta dhil tools check                # health-check all tools

# Usage
darta dhil summary                    # today's token usage and session activity
darta dhil report                     # historical usage and override patterns
darta dhil config                     # set budget and preferences
darta dhil review                     # review pending sub-task decompositions

# Compression
darta dhil linga install              # install LLMLingua dependencies
darta dhil linga start                # start offline compression service
```

---

## Diagram Generation

The wizard uses Dhil for diagram generation at the design stage. When you click **Draw** on a use case or architecture view, Dhil routes the request through the `blueprint` role tool. The result is rendered inline as an SVG.

If you want AI-enhanced diagrams, click **Enhance with Dhil** — this sends the local draft to the higher-priority tool for a refined version.

Install Graphviz to enable diagram rendering:

```bash
darta dhil setup graphviz
```

---

## DHil L1 — Enterprise Private Inference

DHil L1 is a shared Ollama server that runs on enterprise infrastructure — a dedicated Ubuntu machine accessible to the whole team. It is not meant to run on individual developer machines.

The server is secured by an nginx reverse proxy (port 11435) that validates per-developer Bearer tokens. Ollama itself stays bound to localhost; only the proxy is externally accessible.

### Why DHil L1

- **One server, whole team** — no per-developer GPU setup
- **Lightweight models** — phi3.5 (~4 GB), phi4-mini (~2 GB), qwen2.5-coder (~4 GB) run well on a shared CPU/GPU machine
- **Cost-free inference** — no per-token cloud billing for design and local tasks
- **Bearer-keyed access** — each developer gets their own revocable key; no shared password

### Setup

`darta dhil l1 setup` is the single command that handles everything:

```bash
darta dhil l1 setup
```

The wizard asks:

```
Server IP or hostname:
SSH user [ubuntu]:
SSH port [22]:
Public domain for HTTPS? (optional, e.g. dhil.yourco.com):
```

Then it:
1. Detects your local SSH keys — offers `ssh-keygen` if none exist, `ssh-copy-id` if the key is not yet authorised
2. Generates the server setup script internally
3. SCPs the script to the server and runs it via SSH — streams output live
4. Installs Ollama, configures nginx, pulls default models (phi3.5, nomic-embed-text), sets UFW firewall rules
5. Generates an admin API key and registers it on the server
6. Saves the server endpoint and key to `~/.appdarta/ai.yaml` under the `ollama` provider

After setup completes, `darta config ai` and all AI dispatch use the DHil L1 endpoint automatically — no separate configuration step needed.

For air-gapped or manual installs, print the bash script without deploying:

```bash
darta dhil l1 setup --print-script
darta dhil l1 setup --print-script --domain dhil.yourco.com --email admin@yourco.com
```

### Key management (run on the server)

Each developer needs their own API key. Keys are managed on the server by an admin:

```bash
sudo darta dhil l1 keys create --dev alice    # generate + register key for alice
sudo darta dhil l1 keys list                  # list all registered keys
sudo darta dhil l1 keys revoke --dev alice    # deactivate alice's key
```

The admin shares each key with the developer offline (Slack DM, 1Password, email). Developers add it via `darta config ai` → Private / Local LLM → auth token.

### Client configuration

Client-side configuration (endpoint + auth token) lives in `~/.appdarta/ai.yaml` under the `ollama` provider entry — the same place that `darta config ai` writes to. There is no separate DHil L1 config file.

### CLI Reference

```bash
darta dhil l1 setup                          # full SSH deploy wizard
darta dhil l1 setup --print-script           # print setup bash script to stdout
darta dhil l1 keys create --dev <name>       # generate + register a developer key
darta dhil l1 keys list                      # list registered keys
darta dhil l1 keys revoke --dev <name>       # deactivate a key
darta dhil l1 test                           # probe the configured endpoint
```
