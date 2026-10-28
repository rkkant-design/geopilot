# Scope: GeoPilot

GeoPilot measures how AI answer engines talk about a brand, diagnoses why the brand is or is not recommended, and proves with controlled experiments whether a fix worked. It serves brands (India first, then the US and UK) that want visibility in AI answers they can trust.

**Build approach:** Tracer Bullet (one thin path from prompt to answer to metric to console first, then widen engine by engine).
**Workflow:** Beta (after `/develop`, run `/check verify`, then `/test`). The numbers are the product, so statistics and extraction get tested. Any feature can carry its own tag to do more or less.

_These are recommendations to keep the build orderly, not requirements. Skip anything that does not fit: if you already know how to build a feature, use `/develop` and skip `/architect`. You decide when a feature is `done`._

## At a glance

| # | Feature | Phase | Status |
|---|---------|-------|--------|
| 1 | Clickable client console demo | Foundation | existing |
| 2 | Measurement methodology | Foundation | existing |
| 3 | Stack and architecture | Foundation | planned |
| 4 | Data model | Foundation | planned |
| 5 | Coding standards and tooling | Foundation | planned |
| 6 | Collection adapters and one day cost pilot | Slice 1 Measure | planned |
| 7 | Answer extraction and gold set | Slice 1 Measure | planned |
| 8 | Rollups with intervals | Slice 1 Measure | planned |
| 9 | Client console: measure screens | Slice 1 Measure | planned |
| 10 | Access audit | Slice 2 Diagnose | planned |
| 11 | First party data connectors | Slice 2 Diagnose | planned |
| 12 | Failure stage classifier and citation gap | Slice 2 Diagnose | planned |
| 13 | Action plan with evidence labels | Slice 3 Act and prove | planned |
| 14 | Experiment registry and lift analysis | Slice 3 Act and prove | planned |
| 15 | Model change alerts | Slice 3 Act and prove | planned |

## Foundations

### 1. Clickable client console demo · existing
A self contained demo of the full loop for a fictional brand, used to show what the platform will do. code in `demo/`

### 2. Measurement methodology · existing
Metric definitions with denominators, interval method, diagnosis stages, evidence labels, and the experiment protocol. code in `docs/methodology.md`

### 3. Stack and architecture · needs a decision
Decide the runtime, queue, storage, and hosting, then scaffold a runnable backend and console so every later slice builds on real structure. The working design is in `docs/architecture.md`.
**Done when:** the stack is recorded in a spec and an empty backend job and console boot locally and deploy.
- [ ] Decide the stack (spec): `/architect stack and architecture`

### 4. Data model · needs a decision
Workspaces, brands and aliases, versioned prompts, the engine and instrument registry, collection tasks, answers, extracted facts, experiments, and rollups. The draft is `db/schema.sql`.
**Done when:** the schema supports every slice below without a breaking migration, and row level security keeps each workspace private.
- [ ] Design it (spec): `/architect data model`

### 5. Coding standards and tooling
Capture conventions from the real scaffold, then install lint, format, and pre commit checks for Python and the console.
**Done when:** root `AGENTS.md` reflects the real stack and lint and format run clean.
- [ ] Capture conventions and tooling choices: `/audit`

## Slice 1: Measure

### 6. Collection adapters and one day cost pilot · needs a decision
One adapter per engine and instrument behind a common interface, scheduled tasks with idempotency keys, and a raw answer archive. Then one day of real runs to measure tokens, searches, and cost per answer. Open questions the pilot settles: does OpenAI Batch accept web search, what replaced the Perplexity Sonar endpoint, is Gemini grounding billed per prompt or per search, does the AI Mode data provider support India.
**Done when:** a scheduled run lands valid answers for every engine and instrument cell, failures are logged as outcomes, and measured cost per answer is within 20% of the model in `docs/architecture.md`.
- [ ] Design it (spec): `/architect collection adapters and cost pilot`

### 7. Answer extraction and gold set · needs a decision
A deterministic pass for brand aliases and URLs, then a batched LLM parser for mentions, position, sentiment by topic, and citations. A 300 answer gold set labelled by two people keeps it honest.
**Done when:** brand detection reports precision and recall, sentiment reaches kappa 0.6 or better on the gold set, and every extracted fact links to its raw answer.
- [ ] Design it (spec): `/architect answer extraction`

### 8. Rollups with intervals
Daily rollups per workspace, brand, engine, instrument, and question family, with Wilson intervals for single cells and cluster bootstrap intervals for headlines.
**Done when:** the minimum metric set in `docs/methodology.md` is computed for 7 and 28 day windows, each with its interval and denominator.
- [ ] Build it: `/develop rollups with intervals`

### 9. Client console: measure screens
The overview, visibility, prompts and answers, sentiment, and citations screens from the demo, wired to real rollups under row level security.
**Done when:** a signed in workspace member sees their own live numbers on every measure screen and can open the raw answer behind any number.
- [ ] Build it: `/develop client console measure screens`

## Slice 2: Diagnose

### 10. Access audit
Check robots rules for each retrieval bot, CDN and firewall blocks, and whether key pages render without JavaScript.
**Done when:** an audit run produces the checklist shown in the demo for a real site, with each item graded.
- [ ] Build it: `/develop access audit`

### 11. First party data connectors · needs a decision
Search Console AI impressions, Bing Webmaster AI citations, and GA4 AI referrals pulled into the workspace.
**Done when:** each connector syncs weekly for a connected site and its numbers appear beside the measured ones.
- [ ] Design it (spec): `/architect first party data connectors`

### 12. Failure stage classifier and citation gap
For each question family, find the first failing stage (page exists, retrieved, cited, named, framed well) and list domains that cite competitors but not the brand.
**Done when:** every family shows its failing stage with the evidence behind it, and the gap list ranks domains by citation share.
- [ ] Build it: `/develop failure stage classifier`

## Slice 3: Act and prove

### 13. Action plan with evidence labels
Actions linked to question families, each with a lever, owner, status, and an evidence label tied to experiments where one exists.
**Done when:** the action plan screen runs on real data and an action's label updates when its experiment reads out.
- [ ] Build it: `/develop action plan`

### 14. Experiment registry and lift analysis · needs a decision
Pre registration, randomized treatment and holdout families, sealed results until readout, and a difference in differences estimate with a cluster bootstrap interval.
**Done when:** a registered experiment reads out with an effect and interval, null results are reported the same way, and a placebo check runs alongside.
- [ ] Design it (spec): `/architect experiment registry`

### 15. Model change alerts
A change detection alert per engine series so a model update is not mistaken for a client win.
**Done when:** a simulated shift triggers an alert and normal noise does not.
- [ ] Build it: `/develop model change alerts`

## Deferred
Out of scope for the current build pass, kept so the plan stays honest.
- **Hindi and regional language panels**: separate prompt panels per language · needs a decision
- **Copilot measurement**: no consumer capture provider confirmed yet · needs a decision
- **Logged in persona panel**: personalised answers as a paid add on · needs a decision
- **White label reports**: agency branding on the console and reports
- **Multi market workspaces**: one brand tracked across countries · needs a decision
