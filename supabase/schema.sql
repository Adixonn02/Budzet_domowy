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
