# Desain: Alur Assignment Tiket via Admin + Pool Global

- **Tanggal:** 2026-06-18
- **Status:** Disetujui (siap masuk tahap rencana implementasi)
- **Pendekatan enforcement:** Opsi A — logika bisnis terpusat di Go usecases; RLS sebagai lapis kedua.

## 1. Latar Belakang

Alur saat ini salah secara proses: user submit tiket dan **helpdesk langsung mengambil/mengerjakan** tiket apa pun (self-assign "Ambil Tiket"), dan **semua helpdesk bisa melihat semua tiket**. Tidak ada kontrol distribusi beban kerja maupun otoritas penugasan.

Alur yang diinginkan: tiket masuk ke **pool yang dikelola admin**, admin yang **menugaskan** tiket ke helpdesk yang sedang kosong, dan tiap helpdesk hanya melihat/menangani tiket miliknya.

### Kondisi kode saat ini (ringkas)
- Tabel `tiket`: `id, judul, deskripsi, status, dibuat_oleh, ditugaskan_kepada (nullable), dibuat_pada, updated_at, selesai_pada`.
- Status: `TERBUKA → DIPROSES → SELESAI` (enum `ticket_status`).
- Peran (`user_role`): `pengguna`, `helpdesk`, `admin`.
- `Tiket.AssignTo()` saat ini mengizinkan **helpdesk atau admin** assign, dan langsung set `DIPROSES`.
- `GetTiketListUseCase`: helpdesk **dan** admin sama-sama melihat semua tiket.
- Backend Go memakai **service_role key** → RLS di-bypass untuk panggilan via backend API. RLS hanya berlaku untuk akses **langsung dari Flutter** (Supabase SDK + **Realtime**, yang memakai JWT user).

## 2. Aturan Alur Baru (Requirements)

1. User membuat tiket → status `TERBUKA`, `ditugaskan_kepada = NULL` → masuk **pool global**.
2. **Admin** melihat **semua tiket** dari semua user. Helpdesk **tidak lagi** melihat semua tiket.
3. Admin **menugaskan** tiket `TERBUKA` hanya ke **helpdesk yang kosong** (kosong = 0 tiket `DIPROSES`).
4. Saat di-assign → tiket **langsung `DIPROSES`**, helpdesk tersebut menjadi **sibuk**.
5. Helpdesk sibuk **tidak bisa** menerima penugasan baru (di-enforce di usecase). Tiket lain menunggu di pool sampai ada helpdesk kosong → admin assign **manual**.
6. Helpdesk menandai **`SELESAI`** → helpdesk kosong lagi → admin menugaskan tiket berikutnya dari pool.
7. **Visibility helpdesk**: hanya tiket `DIPROSES` miliknya (sedang dikerjakan) + **riwayat `SELESAI` miliknya**. Tidak pernah melihat pool / tiket helpdesk lain.
8. **Admin dapat reassign**: memindahkan tiket `DIPROSES` ke helpdesk kosong lain, **atau menarik balik ke pool** (`DIPROSES → TERBUKA`, assignee di-null-kan). Notifikasi dikirim ke helpdesk terkait.

**Invariant inti:** satu helpdesk maksimal **satu** tiket berstatus `DIPROSES`.

## 3. Keputusan Desain (hasil brainstorming)

| Topik | Keputusan |
|-------|-----------|
| Model queue | **Pool global** + admin hanya assign ke helpdesk kosong; pengisian berikutnya **manual** oleh admin. (Bukan queue per-helpdesk.) |
| Status saat assign | **Langsung `DIPROSES`**. "Kosong" = jumlah tiket `DIPROSES` helpdesk = 0. Tetap 3 status. |
| Lingkup helpdesk | Tiket **aktif + riwayat SELESAI miliknya**. |
| Helpdesk nyangkut | **Admin bisa reassign/tarik balik**. |
| Enforcement | **Opsi A** — logika di Go usecases; RLS lapis kedua. Tanpa DB constraint/trigger. |

## 4. Data Model

**Tidak ada migrasi struktur.** Memakai field yang sudah ada:
- `TERBUKA` + `ditugaskan_kepada = NULL` → di pool, menunggu admin.
- `DIPROSES` + `ditugaskan_kepada = X` → sedang dikerjakan helpdesk X.
- `SELESAI` + `ditugaskan_kepada = X` → riwayat helpdesk X.

Index yang sudah ada cukup: `idx_tiket_status`, `idx_tiket_ditugaskan_kepada`.

## 5. Status & Transisi

3 status tetap. Transisi yang sah:

| Dari | Ke | Pemicu / Otoritas |
|------|----|-------------------|
| `TERBUKA` | `DIPROSES` | **Admin assign** (set assignee + DIPROSES) |
| `DIPROSES` | `SELESAI` | Helpdesk pemilik tiket (atau admin) menyelesaikan |
| `DIPROSES` | `TERBUKA` | **Admin "tarik balik"** (assignee di-null-kan) |
| `DIPROSES` (assignee A) | `DIPROSES` (assignee B) | **Admin "pindahkan"** ke helpdesk kosong B |

Self-assign oleh helpdesk **dihapus**.

## 6. Perubahan Backend (Go)

### 6.1 Entities
- `Tiket.AssignTo(...)`: ubah agar **hanya `RoleAdmin`** yang boleh assign (hapus izin helpdesk).
- Tambah error domain `ErrHelpdeskSibuk` ("Helpdesk sedang menangani tiket lain").
- Transisi `DIPROSES → TERBUKA` sudah didukung `CanTransitionTo` (reopen); pull-back menggunakan jalur unassign khusus agar assignee ikut di-null-kan.

### 6.2 Usecases
- **`AssignTiketUseCase` (modifikasi)** — dipakai untuk assign maupun reassign. Validasi sebelum assign:
  1. Assigner harus `admin`.
  2. Target harus benar berperan `helpdesk`.
  3. Target **kosong** (`CountActiveByHelpdesk == 0`); jika tidak → `ErrHelpdeskSibuk`.
  
  Kirim notifikasi ke helpdesk baru (+ helpdesk lama jika reassign) dan pembuat tiket.
- **`UnassignTiketUseCase` (baru)** — admin "tarik balik": `status=TERBUKA`, `ditugaskan_kepada=NULL`; notifikasi ke helpdesk lama.
- **`GetTiketListUseCase` (modifikasi)** — visibility per peran:
  - `pengguna` → `DibuatOleh = self` (tetap).
  - `helpdesk` → **`DitugaskanKepada = self`** (berubah dari "lihat semua").
  - `admin` → semua (tetap).
- **`ListAvailableHelpdeskUseCase` (baru)** — daftar semua user `peran='helpdesk'` beserta flag `sibuk` (punya tiket `DIPROSES`) untuk dropdown assignment admin.

### 6.3 Repository
- `TiketRepository.CountActiveByHelpdesk(ctx, helpdeskID) (int64, error)` — hitung tiket `DIPROSES` milik helpdesk (cek "kosong").
- `TiketRepository.Unassign(ctx, id) error` — set `ditugaskan_kepada=NULL`, `status='TERBUKA'`. (Method `Update` sekarang tidak bisa men-set assignee ke NULL.)
- `PenggunaRepository.ListByRole(ctx, role) ([]*Pengguna, error)` (atau setara) — ambil semua helpdesk.

### 6.4 Endpoint (HTTP) + Guard Peran
- `POST /tiket/:id/assign` (ada) → kini **admin-only** + cek kosong; dipakai untuk assign & reassign.
- `POST /tiket/:id/unassign` (baru) → admin tarik balik ke pool.
- `GET /helpdesks` (baru) → daftar helpdesk + status kosong/sibuk, **admin-only**.
- Tambahkan guard role admin (di handler atau middleware) untuk ketiga endpoint di atas.

## 7. RLS (lapis kedua — untuk Realtime/SDK langsung dari Flutter)

- **`tiket_select_policy`**: helpdesk **hanya** baris `ditugaskan_kepada = auth.uid()`; admin semua; pengguna `dibuat_oleh = auth.uid()`. (Saat ini helpdesk masih bisa lihat semua — diperketat.)
- Policy turunan **`komentar_select_policy`** dan **`lampiran_select_policy`** (yang sekarang mengizinkan helpdesk via "EXISTS peran helpdesk") disesuaikan: helpdesk hanya akses komentar/lampiran dari tiket yang `ditugaskan_kepada = auth.uid()`.
- Disediakan sebagai file migrasi SQL baru di `supabase/` (mis. `rls_assignment_flow.sql`) tanpa mengubah `schema.sql` historis.

## 8. Perubahan Frontend (Flutter)

- **Pengguna:** tidak berubah (buat tiket, lihat tiket sendiri).
- **Helpdesk:**
  - Hapus tombol **"Ambil Tiket"** (self-assign) di semua tempat.
  - List/dashboard helpdesk → dua bagian: **"Sedang Dikerjakan"** (`DIPROSES` milik dia) + **"Riwayat Saya"** (`SELESAI` milik dia). Aksi: tandai **`SELESAI`**.
  - Selaras dengan widget `helpdesk_dashboard` yang sedang dikembangkan.
- **Admin:**
  - **Pool tiket** (`TERBUKA`) + aksi **"Tugaskan"** → dropdown **helpdesk kosong** (yang sibuk disembunyikan/disable), data dari `GET /helpdesks`.
  - Pada tiket `DIPROSES`: aksi **"Pindahkan"** (ke helpdesk kosong) dan **"Tarik balik ke pool"**.
  - Indikator beban helpdesk (kosong/sibuk).
  - `tiket_cubit` + repository: fetching berdasarkan peran.

## 9. Notifikasi (memakai sistem yang ada)

- **Assign** → ke helpdesk ("Tiket ditugaskan ke Anda") + ke pembuat ("Tiket Anda mulai diproses"). *(sudah ada)*
- **Reassign** → ke helpdesk lama ("Tiket dipindahkan dari Anda") + helpdesk baru.
- **Tarik balik** → ke helpdesk lama ("Tiket ditarik kembali ke pool").

## 10. Provisioning Akun Admin

Belum ada akun admin. Karena auth memakai **Supabase Auth**, admin harus ada di `auth.users` (agar bisa login) **dan** `pengguna.peran = 'admin'`. Baris `pengguna` saja tidak cukup.

**Metode:** script Go sekali-jalan, **idempotent**, di `backend/cmd/seed_admin/main.go`:
1. Panggil **Supabase Auth Admin API** (memakai `SUPABASE_SERVICE_ROLE_KEY`) untuk membuat user (`email_confirm = true`). Jika user sudah ada, lewati pembuatan.
2. `UPDATE pengguna SET peran = 'admin' WHERE email = <ADMIN_EMAIL>` (idempotent). Jika baris `pengguna` belum sempat dibuat webhook, upsert/insert manual.

**Kredensial dibaca dari environment variable** (tidak di-hardcode, tidak di-commit):
- `ADMIN_NAMA` (default contoh: `Administrator`)
- `ADMIN_EMAIL` (default contoh: `admin@helpdesk.local`)
- `ADMIN_PASSWORD` (wajib diisi saat run)

Cara jalankan: `ADMIN_EMAIL=... ADMIN_PASSWORD=... go run ./cmd/seed_admin`.

> Catatan keamanan: password test yang dipakai saat ini lemah dan **hanya untuk testing**; wajib diganti sebelum produksi.

## 11. Edge Cases & Validasi

- Assign ke helpdesk sibuk → ditolak `ErrHelpdeskSibuk` (HTTP 400).
- Assign/unassign oleh non-admin → HTTP 403.
- Target assign bukan berperan helpdesk → ditolak.
- Assign tiket `SELESAI`/`DIPROSES` lewat jalur pool → hanya via reassign admin.
- Tarik balik tiket yang bukan `DIPROSES` → ditolak (no-op/invalid).

## 12. Testing

- **Unit usecase:** assign sukses; assign-ke-sibuk ditolak; unassign; reassign; visibility list per peran (pengguna/helpdesk/admin).
- **Unit entity:** aturan peran & transisi di `AssignTo` / `UpdateStatus`.
- **Manual:** seed admin → login admin → assign ke helpdesk kosong → helpdesk lihat hanya tiketnya → selesaikan → admin assign berikutnya → reassign & tarik balik.

## 13. Known Limitations (sesuai Opsi A)

- Tanpa DB constraint/trigger, secara teori ada celah **race condition** bila dua admin meng-assign helpdesk yang sama nyaris bersamaan. Risiko kecil (penugasan manual oleh admin). Mitigasi ringan: pola cek-lalu-update di usecase. Bila kelak perlu jaminan kuat, tambahkan partial unique index `UNIQUE(ditugaskan_kepada) WHERE status='DIPROSES'` (Opsi C).

## 14. Di Luar Scope (YAGNI)

- Auto-assign otomatis saat helpdesk kosong.
- Status terpisah "DITUGASKAN".
- Prioritas tiket, SLA, load-balancing otomatis antar helpdesk.
