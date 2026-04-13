## Why

Proses pelaporan masalah IT saat ini tidak terstruktur, tidak memiliki sistem pelacakan yang jelas, dan tidak menyediakan komunikasi terpusat antara pelapor dan tim helpdesk. Hal ini menyebabkan status tiket tidak transparan, proses penyelesaian sulit dimonitor, serta komunikasi tidak terdokumentasi dengan baik. Aplikasi E-Ticketing Helpdesk dibuat untuk menyediakan sistem pelaporan berbasis tiket yang terstandarisasi dengan pelacakan status real-time.

## What Changes

- **Aplikasi mobile Flutter** untuk sistem pelaporan dan manajemen tiket IT dengan UI/UX yang polished
- **Backend API Golang** dengan arsitektur Clean Architecture untuk business logic
- **Integrasi Supabase** untuk autentikasi, database PostgreSQL, realtime updates, dan file storage
- **Sistem tiket** dengan status TERBUKA → DIPROSES → SELESAI
- **Sistem notifikasi real-time** untuk perubahan status dan komentar baru
- **Dashboard** dengan statistik tiket berdasarkan status
- **Upload lampiran** menggunakan Supabase Storage
- **Design System UI/UX** komprehensif: 8 screens, 20+ components, dark mode support, design tokens

## Capabilities

### New Capabilities
- `auth`: Autentikasi pengguna (login, registrasi, logout, reset password) menggunakan Supabase Auth
- `tiket`: Manajemen tiket (membuat, melihat, mengubah status, menugaskan) dengan RLS
- `komentar`: Sistem komentar pada tiket untuk komunikasi terpusat
- `notifikasi`: Notifikasi real-time saat status berubah atau ada komentar baru
- `dashboard`: Dashboard dengan statistik dan overview tiket
- `lampiran`: Upload dan manajemen file lampiran tiket menggunakan Supabase Storage

### Modified Capabilities
- *(none - new project)*

## Impact

- **Database**: PostgreSQL via Supabase dengan tabel pengguna, tiket, komentar, dan notifikasi
- **Mobile App**: Aplikasi Flutter mendukung Android dan iOS dengan UI component-based (shadcn-style)
- **UI/UX**: 8 screens (Splash, Login/Register, Dashboard, Tiket List, Tiket Detail, Buat Tiket, Notifikasi, Profil), design system dengan 20+ reusable components, dark mode support
- **Backend**: RESTful API Golang untuk business logic dan orkestrasi
- **Security**: Row Level Security (RLS) pada Supabase untuk kontrol akses
- **Storage**: Supabase Storage bucket `lampiran_tiket` untuk file attachments
- **Design Tokens**: Standardized spacing (4-48px), typography scale, color palette untuk consistency
