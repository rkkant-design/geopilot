# Roadmap

A 90-day plan from a working pipeline to the first proven lift.

| Phase | Build | Exit gate |
|---|---|---|
| **Weeks 1–2: foundations** | Methodology spec v1 (formulas, denominators, interval method, instrument labels). Supabase schema. Collection adapters for the engine APIs and data providers. Raw answer archive. A 300-answer gold set for the parser. A 1-day pilot to measure real tokens, searches and cost per answer. | Cost per answer within 20% of the model; parser reaches kappa ≥ 0.6 on the gold set |
| **Days 15–30: measurement MVP** | Scheduled runs on a Postgres queue. Alias and URL pre-pass, then a batched LLM parser. Wilson and cluster-bootstrap rollups. React console reading rollups under row-level security. Weekly report. Public methodology page. | 14 clean days for one workspace; under 2% failed tasks |
| **Days 31–60: diagnosis** | Access audit (robots.txt, CDN rules, fetch as each bot, raw vs rendered HTML). Index presence checks. Search Console, Bing Webmaster and GA4 connectors. Citation gap analysis. Failure-stage classifier. Drill-down from negative topics to the cited URLs behind them. Competitor discovery. | Diagnosis delivered for the first workspace |
| **Days 61–90: act and prove** | Experiment registry with pre-registration. Randomized holdout families. Difference-in-differences analysis job. Change-point alerts. Action tracker with evidence labels and guardrails. en-IN and Hindi panels. | First pre-registered experiment live; readout with an interval around day 100–120 |

## Open questions for the pilot

- Does OpenAI's Batch API accept the web search tool?
- What replaced Perplexity's Sonar chat endpoint after September 2026, and which model sits behind it?
- Is Gemini grounding billed per prompt or per search query?
- Does the Google AI Mode data provider support India locations?

## Risks

| Risk | Mitigation |
|---|---|
| Terms of service on consumer-app capture | Licensed providers only, disclosed method, API-only fallback |
| API answers differ from what users see | Separate instrument labels; consumer surface as the headline |
| Answer volatility | Probability metrics, 28-day windows, intervals, change alerts |
| Unproven optimization levers | Evidence labels on every action; experiments before claims |
| API churn and price changes | Adapter layer, versioned engine registry, raw archive, monthly price review |
| Client sites silently blocking AI bots | Access audit before any content work |
| Parser error in sentiment and entities | Gold sets, kappa gates, re-checks after model changes |
