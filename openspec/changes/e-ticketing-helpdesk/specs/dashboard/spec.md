## ADDED Requirements

### Requirement: Dashboard menampilkan total tiket
Sistem SHALL menampilkan total jumlah tiket berdasarkan hak akses pengguna.

#### Scenario: Pengguna melihat total tiket mereka
- **GIVEN** pengguna dengan peran "pengguna" sudah login
- **WHEN** pengguna mengakses dashboard
- **THEN** sistem menampilkan total jumlah tiket milik pengguna
- **AND** menampilkan breakdown berdasarkan status (TERBUKA, DIPROSES, SELESAI)

#### Scenario: Helpdesk melihat total semua tiket
- **GIVEN** pengguna dengan peran "helpdesk" sudah login
- **WHEN** helpdesk mengakses dashboard
- **THEN** sistem menampilkan total jumlah semua tiket di sistem
- **AND** menampilkan breakdown berdasarkan status

### Requirement: Dashboard menampilkan tiket terbaru
Sistem SHALL menampilkan daftar tiket terbaru di dashboard untuk akses cepat.

#### Scenario: Pengguna melihat tiket terbaru
- **GIVEN** pengguna memiliki beberapa tiket
- **WHEN** pengguna mengakses dashboard
- **THEN** sistem menampilkan 5 tiket terbaru milik pengguna
- **AND** menampilkan judul, status, dan tanggal pembuatan

#### Scenario: Tiket terbaru update real-time
- **GIVEN** pengguna sedang melihat dashboard
- **WHEN** pengguna membuat tiket baru
- **THEN** sistem secara otomatis menambahkan tiket baru ke daftar tiket terbaru
- **AND** mengupdate total counter

### Requirement: Dashboard menampilkan statistik visual
Sistem SHALL menampilkan representasi visual dari statistik tiket (chart atau progress indicators).

#### Scenario: Menampilkan progress statistik
- **GIVEN** pengguna mengakses dashboard
- **WHEN** dashboard load
- **THEN** sistem menampilkan visualisasi proporsi tiket berdasarkan status
- **AND** menggunakan progress bar atau pie chart

#### Scenario: Statistik kosong
- **GIVEN** pengguna belum memiliki tiket
- **WHEN** pengguna mengakses dashboard
- **THEN** sistem menampilkan empty state dengan ilustrasi
- **AND** menampilkan call-to-action untuk membuat tiket pertama

### Requirement: Helpdesk dashboard menampilkan tiket yang perlu ditangani
Sistem SHALL menampilkan tiket dengan status "TERBUKA" yang belum ditugaskan untuk helpdesk.

#### Scenario: Helpdesk melihat tiket terbuka
- **GIVEN** terdapat tiket dengan status "TERBUKA" belum ditugaskan
- **WHEN** helpdesk mengakses dashboard
- **THEN** sistem menampilkan daftar tiket TERBUKA yang perlu ditangani
- **AND** menampilkan tombol "Ambil Tiket" untuk setiap tiket

#### Scenario: Helpdesk melihat tiket yang ditugaskan ke mereka
- **GIVEN** helpdesk memiliki tiket yang sedang diproses
- **WHEN** helpdesk mengakses dashboard
- **THEN** sistem menampilkan daftar tiket yang sedang ditangani oleh helpdesk tersebut
- **AND** menandai tiket yang mendekati deadline (jika ada SLA)

### Requirement: Admin dashboard menampilkan overview sistem
Sistem SHALL menampilkan statistik keseluruhan sistem untuk admin.

#### Scenario: Admin melihat statistik pengguna
- **GIVEN** pengguna dengan peran "admin" sudah login
- **WHEN** admin mengakses dashboard
- **THEN** sistem menampilkan total jumlah pengguna per peran
- **AND** menampilkan total jumlah tiket per status

#### Scenario: Admin melihat performa helpdesk
- **GIVEN** admin mengakses dashboard
- **WHEN** dashboard load
- **THEN** sistem menampilkan statistik penyelesaian tiket per helpdesk
- **AND** menampilkan rata-rata waktu penyelesaian

### Requirement: Dashboard dengan loading state
Sistem SHALL menampilkan skeleton loading saat data dashboard sedang dimuat.

#### Scenario: Loading dashboard
- **GIVEN** pengguna mengakses dashboard
- **WHEN** data sedang di-fetch dari server
- **THEN** sistem menampilkan skeleton placeholders untuk cards dan charts
- **AND** menampilkan shimmer effect

#### Scenario: Error loading dashboard
- **GIVEN** terjadi error saat mengambil data dashboard
- **WHEN** request gagal
- **THEN** sistem menampilkan error message dengan tombol retry
- **AND** tidak menampilkan data partial atau corrupted
