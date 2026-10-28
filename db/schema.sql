-- GeoPilot draft schema (Postgres 15+ / Supabase)
-- Status: design draft. Apply to a dev project first; production is built from the same migrations.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------- tenancy
create table clients (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  market      text not null,               -- e.g. 'CRM software'
  locale      text not null default 'en-IN',
  created_at  timestamptz not null default now()
);

create table client_members (
  client_id uuid not null references clients(id) on delete cascade,
  user_id   uuid not null,                  -- auth.users.id in Supabase
  role      text not null check (role in ('owner','analyst','viewer')),
  primary key (client_id, user_id)
);

create table brands (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references clients(id) on delete cascade,
  name       text not null,
  domain     text,
  is_client  boolean not null default false,  -- the brand we work for vs a competitor
  unique (client_id, name)
);

create table brand_aliases (
  brand_id uuid not null references brands(id) on delete cascade,
  alias    text not null,
  primary key (brand_id, alias)
);

-- ---------------------------------------------------------------- registry
create table engines (
  id        text primary key,               -- 'chatgpt','gemini','aimode','perplexity','claude'
  name      text not null,
  active    boolean not null default true
);

create table instruments (
  id   text primary key,                    -- 'memory' (API, search off), 'web' (API, search on), 'app' (consumer)
  name text not null
);

create table engine_instruments (
  engine_id     text not null references engines(id),
  instrument_id text not null references instruments(id),
  adapter       text not null,              -- collection adapter name, e.g. 'openai_responses_search'
  model         text,                       -- requested model id; the served model is logged per answer
  runs_per_day  numeric not null default 1,  -- 1/7 = weekly
  primary key (engine_id, instrument_id)
);

-- ---------------------------------------------------------------- prompts
create table prompt_families (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references clients(id) on delete cascade,
  name       text not null,
  stage      text not null check (stage in ('discovery','consideration','comparison','branded')),
  branded    boolean not null default false
);

create table prompts (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references prompt_families(id) on delete cascade,
  text        text not null,
  version     int  not null default 1,
  language    text not null default 'en',
  active_from date not null default current_date,
  active_to   date,
  unique (family_id, text, version)
);

-- ---------------------------------------------------------------- collection
create table collection_tasks (
  id              uuid primary key default gen_random_uuid(),
  idempotency_key text not null unique,     -- prompt:engine:instrument:date:run, so a retry never bills twice
  prompt_id       uuid not null references prompts(id),
  engine_id       text not null,
  instrument_id   text not null,
  run_date        date not null,
  run_no          smallint not null,
  status          text not null default 'queued' check (status in ('queued','running','done','failed')),
  attempts        smallint not null default 0,
  last_error      text,
  created_at      timestamptz not null default now(),
  foreign key (engine_id, instrument_id) references engine_instruments(engine_id, instrument_id)
);
create index on collection_tasks (status, run_date);

create table answers (
  id               uuid primary key default gen_random_uuid(),
  task_id          uuid not null unique references collection_tasks(id),
  raw_key          text not null,           -- object-storage key of the gzipped raw response
  answer_text      text,
  model_served     text,
  search_activated boolean,
  valid            boolean not null default true,
  failure_reason   text,                    -- kept as an outcome, never silently dropped
  location         text,                    -- exit country/city for consumer captures
  captured_at      timestamptz not null default now(),
  parser_version   text
);
create index on answers (captured_at);

-- ---------------------------------------------------------------- extracted facts
create table mentions (
  answer_id    uuid not null references answers(id) on delete cascade,
  brand_id     uuid not null references brands(id),
  position     smallint,                     -- order first named, 1 = first
  recommended  boolean,
  sentiment    text check (sentiment in ('positive','neutral','negative','mixed')),
  aspects      jsonb not null default '{}',  -- {"support":"negative","pricing":"positive"}
  primary key (answer_id, brand_id)
);

create table domains (
  domain       text primary key,
  source_type  text not null check (source_type in ('owned','competitor','review','forum','news_blog','video_reference','other')),
  owner_brand  uuid references brands(id)
);

create table citations (
  answer_id   uuid not null references answers(id) on delete cascade,
  ordinal     smallint not null,
  url         text not null,
  domain      text not null references domains(domain),
  primary key (answer_id, ordinal)
);
create index on citations (domain);

-- ---------------------------------------------------------------- diagnose, act, prove
create table audit_checks (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references clients(id) on delete cascade,
  item       text not null,                 -- e.g. 'PerplexityBot', 'Pricing page renders without JS'
  status     text not null check (status in ('ok','fixed','warning','critical','info')),
  detail     text,
  checked_at timestamptz not null default now()
);

create table experiments (
  id             text primary key,           -- 'GP-01'
  client_id      uuid not null references clients(id) on delete cascade,
  name           text not null,
  hypothesis     text not null,
  primary_metric text not null,
  min_effect     numeric not null,           -- smallest effect that matters, in percentage points
  registered_on  date not null,
  shipped_on     date,
  readout_on     date not null,
  status         text not null default 'registered' check (status in ('registered','running','lift','no_effect','harm')),
  estimate       numeric,
  ci_low         numeric,
  ci_high        numeric
);

create table experiment_families (
  experiment_id text not null references experiments(id) on delete cascade,
  family_id     uuid not null references prompt_families(id),
  arm           text not null check (arm in ('treatment','holdout')),
  primary key (experiment_id, family_id)
);

create table actions (
  id            uuid primary key default gen_random_uuid(),
  client_id     uuid not null references clients(id) on delete cascade,
  title         text not null,
  lever         text not null,               -- access, content, comprehension, earned citations, narrative
  evidence      text not null check (evidence in ('proven','backed','plausible','no_effect')),
  experiment_id text references experiments(id),
  owner         text,
  status        text not null default 'planned' check (status in ('planned','in_progress','testing','done','dropped'))
);

-- ---------------------------------------------------------------- rollups the console reads
create table daily_rollups (
  client_id     uuid not null references clients(id) on delete cascade,
  day           date not null,
  brand_id      uuid not null references brands(id),
  family_id     uuid references prompt_families(id),  -- null = all unbranded families
  engine_id     text not null,
  instrument_id text not null,
  valid_answers int not null,
  mentions      int not null,
  top3          int not null,
  owned_cites   int not null,
  unique nulls not distinct (client_id, day, brand_id, engine_id, instrument_id, family_id)
);

-- ---------------------------------------------------------------- row-level security
create or replace function is_member(c uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from client_members m where m.client_id = c and m.user_id = auth.uid())
$$;

-- Every table has RLS on. Tables without a policy below are reachable only by the backend's service role.
do $$
declare t text;
begin
  foreach t in array array['clients','client_members','brands','brand_aliases','engines','instruments',
    'engine_instruments','prompt_families','prompts','collection_tasks','answers','mentions','domains',
    'citations','audit_checks','experiments','experiment_families','actions','daily_rollups']
  loop
    execute format('alter table %I enable row level security', t);
  end loop;
end $$;

create policy public_read on engines     for select using (true);
create policy public_read on instruments for select using (true);
create policy own_membership on client_members for select using (user_id = auth.uid());

create policy member_read on clients         for select using (is_member(id));
create policy member_read on brands          for select using (is_member(client_id));
create policy member_read on prompt_families for select using (is_member(client_id));
create policy member_read on audit_checks    for select using (is_member(client_id));
create policy member_read on experiments     for select using (is_member(client_id));
create policy member_read on actions         for select using (is_member(client_id));
create policy member_read on daily_rollups   for select using (is_member(client_id));
-- Raw tables (collection_tasks, answers, mentions, citations, domains) have no client policies:
-- only the backend's service role reads and writes them.
