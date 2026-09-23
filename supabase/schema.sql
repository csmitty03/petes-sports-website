-- Pete's Sports staff job tracker
-- Run this in the Supabase SQL editor after creating a project.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('admin', 'london', 'strathroy', 'newera', 'view')),
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  job_number text not null unique,
  new_era_job_number text,
  customer_name text not null,
  customer_phone text,
  customer_email text,
  team text,
  pickup_wanted text check (pickup_wanted in ('london', 'strathroy')),
  due_date date,
  items jsonb not null default '[]'::jsonb,
  blanks_start text,
  sold_by text,
  notes text,
  art_link text,
  status text not null,
  current_location text not null,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.movements (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  logged_by uuid references public.profiles (id),
  from_location text,
  to_location text,
  action text not null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.pickups (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  released_by uuid references public.profiles (id),
  pickup_name text not null,
  pickup_phone text,
  relationship text not null,
  what_taken text not null,
  confirmed boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists orders_status_idx on public.orders (status);
create index if not exists orders_location_idx on public.orders (current_location);
create index if not exists orders_created_idx on public.orders (created_at desc);
create index if not exists movements_order_idx on public.movements (order_id, created_at);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists orders_updated_at on public.orders;
create trigger orders_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

create or replace function public.next_job_number()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  yymm text := to_char(timezone('America/Toronto', now()), 'YYMM');
  prefix text := 'PS-' || yymm || '-';
  n int;
begin
  select coalesce(max(nullif(substring(job_number from 9), '')::int), 0) + 1
    into n
  from public.orders
  where job_number like prefix || '%';
  return prefix || lpad(n::text, 3, '0');
end;
$$;

grant execute on function public.next_job_number() to authenticated;

alter table public.profiles enable row level security;
alter table public.orders enable row level security;
alter table public.movements enable row level security;
alter table public.pickups enable row level security;

drop policy if exists "staff read profiles" on public.profiles;
create policy "staff read profiles" on public.profiles
  for select to authenticated using (true);

drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile" on public.profiles
  for update to authenticated using (auth.uid() = id);

drop policy if exists "staff read orders" on public.orders;
create policy "staff read orders" on public.orders
  for select to authenticated using (true);

drop policy if exists "staff insert orders" on public.orders;
create policy "staff insert orders" on public.orders
  for insert to authenticated with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('admin', 'london', 'strathroy')
    )
  );

drop policy if exists "staff update orders" on public.orders;
create policy "staff update orders" on public.orders
  for update to authenticated using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('admin', 'london', 'strathroy', 'newera')
    )
  );

drop policy if exists "staff read movements" on public.movements;
create policy "staff read movements" on public.movements
  for select to authenticated using (true);

drop policy if exists "staff insert movements" on public.movements;
create policy "staff insert movements" on public.movements
  for insert to authenticated with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('admin', 'london', 'strathroy', 'newera')
    )
  );

drop policy if exists "staff read pickups" on public.pickups;
create policy "staff read pickups" on public.pickups
  for select to authenticated using (true);

drop policy if exists "counter insert pickups" on public.pickups;
create policy "counter insert pickups" on public.pickups
  for insert to authenticated with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('admin', 'london', 'strathroy')
    )
  );

-- After creating your first Auth user in the dashboard, attach an admin profile:
-- insert into public.profiles (id, full_name, role)
-- values ('USER-UUID-FROM-AUTH', 'Carsen Smith', 'admin');
