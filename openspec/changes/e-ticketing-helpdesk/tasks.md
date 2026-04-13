## 1. Project Setup & Infrastructure

- [x] 1.1 Initialize Flutter project dengan struktur modular (lib/features, lib/core, lib/shared)
- [x] 1.2 Setup Supabase project dan konfigurasi database
- [x] 1.3 Initialize Golang project dengan struktur Clean Architecture (entities, usecases, interfaces, delivery, repository)
- [x] 1.4 Setup dependency injection untuk Flutter (get_it) dan Golang (wire)
- [x] 1.5 Konfigurasi environment variables untuk development dan production
- [x] 1.6 Setup Git repository dengan .gitignore untuk Flutter dan Golang

## 2. Database Schema & RLS Policies (Supabase)

- [x] 2.1 Buat tabel `pengguna` (id UUID PK, nama, email, password_hash, peran, dibuat_pada)
- [x] 2.2 Buat tabel `tiket` (id UUID PK, judul, deskripsi, status, dibuat_oleh FK, ditugaskan_kepada FK, dibuat_pada)
- [x] 2.3 Buat tabel `komentar` (id UUID PK, tiket_id FK, penulis_id FK, isi_pesan, dibuat_pada)
- [x] 2.4 Buat tabel `notifikasi` (id UUID PK, pengguna_id FK, tipe, referensi_id, sudah_dibaca, dibuat_pada)
- [x] 2.5 Buat tabel `lampiran` (id UUID PK, tiket_id FK, nama_file, path_file, ukuran, tipe_file, dibuat_pada)
- [x] 2.6 Setup RLS policy: pengguna hanya lihat tiket miliknya
- [x] 2.7 Setup RLS policy: helpdesk dan admin lihat semua tiket
- [x] 2.8 Setup RLS policy: notifikasi hanya dapat diakses oleh pengguna terkait
- [x] 2.9 Setup RLS policy: komentar mengikuti akses tiket terkait
- [x] 2.10 Buat Supabase Storage bucket `lampiran_tiket` dengan policies
- [x] 2.11 Setup Supabase Realtime untuk tabel tiket, komentar, dan notifikasi

## 3. Backend Golang - Domain Layer

- [x] 3.1 Definisikan entity `Pengguna` (domain model dengan validation)
- [x] 3.2 Definisikan entity `Tiket` dengan status enum (TERBUKA, DIPROSES, SELESAI)
- [x] 3.3 Definisikan entity `Komentar`
- [x] 3.4 Definisikan entity `Notifikasi` dengan tipe enum
- [x] 3.5 Definisikan entity `Lampiran`
- [x] 3.6 Buat repository interfaces untuk setiap entity
- [x] 3.7 Definisikan error domain (DomainError, NotFoundError, ValidationError)

## 4. Backend Golang - Repository Layer (Supabase)

- [x] 4.1 Implementasi SupabaseAuthRepository untuk autentikasi
- [x] 4.2 Implementasi SupabasePenggunaRepository
- [x] 4.3 Implementasi SupabaseTiketRepository dengan RLS awareness
- [x] 4.4 Implementasi SupabaseKomentarRepository
- [x] 4.5 Implementasi SupabaseNotifikasiRepository
- [x] 4.6 Implementasi SupabaseLampiranRepository dengan Storage integration
- [x] 4.7 Setup Supabase client dengan proper error handling

## 5. Backend Golang - Use Case Layer

- [x] 5.1 Implementasi RegisterUseCase dengan validasi password
- [x] 5.2 Implementasi LoginUseCase dengan JWT generation
- [x] 5.3 Implementasi LogoutUseCase
- [x] 5.4 Implementasi CreateTiketUseCase
- [x] 5.5 Implementasi GetTiketListUseCase (dengan filter dan pagination)
- [x] 5.6 Implementasi GetTiketDetailUseCase
- [x] 5.7 Implementasi UpdateTiketStatusUseCase
- [x] 5.8 Implementasi AssignTiketUseCase
- [x] 5.9 Implementasi AddKomentarUseCase
- [x] 5.10 Implementasi CreateNotifikasiUseCase (triggered by events)
- [x] 5.11 Implementasi GetNotifikasiListUseCase
- [x] 5.12 Implementasi MarkNotifikasiReadUseCase
- [x] 5.13 Implementasi UploadLampiranUseCase dengan file validation
- [x] 5.14 Implementasi DeleteLampiranUseCase
- [x] 5.15 Implementasi GetDashboardStatsUseCase

## 6. Backend Golang - Delivery Layer (HTTP API)

- [x] 6.1 Setup HTTP router (Gin atau Echo) dengan middleware
- [x] 6.2 Implementasi AuthHandler (POST /api/auth/register, POST /api/auth/login, POST /api/auth/logout)
- [x] 6.3 Implementasi TiketHandler (GET, POST, PATCH tiket endpoints)
- [x] 6.4 Implementasi KomentarHandler (GET, POST komentar endpoints)
- [x] 6.5 Implementasi NotifikasiHandler (GET notifikasi, PATCH mark-read)
- [x] 6.6 Implementasi LampiranHandler (POST upload, GET download, DELETE)
- [x] 6.7 Implementasi DashboardHandler (GET /api/dashboard/stats)
- [x] 6.8 Setup JWT middleware untuk protected routes
- [x] 6.9 Setup role-based middleware (pengguna, helpdesk, admin)
- [x] 6.10 Implementasi error handling dan response standardization

## 7. Backend Golang - Realtime Events

- [x] 7.1 Setup Supabase Realtime client di backend
- [x] 7.2 Implementasi event listener untuk perubahan tiket
- [x] 7.3 Implementasi event listener untuk komentar baru
- [x] 7.4 Implementasi broadcast notifikasi ke client via WebSocket/Firebase
- [x] 7.5 Setup notification trigger pada create/update tiket

## 8. Flutter - Core, Design System & Shared Components

- [x] 8.1 Setup Supabase client Flutter dengan proper initialization
- [x] 8.2 Buat base API client untuk Golang backend (Dio dengan interceptors)
- [x] 8.3 Implementasi global error handler dan exception mapping

### Design System - Foundation
- [x] 8.4 Buat AppTheme dengan ColorScheme untuk light dan dark mode
- [x] 8.5 Definisikan AppColors (primary, secondary, error, success, warning, info, neutral grays)
- [x] 8.6 Definisikan AppTextStyles (headline, title, subtitle, body, caption, button)
- [x] 8.7 Definisikan AppSpacing (xs:4, sm:8, md:12, default:16, lg:24, xl:32, xxl:48)
- [x] 8.8 Definisikan AppBorderRadius (button:8, card:12, input:8, badge:16, modal:16)
- [x] 8.9 Implementasi theme provider untuk dark mode toggle dan system preference

### Design System - Components
- [x] 8.10 Implementasi AppButton dengan variants: primary, secondary, destructive, ghost, outline
- [x] 8.11 Implementasi AppButton states: default, pressed, disabled, loading
- [x] 8.12 Implementasi AppInput dengan types: text, password, textarea, email
- [x] 8.13 Implementasi AppInput features: label, helper text, error text, prefix/suffix icons, clear button
- [x] 8.14 Implementasi AppCard dengan types: tiket, komentar, stat, notifikasi
- [x] 8.15 Implementasi StatusBadge dengan colors: TERBUKA=amber, DIPROSES=blue, SELESAI=green
- [x] 8.16 Implementasi AppModal/Dialog dengan types: confirmation, form, loading
- [x] 8.17 Implementasi Toast/Snackbar dengan types: success, error, info, warning
- [x] 8.18 Implementasi SkeletonLoading dengan shimmer effect untuk cards, lists, detail
- [x] 8.19 Implementasi AppScaffold dengan BottomNavigationBar (4 menu: Dashboard, Tiket, Notifikasi, Profil)
- [x] 8.20 Implementasi AppBar dengan variants: default, transparent, dengan actions
- [x] 8.21 Implementasi PullToRefresh wrapper component
- [x] 8.22 Implementasi EmptyState component dengan icon, title, subtitle, CTA button
- [x] 8.23 Implementasi ErrorState component dengan icon, title, message, retry button
- [x] 8.24 Implementasi LoadingOverlay component untuk full-screen loading

## 9. Flutter - Auth Feature & Splash Screen

- [x] 9.1 Buat AuthRepository dengan Supabase Auth
- [x] 9.2 Implementasi AuthCubit/Bloc untuk state management (LoginState, RegisterState, AuthState)

### Splash Screen
- [x] 9.3 Buat SplashScreen dengan logo animasi (fade/scale)
- [x] 9.4 Implementasi auto-login check: redirect ke Dashboard jika sudah login, ke Login jika belum
- [x] 9.5 Tambahkan minimum display duration (1.5 detik) untuk UX yang baik

### Login Page
- [x] 9.6 Buat LoginPage dengan AppScaffold tanpa bottom nav
- [x] 9.7 Implementasi form: email input dengan validation format, password input dengan visibility toggle
- [x] 9.8 Implementasi loading state pada tombol login saat proses autentikasi
- [x] 9.9 Implementasi error state: toast/snackbar merah untuk credential salah
- [x] 9.10 Tambahkan link "Belum punya akun? Daftar" ke RegisterPage
- [x] 9.11 Tambahkan link "Lupa password?" (opsional)

### Register Page
- [x] 9.12 Buat RegisterPage dengan form: nama, email, password, confirm password
- [x] 9.13 Implementasi password validation: minimal 8 karakter, strength indicator (opsional)
- [x] 9.14 Implementasi real-time validation pada email (format) dan password (length)
- [x] 9.15 Implementasi loading state dan error handling (email sudah terdaftar)
- [x] 9.16 Tambahkan link "Sudah punya akun? Login"

### Auth Logic
- [x] 9.17 Implementasi token refresh mechanism (auto refresh saat expired)
- [x] 9.18 Implementasi secure token storage (FlutterSecureStorage)
- [x] 9.19 Implementasi logout dengan AppModal confirmation dialog
- [x] 9.20 Implementasi session timeout handling (redirect ke login dengan pesan)

## 10. Flutter - Tiket Feature

- [x] 10.1 Buat TiketRepository dengan Supabase dan Golang API
- [x] 10.2 Implementasi TiketCubit untuk state management (TiketListState, TiketDetailState, CreateTiketState)

### Daftar Tiket Page
- [x] 10.3 Buat TiketListPage dengan AppScaffold dan bottom nav
- [x] 10.4 Implementasi filter chips: Semua, Terbuka, Diproses, Selesai
- [x] 10.5 Implementasi search bar di AppBar untuk pencarian judul/deskripsi
- [x] 10.6 Implementasi TiketCard component dengan: judul (truncated), StatusBadge, tanggal relatif, lampiran indicator
- [x] 10.7 Implementasi infinite scroll / pagination (load more saat scroll bottom)
- [x] 10.8 Implementasi pull to refresh
- [x] 10.9 Implementasi EmptyState: "Belum ada tiket" dengan ilustrasi dan CTA "Buat Tiket"
- [x] 10.10 Implementasi FAB (Floating Action Button) "+" untuk navigasi ke CreateTiketPage
- [x] 10.11 Implementasi skeleton loading untuk initial load

### Detail Tiket Page
- [x] 10.12 Buat TiketDetailPage dengan custom AppBar (judul tiket, back button)
- [x] 10.13 Implementasi header section: StatusBadge besar, tanggal dibuat format lengkap
- [x] 10.14 Implementasi info section: Judul, deskripsi lengkap, pembuat, penanggung jawab (jika ada)
- [x] 10.15 Implementasi lampiran section: LampiranList dengan thumbnail dan nama file
- [x] 10.16 Implementasi komentar section: KomentarList dengan chat-style bubble
- [x] 10.17 Implementasi komentar input: Fixed bottom dengan text field dan tombol kirim
- [x] 10.18 Implementasi helpdesk controls: StatusDropdown (TERBUKA/DIPROSES/SELESAI), AssignDropdown
- [x] 10.19 Implementasi realtime update: auto refresh saat ada perubahan status/komentar
- [x] 10.20 Implementasi scroll to bottom saat komentar baru ditambahkan
- [x] 10.21 Implementasi error state dan retry mechanism

### Buat Tiket Page
- [x] 10.22 Buat CreateTiketPage dengan AppBar "Buat Tiket Baru"
- [x] 10.23 Implementasi form fields: Judul (required, max 100), Deskripsi (required, min 10, max 1000, textarea)
- [x] 10.24 Implementasi real-time validation: onBlur validation untuk judul dan deskripsi
- [x] 10.25 Implementasi lampiran upload section: File picker, preview, file validation (max 10MB, format: jpg/png/pdf/doc/docx)
- [x] 10.26 Implementasi loading state saat submit dengan LoadingOverlay
- [x] 10.27 Implementasi submit button dengan state: disabled jika invalid, loading saat submit
- [x] 10.28 Implementasi success flow: Toast "Tiket berhasil dibuat" → redirect ke TiketDetailPage tiket baru
- [x] 10.29 Implementasi error handling: Snackbar dengan pesan error spesifik
- [x] 10.30 Implementasi cancel confirmation jika ada perubahan yang belum disimpan

## 11. Flutter - Komentar Feature

- [x] 11.1 Buat KomentarRepository dengan Supabase
- [x] 11.2 Implementasi KomentarCubit untuk state management

### Komentar List Component
- [x] 11.3 Buat KomentarList component untuk digunakan di TiketDetailPage
- [x] 11.4 Implementasi chat-style bubble layout (left untuk helpdesk/admin, right untuk pembuat)
- [x] 11.5 Implementasi KomentarCard dengan: avatar (inisial), nama penulis, isi pesan, waktu relatif
- [x] 11.6 Implementasi badge penulis: "Pembuat", "Helpdesk", atau "Admin"
- [x] 11.7 Implementasi bubble styling dengan tail berdasarkan pengirim
- [x] 11.8 Implementasi auto scroll ke komentar terbaru saat submit atau saat ada komentar baru (realtime)
- [x] 11.9 Implementasi animation slide up saat komentar baru muncul
- [x] 11.10 Implementasi "Komentar baru" badge untuk highlight komentar yang belum dibaca
- [x] 11.11 Implementasi empty state jika belum ada komentar: "Belum ada komentar. Jadilah yang pertama!"

### Komentar Input Component
- [x] 11.12 Buat KomentarInput component fixed di bottom TiketDetailPage
- [x] 11.13 Implementasi text field multi-line dengan auto-expand (max 5 lines)
- [x] 11.14 Implementasi tombol kirim dengan icon send, disabled jika text kosong
- [x] 11.15 Implementasi loading state pada tombol saat submit
- [x] 11.16 Implementasi clear button di text field
- [x] 11.17 Implementasi keyboard handling: resize avoidance, dismiss on tap outside
- [x] 11.18 Implementasi realtime subscription: listen ke Supabase Realtime untuk komentar baru
- [x] 11.19 Implementasi optimistic update: tampilkan komentar segera setelah submit (pending state), update saat confirmed

## 12. Flutter - Notifikasi Feature

- [x] 12.1 Buat NotifikasiRepository dengan Supabase
- [x] 12.2 Implementasi NotifikasiCubit untuk state management

### Notifikasi List Page
- [x] 12.3 Buat NotifikasiListPage dengan AppScaffold dan bottom nav aktif "Notifikasi"
- [x] 12.4 Implementasi filter tabs: "Semua" dan "Belum dibaca"
- [x] 12.5 Implementasi NotifikasiCard dengan: icon berdasarkan tipe (status change, komentar), judul/pesan, waktu relatif, indikator belum dibaca (dot atau background berbeda)
- [x] 12.6 Implementasi swipe to mark as read gesture
- [x] 12.7 Implementasi pull to refresh
- [x] 12.8 Implementasi infinite scroll untuk pagination
- [x] 12.9 Implementasi EmptyState: Icon bell dengan slash, "Tidak ada notifikasi"
- [x] 12.10 Implementasi "Tandai semua dibaca" button di AppBar (hanya muncul jika ada notifikasi belum dibaca)

### Badge Counter & Realtime
- [x] 12.11 Implementasi badge counter di BottomNavigationBar menu Notifikasi
- [x] 12.12 Implementasi badge animation saat counter bertambah (scale bounce)
- [x] 12.13 Implementasi realtime subscription: listen ke notifikasi baru untuk pengguna
- [x] 12.14 Implementasi toast/snackbar saat notifikasi baru masuk (judul dan preview)
- [x] 12.15 Implementasi deep linking: tap notifikasi navigasi ke TiketDetailPage terkait

### Push Notification (Opsional)
- [ ] 12.16 Setup Firebase Cloud Messaging (FCM)
- [ ] 12.17 Implementasi push notification saat app di background/foreground
- [ ] 12.18 Implementasi tap notification untuk navigasi ke detail tiket

## 13. Flutter - Dashboard Feature

- [x] 13.1 Buat DashboardRepository untuk mengambil statistik dari backend
- [x] 13.2 Implementasi DashboardCubit untuk state management

### Dashboard Page UI
- [x] 13.3 Buat DashboardPage sebagai home screen dengan AppScaffold dan bottom nav aktif "Dashboard"
- [x] 13.4 Implementasi greeting section: "Selamat pagi/siang/sore/malam, [Nama]" dengan avatar
- [x] 13.5 Implementasi peran badge: "Pengguna", "Helpdesk", atau "Admin"

### Statistik Cards
- [x] 13.6 Implementasi StatCard untuk Total Tiket dengan icon dan angka besar
- [x] 13.7 Implementasi horizontal row dengan 3 StatCard mini: Terbuka (amber), Diproses (blue), Selesai (green)
- [x] 13.8 Implementasi progress bar atau pie chart visualization untuk proporsi status
- [x] 13.9 Implementasi skeleton loading untuk stat cards saat initial load
- [x] 13.10 Implementasi error state dengan retry button untuk section statistik

### Tiket Terbaru Section
- [x] 13.11 Implementasi TiketRecentList: 5 tiket terbaru dengan TiketCard mini
- [x] 13.12 Implementasi "Lihat Semua" link ke TiketListPage
- [x] 13.13 Implementasi empty state: "Belum ada tiket" dengan CTA "Buat Tiket Pertama"

### Quick Actions
- [x] 13.14 Implementasi QuickAction FAB atau button row: "+ Buat Tiket Baru"
- [x] 13.15 Implementasi shortcut ke TiketListPage dengan filter (opsional)

### Helpdesk/Admin Specific
- [x] 13.16 Implementasi section "Tiket Terbuka" untuk helpdesk: list tiket TERBUKA yang belum ditugaskan dengan tombol "Ambil Tiket"
- [x] 13.17 Implementasi section "Tiket Saya" untuk helpdesk: tiket yang sedang ditangani
- [x] 13.18 Implementasi admin stats: total pengguna per peran, performa helpdesk (opsional)

## 14. Flutter - Lampiran Feature

- [x] 14.1 Buat LampiranRepository dengan Supabase Storage integration
- [x] 14.2 Implementasi LampiranCubit untuk state management

### File Picker & Upload
- [x] 14.3 Implementasi file picker menggunakan file_picker atau image_picker package
- [x] 14.4 Implementasi LampiranUpload component dengan: drag area/ button, selected file preview, file info (nama, ukuran), remove button
- [x] 14.5 Implementasi file validation: max 10MB, format: jpg, png, pdf, doc, docx
- [x] 14.6 Implementasi error message untuk file tidak valid: "Format file tidak diizinkan" atau "Ukuran file maksimal 10MB"
- [x] 14.7 Implementasi upload progress indicator (linear progress atau circular)
- [x] 14.8 Implementasi image compression sebelum upload untuk menghemat bandwidth (opsional)

### Lampiran List & Preview
- [x] 14.9 Implementasi LampiranList component untuk TiketDetailPage dengan: grid atau list layout, thumbnail untuk images, icon untuk dokumen
- [x] 14.10 Implementasi image preview: tap thumbnail untuk full-size preview dengan zoom dan pan
- [x] 14.11 Implementasi file download: tap file untuk download ke device
- [x] 14.12 Implementasi download progress indicator
- [x] 14.13 Implementasi file delete dengan AppModal confirmation: "Yakin ingin menghapus lampiran ini?"
- [x] 14.14 Implementasi permission handling: storage permission untuk download, camera/gallery permission untuk upload

### Security & Validation
- [x] 14.15 Implementasi file type whitelist di client side
- [x] 14.16 Implementasi file size check sebelum upload
- [x] 14.17 Implementasi disable delete untuk tiket yang statusnya DIPROSES atau SELESAI (kecuali admin)

## 15. Flutter - Profil Feature

- [x] 15.1 Buat ProfilRepository untuk mengambil dan update data pengguna
- [x] 15.2 Implementasi ProfilCubit untuk state management

### Profil Page
- [x] 15.3 Buat ProfilPage dengan AppScaffold dan bottom nav aktif "Profil"
- [x] 15.4 Implementasi header section: Avatar (inisial nama atau foto), Nama lengkap, Email, Peran badge (Pengguna/Helpdesk/Admin)
- [x] 15.5 Implementasi info tambahan: Tanggal bergabung

### Profil Menu
- [x] 15.6 Implementasi menu list: Edit Profil (nama), Ubah Password, Tentang Aplikasi, Logout
- [x] 15.7 Implementasi Edit Profil: form untuk mengubah nama dengan validation
- [x] 15.8 Implementasi Ubah Password: form dengan old password, new password, confirm password
- [x] 15.9 Implementasi Tentang Aplikasi: versi app, copyright, links
- [x] 15.10 Implementasi Logout: AppModal confirmation "Yakin ingin keluar?", loading state, redirect ke LoginPage

## 16. Flutter - Navigation & Routing

- [x] 16.1 Setup GoRouter atau AutoRoute untuk navigation
- [x] 16.2 Definisikan route structure: SplashRoute, LoginRoute, RegisterRoute, DashboardRoute, TiketListRoute, TiketDetailRoute, CreateTiketRoute, NotifikasiRoute, ProfilRoute
- [x] 16.3 Implementasi route guards untuk authenticated routes (redirect ke login jika belum auth)
- [x] 16.4 Implementasi deep linking untuk notifikasi tap (navigasi ke TiketDetailRoute dengan tiket id)
- [x] 16.5 Setup role-based access control: helper function untuk check role sebelum akses fitur tertentu
- [x] 16.6 Implementasi back button handling: confirmation jika ada unsaved changes di form
- [x] 16.7 Implementasi navigation transition animations (fade, slide)
- [x] 16.8 Implementasi bottom navigation state preservation (keep alive state)

## 17. Integration & Testing

### End-to-End Flow Testing
- [ ] 17.1 Integrasi full flow pengguna: registrasi → login → buat tiket → upload lampiran → beri komentar
- [ ] 17.2 Integrasi full flow helpdesk: login → lihat tiket terbuka → ambil tiket → ubah status → beri komentar dengan lampiran
- [ ] 17.3 Integrasi realtime flow: buka 2 device → user buat komentar → helpdesk lihat realtime update
- [ ] 17.4 Test notifikasi flow: ubah status → notifikasi muncul di device pembuat → tap notifikasi navigasi ke detail

### Technical Testing
- [ ] 17.5 Test real-time updates pada multiple devices (Supabase Realtime)
- [ ] 17.6 Test RLS policies dengan berbagai user scenarios (pengguna A tidak lihat tiket B)
- [ ] 17.7 Test file upload dan download dengan berbagai ukuran (1KB - 10MB)
- [ ] 17.8 Test error handling dan network failure scenarios (offline mode, timeout, 500 error)
- [ ] 17.9 Test form validation edge cases: empty input, max length, special characters
- [ ] 17.10 Test authentication edge cases: token expired, invalid token, concurrent sessions

### Performance & UX Testing
- [ ] 17.11 Performa test: response time API < 2 detik (gunakan stopwatch/logging)
- [ ] 17.12 UI/UX testing: maksimal 3 langkah untuk membuat tiket (Dashboard → FAB → Submit)
- [ ] 17.13 Memory leak testing: navigasi bolak-balik, scroll list panjang
- [ ] 17.14 Device compatibility testing: Android 5.0+, iOS 12+, various screen sizes

## 18. Polish & Deployment Preparation

### UI/UX Polish
- [ ] 18.1 Review dan implementasi loading states di semua halaman (skeleton, shimmer)
- [ ] 18.2 Review dan implementasi error states di semua halaman (ErrorState component)
- [ ] 18.3 Review dan implementasi empty states di semua list (EmptyState component)
- [ ] 18.4 Review form validation: error messages yang jelas, dekat field yang error
- [ ] 18.5 Polish animations: page transitions, button presses, list item animations
- [ ] 18.6 Review dan perbaiki dark mode consistency (test semua screens di dark mode)
- [ ] 18.7 Optimasi gambar: compressed images, cached network images
- [ ] 18.8 Implementasi haptic feedback untuk actions penting (optional)
- [ ] 18.9 Review accessibility: touch targets 48px+, contrast ratios, screen reader labels

### Assets & Branding
- [ ] 18.10 Generate splash screen dengan logo dan branding
- [ ] 18.11 Generate app icons untuk Android (adaptive icons) dan iOS
- [ ] 18.12 Setup app name dan package name/bundle ID
- [ ] 18.13 Generate launcher icons untuk berbagai density (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

### Build & Deployment
- [ ] 18.14 Konfigurasi app signing untuk Android (keystore, build.gradle)
- [ ] 18.15 Konfigurasi iOS provisioning profiles dan certificates (jika deploy ke iOS)
- [ ] 18.16 Build release APK/AAB untuk internal testing
- [ ] 18.17 Deploy backend Golang ke cloud server (Railway, Render, AWS, dll)
- [ ] 18.18 Konfigurasi production environment variables (jangan commit secrets!)
- [ ] 18.19 Setup CI/CD pipeline untuk automated builds (optional: GitHub Actions, Codemagic)
- [ ] 18.20 Prepare store listing: screenshots, description, privacy policy
- [ ] 18.21 Upload ke Play Store Internal Testing (Android)
- [ ] 18.22 Upload ke TestFlight (iOS, jika applicable)
