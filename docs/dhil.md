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
