-- =========================================================
-- Setup Supabase untuk "Form Pengumpulan Data WebGIS UMKM/Wisata Deworejo"
-- Jalankan seluruh skrip ini di Supabase Dashboard > SQL Editor
-- =========================================================

-- 1. Tabel utama untuk menyimpan data UMKM dan Wisata
create table if not exists public.umkm_wisata_data (
  id uuid primary key default gen_random_uuid(),
  jenis text not null check (jenis in ('umkm', 'wisata')),
  nama text not null,
  kategori text not null,
  alamat text not null,
  alamat_lengkap text,
  latitude double precision not null,
  longitude double precision not null,
  deskripsi text,
  kontak text not null,
  foto_urls text[] default '{}',
  created_at timestamptz not null default now()
);

-- 2. Aktifkan Row Level Security
alter table public.umkm_wisata_data enable row level security;

-- 3. Izinkan siapa saja (pengisi form) menambah data baru
create policy "Publik bisa menambah data"
  on public.umkm_wisata_data
  for insert
  to anon
  with check (true);

-- 4. Izinkan siapa saja membaca data (dipakai halaman "Lihat & unduh data")
--    Jika ingin data hanya bisa dibaca lewat backend/admin, hapus policy ini
--    dan gunakan service role key di server terpisah.
create policy "Publik bisa membaca data"
  on public.umkm_wisata_data
  for select
  to anon
  using (true);

-- 5. Buat bucket penyimpanan foto (public, agar foto bisa ditampilkan langsung)
insert into storage.buckets (id, name, public)
values ('umkm-wisata-foto', 'umkm-wisata-foto', true)
on conflict (id) do nothing;

-- 6. Izinkan siapa saja mengunggah foto ke bucket tersebut
create policy "Publik bisa unggah foto"
  on storage.objects
  for insert
  to anon
  with check (bucket_id = 'umkm-wisata-foto');

-- 7. Izinkan siapa saja membaca/melihat foto di bucket tersebut
create policy "Publik bisa lihat foto"
  on storage.objects
  for select
  to anon
  using (bucket_id = 'umkm-wisata-foto');

-- =========================================================
-- Setelah menjalankan skrip ini:
-- 1. Buka Settings > API di dashboard Supabase
-- 2. Salin "Project URL" dan "anon public" key
-- 3. Tempel ke bagian KONFIGURASI SUPABASE di file index.html
--    (variabel SUPABASE_URL dan SUPABASE_ANON_KEY)
-- =========================================================
