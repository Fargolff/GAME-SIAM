create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  display_name text,
  restore_token_hash text unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.hero_definitions (
  hero_id text primary key,
  rarity text not null check (rarity in ('S', 'A', 'B', 'C', 'D')),
  role text not null,
  base_stats jsonb not null,
  enabled boolean not null default true
);

create table if not exists public.hero_instances (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  hero_id text not null references public.hero_definitions(hero_id),
  level int not null default 1 check (level >= 1),
  stars int not null default 1 check (stars between 1 and 5),
  shards int not null default 0 check (shards >= 0),
  created_at timestamptz not null default now(),
  unique (profile_id, hero_id)
);

create table if not exists public.currencies (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  currency_code text not null check (currency_code in ('gold', 'essence', 'premium')),
  amount bigint not null default 0 check (amount >= 0),
  updated_at timestamptz not null default now(),
  primary key (profile_id, currency_code)
);

create table if not exists public.inventory_items (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  item_id text not null,
  amount bigint not null default 0 check (amount >= 0),
  updated_at timestamptz not null default now(),
  primary key (profile_id, item_id)
);

create table if not exists public.wave_progress (
  profile_id uuid primary key references public.profiles(id) on delete cascade,
  highest_cleared int not null default 0 check (highest_cleared >= 0),
  last_offline_claim_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.battle_tickets (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  request_id text not null,
  wave_id int not null check (wave_id >= 1),
  seed bigint not null,
  formation jsonb not null,
  enemy_lineup jsonb not null,
  expires_at timestamptz not null,
  consumed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (profile_id, request_id)
);

create table if not exists public.battle_results (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null unique references public.battle_tickets(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  result text not null check (result in ('win', 'loss')),
  summary jsonb not null,
  rewards jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.gacha_banners (
  id uuid primary key default gen_random_uuid(),
  banner_key text not null unique,
  title text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  enabled boolean not null default true
);

create table if not exists public.gacha_rates (
  banner_id uuid not null references public.gacha_banners(id) on delete cascade,
  rarity text not null check (rarity in ('S', 'A', 'B', 'C', 'D')),
  probability_bps int not null check (probability_bps > 0),
  pity_at int,
  primary key (banner_id, rarity)
);

create table if not exists public.gacha_pulls (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  banner_id uuid not null references public.gacha_banners(id),
  request_id text not null,
  cost jsonb not null,
  results jsonb not null,
  pity_before int not null default 0,
  pity_after int not null default 0,
  created_at timestamptz not null default now(),
  unique (profile_id, request_id)
);

create table if not exists public.purchase_receipts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  platform text not null check (platform = 'google_play'),
  product_id text not null,
  purchase_token text not null unique,
  order_id text unique,
  state text not null check (state in ('pending', 'validated', 'granted', 'rejected')),
  raw_receipt jsonb not null default '{}'::jsonb,
  granted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.economy_ledger (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  source_type text not null,
  source_id uuid,
  currency_code text,
  item_id text,
  amount bigint not null,
  balance_after bigint,
  reason text not null,
  created_at timestamptz not null default now(),
  check (currency_code is not null or item_id is not null)
);

alter table public.profiles enable row level security;
alter table public.hero_definitions enable row level security;
alter table public.hero_instances enable row level security;
alter table public.currencies enable row level security;
alter table public.inventory_items enable row level security;
alter table public.wave_progress enable row level security;
alter table public.battle_tickets enable row level security;
alter table public.battle_results enable row level security;
alter table public.gacha_banners enable row level security;
alter table public.gacha_rates enable row level security;
alter table public.gacha_pulls enable row level security;
alter table public.purchase_receipts enable row level security;
alter table public.economy_ledger enable row level security;

create policy profiles_select_own on public.profiles
  for select using (user_id = auth.uid());

create policy hero_definitions_select_enabled on public.hero_definitions
  for select using (enabled);

create policy gacha_banners_select_enabled on public.gacha_banners
  for select using (enabled);

create policy gacha_rates_select_enabled_banner on public.gacha_rates
  for select using (
    exists (
      select 1 from public.gacha_banners b
      where b.id = banner_id and b.enabled
    )
  );

create policy hero_instances_select_own on public.hero_instances
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );

create policy currencies_select_own on public.currencies
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );

create policy inventory_items_select_own on public.inventory_items
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );

create policy wave_progress_select_own on public.wave_progress
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );

create policy battle_results_select_own on public.battle_results
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );

create policy gacha_pulls_select_own on public.gacha_pulls
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );

create policy purchase_receipts_select_own on public.purchase_receipts
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );

create policy economy_ledger_select_own on public.economy_ledger
  for select using (
    exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  );
