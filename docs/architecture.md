# Architecture

## Overview

```
 Scheduler (cron)
      │
      ▼
 Task queue in Postgres ──► Collection adapters ──► Raw answer archive (object storage, gzipped JSON)
 (idempotency key per task)   one per engine × instrument          │
                                                                   ▼
                                                     Extraction: alias/URL pass, then LLM parser
                                                                   │
                                                                   ▼
                                     Postgres facts: answers, mentions, citations, sentiment
                                                                   │
                                                                   ▼
                                     Rollups + intervals ──► Client console (React) under row-level security
                                                                   ▲
                       First-party connectors: Search Console, Bing Webmaster, GA4
```

| Layer | Choice | Why |
|---|---|---|
| Jobs | Python on Railway | Collection, extraction and statistics are Python work |
| Queue | Postgres-native (Procrastinate or pgmq) | No extra infrastructure; retries and idempotency in one database |
| Database | Supabase Postgres | Row-level security per client, managed backups |
| Raw archive | Object storage, gzipped JSON | Re-extract when the schema changes instead of re-querying engines |
| Console | React on Netlify | Reads rollups only, never raw tables |
| Tracing | Langfuse at a 10% sample | Parser quality and cost tracking |

At about 20 clients (tens of millions of fact rows a month), raw fact tables move to Parquet queried with DuckDB, and Postgres keeps operational data and rollups.

## Collection instruments

| Engine | Model memory (API, search off) | Live web (API, search on) | What users see (consumer app) |
|---|---|---|---|
| ChatGPT | Batch API | Responses API `web_search`, `user_location` | Licensed data provider |
| Gemini | Batch API | Grounding with Google Search | Licensed data provider |
| Google AI Mode | n/a | n/a | SERP data provider |
| Perplexity | n/a (always searches) | API with web search | Licensed data provider |
| Claude | Message Batches | `web_search` tool, works inside batches | Not available; API only |

Consumer captures run under a fixed protocol: logged out, one prompt per new chat, fixed exit country and city, separate en-IN and Hindi panels, and the model, timestamp and location logged on every answer.

The platform does not run its own logged-in bots against consumer apps. OpenAI's consumer terms prohibit programmatic extraction of output ([OpenAI Terms](https://openai.com/en-GB/policies/row-terms-of-use/)), so consumer data comes from licensed providers and the method is disclosed to every client.

## Data model

The draft schema is in [`db/schema.sql`](../db/schema.sql). Core entities:

- **clients, brands, brand_aliases:** each client workspace tracks its own brand and competitors
- **prompt_families, prompts:** versioned; branded and unbranded kept apart
- **engines, instruments:** a registry, so new engines or retired APIs are configuration, not code changes
- **collection_tasks:** one row per prompt × engine × instrument × run, with a unique idempotency key so retries never bill twice
- **answers:** pointer to the raw archive, model served, search activation, failure reason
- **mentions, citations, domains:** extracted facts
- **experiments, experiment_families:** pre-registration and treatment/holdout assignment
- **actions, audit_checks:** the action plan and access audit
- **daily_rollups:** what the console reads

## Unit cost

Estimated from list prices in October 2026, before a pilot run measures real token and search counts. Shared infrastructure (database, workers, tracing) is about $220–260 a month.

| Configuration | Mix | Answers a month | Cost per client a month |
|---|---|---|---|
| Lite | 50 prompts; 4 consumer surfaces × 3 runs daily; API instruments weekly | ~22k | ~$120–150 |
| Standard | 100 prompts; 5 consumer surfaces × 4 runs daily; API search-on on 50 key prompts × 4 engines × 2 runs daily; API search-off weekly | ~77k | ~$400–520 |
| Research-grade | 60 prompts × 13 engine-instrument cells × 8 runs daily | ~187k | ~$1,365–1,585 |

Search-grounded API answers dominate the bill at about $0.016–0.021 each; consumer captures from providers cost about $0.001–0.009 each, and extraction about $0.0002 per answer with batching and prompt caching. Biggest savers: fewer same-day repeats, weekly runs for long-tail prompts, and batch APIs everywhere except OpenAI web search.

## Security

- Row-level security on every client table; the console uses the public key only.
- The service-role key and all model API keys live only in the backend environment, never in the frontend or the repository.
- Raw answers and client data stay out of Git (see `.gitignore`).
