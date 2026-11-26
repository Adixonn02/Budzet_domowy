-- Nasz budżet: schemat synchronizacji dla Supabase.
-- Jak uruchomić: w panelu Supabase otwórz SQL Editor → New query → wklej całość → Run.

create table if not exists public.budget_households (
  id         text primary key,
  doc        jsonb       not null default '{}'::jsonb,
  version    bigint      not null default 0,
  updated_at timestamptz not null default now()
);

-- Włączamy RLS i NIE dodajemy polityk: klucz anon nie ma bezpośredniego dostępu do tabeli.
alter table public.budget_households enable row level security;

-- Jedyny dostęp to te dwie funkcje. Wymagają identyfikatora budżetu (32 znaki losowe),
-- który znają tylko osoby, którym dałeś kod połączenia.

create or replace function public.budget_pull(hid text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  r public.budget_households%rowtype;
begin
  if char_length(hid) < 16 then
    raise exception 'invalid household id';
  end if;
  select * into r from public.budget_households where id = hid;
  if not found then
    return jsonb_build_object('version', 0, 'doc', null);
  end if;
  return jsonb_build_object('version', r.version, 'doc', r.doc);
end;
$$;

create or replace function public.budget_push(hid text, base_version bigint, new_doc jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  cur public.budget_households%rowtype;
begin
  if char_length(hid) < 16 then
    raise exception 'invalid household id';
  end if;
  select * into cur from public.budget_households where id = hid for update;
  if not found then
    insert into public.budget_households (id, doc, version) values (hid, new_doc, 1);
    return jsonb_build_object('ok', true, 'version', 1);
  end if;
  -- Ktoś zapisał w międzyczasie: klient pobierze nowszą wersję, scali i spróbuje ponownie.
  if cur.version <> base_version then
    return jsonb_build_object('ok', false, 'version', cur.version);
  end if;
  update public.budget_households
     set doc = new_doc, version = cur.version + 1, updated_at = now()
   where id = hid;
  return jsonb_build_object('ok', true, 'version', cur.version + 1);
end;
$$;

grant execute on function public.budget_pull(text) to anon, authenticated;
grant execute on function public.budget_push(text, bigint, jsonb) to anon, authenticated;

-- Zdjęcia zakupów: zapisywane osobno, raz, już zaszyfrowane po stronie aplikacji
create table if not exists public.budget_photos (
  hid        text        not null,
  pid        text        not null,
  data       text        not null,
  created_at timestamptz not null default now(),
  primary key (hid, pid)
);

alter table public.budget_photos enable row level security;

create or replace function public.budget_put_photo(hid text, pid text, data text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if char_length(hid) < 16 or char_length(pid) < 8 then
    raise exception 'invalid id';
  end if;
  if char_length(data) > 3000000 then
    raise exception 'photo too large';
  end if;
  insert into public.budget_photos as bp (hid, pid, data)
  values (budget_put_photo.hid, budget_put_photo.pid, budget_put_photo.data)
  on conflict on constraint budget_photos_pkey do update set data = excluded.data;
  return true;
end;
$$;

create or replace function public.budget_get_photo(hid text, pid text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  d text;
begin
  if char_length(hid) < 16 or char_length(pid) < 8 then
    raise exception 'invalid id';
  end if;
  select bp.data into d from public.budget_photos bp
   where bp.hid = budget_get_photo.hid and bp.pid = budget_get_photo.pid;
  return d;
end;
$$;

create or replace function public.budget_delete_photo(hid text, pid text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if char_length(hid) < 16 or char_length(pid) < 8 then
    raise exception 'invalid id';
  end if;
  delete from public.budget_photos bp
   where bp.hid = budget_delete_photo.hid and bp.pid = budget_delete_photo.pid;
  return true;
end;
$$;

grant execute on function public.budget_put_photo(text, text, text) to anon, authenticated;
grant execute on function public.budget_get_photo(text, text) to anon, authenticated;
grant execute on function public.budget_delete_photo(text, text) to anon, authenticated;
