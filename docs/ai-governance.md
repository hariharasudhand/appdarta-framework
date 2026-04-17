# AI Governance

Darta Platform manages AI governance at two levels: **Darta Dhil** for interactive AI routing across the wizard and CLI, and the **spec-level control plane** for AI usage inside your running agents.

---

## Darta Dhil — Interactive AI

Dhil is the AI proxy and router for everything you do interactively — wizard steps, diagram generation, codegen prompts. Every AI request routes through Dhil. You configure the tools; Dhil picks the right one.

What Darta owns:
- the tool registry schema and resolution logic
- role priority evaluation across your configured tools
- ContextOS config persistence via Tank
- token usage recording per session

What you configure:
- which tools are in your registry (`~/.appdarta/dhil/tools.yaml`)
- which ContextOS config is active
- budget preferences per role

See [dhil.md](docs/dhil.md) for the full guide.

---

## Spec-Level AI Governance

For agents that call `appdarta_ai_complete` at runtime, the platform uses `ModelRegistrySpec` and `ModelRoleBindingSpec` to control which provider and model run for which task.

What Darta owns:
- model registry resolution
- role binding resolution
- provider routing and fallback chains
- framework-level AI policy defaults
- token and cost accounting
- budget visibility for operators

What your vertical declares:
- which business phases need AI
- which framework roles those phases use
- optional enterprise-level policy overlays (allowed providers, budget ceilings, approval requirements)

---

## Inspecting AI Config

From a vertical project root:

```bash
darta project inspect --file .
```

This shows:
- `AI config`
- `Model registry`
- `Role bindings`
- `Build codegen role`
- `Runtime reasoning role`
- `AI budget`
- `AI policy`

---

## Usage and Cost Visibility

```bash
darta token-usage --period daily
darta token-usage --period daily --by role
darta token-usage --period daily --by provider
darta token-usage --period daily --by module
```

Darta can answer today:
- which role was active
- which provider and model ran
- how many tokens were consumed
- what the daily budget looks like
- which policy checkpoint applied

---

## UI Surface

The wizard shell surfaces the same information:
- active role and provider
- daily AI cost and token count
- budget burn
- provider, role, model, and module breakdowns

---

## What Is Coming

The current AI governance story is intentionally minimal. Future work includes:

- hard budget enforcement (block requests when ceiling is reached)
- richer provider fallback policies
- deeper per-project and per-team ContextOS controls
- Forge integration — quality signals factored into AI routing decisions
