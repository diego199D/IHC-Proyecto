-- =========================================================
-- Gestor de Citas — esquema de base de datos (Supabase / Postgres)
-- Ejecutar en: Supabase → SQL Editor → New query
-- =========================================================

create table if not exists servicios (
  id        bigint generated always as identity primary key,
  nombre    text not null,
  duracion  text not null,        -- ej: "30 min"
  precio    numeric not null check (precio >= 0),
  creado_en timestamptz not null default now()
);

create table if not exists bebidas (
  id        bigint generated always as identity primary key,
  nombre    text not null,
  precio    numeric not null check (precio >= 0),
  cantidad  integer not null default 0 check (cantidad >= 0),
  creado_en timestamptz not null default now()
);

create table if not exists citas (
  id          bigint generated always as identity primary key,
  nombre      text not null,
  telefono    text not null,
  servicio_id bigint not null references servicios(id) on delete restrict,
  fecha       date not null default current_date,
  hora        text not null,
  estado      text not null default 'pendiente'
              check (estado in ('pendiente', 'atendiendo', 'cobrado')),
  creado_en   timestamptz not null default now()
);

create table if not exists consumos (
  id               bigint generated always as identity primary key,
  cita_id          bigint not null references citas(id) on delete cascade,
  bebida_id        bigint not null references bebidas(id) on delete restrict,
  precio_unitario  numeric not null check (precio_unitario >= 0),
  creado_en        timestamptz not null default now()
);

create index if not exists idx_citas_fecha on citas (fecha);
create index if not exists idx_consumos_cita on consumos (cita_id);

-- ---------------------------------------------------------
-- Row Level Security: la app usa la clave "anon", así que se
-- habilita RLS y se permite lectura/escritura pública. Si el
-- sitio va a tener login más adelante, estas políticas deben
-- restringirse por usuario/rol.
-- ---------------------------------------------------------
alter table servicios enable row level security;
alter table bebidas   enable row level security;
alter table citas     enable row level security;
alter table consumos  enable row level security;

create policy "servicios_all" on servicios for all using (true) with check (true);
create policy "bebidas_all"   on bebidas   for all using (true) with check (true);
create policy "citas_all"     on citas     for all using (true) with check (true);
create policy "consumos_all"  on consumos  for all using (true) with check (true);

-- ---------------------------------------------------------
-- Datos de ejemplo (opcional, borra este bloque si no los quieres)
-- ---------------------------------------------------------
insert into servicios (nombre, duracion, precio) values
  ('Corte Clasico',   '30 min', 40),
  ('Barba',           '20 min', 30),
  ('Corte + Barba',   '45 min', 60),
  ('Corte Degradado', '40 min', 50);

insert into bebidas (nombre, precio, cantidad) values
  ('Cocacola peque', 40, 20),
  ('Agua vital',      6, 20);
