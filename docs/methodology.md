# Methodology

How GeoPilot turns AI answers into numbers a client can trust. Every metric states its denominator, every headline carries an interval, and no lift is claimed without a controlled test.

## Principles

1. **Unbranded prompts carry the headline.** Branded questions ("Is NovaCRM good?") name the brand almost every time, so they are tracked separately and never blended into visibility.
2. **Presence, not position, is the stable unit.** The same prompt returns the same brand list less than 1% of the time and the same order less than 0.1% of the time, but how often a brand appears is stable ([SparkToro via Search Engine Journal](https://www.searchenginejournal.com/ai-recommendations-change-with-nearly-every-query-sparktoro/566242/)).
3. **Three instruments, never blended.** Model memory (API, search off), live web (API, search on) and the consumer apps answer differently. API web search recovered only about 23% of the URLs that the ChatGPT app cited ([Jiang et al., arXiv 2610.15382](https://arxiv.org/html/2610.15382)).
4. **Report uncertainty at the level of the claim.** A single prompt-day of 8 runs with 4 mentions has a 95% Wilson interval of roughly 22–78%. Headline numbers use 28-day windows.
5. **Show the working.** Raw answers are archived and every metric can be traced back to the answers it was computed from.

## Metrics

| Metric | Definition | Reported at |
|---|---|---|
| Unbranded mention rate (headline) | Answers naming the brand ÷ all valid unbranded answers | Engine × instrument × question family; 7- and 28-day rolling |
| Share of voice | Brand mentions ÷ mentions of the brand and qualified competitors | Same |
| Top-3 rate | Answers naming the brand among the first three ÷ valid answers | Same |
| Average position | Order in which the brand is first named (1 = first), among answers naming it | Same; secondary to top-3 rate |
| Owned-citation rate | Search-activated answers citing at least one owned URL ÷ search-activated answers | Engine × family |
| Source mix | Citations by source type (owned, competitor, review, forum, news/blog, video/reference) as a share of **all** citations | Engine, monthly |
| Aspect sentiment | % positive, neutral and negative per topic (price, support, scale…), among answers naming the brand and discussing that topic | Topic; only where at least 10 prompts cover it |
| Net sentiment | % positive − % negative, among answers naming the brand | Brand, engine |
| Branded accuracy | Branded answers with no factual error against the client's fact sheet ÷ branded answers | Engine, monthly |
| Search activation | Answers where the engine actually searched ÷ all answers on a search-enabled instrument | Engine |
| First-party exposure | Search Console AI impressions, Bing Webmaster AI citations, GA4 AI referrals | Client site, weekly |

A competitor enters the share-of-voice denominator only if it recurs across answers or resolves to a real domain. Weighted composite scores, if used, are a secondary view with their weights declared.

## Statistics

- **Intervals.** 95% intervals come from a cluster bootstrap that resamples question families, because repeated runs of one prompt are correlated. Wilson intervals are used for single cells.
- **Sample design.** Precision comes from more question families and longer windows, not from more same-day reruns. With an intraclass correlation of 0.5, 8 repeats across 50 prompts carry the information of only about 89 independent runs.
- **Repeats.** Consumer surfaces about 4 runs a day; API with search about 2 runs a day on key prompts; API without search weekly. Published work recommends at least 7–8 runs per prompt per day when single prompt-days must be read ([Schulte et al., arXiv 2604.07585](https://arxiv.org/html/2604.07585)).
- **Change detection.** A CUSUM-style alert flags shifts beyond normal noise, so a model update is not mistaken for a client win.

## Extraction quality

An LLM parser extracts mentions, positions, sentiment and citations from each answer, after a deterministic pass for brand aliases and URLs.

- A 300-answer gold set is labelled by two people.
- Brand detection reports precision and recall. Sentiment and each attribute report Cohen's kappa against the gold set; anything below about 0.6 is merged or dropped.
- The gold-set checks are re-run whenever the parser model changes.

Failed runs, answers where search did not trigger, and the model version actually served are logged as outcomes rather than silently dropped.

## Diagnosis

Each question family is traced through five stages. The first stage that fails decides the fix.

1. **Page exists:** is there an indexed page that answers the question?
2. **Retrieved:** does the engine fetch that page for the question and its fan-out sub-queries?
3. **Cited:** is the page cited in the answer?
4. **Named:** is the brand named?
5. **Framed well:** is it named early and positively?

An access audit runs first: retrieval bots (OAI-SearchBot, Claude-SearchBot, PerplexityBot, Bingbot, Googlebot) allowed, CDN and firewall rules checked, and critical content served without JavaScript. AI crawlers other than Googlebot do not execute JavaScript ([Vercel](https://vercel.com/blog/the-rise-of-the-ai-crawler)).

## Evidence labels on recommendations

| Label | Meaning |
|---|---|
| Proven in your data | A GeoPilot experiment for this client showed a significant lift |
| Backed by docs or studies | Official engine documentation or large published studies |
| Plausible, to be tested | Reasonable but unproven; run as an experiment |
| No effect found | Tested and dropped (for example llms.txt) |

## Experiment protocol

1. **Pre-register** the hypothesis, question families, primary metric, smallest effect that matters and analysis window.
2. **Randomize** matched question families into treatment and holdout groups.
3. **Baseline** for 2–4 weeks to check the two groups move in parallel.
4. **Estimate** the effect with difference-in-differences or a mixed-effects logistic model, with cluster-bootstrap intervals.
5. **Check the mechanism.** Treated pages should start being cited before mentions rise.
6. **Run placebos.** Fake treatment dates and competitor brands as negative controls.
7. **Seal results until the readout date** and publish null results too.

## What GeoPilot does not claim

- Fixed rankings. Answers vary run to run; the platform reports probabilities.
- What every user sees. Logged-in history, memory and location change answers; the panel is a consistent sample.
- Lift from a before/after comparison alone. Impact is claimed only from pre-registered experiments with a holdout.
