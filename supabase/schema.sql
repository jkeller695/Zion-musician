-- =====================================================================
--  Zion Worship Musicians — database setup for Supabase
--  Run this once in Supabase: SQL Editor → New query → paste → Run.
--
--  BEFORE YOU RUN IT: change the email on the line marked  >>> EDIT <<<
--  near the bottom to the email of the first music director (you).
--  That person can then add everyone else from the site's Musicians tab.
-- =====================================================================

-- ---------- Who may use the site ----------
-- Only people on this list can see or change anything. Anyone can request
-- a login link, but without a row here they see "not on the list yet".
create table if not exists public.members (
  email       text primary key check (email = lower(email)),
  name        text not null check (length(name) between 1 and 80),
  is_director boolean not null default false,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Helper checks used by every access rule below.
create or replace function public.my_email() returns text
  language sql stable as $$ select lower(coalesce(auth.jwt() ->> 'email', '')) $$;

create or replace function public.is_member() returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members m where m.email = public.my_email() and m.active)
$$;

create or replace function public.is_director() returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members m where m.email = public.my_email() and m.active and m.is_director)
$$;

-- ---------- Site data ----------
-- Each table holds one record per item: a text id and its details.
--   services       director changes to a Sunday (spots, time, notes, no-service) and special services
--   signups        one row per filled spot; id = "<service>~<role>~<n>", so two people can't take one spot
--   hymns          hymn list per service
--   unavail        each musician's own unavailable dates; id = their login id
--   unavail_named  dates the director enters for musicians without a login
create table if not exists public.services      (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists public.signups       (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists public.hymns         (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists public.unavail       (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists public.unavail_named (id text primary key, data jsonb not null, updated_at timestamptz not null default now());

-- ---------- Access rules ----------
alter table public.members       enable row level security;
alter table public.services      enable row level security;
alter table public.signups       enable row level security;
alter table public.hymns         enable row level security;
alter table public.unavail       enable row level security;
alter table public.unavail_named enable row level security;

-- Start clean so this file can be re-run safely.
do $$ declare r record; begin
  for r in select policyname, tablename from pg_policies
           where schemaname = 'public'
             and tablename in ('members','services','signups','hymns','unavail','unavail_named')
  loop execute format('drop policy %I on public.%I', r.policyname, r.tablename); end loop;
end $$;

-- members: you can read your own row; directors read and manage everyone.
create policy members_read_self  on public.members for select to authenticated using (email = public.my_email() or public.is_director());
create policy members_dir_insert on public.members for insert to authenticated with check (public.is_director());
create policy members_dir_update on public.members for update to authenticated using (public.is_director()) with check (public.is_director());
create policy members_dir_delete on public.members for delete to authenticated using (public.is_director() and email <> public.my_email());

-- Everyone on the list can read the schedule, hymns and availability.
create policy services_read      on public.services      for select to authenticated using (public.is_member());
create policy signups_read       on public.signups       for select to authenticated using (public.is_member());
create policy hymns_read         on public.hymns         for select to authenticated using (public.is_member());
create policy unavail_read       on public.unavail       for select to authenticated using (public.is_member());
create policy unavail_named_read on public.unavail_named for select to authenticated using (public.is_member());

-- Only directors change services, hymns and director-entered dates.
create policy services_dir_all      on public.services      for all to authenticated using (public.is_director()) with check (public.is_director());
create policy hymns_dir_all         on public.hymns         for all to authenticated using (public.is_director()) with check (public.is_director());
create policy unavail_named_dir_all on public.unavail_named for all to authenticated using (public.is_director()) with check (public.is_director());

-- Sign-ups: a musician claims a spot for themself; directors can assign anyone.
-- Withdrawing: your own spot, or any spot if you are a director.
create policy signups_claim on public.signups for insert to authenticated
  with check (public.is_member() and (data ->> 'uid' = auth.uid()::text or public.is_director()));
create policy signups_dir_update on public.signups for update to authenticated
  using (public.is_director()) with check (public.is_director());
create policy signups_withdraw on public.signups for delete to authenticated
  using (data ->> 'uid' = auth.uid()::text or public.is_director());

-- Availability: each musician manages only their own dates.
create policy unavail_own on public.unavail for all to authenticated
  using (public.is_member() and (id = auth.uid()::text or public.is_director()))
  with check (public.is_member() and id = auth.uid()::text);

-- ---------- Live updates ----------
-- Lets every open copy of the site refresh as soon as someone signs up.
do $$ declare t text; begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach t in array array['services','signups','hymns','unavail','unavail_named'] loop
      if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t) then
        execute format('alter publication supabase_realtime add table public.%I', t);
      end if;
    end loop;
  end if;
end $$;

-- ---------- First director ----------
insert into public.members (email, name, is_director)
values ('you@example.com', 'Music Director', true)   -- >>> EDIT <<< your email and name
on conflict (email) do update set is_director = true, active = true;
