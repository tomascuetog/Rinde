-- ================================================
-- RINDE — Setup de base de datos en Supabase
-- Corré este script en el SQL Editor de Supabase
-- ================================================

-- 1. Tabla principal de datos
create table if not exists public.rinde_data (
  id          uuid default gen_random_uuid() primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  key         text not null,
  data        jsonb not null default '[]',
  updated_at  timestamptz default now(),
  constraint rinde_data_user_key unique (user_id, key)
);

-- 2. Índice para consultas rápidas por usuario
create index if not exists rinde_data_user_idx on public.rinde_data(user_id);

-- 3. Row Level Security — cada usuario solo ve sus propios datos
alter table public.rinde_data enable row level security;

-- Política: el usuario autenticado solo accede a sus filas
create policy "Cada usuario accede solo a sus datos"
  on public.rinde_data
  for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 4. Función para auto-actualizar updated_at
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger rinde_data_updated_at
  before update on public.rinde_data
  for each row execute function public.handle_updated_at();

-- ================================================
-- LISTO. Ya podés usar Rinde con tu proyecto.
-- 
-- Pasos siguientes:
-- 1. En Supabase → Settings → API copiá:
--    - Project URL
--    - anon / public key
-- 2. Abrí Rinde.html → pantalla de configuración
-- 3. Pegá la URL y la key
-- 4. Creá tu cuenta con email y contraseña
-- ================================================
