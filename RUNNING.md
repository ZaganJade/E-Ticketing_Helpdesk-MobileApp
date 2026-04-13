# 🚀 E-Ticketing Helpdesk - Running Documentation

Panduan lengkap menjalankan aplikasi E-Ticketing Helpdesk (Flutter + Golang Backend + Supabase).

---

## 📋 Prerequisites (Prasyarat)

### 1. Install Flutter
```bash
# Download Flutter dari https://docs.flutter.dev/get-started/install
# Extract ke C:\flutter (Windows) atau /opt/flutter (Linux/Mac)

# Tambahkan ke PATH
c:\flutter\bin  # Windows

# Verifikasi instalasi
flutter doctor
```

**Output yang diharapkan:**
- ✅ Flutter SDK
- ✅ Android toolchain
- ✅ Android Studio (atau VS Code)
- ✅ Connected device (emulator/physical)

### 2. Install Golang
```bash
# Download dari https://go.dev/dl/
# Install dengan installer

# Verifikasi
go version
# Output: go version go1.21.x windows/amd64
```

### 3. Install Supabase CLI
```bash
# Install via npm
npm install -g supabase

# Atau download binary langsung
# https://github.com/supabase/cli/releases

# Verifikasi
supabase --version
```

### 4. Setup Emulator/Device

**Option A: Android Emulator**
- Buka Android Studio → Device Manager
- Create Device → Pixel 6 → Android 14
- Start Emulator

**Option B: Physical Device**
- Enable Developer Options (Settings → About → Tap Build Number 7x)
- Enable USB Debugging
- Connect via USB → Allow debugging

---

## 🔧 Environment Setup

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd eticketinghelpdesk
```

### 2. Setup Flutter Environment

**Copy environment file:**
```bash
cd eticketinghelpdesk
copy .env.example .env
# atau
cp .env.example .env
```

**Isi `.env` file:**
```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...

# Backend API URL (Golang)
API_BASE_URL=http://localhost:8080/api

# Environment
debug=true
```

**Dapatkan Supabase credentials:**
1. Buka https://app.supabase.com
2. Pilih project
3. Settings → API
4. Copy `Project URL` dan `anon/public` key

### 3. Setup Backend Environment

```bash
cd backend
copy .env.example .env
# atau
cp .env.example .env
```

**Isi `.env` file:**
```env
# Server Configuration
PORT=8080
ENV=development

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIs...

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-min-32-chars

# Storage Configuration (opsional)
STORAGE_BUCKET=lampiran_tiket
MAX_UPLOAD_SIZE=10485760  # 10MB dalam bytes
```

**⚠️ Penting:**
- `SUPABASE_SERVICE_KEY` adalah **service_role key** (bukan anon key!)
- Dapatkan di: Supabase Dashboard → Settings → API → service_role key
- **JANGAN** commit key ini ke git!

---

## 🗄️ Database Setup (Supabase)

### 1. Setup Schema
```bash
cd supabase

# Login ke Supabase (jika belum)
supabase login

# Link project
supabase link --project-ref your-project-ref

# Jalankan migration
supabase db push

# Atau manual via SQL Editor di dashboard
cat schema.sql | pbcopy
# Paste ke Supabase Dashboard → SQL Editor → New query → Run
```

### 2. Seed Data (Opsional)
```bash
# Insert data test
supabase db seed

# Atau manual:
cat seed.sql | pbcopy
# Paste ke SQL Editor → Run
```

### 3. Enable Realtime
```bash
# Atau via Dashboard:
# Database → Replication → Realtime → Enable untuk tabel:
# - tiket
# - komentar
# - notifikasi
```

---

## ▶️ Menjalankan Backend (Golang)

### Terminal 1: Backend Server
```bash
cd backend

# Download dependencies
go mod tidy

# Jalankan server
go run main.go

# Atau dengan hot reload (install air dulu)
# go install github.com/cosmtrek/air@latest
air
```

**Output yang diharapkan:**
```
2024/xx/xx 03:23:28 Server starting on port 8080
2024/xx/xx 03:23:28 API endpoints available at http://localhost:8080/api
```

**Test API:**
```bash
# Test health check
curl http://localhost:8080/api/auth/login
# Response: 401 Unauthorized (expected, karena perlu auth)
```

---

## 📱 Menjalankan Flutter App

### Terminal 2: Flutter
```bash
cd eticketinghelpdesk  # root project

# Download dependencies
flutter pub get

# Build generated files (jika pakai build_runner)
# flutter pub run build_runner build

# Jalankan app
flutter run

# Atau spesifik device
flutter run -d emulator-5554
flutter run -d "iPhone 14 Pro"
```

**Output yang diharapkan:**
```
Launching lib/main.dart on sdk gphone64 x86 64 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app-debug.apk...
Syncing files to device sdk gphone64 x86 64...
```

---

## 🔄 Running Both (Flutter + Backend)

### Urutan Menjalankan:

1. **Start Supabase** (cloud/online)
   - Pastikan project Supabase aktif di https://app.supabase.com

2. **Start Backend** (Terminal 1)
   ```bash
   cd backend
   go run main.go
   ```

3. **Start Flutter** (Terminal 2)
   ```bash
   cd eticketinghelpdesk
   flutter run
   ```

### Verifikasi Koneksi:

**Cek Backend terkoneksi ke Supabase:**
```bash
curl http://localhost:8080/api/dashboard/stats
# Response: 401 (perlu login) → Berarti backend jalan
```

**Cek Flutter terkoneksi:**
- Splash screen muncul → Auto-check auth
- Login page muncul (jika belum login) → OK
- Dashboard muncul (jika sudah login) → OK

---

## 🧪 Testing Checklist

### 1. Auth Flow
```bash
# Register → Login → Logout
# Test file: test/auth_flow_test.dart (jika ada)
flutter test test/auth_flow_test.dart
```

### 2. Tiket Flow
```bash
# Buat tiket → Detail → Tambah komentar
flutter test test/tiket_flow_test.dart
```

### 3. Manual Testing
- [ ] Register akun baru
- [ ] Login dengan akun tersebut
- [ ] Buat tiket baru
- [ ] Upload lampiran
- [ ] Beri komentar
- [ ] Check realtime (buka 2 emulator)
- [ ] Logout

---

## 🐛 Troubleshooting

### Error 1: `flutter doctor` shows issues
```bash
# Install Android SDK Command Line Tools
# Android Studio → SDK Manager → SDK Tools → Android SDK Command-line Tools

# Accept licenses
flutter doctor --android-licenses
```

### Error 2: Backend port already in use
```bash
# Kill process di port 8080
# Windows:
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac:
lsof -ti:8080 | xargs kill -9

# Atau ganti port di .env
PORT=8081
```

### Error 3: Supabase connection failed
```bash
# Check URL dan Key
cat .env

# Test dengan curl
curl https://your-project.supabase.co/rest/v1/pengguna \
  -H "apikey: your-anon-key"
```

### Error 4: `go mod tidy` fails
```bash
# Clear module cache
go clean -modcache
go mod tidy
```

### Error 5: Flutter stuck at "Running Gradle task"
```bash
# Clear Gradle cache
cd android
./gradlew clean  # Linux/Mac
gradlew clean    # Windows

# Atau
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
eticketinghelpdesk/
├── lib/                    # Flutter app
│   ├── core/              # Router, theme, utils
│   ├── features/          # Auth, Tiket, Komentar, dll
│   └── shared/            # Widgets reusable
│
├── backend/               # Golang backend
│   ├── delivery/          # HTTP handlers
│   ├── entities/          # Domain models
│   ├── interfaces/        # Repository interfaces
│   ├── repository/        # Supabase implementations
│   ├── usecases/          # Business logic
│   └── main.go            # Entry point
│
├── supabase/              # Database schema
│   ├── schema.sql         # Table definitions
│   ├── seed.sql           # Test data
│   └── storage_policies.sql
│
├── android/               # Android-specific
├── ios/                   # iOS-specific
├── test/                  # Flutter tests
├── .env                   # Environment variables
└── pubspec.yaml           # Flutter dependencies
```

---

## 📝 Development Workflow

### Daily Development:
```bash
# 1. Start Supabase (cloud - always on)

# 2. Terminal 1 - Backend
cd backend
go run main.go

# 3. Terminal 2 - Flutter
cd eticketinghelpdesk
flutter run

# 4. Coding...
# Hot reload: Save file (Ctrl+S) atau tekan `r` di terminal
# Hot restart: tekan `R` di terminal
# Quit: tekan `q`
```

### Backend Development (with hot reload):
```bash
# Install air (one time)
go install github.com/cosmtrek/air@latest

# Run dengan hot reload
cd backend
air
```

---

## 🌐 API Endpoints Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | ❌ | Register user |
| POST | `/api/auth/login` | ❌ | Login |
| POST | `/api/auth/logout` | ✅ | Logout |
| GET | `/api/auth/me` | ✅ | Get current user |
| GET | `/api/dashboard/stats` | ✅ | Dashboard statistics |
| GET | `/api/tikets` | ✅ | List tiket |
| POST | `/api/tikets` | ✅ | Create tiket |
| GET | `/api/tikets/:id` | ✅ | Detail tiket |
| PATCH | `/api/tikets/:id/status` | ✅ | Update status |
| POST | `/api/tikets/:id/assign` | ✅ | Assign tiket |
| POST | `/api/tikets/:id/komentars` | ✅ | Add komentar |
| POST | `/api/tikets/:id/lampirans/upload` | ✅ | Upload file |
| GET | `/api/tikets/:id/lampirans/:id/download` | ✅ | Download file |
| DELETE | `/api/tikets/:id/lampirans/:id` | ✅ | Delete file |
| GET | `/api/notifikasis` | ✅ | List notifikasi |
| PATCH | `/api/notifikasis/:id/read` | ✅ | Mark read |
| PATCH | `/api/notifikasis/read-all` | ✅ | Mark all read |

---

## ✅ Success Criteria

Aplikasi berjalan dengan baik jika:
- ✅ Backend: `http://localhost:8080/api/dashboard/stats` return 401 (not 404)
- ✅ Flutter: Splash screen muncul, navigasi ke Login/Dashboard berjalan
- ✅ Login: User bisa login dengan kredensial valid
- ✅ Tiket: User bisa buat tiket baru
- ✅ Realtime: Komentar muncul otomatis di device lain
- ✅ Upload: File bisa diupload dan didownload

---

## 📞 Support

Jika ada error:
1. Check `flutter doctor`
2. Check `go version`
3. Check `.env` configuration
4. Check Supabase dashboard (project active?)
5. Check port conflicts (8080)

Happy coding! 🚀


./server.exe