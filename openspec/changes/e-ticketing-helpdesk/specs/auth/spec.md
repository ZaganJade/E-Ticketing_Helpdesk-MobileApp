## ADDED Requirements

### Requirement: Pengguna dapat melakukan registrasi
Sistem SHALL mengizinkan pengguna baru untuk mendaftar dengan nama, email, dan password. Password SHALL di-hash sebelum disimpan.

#### Scenario: Registrasi berhasil dengan data valid
- **WHEN** pengguna mengisi form registrasi dengan nama, email valid, dan password minimal 8 karakter
- **THEN** sistem membuat akun pengguna baru dengan peran default "pengguna"
- **AND** sistem mengirimkan email konfirmasi (jika diaktifkan)
- **AND** pengguna diarahkan ke halaman login

#### Scenario: Registrasi gagal dengan email yang sudah terdaftar
- **WHEN** pengguna mengisi form registrasi dengan email yang sudah terdaftar
- **THEN** sistem menampilkan error "Email sudah terdaftar"
- **AND** akun tidak dibuat

#### Scenario: Registrasi gagal dengan password yang terlalu pendek
- **WHEN** pengguna mengisi form registrasi dengan password kurang dari 8 karakter
- **THEN** sistem menampilkan error "Password minimal 8 karakter"
- **AND** akun tidak dibuat

### Requirement: Pengguna dapat melakukan login
Sistem SHALL mengizinkan pengguna untuk login dengan email dan password yang valid. Sistem SHALL mengembalikan JWT token untuk session management.

#### Scenario: Login berhasil dengan kredensial valid
- **WHEN** pengguna memasukkan email dan password yang benar
- **THEN** sistem mengembalikan JWT token dan data pengguna (id, nama, email, peran)
- **AND** pengguna diarahkan ke dashboard

#### Scenario: Login gagal dengan password salah
- **WHEN** pengguna memasukkan email yang benar tetapi password salah
- **THEN** sistem menampilkan error "Email atau password salah"
- **AND** token tidak diberikan

#### Scenario: Login gagal dengan email tidak terdaftar
- **WHEN** pengguna memasukkan email yang tidak terdaftar
- **THEN** sistem menampilkan error "Email atau password salah"
- **AND** token tidak diberikan (sama dengan password salah untuk security)

### Requirement: Pengguna dapat melakukan logout
Sistem SHALL mengizinkan pengguna untuk logout dan invalidate session/token mereka.

#### Scenario: Logout berhasil
- **WHEN** pengguna yang sudah login menekan tombol logout
- **THEN** sistem menghapus session/token pengguna
- **AND** pengguna diarahkan ke halaman login

### Requirement: Pengguna dapat melakukan reset password
Sistem SHALL menyediakan mekanisme reset password melalui email.

#### Scenario: Request reset password dengan email terdaftar
- **WHEN** pengguna memasukkan email terdaftar di form reset password
- **THEN** sistem mengirimkan email dengan link/token reset password
- **AND** menampilkan pesan "Link reset password telah dikirim ke email"

#### Scenario: Reset password dengan token valid
- **WHEN** pengguna mengakses link reset dengan token valid dan memasukkan password baru
- **THEN** sistem mengupdate password pengguna
- **AND** menampilkan pesan sukses dan mengarahkan ke login

#### Scenario: Request reset password dengan email tidak terdaftar
- **WHEN** pengguna memasukkan email tidak terdaftar di form reset password
- **THEN** sistem menampilkan pesan yang sama dengan email terdaftar (security through obscurity)
- **AND** tidak ada email yang dikirim

### Requirement: Role-based access control
Sistem SHALL memiliki tiga peran pengguna: pengguna, helpdesk, dan admin. Setiap peran memiliki hak akses yang berbeda.

#### Scenario: Akses dashboard pengguna
- **GIVEN** pengguna dengan peran "pengguna" sudah login
- **WHEN** pengguna mengakses dashboard
- **THEN** sistem hanya menampilkan tiket milik pengguna tersebut

#### Scenario: Akses dashboard helpdesk
- **GIVEN** pengguna dengan peran "helpdesk" sudah login
- **WHEN** helpdesk mengakses dashboard
- **THEN** sistem menampilkan semua tiket dengan filter dan search
- **AND** helpdesk dapat menugaskan dan mengubah status tiket

#### Scenario: Akses dashboard admin
- **GIVEN** pengguna dengan peran "admin" sudah login
- **WHEN** admin mengakses dashboard
- **THEN** sistem menampilkan semua tiket dan statistik sistem
- **AND** admin dapat mengelola pengguna dan konfigurasi

### Requirement: Token refresh
Sistem SHALL secara otomatis refresh JWT token sebelum expired untuk menjaga session pengguna.

#### Scenario: Token refresh otomatis
- **GIVEN** pengguna sudah login dengan JWT token
- **WHEN** token hampir expired dan pengguna masih aktif
- **THEN** sistem secara otomatis refresh token tanpa mengganggu pengguna

#### Scenario: Redirect ke login saat token invalid
- **GIVEN** pengguna sudah login
- **WHEN** token invalid atau expired dan tidak dapat di-refresh
- **THEN** sistem mengarahkan pengguna ke halaman login
- **AND** menampilkan pesan "Sesi telah berakhir, silakan login kembali"
