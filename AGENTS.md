# GeoPilot

Project context for AI agents. Keep this file short and global. Area specific rules live in nested AGENTS.md files listed under Context files.

## Project

GeoPilot is a Generative Engine Optimization (GEO) platform. It measures how AI answer engines (ChatGPT, Gemini, Google AI Mode, Perplexity, Claude) mention a brand, diagnoses why the brand is or is not recommended, and proves with controlled experiments whether a fix moved the answers. The loop is Measure, Diagnose, Act, Prove. Measurement alone is a commodity; diagnosis and proven lift are the point of the product.

This is a personal project in a public repository.

## Stack

Today the repo holds a clickable demo, design docs, and a draft schema. There is no running backend yet.

- Demo: one static HTML file with vanilla JavaScript and hand drawn SVG charts. No build step, no framework, no package install. The only external load is Google Fonts.
- Planned backend: Python jobs on Railway (collection, extraction, statistics) with a Postgres native queue (Procrastinate or pgmq).
- Planned database: Supabase Postgres in ap-south-1 (Mumbai), row level security per client workspace. Draft in db/schema.sql.
- Planned console: React on Netlify, reading rollups only.
- Raw answers: gzipped JSON in object storage, never in Git.

The stack is not yet decided in a spec. See docs/architecture.md for the working design and docs/scope/scope.md for the decision still owed.

## Repository layout

- demo/ the clickable client console (demo/index.html). Simulated data for a fictional brand.
- db/ the draft Postgres schema.
- docs/methodology.md metric definitions, statistics, diagnosis stages, experiment protocol.
- docs/architecture.md collection instruments, pipeline, data model, unit cost, risks.
- docs/scope/ the living plan. docs/specs/ decision specs. docs/reviews/, docs/releases/, docs/postmortems/ are written by the workflow skills when needed.
- netlify.toml publishes demo/.

## Commands

- Run the demo: `python -m http.server 8765 --directory demo`, then open http://localhost:8765.
- No build, lint, or test harness yet. The local Windows machine has Python but no Node; builds that need Node run on Netlify or CI.

## Conventions

These measurement rules are the product. Do not bend them.

- Unbranded prompts carry the headline. Branded prompts are tracked and reported separately, never blended into visibility.
- Every metric states its denominator. Share of voice counts only qualified competitors.
- Three instruments, never blended: model memory (API, search off), live web (API, search on), and what users see (consumer apps). Label every number with its instrument.
- Every headline number carries a 95% interval. Intervals bootstrap over question families because repeated runs are correlated. Headline windows are 28 days.
- No lift claim without a pre registered experiment with a holdout group. Publish null results too.
- Every recommendation carries an evidence label: proven in your data, backed by docs or studies, plausible and to be tested, or no effect found.
- Log failures, search activation, and the model actually served as outcomes. Never drop them silently.
- Consumer app answers come from licensed data providers only. Never run logged in bots against consumer apps.
- Keep secrets, raw answers, and any real client data out of the repo. Demo data stays simulated, fictional, and labelled as such. Keep employer and real client names out of the repo.

## Design

- Console look (demo/index.html): navy sidebar whose nav groups trace the loop, cool blue tinted neutrals, one teal accent. Sora for headings, IBM Plex Sans for the interface, IBM Plex Mono for data labels. Full light and dark themes through CSS tokens.
- Charts use the validated categorical palette in fixed slot order (blue, orange, aqua, yellow, magenta, green). The client brand is always slot 1. Status colors (good, warning, critical) always ship with an icon and a label.

## Context files

- [docs/scope/scope.md](docs/scope/scope.md) living plan and feature status
- [demo/AGENTS.md](demo/AGENTS.md) rules for the demo
- [db/AGENTS.md](db/AGENTS.md) rules for the schema
