## ADDED Requirements

### Requirement: Pengguna dapat memberikan komentar pada tiket mereka
Sistem SHALL mengizinkan pembuat tiket untuk menambahkan komentar pada tiket miliknya.

#### Scenario: Menambahkan komentar pada tiket sendiri
- **GIVEN** pengguna sedang melihat detail tiket yang mereka buat
- **WHEN** pengguna mengetik pesan di form komentar dan menekan submit
- **THEN** sistem menyimpan komentar dengan penulis_id pengguna tersebut
- **AND** komentar muncul di daftar komentar tiket
- **AND** notifikasi dikirim ke helpdesk yang menangani (jika ada)

#### Scenario: Menambahkan komentar dengan pesan kosong
- **GIVEN** pengguna sedang melihat detail tiket
- **WHEN** pengguna mencoba submit komentar tanpa isi
- **THEN** sistem menampilkan error "Pesan tidak boleh kosong"
- **AND** komentar tidak disimpan

### Requirement: Helpdesk dapat memberikan komentar pada tiket yang ditangani
Sistem SHALL mengizinkan helpdesk untuk menambahkan komentar pada tiket yang ditugaskan kepada mereka atau semua tiket (jika admin).

#### Scenario: Helpdesk memberikan respon pada tiket
- **GIVEN** tiket ditugaskan ke helpdesk A
- **WHEN** helpdesk A menambahkan komentar dengan solusi atau update
- **THEN** sistem menyimpan komentar
- **AND** mengirim notifikasi ke pembuat tiket
- **AND** komentar ditandai sebagai dari "Helpdesk"

#### Scenario: Admin memberikan komentar pada semua tiket
- **GIVEN** pengguna dengan peran "admin"
- **WHEN** admin menambahkan komentar pada tiket apapun
- **THEN** sistem menyimpan komentar
- **AND** komentar ditandai sebagai dari "Admin"

### Requirement: Sistem menampilkan daftar komentar pada tiket
Sistem SHALL menampilkan semua komentar pada tiket, terurut dari yang paling lama ke paling baru (oldest first).

#### Scenario: Melihat riwayat komentar
- **GIVEN** tiket memiliki beberapa komentar
- **WHEN** pengguna membuka detail tiket
- **THEN** sistem menampilkan semua komentar dalam urutan kronologis
- **AND** menampilkan nama penulis, isi pesan, dan waktu komentar

#### Scenario: Update real-time komentar baru
- **GIVEN** pengguna sedang melihat detail tiket
- **WHEN** ada komentar baru ditambahkan oleh helpdesk
- **THEN** sistem secara otomatis menampilkan komentar baru tanpa refresh
- **AND** menampilkan indikator "Komentar baru"

### Requirement: RLS untuk komentar
Sistem SHALL menerapkan RLS sehingga komentar hanya dapat diakses melalui relasi tiket yang diizinkan.

#### Scenario: Pengguna melihat komentar pada tiket mereka
- **GIVEN** pengguna memiliki tiket dengan beberapa komentar
- **WHEN** pengguna mengakses detail tiket
- **THEN** sistem menampilkan semua komentar pada tiket tersebut

#### Scenario: Pengguna tidak melihat komentar tiket orang lain
- **GIVEN** tiket milik pengguna A dengan komentar
- **WHEN** pengguna B mencoba query langsung ke tabel komentar
- **THEN** sistem hanya mengembalikan komentar dari tiket milik pengguna B (jika ada)
- **AND** tidak mengembalikan komentar dari tiket pengguna A
