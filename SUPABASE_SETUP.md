# Setup Supabase untuk Hybrid Auth - Langkah Langkah

## ✅ Step 1: Dapatkan JWT Secret (WAJIB)

Project ID Anda: `bmibtqzfzavxcbeckqva`

### Cara mendapatkan JWT Secret:
1. Buka https://supabase.com/dashboard/project/bmibtqzfzavxcbeckqva/settings/api
2. Scroll ke bagian **JWT Settings**
3. Copy nilai **JWT Secret** (bukan anon key, bukan service role key)
4. JWT Secret terlihat seperti: `super-secret-jwt-token-with-at-least-32-characters`

### Update backend/.env:
```bash
SUPABASE_JWT_SECRET=paste-jwt-secret-anda-di-sini
```

## ✅ Step 2: Database Migration (SUDAH DIAPLIKASIKAN)

Migration "remove_password_hash_for_supabase_auth" telah diapply:
- Kolom `password_hash` di tabel `pengguna` sekarang nullable
- Setelah migrasi user selesai, kolom ini bisa dihapus

## ✅ Step 3: Setup Webhook untuk Auto-Sync User

### 3.1 Update Webhook Secret di backend/.env:
```bash
SUPABASE_WEBHOOK_SECRET=webhook-secret-random-string-2024
```

### 3.2 Buat Webhook di Supabase Dashboard:

**URL Dashboard**: https://supabase.com/dashboard/project/bmibtqzfzavxcbeckqva/database/hooks

**Langkah-langkah**:
1. Click **"Create a new hook"**
2. Isi form berikut:

**General:**
```
Name: auth_user_sync
       └─> Tidak boleh ada spasi!
```

**Conditions to fire webhook:**
```
Table: auth.users
       └─> Pilih dari dropdown

Events:
☑️ Insert  (Any insert operation on the table)
☑️ Update  (Any update operation, of any column in the table)
☑️ Delete  (Any deletion of a record)
```

**Webhook configuration:**
```
Type of webhook: HTTP Request

HTTP Request:
Method: POST
       └─> Pilih dari dropdown

URL: http://192.168.137.1:8080/api/webhooks/user-events
     └─> Ganti IP dengan IP komputer Anda jika berbeda

Timeout: 5000 ms
```

**HTTP Headers:**
```
Header 1:
  Name: Content-Type
  Value: application/json

Header 2:
  Name: X-Supabase-Signature
  Value: webhook-secret-random-string-2024
       └─> Harus sama dengan SUPABASE_WEBHOOK_SECRET di backend/.env
```

**HTTP Parameters:** (kosongkan, tidak perlu isi)

3. Click **"Create webhook"**

## ✅ Step 4: Enable Email Auth Provider (SUDAH AKTIF)

Status: Email Auth provider sudah enabled di project Anda.

## ✅ Step 5: Test Koneksi

### Test 1: Backend Compile
```bash
cd backend
go build -o main.exe .
```

### Test 2: Jalankan Backend
```bash
./main.exe
```

### Test 3: Test dari Flutter atau Dashboard
1. **Test INSERT**: Register user baru di Flutter app
   - Cek log backend - seharusnya menerima webhook dengan `type: INSERT`
   
2. **Test UPDATE**: Update user di Supabase dashboard (ganti nama atau metadata)
   - Cek log backend - seharusnya menerima webhook dengan `type: UPDATE`
   
3. **Test DELETE**: Hapus user (hati-hati, gunakan test account)
   - Cek log backend - seharusnya menerima webhook dengan `type: DELETE`

### Payload yang Dikirim Supabase:
```json
{
  "type": "INSERT",
  "table": "users",
  "record": {
    "id": "uuid-user",
    "email": "user@example.com",
    "raw_user_meta_data": {
      "nama": "John Doe",
      "peran": "pengguna"
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "old_record": null
}
```

## 🔐 Security Notes

1. **JWT Secret** jangan pernah di-commit ke git
2. **Webhook Secret** gunakan random string yang kuat dan sama antara backend .env dan Supabase dashboard
3. **SUPABASE_SERVICE_ROLE_KEY** hanya untuk backend, jangan untuk Flutter
4. **SUPABASE_ANON_KEY** untuk Flutter (sudah di .env)

## 📝 Summary File yang Perlu Diupdate

| File | Action |
|------|--------|
| `backend/.env` | Isi `SUPABASE_JWT_SECRET` dengan nilai dari dashboard |
| `backend/.env` | Pastikan `SUPABASE_WEBHOOK_SECRET=webhook-secret-random-string-2024` |
| Supabase Dashboard | Buat webhook `auth_user_sync` dengan 3 events |
