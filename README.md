<div align="center">
  <p>
    <a href="https://www.dhruvialabs.com/">
      <img src="https://raw.githubusercontent.com/hariharasudhand/appdarta-vertical-template/master/logo_dhruvialabs.png" alt="Dhruvia Labs" width="260">
    </a>
  </p>
  <p><strong>A product from <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a></strong></p>
</div>

# Darta Platform

> **Beta** — Active development. Early trials and feedback are welcome.

**Darta** is a platform for teams who want to build governed, domain-specific AI applications — not just wire prompts together.

The idea behind the name: *app_in darta* — you bring your app into Darta. Your domain, your agents, your data. Darta provides the structure, the routing, the governance, and the execution environment that turns it into something production-shaped.

---

## What Darta Is For

Most AI tooling asks you to figure out governance, routing, knowledge management, and operational visibility yourself. Darta does that work so your team can focus on the domain problem.

You bring:
- the business logic
- the domain knowledge
- the agents you need

Darta brings:
- a governed execution environment
- a smart AI routing layer
- a scanning and quality layer
- a runtime that keeps your agents isolated and auditable

**Three bets Darta makes:**

1. **Domain-first.** You declare your domain model — BDD scenarios, ontology, policies — before building agents. The platform derives what agents need, what data they use, and what rules govern them. You cannot design a capable decision-making agent without first understanding the domain it operates in.

2. **No domain training.** A base LLM (Claude, GPT-4o, Ollama — your choice) reasons over domain-accurate context from Data Tanks, governed by PolicySpec. Domain expertise lives in specs and knowledge assets, not model weights. New domain: new specs, not a new model.

3. **Design to runtime — one vertical, both planes.** The same specs that drive the design wizard enforce runtime behavior at the gateway. There is no gap between what you designed and what runs.

Darta does not replace your AI provider, runtime framework, or orchestration layer. It adds what none of them ship: lifecycle governance from business intent to deployed agent, with domain knowledge and policy enforcement baked in.

---

## The Products Inside Darta

### Darta Framework

The foundation. Install it once, build any number of domain verticals on top of it.

A vertical is your domain app — it carries your agents, your knowledge, your flows, and your rules. The framework handles everything else: execution, routing, context, policy evaluation, and lifecycle management.

```
darta project bootstrap   → start a new vertical
darta stack up            → run your vertical locally
darta ui serve            → open the wizard UI
```

### Darta Dhil

The AI routing layer. Dhil is the intelligent proxy that sits between every AI action in your project and the actual tools running behind it.

You tell Dhil what tools you have (a local Ollama, a Claude Code session, an AI gateway). Dhil handles which one runs for which task, in what order, with what fallback. No hardcoded provider calls inside your domain code.

Dhil also manages **ContextOS** — named governance configurations that map AI roles to tools. Switch configs per environment or project. Everything persists in your Tank.

```
darta dhil setup          → install and verify Dhil
darta dhil summary        → today's usage and session activity
```

### Darta Forge

The code and dependency scanning layer. Forge keeps your vertical healthy as it grows — scanning for dependency issues, structural drift, and quality signals across your project.

```
darta forge scan          → scan project dependencies and structure
```

Forge is early. The current focus is dependency organisation and scanning. More quality and governance signals are coming.

---

## Product Scope

Darta is being rolled out in stages. This is the current scope and the next product areas:

### Now — Foundation and AI Routing
- Framework is installable and runs real domain verticals
- Wizard UI covers the full lifecycle: setup → design → build → deploy
- Darta Dhil is live — route AI prompts to any tool via the registry
- ContextOS persists named AI governance configs
- Graphviz diagram generation works inside the wizard
- Offline compression available via Darta Dhil LLMLingua

### Next — Forge and Quality Layer
- Darta Forge scans project structure and dependencies
- Scan results surface inside the wizard and CLI
- Structural health becomes part of the deploy gate

### Ahead — Enterprise and Marketplace
- Shared enterprise tank registry (distributed mode is already stubbed)
- Vertical marketplace for domain agent bundles
- Cross-project use case linking at the enterprise level
- Richer ContextOS policy controls per team and project

---

## Building a Vertical

Start here: **[appdarta-vertical-template](https://github.com/hariharasudhand/appdarta-vertical-template)**

That repository is the entry point for vertical developers. It has everything to get you from zero to a running vertical — setup instructions (macOS and Linux, including WSL2 on Windows), reading order, and the full lifecycle walkthrough. This repository is the reference hub for docs, architecture, and release assets.

---

## Documentation

| Topic | Doc |
|---|---|
| Architecture overview | [architecture.md](docs/architecture.md) |
| Darta Dhil — AI routing | [dhil.md](docs/dhil.md) |
| Data tanks and knowledge retrieval | [data-tanks.md](docs/data-tanks.md) |
| Domain ontology | [ontology.md](docs/ontology.md) |
| OPEA compatibility | [opea.md](docs/opea.md) |
| Evaluation specs | [evals.md](docs/evals.md) |
| Runtime signals | [signals.md](docs/signals.md) |
| AI governance and model roles | [ai-governance.md](docs/ai-governance.md) |
| Component model — what's platform, what's yours | [component-model.md](docs/component-model.md) |
| Framework services reference | [services.md](docs/services.md) |
| Vertical lifecycle walkthrough | [quickstart.md](docs/quickstart.md) |
| Multi-instance and tenant isolation | [multi-instance-deployment.md](docs/multi-instance-deployment.md) |

---

<div align="center">
  <p><strong>Currently available for trial use.</strong></p>
  <p>Contact <a href="https://www.dhruvialabs.com/">Dhruvia Labs</a> for production rollout, adoption support, and commercial rollout.</p>
</div>
