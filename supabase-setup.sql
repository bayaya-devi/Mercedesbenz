-- Dans Supabase Auth, créer l'utilisateur saadbarki@etoile-moteur.local.
-- Définir son mot de passe uniquement dans le tableau de bord Supabase.
-- Puis remplacer YOUR_ADMIN_UUID par l'UUID de cet utilisateur.
create table public.articles(id uuid primary key default gen_random_uuid(),title text not null check(char_length(title) between 1 and 140),subtitle text check(subtitle is null or char_length(subtitle)<=240),content text not null,image_url text,language text not null check(language in('fr','ar')),published boolean not null default false,author_id uuid not null references auth.users(id),created_at timestamptz not null default now(),updated_at timestamptz not null default now(),published_at timestamptz);
alter table public.articles enable row level security;
revoke all on public.articles from anon,authenticated;
grant select on public.articles to anon,authenticated;
grant insert,update,delete on public.articles to authenticated;
create policy "read published" on public.articles for select using(published or auth.uid()=author_id);
create policy "admin insert" on public.articles for insert to authenticated with check(auth.uid()='YOUR_ADMIN_UUID'::uuid and author_id=auth.uid());
create policy "admin update" on public.articles for update to authenticated using(auth.uid()='YOUR_ADMIN_UUID'::uuid) with check(auth.uid()='YOUR_ADMIN_UUID'::uuid);
create policy "admin delete" on public.articles for delete to authenticated using(auth.uid()='YOUR_ADMIN_UUID'::uuid);
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('article-images','article-images',true,6291456,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy "public article images" on storage.objects for select using(bucket_id='article-images');
create policy "admin upload images" on storage.objects for insert to authenticated with check(bucket_id='article-images' and auth.uid()='YOUR_ADMIN_UUID'::uuid);
create policy "admin delete images" on storage.objects for delete to authenticated using(bucket_id='article-images' and auth.uid()='YOUR_ADMIN_UUID'::uuid);
