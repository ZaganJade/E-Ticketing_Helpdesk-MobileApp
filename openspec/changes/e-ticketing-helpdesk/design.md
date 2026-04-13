## Context

Aplikasi E-Ticketing Helpdesk adalah sistem pelaporan masalah IT berbasis tiket. Sistem ini perlu menyediakan pelacakan real-time, komunikasi terpusat, dan manajemen tiket yang efisien. Arsitektur menggabungkan Flutter untuk mobile frontend, Golang untuk backend API business logic, dan Supabase untuk autentikasi, database, realtime, dan storage.

**Constraints:**
- Waktu respon sistem < 2 detik
- Update real-time < 1 detik
- UI mudah digunakan (maksimal 3 langkah membuat tiket)
- Mendukung Android dan iOS
- Tidak mendukung offline penuh
- Tidak ada versi web
- Tidak mendukung multi-tenant

## Goals / Non-Goals

**Goals:**
- Sistem pelaporan tiket yang terstruktur dengan status transparan
- Pelacakan tiket real-time menggunakan Supabase Realtime
- Komunikasi terpusat melalui sistem komentar pada tiket
- Autentikasi aman dengan role-based access (pengguna, helpdesk, admin)
- Upload dan manajemen lampiran file
- Dashboard statistik untuk monitoring
- Clean Architecture pada backend Golang
- Modular structure pada Flutter frontend

**Non-Goals:**
- Offline-first architecture
- Versi web dari aplikasi
- Multi-tenant support
- SLA otomatis (fitur pengembangan lanjutan)
- Sistem prioritas tiket (fitur pengembangan lanjutan)
- Integrasi WhatsApp atau AI (fitur pengembangan lanjutan)

## Decisions

### 1. Arsitektur Hybrid: Golang + Supabase
**Decision**: Menggunakan kombinasi Golang backend dan Supabase BaaS
**Rationale**:
- Supabase menyediakan autentikasi, database, realtime, dan storage out-of-the-box
- Golang menangani business logic kompleks, validasi, dan orkestrasi yang tidak cocok di database layer
- Memisahkan concerns: Supabase untuk data layer, Golang untuk application layer

**Alternatives considered**:
- Pure Supabase (functions): Terbatas untuk logic kompleks dan integrasi eksternal
- Pure Golang +自建 database: Memerlukan setup dan maintenance tambahan

### 2. Clean Architecture pada Backend Golang
**Decision**: Struktur layered dengan entities, use cases, interfaces, dan frameworks
**Rationale**:
- Separation of concerns yang jelas
- Testability yang tinggi
- Independent of frameworks, UI, dan database
- Sesuai dengan prinsip SOLID

**Layer structure**:
```
entities/     - Domain models (tiket, pengguna, komentar)
usecases/     - Business logic (ticket service, auth service)
interfaces/   - Repository interfaces
delivery/     - HTTP handlers/controllers
repository/   - Supabase implementations
```

### 3. UI Component-Based dengan shadcn-style
**Decision**: Membangun UI Flutter dengan pendekatan component-based
**Rationale**:
- Konsistensi UI di seluruh aplikasi
- Reusability komponen
- Mudah maintenance dan update design system
- Mendukung dark mode secara native

**Core components**:
- Button (primary, secondary, ghost variants)
- Input (text, textarea, password)
- Card (ticket card, comment card, stat card)
- Badge (status badges: TERBUKA, DIPROSES, SELESAI)
- Modal (confirmation, form modal)
- Toast (success, error, info notifications)
- Skeleton (loading states)

### 4. Database Design dengan PostgreSQL
**Decision**: Menggunakan PostgreSQL via Supabase dengan UUID primary keys
**Rationale**:
- UUID cocok untuk distributed systems dan security
- Foreign key constraints untuk data integrity
- Row Level Security (RLS) untuk access control granular

**Schema**:
```sql
-- pengguna
id (UUID PK), nama, email, password_hash, peran, dibuat_pada

-- tiket
id (UUID PK), judul, deskripsi, status, dibuat_oleh (FK), ditugaskan_kepada (FK), dibuat_pada

-- komentar
id (UUID PK), tiket_id (FK), penulis_id (FK), isi_pesan, dibuat_pada

-- notifikasi
id (UUID PK), pengguna_id (FK), tipe, referensi_id, sudah_dibaca, dibuat_pada
```

### 5. Real-time dengan Supabase Realtime
**Decision**: Menggunakan Supabase Realtime untuk update otomatis
**Rationale**:
- Built-in websocket support
- Listen ke perubahan database secara native
- No polling required, lebih efisien

**Events yang di-listen**:
- Perubahan status tiket
- Komentar baru pada tiket
- Notifikasi baru untuk pengguna

### 6. File Storage dengan Supabase Storage
**Decision**: Bucket `lampiran_tiket` untuk file attachments
**Rationale**:
- Terintegrasi dengan autentikasi Supabase
- Mudah mengatur access policies
- Mendukung various file types

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Dependency pada Supabase sebagai external service | Design backend Golang agar bisa migrasi ke database lain jika diperlukan; gunakan repository pattern |
| Realtime updates memerlukan koneksi internet | Implement proper error handling dan reconnect logic; tampilkan status koneksi ke user |
| Flutter learning curve untuk tim | Dokumentasi yang baik; component library yang reusable; konsisten design pattern |
| RLS policies yang kompleks bisa memperlambat query | Test performance dengan data volume tinggi; optimize queries dengan proper indexing |
| File upload size limits di Supabase | Validasi file size di client; compress images sebelum upload; informasikan limits ke user |

## Migration Plan

**Deployment Steps:**
1. Setup Supabase project dan konfigurasi database schema
2. Implement RLS policies untuk setiap tabel
3. Setup Supabase Storage bucket dengan policies
4. Deploy backend Golang ke server/cloud
5. Build dan deploy Flutter app ke Play Store dan App Store
6. Konfigurasi environment variables dan secrets

**Rollback Strategy:**
- Database migrations menggunakan version control (Supabase migrations)
- Backend deployment dengan blue-green strategy
- Mobile app dengan staged rollout (beta → production)

## Open Questions

1. Apakah perlu implementasi rate limiting pada API?
2. Bagaimana strategi backup dan disaster recovery untuk database?
3. Apakah perlu logging dan monitoring external (Sentry, Logrocket)?
4. Bagaimana handling session timeout dan token refresh?

---

# 9. DESAIN ANTARMUKA (UI/UX SPECIFICATION)

## 9.1 Prinsip Desain

Desain antarmuka aplikasi menggunakan pendekatan **component-based (shadcn-style)** dengan fokus pada:

* Konsistensi visual dan interaksi
* Reusability komponen
* Responsivitas pada berbagai ukuran layar
* Kemudahan penggunaan (usability-first)
* Dukungan dark mode

Semua elemen UI harus mengikuti **design system terpusat**.

---

## 9.2 Struktur Navigasi

Aplikasi menggunakan **Bottom Navigation Bar** sebagai navigasi utama dengan 4 menu:

1. **Dashboard** - Overview dan statistik
2. **Tiket** - Daftar dan manajemen tiket
3. **Notifikasi** - Pusat notifikasi pengguna
4. **Profil** - Informasi akun dan pengaturan

Navigasi tambahan menggunakan:

* Stack navigation untuk halaman detail
* Modal untuk aksi cepat (form, konfirmasi)

---

## 9.3 Daftar Halaman (Screens)

### 1. Splash Screen

* Menampilkan logo aplikasi
* Loading awal aplikasi dengan animasi
* Auto-redirect ke login atau dashboard (jika sudah login)

---

### 2. Login & Register

**Komponen:**
* Input email dengan validasi format
* Input password dengan toggle visibility
* Tombol login/register (primary)
* Link ke reset password
* Loading state saat proses autentikasi

**State:**
* Loading (saat login - skeleton atau spinner)
* Error (credential salah - toast/snackbar merah)
* Success (redirect ke dashboard)

---

### 3. Dashboard

**Menampilkan:**
* Total tiket (breakdown: terbuka, diproses, selesai)
* Statistik berdasarkan status (chart/progress bar)
* Ringkasan aktivitas terbaru (5 tiket terakhir)
* Quick action: tombol "Buat Tiket Baru"

**Komponen:**
* StatCard (total, terbuka, diproses, selesai)
* StatusBadge dengan warna:
  - TERBUKA: amber/warning
  - DIPROSES: blue/info
  - SELESAI: green/success
* TiketList mini untuk tiket terbaru

---

### 4. Daftar Tiket

**Menampilkan:**
* List tiket dalam bentuk TicketCard
* Filter berdasarkan status (All, Terbuka, Diproses, Selesai)
* Search bar untuk pencarian judul/deskripsi

**Setiap TicketCard berisi:**
* Judul tiket (truncated jika terlalu panjang)
* Status badge
* Tanggal dibuat (format relative: "2 jam yang lalu")
* Icon indikator lampiran (jika ada)

**Fitur:**
* Infinite scroll / pagination (load more saat scroll bottom)
* Pull to refresh
* Empty state: "Belum ada tiket" dengan ilustrasi dan CTA

---

### 5. Detail Tiket

**Menampilkan:**
* Header: Judul tiket, status badge, tanggal dibuat
* Section Info: Deskripsi lengkap, pembuat, penanggung jawab
* Section Lampiran: List file dengan preview thumbnail
* Section Komentar: Chat-style conversation
* Input komentar di bottom fixed

**Fitur:**
* Realtime update komentar (tanpa refresh)
* Auto scroll ke komentar terbaru saat submit
* Status change dropdown (untuk helpdesk/admin)
* Assign dropdown (untuk helpdesk/admin)
* Action button: edit (jika TERBUKA), delete (dengan confirmation)

**Layout:**
```
[AppBar: Judul Tiket]
[Status Badge | Tanggal]
[Deskripsi]
[Lampiran Section]
[Divider]
[Komentar List - Scrollable]
[Input Komentar - Fixed Bottom]
```

---

### 6. Buat Tiket

**Form fields:**
* Judul (required) - TextInput
* Deskripsi (required) - TextArea (min 3 lines)
* Upload lampiran (optional) - File picker dengan preview

**Validasi:**
* Judul: tidak boleh kosong, max 100 karakter
* Deskripsi: minimal 10 karakter, max 1000 karakter
* File: max 10MB, format: jpg, png, pdf, doc, docx

**Flow:**
1. User mengisi form
2. Validasi real-time (onBlur)
3. Submit button disabled jika invalid
4. Loading state saat submit
5. Success: redirect ke detail tiket baru
6. Error: snackbar dengan pesan error

---

### 7. Notifikasi

**Menampilkan:**
* List notifikasi dengan read/unread state
* Filter: Semua / Belum dibaca

**NotifikasiCard berisi:**
* Icon berdasarkan tipe (status change, komentar)
* Judul/pesan notifikasi
* Waktu notifikasi
* Indikator belum dibaca (dot atau background berbeda)

**Fitur:**
* Swipe to mark read
* Pull to refresh
* "Tandai semua dibaca" button
* Tap notifikasi untuk navigasi ke detail terkait

**Empty state:**
* Icon bell dengan slash
* Pesan: "Tidak ada notifikasi"

---

### 8. Profil

**Menampilkan:**
* Avatar (inisial nama atau foto)
* Nama lengkap
* Email
* Peran (Pengguna/Helpdesk/Admin badge)
* Tanggal bergabung

**Menu:**
* Edit profil (nama)
* Ubah password
* Tentang aplikasi
* Logout (destructive - merah)

**Logout flow:**
1. Tap logout
2. Confirmation dialog: "Yakin ingin keluar?"
3. Loading
4. Redirect ke login

---

## 9.4 Komponen UI (Design System)

### AppButton

Variants:
* **primary** - Background primary, white text (untuk aksi utama)
* **secondary** - Background secondary, dark text (untuk aksi alternatif)
* **destructive** - Background red, white text (untuk delete, logout)
* **ghost** - Transparent, primary text (untuk link, cancel)
* **outline** - Border only, dark text (untuk secondary action)

States:
* default, pressed, disabled, loading

### AppInput

Types:
* **text** - Single line
* **password** - Dengan visibility toggle
* **textarea** - Multi line, auto-expand
* **email** - Dengan email keyboard type

Features:
* Label di atas input
* Helper text / error text di bawah
* Prefix/suffix icon (opsional)
* Clear button (opsional)

### AppCard

Types:
* **tiket** - Untuk list tiket dengan status badge
* **komentar** - Chat bubble style dengan avatar
* **stat** - Dashboard stat card dengan icon
* **notifikasi** - Horizontal card dengan icon dan text

### StatusBadge

Colors:
* TERBUKA: `Colors.amber` dengan icon `Icons.access_time`
* DIPROSES: `Colors.blue` dengan icon `Icons.sync`
* SELESAI: `Colors.green` dengan icon `Icons.check_circle`

Style: Rounded pill/rounded rectangle dengan padding horizontal

### AppModal / Dialog

Types:
* **confirmation** - Title, message, cancel + confirm button
* **form** - Title, form fields, cancel + submit
* **loading** - Spinner dengan text (non-dismissible)

Animation: Fade in + scale dari center

### Toast / Snackbar

Types:
* **success** - Green background, check icon
* **error** - Red background, error icon
* **info** - Blue background, info icon
* **warning** - Amber background, warning icon

Position: Bottom of screen dengan padding safe area
Duration: 3 detik atau swipe to dismiss

### SkeletonLoading

Used for:
* Card lists saat loading
* Detail page saat fetch data
* Stats saat loading dashboard

Style: Shimmer effect dengan base color dan highlight color

---

## 9.5 Status UI (State Handling)

### 1. Loading State

* **Initial load**: Skeleton loading untuk semua content area
* **Action loading**: Button dengan spinner, atau overlay loading
* **Pull refresh**: Circular progress indicator di top
* **Pagination**: Spinner di bottom list

### 2. Empty State

Template:
* Icon/Ilustrasi (120px)
* Title: "Belum ada [data]"
* Subtitle: Penjelasan singkat
* CTA Button (jika applicable)

Contoh:
```
[Icon: inbox_outlined]
"Belum ada tiket"
"Buat tiket pertama Anda untuk melaporkan masalah"
[Button: Buat Tiket]
```

### 3. Error State

Template:
* Icon error (error_outline atau cloud_off)
* Title: "Terjadi kesalahan"
* Subtitle: Pesan error spesifik atau generic
* Retry button

Contoh:
```
[Icon: error_outline]
"Gagal memuat data"
"Periksa koneksi internet Anda dan coba lagi"
[Button: Coba Lagi]
```

### 4. Success State

* Toast/snackbar dengan check icon
* Green color scheme
* Auto dismiss 3 detik

---

## 9.6 Interaksi Pengguna

### Flow: Pembuatan Tiket

```
[Dashboard/Tiket List]
    ↓ (Tap FAB "+")
[CreateTiketPage]
    ↓ (Isi form: Judul, Deskripsi, Lampiran opsional)
    ↓ (Tap Submit)
[Loading State]
    ↓ (Success)
[TiketDetailPage] - Tiket baru dengan status TERBUKA
```

### Flow: Komentar

```
[TiketDetailPage]
    ↓ (User ketik di input komentar)
    ↓ (Tap Kirim / Enter)
[Loading State pada input]
    ↓ (Success)
[Komentar muncul di list dengan animation slide up]
[Auto scroll ke komentar baru]
[Notifikasi realtime ke helpdesk]
```

### Flow: Update Status (Helpdesk)

```
[TiketDetailPage]
    ↓ (Helpdesk tap Status Dropdown)
[Dropdown Menu: TERBUKA, DIPROSES, SELESAI]
    ↓ (Pilih status baru)
[Confirmation Modal] (jika diproses → selesai)
    ↓ (Confirm)
[Status badge update dengan animation]
[Notifikasi realtime ke pembuat tiket]
```

---

## 9.7 Realtime Behavior

* **Tiket update**: Badge status berubah warna secara animasi (fade transition)
* **Komentar baru**: Slide in dari bottom dengan animation, badge "Baru" muncul
* **Notifikasi masuk**: Counter badge di nav bar increment dengan animation, toast muncul

**Reconnect handling:**
* Saat koneksi terputus: Snackbar warning "Koneksi terputus"
* Saat koneksi kembali: Snackbar success "Koneksi kembali", auto-refresh data

---

## 9.8 Spacing & Layout

**Standar spacing (grid 8px):**
* xs: 4px
* sm: 8px
* md: 12px
* default: 16px
* lg: 24px
* xl: 32px
* xxl: 48px

**Screen padding:**
* Horizontal: 16px (default screen padding)
* List item spacing: 12px
* Card internal padding: 16px

**Minimum touch target:**
* 48px x 48px (Material Design guideline)
* Icon buttons: 48px min size
* List items: 56px min height

**Border radius:**
* Buttons: 8px
* Cards: 12px
* Inputs: 8px
* Badges: 16px (pill)
* Modals: 16px (top corners)

---

## 9.9 Dark Mode

**Color scheme:**

Light Mode:
* Background: `Colors.white` / `Colors.grey[50]`
* Surface: `Colors.white`
* Text primary: `Colors.grey[900]`
* Text secondary: `Colors.grey[600]`
* Divider: `Colors.grey[300]`

Dark Mode:
* Background: `Colors.grey[900]` / `Colors.black`
* Surface: `Colors.grey[800]`
* Text primary: `Colors.white`
* Text secondary: `Colors.grey[400]`
* Divider: `Colors.grey[700]`

**Status colors (consistent both modes):**
* TERBUKA: Amber-500
* DIPROSES: Blue-500
* SELESAI: Green-500

**Implementation:**
* Gunakan `Theme.of(context)` untuk akses colors
* Definisikan `ThemeData` untuk light dan dark
* Support system preference (`MediaQuery.platformBrightnessOf`)
* Manual toggle di settings (opsional)

---

## 9.10 Performa UI

**Optimasi:**
* Gunakan `const` constructor untuk widget statis
* Implementasi `ListView.builder` untuk list panjang
* Image caching dengan `CachedNetworkImage`
* Lazy loading untuk pagination
* Debounce pada search input (300ms)
* Throttle pada realtime updates (batch updates jika banyak)

**Avoid:**
* Rebuild berlebihan (gunakan `const`, `RepaintBoundary`)
* Deep widget trees (gunakan composition)
* Synchronous operations di main thread

---

## 9.11 Responsivitas

**Target devices:**
* Android: minSdk 21 (Android 5.0), targetSdk 34
* iOS: minimum iOS 12

**Layout adaptif:**
* Gunakan `MediaQuery` untuk screen size awareness
* Max content width: 600px (tablet tetap seperti mobile, tidak expand penuh)
* Safe area handling untuk notch/dynamic island
* Keyboard avoiding view untuk input forms

**Orientation:**
* Primary: Portrait
* Landscape: Support dengan scrollable content

---

## 9.12 Typography

**Font:**
* Primary: System font (Roboto di Android, San Francisco di iOS)
* Fallback: Inter (jika custom font digunakan)

**Scale:**
* Headline: 24px, Bold
* Title: 20px, SemiBold
* Subtitle: 16px, Medium
* Body: 14px, Regular
* Caption: 12px, Regular
* Button: 14px, Medium (all caps optional)

**Line height:**
* Headings: 1.2
* Body: 1.5
* Dense (lists): 1.3
