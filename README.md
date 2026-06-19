# E-Ticketing Helpdesk

Aplikasi mobile helpdesk berbasis tiket untuk pengelolaan permintaan bantuan IT. Pengguna dapat mengajukan tiket, helpdesk menangani penyelesaian, dan admin mengatur alur penugasan serta monitoring operasional.

**Stack:** Flutter (mobile) · Go (REST API) · Supabase (Auth, PostgreSQL, Storage)

---

## Fitur Utama

| Modul | Deskripsi |
|-------|-----------|
| **Autentikasi** | Login, registrasi, dan manajemen profil via Supabase Auth |
| **Tiket** | Buat, lihat detail, ubah status, dan lacak riwayat tiket |
| **Penugasan Admin** | Admin menugaskan tiket ke helpdesk yang tersedia (satu tiket aktif per helpdesk) |
| **Komentar** | Diskusi threaded pada setiap tiket |
| **Lampiran** | Upload, unduh, dan hapus file pendukung (gambar & dokumen) |
| **Notifikasi** | Pemberitahuan aktivitas tiket dengan status baca |
| **Dashboard** | Statistik dan ringkasan berbeda per peran (Pengguna, Helpdesk, Admin) |

---

## Peran Pengguna

| Peran | Hak Akses |
|-------|-----------|
| **Pengguna** | Membuat tiket, melihat tiket sendiri, menambah komentar & lampiran |
| **Helpdesk** | Melihat tiket yang ditugaskan, memperbarui status, dashboard operasional |
| **Admin** | Semua akses helpdesk + pool tiket global, penugasan/unassign, monitoring helpdesk |

### Alur Status Tiket

```
TERBUKA  →  DIPROSES  →  SELESAI
   ↑           │
   └─ unassign ┘  (admin menarik penugasan)
```

Tiket baru masuk ke **pool global**. Admin menugaskan ke helpdesk yang **bebas** (maks. 1 tiket `DIPROSES` per helpdesk). Helpdesk hanya melihat tiket yang ditugaskan kepadanya beserta riwayat selesai.

---

## Tech Stack

### Mobile (Flutter)

- **UI:** shadcn_ui, desain glassmorphism responsif (phone & tablet)
- **State:** flutter_bloc, get_it (DI)
- **Navigasi:** go_router
- **Backend client:** dio + supabase_flutter
- **Lainnya:** flutter_secure_storage, image_picker, flutter_local_notifications

### Backend (Go)

- **Framework:** Gin
- **Arsitektur:** Clean Architecture (delivery → usecases → repository)
- **Database & Auth:** Supabase (PostgREST + JWT verification)
- **Testing:** unit tests pada layer usecases

### Infrastruktur

- **Supabase Auth** — autentikasi pengguna
- **Supabase PostgreSQL** — data tiket, pengguna, komentar, notifikasi
- **Supabase Storage** — foto profil & lampiran tiket
- **Supabase Webhooks** — sinkronisasi event pengguna ke backend

---

## Struktur Proyek

```
eticketinghelpdesk/
├── lib/                          # Flutter app
│   ├── core/                     # Router, DI, theme, services
│   ├── features/                 # Feature modules (auth, tiket, dashboard, …)
│   └── shared/                   # Widget & utilitas bersama
├── backend/                      # Go REST API
│   ├── cmd/                      # CLI utilities (seed admin, apply RLS)
│   ├── config/                   # Konfigurasi environment
│   ├── delivery/http/            # HTTP handlers & middleware
│   ├── entities/                 # Domain entities
│   ├── repository/               # Supabase repositories
│   ├── usecases/                 # Business logic
│   └── scripts/                  # Skrip operasional
├── android/ · ios/ · linux/      # Platform runners
├── .env                          # Env Flutter (tidak di-commit)
```

---

## Prasyarat

| Tool | Versi minimum |
|------|---------------|
| Flutter SDK | 3.11+ |
| Dart SDK | 3.11+ |
| Go | 1.26+ |
| Supabase project | URL, anon key, service role key, JWT secret |

---

## Instalasi & Menjalankan

### 1. Clone repository

```bash
git clone https://github.com/ZaganJade/E-Ticketing_Helpdesk-MobileApp.git
cd E-Ticketing_Helpdesk-MobileApp
```

### 2. Konfigurasi environment

Buat file `.env` di root proyek (Flutter):

```env
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<supabase-anon-key>
API_BASE_URL=http://localhost:8080/api
APP_NAME=E-Ticketing Helpdesk
APP_VERSION=1.0.0
```

Buat file `backend/.env` (Go API):

```env
PORT=8080
ENV=development
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_KEY=<supabase-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
SUPABASE_JWT_SECRET=<jwt-secret>
SUPABASE_WEBHOOK_SECRET=<webhook-secret>
```

> **Catatan `API_BASE_URL`:**
> - Android Emulator → `http://10.0.2.2:8080/api`
> - iOS Simulator / desktop → `http://localhost:8080/api`
> - Perangkat fisik → `http://<IP-komputer>:8080/api`

### 3. Jalankan backend

```bash
cd backend
go mod download
go run main.go
```

API tersedia di `http://localhost:8080/api`.

### 4. Jalankan Flutter app

```bash
flutter pub get
flutter run
```

---

## API Endpoints (Ringkas)

| Method | Endpoint | Akses | Keterangan |
|--------|----------|-------|------------|
| `GET` | `/api/auth/me` | Auth | Profil pengguna saat ini |
| `GET` | `/api/dashboard/stats` | Auth | Statistik dashboard pengguna |
| `GET` | `/api/helpdesk/dashboard` | Helpdesk/Admin | Statistik dashboard helpdesk |
| `GET` | `/api/helpdesks` | Admin | Daftar helpdesk & ketersediaan |
| `GET/POST` | `/api/tikets` | Auth | List & buat tiket |
| `POST` | `/api/tikets/:id/assign` | Admin | Tugaskan tiket ke helpdesk |
| `POST` | `/api/tikets/:id/unassign` | Admin | Tarik penugasan tiket |
| `PATCH` | `/api/tikets/:id/status` | Helpdesk/Admin | Ubah status tiket |
| `GET/POST` | `/api/tikets/:id/komentars` | Auth | Komentar tiket |
| `POST` | `/api/tikets/:id/lampirans/upload` | Auth | Upload lampiran |
| `GET/PATCH` | `/api/notifikasis` | Auth | Notifikasi pengguna |
| `POST` | `/api/webhooks/user-events` | Webhook | Event sinkronisasi Supabase |

Semua endpoint protected memerlukan header `Authorization: Bearer <supabase-jwt>`.

---

## Pengembangan

```bash
# Analisis & lint Flutter
flutter analyze

# Test backend
cd backend && go test ./...

# Seed admin (sekali jalan, butuh env backend)
cd backend && go run cmd/seed_admin/main.go
```

---

## Lisensi

Proyek privat — tidak dipublikasikan ke pub.dev (`publish_to: 'none'`).

## Maintainer

**ZaganJade** — [tipstrik81@gmail.com](mailto:tipstrik81@gmail.com)
