# AI Coding Agent Integration

AppDarta exposes an MCP server that AI coding agents (OpenCode, Cursor, Claude Code, and others) can connect to for spec-aware code generation.

## Connect via MCP

Add to your MCP config:

```json
{"mcpServers": {"appDarta": {"command": "darta", "args": ["mcp", "serve"]}}}
```

Then start the server in your vertical project:

```bash
darta mcp serve
```

The agent can now read your project specs, check build status, route tasks to the right model tier, and record outcomes back into the framework lifecycle.

## What the MCP server exposes

| Tool | What it does |
|---|---|
| `dhil_route` | Route a task to the right model tier before generating |
| `get_project_spec` | Read project specs, list agents and tanks |
| `appdarta_get_context_pack` | Get chain context for a build step |
| `appdarta_route_design_task` | Route a design-time task through DHIL-DT |
| `appdarta_get_build_status` | Read current build status |
| `appdarta_get_build_row_output` | Read generated output for a build row |
| `appdarta_record_codegen_outcome` | Log compile/test result back to the framework |
| `appdarta_get_template_recommendation` | Find the right template bundle for a usecase |
| `appdarta_validate_lifecycle_gate` | Check if the current stage is ready to proceed |
| `tank_hydrate` | Pull context chunks from a knowledge tank |
| `invoke_agent` | Invoke an agent and return the result |
| `evaluate_policy` | Check an action against a governance policy |
| `list_policies` | List governance policies |
| `list_model_roles` | List model role bindings |
| `request_approval` | Generate a signed approval link |
| `search_tank` | Keyword or graph query on knowledge tanks |
| `get_flow_status` | Get execution status of a flow or task |
| `appdarta_get_build_logs` | Read persisted build logs |
| `appdarta_get_relevant_examples` | Retrieve top-K learning examples |

## Typical AI agent workflow

```bash
# 1. Start the project
darta ui serve

# 2. Expose MCP tools to the coding agent (separate terminal)
darta mcp serve
```

The agent then:
1. Calls `appdarta_get_context_pack` to load build context for the current node
2. Calls `dhil_route` to select the right model tier for the task
3. Calls `appdarta_get_template_recommendation` to find matching template bundles
4. Generates code
5. Calls `appdarta_record_codegen_outcome` to log the compile/test result back to the framework

## DHIL-DT server for AI routing

The DHIL-DT server is the AI routing layer that the MCP tools call. Connect to a shared server or run locally:

```bash
# Use a shared server
darta framework set-server public \
  --dt http://<server-ip>:8080 \
  --l1 http://<server-ip>:11435 \
  --litellm http://<server-ip>:4000
darta framework use public

# Or run locally
darta dhil-dt serve --port 8080
```
```
