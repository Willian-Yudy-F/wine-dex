-- Wine Dex – database schema for Supabase (PostgreSQL)
-- Run this once in Supabase > SQL Editor > New query > Run.

-- ---------------------------------------------------------------
-- 1. Tables
-- ---------------------------------------------------------------

-- One row per wine (shared by everyone). Created by the first person who logs it.
create table if not exists public.wines (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  producer    text,
  vintage     int  check (vintage is null or vintage between 1900 and 2100),
  wine_type   text not null default 'red'
              check (wine_type in ('red','white','rose','sparkling','dessert','fortified','orange')),
  grape       text,
  country     text,
  region      text,
  created_by  uuid references auth.users(id) on delete set null,
  created_at  timestamptz not null default now()
);

-- One row per tasting: a person's personal note about a wine.
create table if not exists public.tastings (
  id          uuid primary key default gen_random_uuid(),
  wine_id     uuid not null references public.wines(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  taster_name text not null default 'Anonymous',
  rating      numeric(2,1) not null check (rating between 1 and 5),
  notes       text,
  photo_url   text,
  price       numeric(8,2),
  place       text,
  tags        text[] not null default '{}',   -- e.g. {"Dark fruit","Oak"}
  tasted_at   date not null default current_date,
  created_at  timestamptz not null default now()
);

create index if not exists tastings_wine_idx on public.tastings(wine_id);
create index if not exists tastings_user_idx on public.tastings(user_id);

-- ---------------------------------------------------------------
-- 2. Community statistics (average rating per wine)
-- ---------------------------------------------------------------
create or replace view public.wine_stats as
select
  w.id                      as wine_id,
  count(t.id)               as tasting_count,
  round(avg(t.rating), 2)   as avg_rating,
  count(distinct t.user_id) as taster_count
from public.wines w
left join public.tastings t on t.wine_id = w.id
group by w.id;

-- ---------------------------------------------------------------
-- 3. Row Level Security
--    Everyone logged in can read all wines and tastings (that is the
--    "compare with others" feature). Each person can only write their own rows.
-- ---------------------------------------------------------------
alter table public.wines    enable row level security;
alter table public.tastings enable row level security;

drop policy if exists "wines: read for authenticated"   on public.wines;
drop policy if exists "wines: insert for authenticated" on public.wines;
drop policy if exists "wines: update own"               on public.wines;

create policy "wines: read for authenticated"   on public.wines for select to authenticated using (true);
create policy "wines: insert for authenticated" on public.wines for insert to authenticated with check (auth.uid() = created_by);
create policy "wines: update own"               on public.wines for update to authenticated using (auth.uid() = created_by);

drop policy if exists "tastings: read for authenticated" on public.tastings;
drop policy if exists "tastings: insert own"             on public.tastings;
drop policy if exists "tastings: update own"             on public.tastings;
drop policy if exists "tastings: delete own"             on public.tastings;

create policy "tastings: read for authenticated" on public.tastings for select to authenticated using (true);
create policy "tastings: insert own"             on public.tastings for insert to authenticated with check (auth.uid() = user_id);
create policy "tastings: update own"             on public.tastings for update to authenticated using (auth.uid() = user_id);
create policy "tastings: delete own"             on public.tastings for delete to authenticated using (auth.uid() = user_id);

-- ---------------------------------------------------------------
-- 4. Photo storage
--    Bucket "wine-photos": public read, each user uploads only inside
--    a folder named with their own user id (e.g. <uid>/<file>.jpg).
-- ---------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('wine-photos', 'wine-photos', true)
on conflict (id) do nothing;

drop policy if exists "photos: public read"  on storage.objects;
drop policy if exists "photos: upload own"   on storage.objects;
drop policy if exists "photos: delete own"   on storage.objects;

create policy "photos: public read" on storage.objects for select
  using (bucket_id = 'wine-photos');

create policy "photos: upload own" on storage.objects for insert to authenticated
  with check (bucket_id = 'wine-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "photos: delete own" on storage.objects for delete to authenticated
  using (bucket_id = 'wine-photos' and (storage.foldername(name))[1] = auth.uid()::text);
