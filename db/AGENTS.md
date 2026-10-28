# db

Rules for the database schema. Global context is in the root [AGENTS.md](../AGENTS.md).

## Status

db/schema.sql is a design draft for Supabase Postgres 15 or newer. It has not been applied to a database yet. The data model still needs its decision spec (see docs/scope/scope.md) before it becomes the first migration.

## Rules

- Row level security is enabled on every table. A table with no policy is reachable only by the backend service role, which is the intent for raw tables (collection tasks, answers, mentions, citations, domains).
- The client console reads rollups and workspace tables through member policies (`is_member`). It never reads raw answers.
- Every collection task carries a unique idempotency key (prompt, engine, instrument, date, run) so a retry never runs or bills twice.
- Failures, search activation, and the model served are columns on `answers`, not dropped rows.
- Engines, instruments, and their adapters live in registry tables, so a new engine or a retired API is a data change, not a code change.
- Prompts are versioned. Never edit a prompt in place once it has answers; add a new version.
- Dev first: apply changes to a `geopilot-dev` project, then build production from the same migrations.
- The service role key lives only in the backend environment, never in the frontend or the repo.
