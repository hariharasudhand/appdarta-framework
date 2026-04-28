# OPEA Integration

Darta Platform produces OPEA-compatible microservices. This document covers the DR-0.6 additions: PromptSpec for build-time metadata, runtime PromptMeta in the invocation envelope, and the updated compliance matrix.

For the full compliance runbook and export walkthrough, see the [compliance docs](../docs/opea/compliance.md) in the main platform repo.

---

## PromptSpec — Build-Time Metadata

Agents can declare prompt metadata in the `opea:` block of their `AgentSpec` YAML:

```yaml
opea:
  enabled: true
  service-type: LLM
  input-datatype: TextDoc
  output-datatype: TextDoc
  prompt:
    template-version: "1.0.0"
    system-prompt-hash: "a3f7bc12"   # sha256 first 8 chars
    context-strategy: rag            # "rag" | "memory" | "none"
    max-context-tokens: 4096
```

| Field | Type | Purpose |
|---|---|---|
| `template-version` | semver string | Tracks which prompt template the agent uses — enables rollback if a prompt change causes regressions |
| `system-prompt-hash` | 8-char sha256 | Detects accidental system prompt drift across environments |
| `context-strategy` | string | Declares whether the agent uses RAG, episodic memory, or no external context |
| `max-context-tokens` | int | Declared upper bound — used by OPEA compliance checks and cost estimation |

The `prompt:` block is optional. Agents that omit it receive a `warning` in L2 compliance (see below) but are not blocked from export.

---

## Export — opea-component.yaml

When you run `darta export opea --agent <path>`, the `prompt:` block is included in the generated `opea-component.yaml` if any field is set:

```yaml
# generated opea-component.yaml (excerpt)
metadata:
  name: fraud-detection-agent
spec:
  serviceType: LLM
  prompt:
    templateVersion: "1.0.0"
    contextStrategy: rag
    maxContextTokens: 4096
```

---

## L2 Compliance Check — prompt-metadata-declared

Added to `config/opea/v1.5/compliance-matrix.yaml`:

```yaml
- id: prompt-metadata-declared
  description: "Agent declares prompt.template-version in OPEA spec"
  check: opea.prompt.template_version != ""
  severity: warning
```

This check fires at L2 (not L1). Agents that predate DR-0.6 will show this warning but will not fail export. New agents should include `template-version` as a minimum.

Check the compliance result for any agent:

```bash
darta export opea --agent specs/agents/my-agent.yaml
# or via the API:
curl -s http://localhost:18110/api/opea/agents | jq '.[0].compliance'
```

---

## PromptMeta — Runtime Invocation Envelope

After Dhil dispatches a prompt, `InvocationEnvelope` carries runtime metadata for every downstream handler:

```json
{
  "prompt_meta": {
    "tier_used": "l2",
    "model_id": "claude-haiku-4-5",
    "tokens_in": 842,
    "tokens_out": 310,
    "cost_usd": 0.00127
  }
}
```

This makes token and tier data available to:
- The `token-limit` builtin handler — can enforce per-invocation budget
- Audit log handler — persistent cost record per invocation
- The UI `CloudUsageBadge` — shows tier, model, tokens, cost, and compression savings

`PromptMeta` is populated from `dispatchLLMResponse` fields (built in the Dhil dispatch layer). It is `nil` when the invocation does not go through Dhil (e.g. direct HTTP agent calls).

---

## Compression Stats in Usage Response

When the Linga compression sidecar (`darta dhil linga start`) is running and the prompt exceeds 4,000 tokens, the `usage` object in API responses includes:

```json
{
  "tier": "l2",
  "model": "claude-haiku-4-5",
  "tokens_in": 842,
  "tokens_out": 310,
  "cost_usd": 0.00127,
  "is_cloud": true,
  "compression_original_tokens": 3640,
  "compression_saved_tokens": 2798,
  "compression_ratio": 0.231
}
```

`tokens_in` always reflects what the LLM was actually billed for (post-compression). `compression_saved_tokens` is how many tokens Linga removed before the call.
