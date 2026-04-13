## ADDED Requirements

### Requirement: Sistem mengirim notifikasi saat status tiket berubah
Sistem SHALL membuat notifikasi dan mengirimkan ke pembuat tiket ketika status tiket berubah.

#### Scenario: Notifikasi status DIPROSES
- **GIVEN** tiket dengan status "TERBUKA"
- **WHEN** helpdesk mengubah status menjadi "DIPROSES"
- **THEN** sistem membuat notifikasi untuk pembuat tiket
- **AND** notifikasi berisi pesan "Tiket '[judul]' sedang diproses"
- **AND** notifikasi muncul di daftar notifikasi pengguna

#### Scenario: Notifikasi status SELESAI
- **GIVEN** tiket dengan status "DIPROSES"
- **WHEN** helpdesk mengubah status menjadi "SELESAI"
- **THEN** sistem membuat notifikasi untuk pembuat tiket
- **AND** notifikasi berisi pesan "Tiket '[judul]' telah selesai"
- **AND** menampilkan badge atau indikator notifikasi baru

### Requirement: Sistem mengirim notifikasi saat ada komentar baru
Sistem SHALL membuat notifikasi ketika ada komentar baru pada tiket.

#### Scenario: Notifikasi komentar dari helpdesk
- **GIVEN** pengguna memiliki tiket yang sedang diproses
- **WHEN** helpdesk menambahkan komentar pada tiket tersebut
- **THEN** sistem membuat notifikasi untuk pembuat tiket
- **AND** notifikasi berisi "Ada komentar baru pada tiket '[judul]'"
- **AND** menampilkan preview dari isi komentar

#### Scenario: Notifikasi komentar dari pembuat ke helpdesk
- **GIVEN** tiket ditugaskan ke helpdesk A
- **WHEN** pembuat tiket menambahkan komentar follow-up
- **THEN** sistem membuat notifikasi untuk helpdesk A
- **AND** notifikasi berisi "Pembuat tiket memberikan komentar baru"

### Requirement: Pengguna dapat melihat daftar notifikasi
Sistem SHALL menampilkan daftar notifikasi untuk pengguna yang sedang login, terurut dari yang terbaru.

#### Scenario: Melihat daftar notifikasi
- **GIVEN** pengguna memiliki beberapa notifikasi
- **WHEN** pengguna mengakses halaman notifikasi
- **THEN** sistem menampilkan semua notifikasi pengguna
- **AND** menampilkan tipe, pesan, waktu, dan status dibaca/belum
- **AND** notifikasi belum dibaca ditandai dengan indikator visual

#### Scenario: Notifikasi kosong
- **GIVEN** pengguna tidak memiliki notifikasi
- **WHEN** pengguna mengakses halaman notifikasi
- **THEN** sistem menampilkan pesan "Tidak ada notifikasi"

### Requirement: Pengguna dapat menandai notifikasi sebagai sudah dibaca
Sistem SHALL mengizinkan pengguna untuk menandai notifikasi individual atau semua notifikasi sebagai sudah dibaca.

#### Scenario: Menandai satu notifikasi sebagai dibaca
- **GIVEN** pengguna memiliki notifikasi belum dibaca
- **WHEN** pengguna menekan notifikasi atau tombol "Tandai dibaca"
- **THEN** sistem mengupdate status notifikasi menjadi sudah dibaca
- **AND** mengurangi badge counter notifikasi

#### Scenario: Menandai semua notifikasi sebagai dibaca
- **GIVEN** pengguna memiliki beberapa notifikasi belum dibaca
- **WHEN** pengguna menekan tombol "Tandai semua dibaca"
- **THEN** sistem mengupdate semua notifikasi pengguna menjadi sudah dibaca
- **AND** menghilangkan badge counter notifikasi

### Requirement: Real-time update notifikasi
Sistem SHALL mengupdate notifikasi secara real-time tanpa perlu refresh halaman.

#### Scenario: Notifikasi baru muncul real-time
- **GIVEN** pengguna sedang menggunakan aplikasi
- **WHEN** ada notifikasi baru untuk pengguna tersebut
- **THEN** sistem secara otomatis menampilkan notifikasi baru di daftar
- **AND** menampilkan toast atau banner notifikasi
- **AND** mengupdate badge counter notifikasi

#### Scenario: Push notification (opsional)
- **GIVEN** aplikasi berjalan di background atau foreground
- **WHEN** ada notifikasi baru
- **THEN** sistem menampilkan push notification di device
- **AND** pengguna dapat tap notifikasi untuk navigasi ke detail terkait

### Requirement: RLS untuk notifikasi
Sistem SHALL menerapkan RLS sehingga pengguna hanya dapat melihat notifikasi milik mereka sendiri.

#### Scenario: Pengguna hanya melihat notifikasi sendiri
- **GIVEN** pengguna A dan B memiliki notifikasi masing-masing
- **WHEN** pengguna A mengakses daftar notifikasi
- **THEN** sistem hanya menampilkan notifikasi milik pengguna A
- **AND** tidak menampilkan notifikasi milik pengguna B

#### Scenario: Query notifikasi orang lain ditolak
- **GIVEN** pengguna A mencoba query langsung ke tabel notifikasi
- **WHEN** query mencoba mengakses notifikasi dengan pengguna_id milik B
- **THEN** sistem tidak mengembalikan data (RLS policy)
