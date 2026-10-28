# GeoPilot

GeoPilot is a Generative Engine Optimization (GEO) platform. It measures how AI answer engines (ChatGPT, Gemini, Google AI Mode, Perplexity, Claude) talk about a brand, finds out why the brand is or is not recommended, and proves whether a fix moved the answers.

Most AI-visibility tools stop at measurement. GeoPilot runs the full loop:

| Stage | What it answers |
|---|---|
| **Measure** | How often is the brand named, in what position, with what sentiment, and which sources do engines cite? |
| **Diagnose** | Where does the chain break: no page, page not retrieved, retrieved but not cited, or named but framed weakly? |
| **Act** | Which fixes to make, each labelled by the strength of its evidence. |
| **Prove** | Did the fix cause the lift? Pre-registered experiments with holdout prompt groups and confidence intervals. |

## Demo

[`demo/index.html`](demo/index.html) is a clickable, self-contained demo of the client console. It uses **simulated data for a fictional brand** (NovaCRM, an India CRM vendor, against fictional competitors). Click **Guided tour** in the top bar for a 10-step walkthrough.

Run it locally:

```bash
python -m http.server 8765 --directory demo
```

Then open http://localhost:8765. No build step and no dependencies; fonts load from Google Fonts.

To deploy, connect the repository to Netlify. [`netlify.toml`](netlify.toml) publishes the `demo` folder.

### Screens

- **Overview:** headline mention rate with its 95% interval, 90-day trend with event markers, three measurement instruments, engine × instrument grid
- **Visibility and rank:** competitor leaderboard with intervals, position in the answer, head-to-head
- **Prompts and answers:** question families, run-to-run consistency grid, and the individual answer behind every number
- **Sentiment:** net sentiment by topic and the cited sources behind each narrative
- **Citations:** source mix by engine and the gap list of domains that cite competitors but not the brand
- **Diagnose:** failure stage per question family and an AI-crawler access audit
- **Action plan:** fixes labelled proven, backed by evidence, to be tested, or no effect found
- **Experiments:** difference-in-differences results, including a null result
- **Method and data quality:** collection, formulas, accuracy checks, and what the platform does not claim

## Repository layout

```
AGENTS.md          Project context for AI coding agents (CLAUDE.md points here)
demo/              Clickable client console demo (static HTML)
db/
  schema.sql       Draft Postgres (Supabase) schema
docs/
  methodology.md   Metric definitions, statistics, experiment protocol
  architecture.md  Collection instruments, pipeline, data model, cost model, risks
  scope/scope.md   Living plan: features by phase and their status
  specs/           Decision specs, one per feature that needs a decision
  reviews/         Code and verification reviews
  releases/        Release notes
  postmortems/     Incident write-ups
netlify.toml       Static deploy config for the demo
```

## Planned stack

Python collection and analysis jobs on Railway, Postgres on Supabase with row-level security per client, and a React client console on Netlify. See [docs/architecture.md](docs/architecture.md).

## Status

The demo is complete. The platform itself is in the design stage; [docs/scope/scope.md](docs/scope/scope.md) is the living plan and tracks each feature's status.

## Working on this repo

The repo follows the [jsmastery-pro/skills](https://github.com/jsmastery-pro/skills) agentic workflow, where project state lives in files: `/scope` keeps the plan in `docs/scope/`, `/architect` writes decision specs to `docs/specs/`, `/develop` builds to a spec, `/check` writes to `docs/reviews/`, and `/document` writes to `docs/releases/` and `docs/postmortems/`. Start with the first unticked box in the scope.
