# demo

Rules for the clickable client console demo. Global context is in the root [AGENTS.md](../AGENTS.md).

## What it is

demo/index.html is a single self contained page: CSS, data, chart code, and the guided tour all live in the file. It shows the full Measure, Diagnose, Act, Prove loop for a fictional brand so a viewer can click through what the platform will do.

## Rules

- Keep it one file with no build step and no dependencies beyond Google Fonts. It must open from a plain static server.
- All data is simulated and deterministic: a seeded random generator (`rng`, `hash`) so every load shows the same numbers. Never use `Math.random`.
- Brands are fictional: NovaCRM is the client (chart slot 1), competitors are Orbitly, LeadNest, Kalyx, Salesmint, Pipewise. Do not add real company names or real client data.
- The top bar must keep the "Demo workspace, simulated data" label.
- Numbers must agree across screens. The overview headline is the mean of the engine level rates in `MENTION`; the experiment effects are computed from their weekly series, and copy that quotes them reads the computed value.
- Views are functions on `V` keyed by route id. Navigation uses `go(route)`; the address hash mirrors the route. Charts render into slots through `chartSlot` and redraw on resize at the real container width.
- Every chart keeps a hover tooltip, a legend when it has two or more series, and theme tokens for all text. No page level horizontal scroll at 375px wide; wide tables sit inside `.scroll`.
- Copy is plain and direct, written from the client's side of the screen.

## Checking a change

Serve the folder, click through every screen and the guided tour in light and dark themes, and confirm the console shows no errors and nothing overflows at phone width.
