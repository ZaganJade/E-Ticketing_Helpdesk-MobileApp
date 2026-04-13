# Environment Setup Guide

Panduan setup environment variables untuk E-Ticketing Helpdesk Flutter App.

## 📁 File Environment

Project menggunakan beberapa file environment:

| File | Kegunaan |
|------|----------|
| `.env` | Production environment (default) |
| `.env.development` | Development environment |
| `.env.example` | Template untuk reference |

## ⚙️ Setup Supabase

### 1. Supabase Configuration

File `.env` sudah terkonfigurasi dengan project Supabase:

```env
SUPABASE_URL=https://bmibtqzfzavxcbeckqva.supabase.co
SUPABASE_ANON_KEY=sb_publishable_3b9hcdvBn_kx6yxDS9VTBw_x7PCK1cH
```

**Project Details:**
- **Project Name:** E-Ticketing Helpdesk
- **Region:** ap-northeast-2 (Seoul)
- **Status:** ACTIVE_HEALTHY

### 2. Backend API Configuration

Update `API_BASE_URL` saat backend Golang sudah di-deploy:

```env
# Local Development
API_BASE_URL=http://localhost:8080/api

# Production (update dengan URL deploy backend)
API_BASE_URL=https://your-backend-domain.com/api
```

## 🚀 Run App dengan Environment Berbeda

### Default (Production)
```bash
flutter run
```

### Development Mode
```bash
flutter run --dart-define=ENV=.env.development
```

### Production Build
```bash
flutter build apk --release
# atau
flutter build ios --release
```

## 🔒 Security Notes

1. **Jangan commit file `.env`** - Sudah di-exclude di `.gitignore`
2. **Gunakan publishable key** - Key yang digunakan (`sb_publishable_...`) adalah publishable key yang lebih aman
3. **Rotate keys** - Jika key bocor, regenerate via Supabase Dashboard

## 📊 Database Schema

Database sudah setup dengan 5 tabel:
- `pengguna` - Data user
- `tiket` - Data tiket
- `komentar` - Komentar pada tiket
- `notifikasi` - Notifikasi user
- `lampiran` - Metadata file lampiran

### RLS Policies
- User hanya lihat tiket miliknya
- Helpdesk/Admin lihat semua tiket
- Realtime enabled untuk live updates

## 🛠️ Troubleshooting

### Error: "SUPABASE_URL not found"
Pastikan file `.env` ada di root project dan berisi:
```env
SUPABASE_URL=https://bmibtqzfzavxcbeckqva.supabase.co
SUPABASE_ANON_KEY=sb_publishable_3b9hcdvBn_kx6yxDS9VTBw_x7PCK1cH
```

### Error: "Cannot load .env"
Pastikan `pubspec.yaml` sudah include:
```yaml
flutter:
  assets:
    - .env
```

Kemudian run:
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Related Files

- `lib/core/config/app_config.dart` - App configuration loader
- `lib/core/services/supabase_service.dart` - Supabase client
- `lib/main.dart` - Entry point dengan initialization
