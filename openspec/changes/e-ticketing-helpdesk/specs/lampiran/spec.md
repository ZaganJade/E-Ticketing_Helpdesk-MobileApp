## ADDED Requirements

### Requirement: Pengguna dapat mengupload file lampiran saat membuat tiket
Sistem SHALL mengizinkan pengguna untuk mengupload file sebagai lampiran saat membuat tiket baru.

#### Scenario: Upload lampiran saat membuat tiket
- **GIVEN** pengguna sedang mengisi form tiket
- **WHEN** pengguna memilih file dari device dan submit form
- **THEN** sistem mengupload file ke Supabase Storage bucket "lampiran_tiket"
- **AND** menyimpan referensi file (path, filename, size, type) di database
- **AND** mengaitkan lampiran dengan tiket yang dibuat

#### Scenario: Upload lampiran dengan format yang diizinkan
- **GIVEN** pengguna memilih file dengan format yang diizinkan (jpg, png, pdf, doc, docx)
- **WHEN** pengguna submit form tiket
- **THEN** sistem menerima dan menyimpan file
- **AND** menampilkan preview thumbnail untuk image files

#### Scenario: Upload lampiran dengan format tidak diizinkan
- **GIVEN** pengguna memilih file dengan format tidak diizinkan (exe, zip besar)
- **WHEN** pengguna mencoba submit
- **THEN** sistem menampilkan error "Format file tidak diizinkan"
- **AND** tiket tidak dibuat sampai file tidak valid dihapus

#### Scenario: Upload lampiran melebihi ukuran maksimum
- **GIVEN** pengguna memilih file dengan ukuran > 10MB
- **WHEN** pengguna mencoba submit
- **THEN** sistem menampilkan error "Ukuran file maksimal 10MB"
- **AND** menyarankan untuk compress file atau upload link external

### Requirement: Pengguna dapat melihat lampiran pada detail tiket
Sistem SHALL menampilkan daftar lampiran yang terkait dengan tiket.

#### Scenario: Melihat lampiran pada tiket
- **GIVEN** tiket memiliki satu atau lebih lampiran
- **WHEN** pengguna membuka detail tiket
- **THEN** sistem menampilkan daftar lampiran dengan nama file dan ukuran
- **AND** menampilkan icon berdasarkan tipe file

#### Scenario: Preview image lampiran
- **GIVEN** tiket memiliki lampiran berupa image
- **WHEN** pengguna menekan image thumbnail
- **THEN** sistem menampilkan full-size preview dalam modal
- **AND** pengguna dapat zoom dan pan image

#### Scenario: Download lampiran
- **GIVEN** pengguna sedang melihat detail tiket dengan lampiran
- **WHEN** pengguna menekan tombol download pada lampiran
- **THEN** sistem menggenerate signed URL dari Supabase Storage
- **AND** memulai download file ke device pengguna

### Requirement: Helpdesk dapat mengupload lampiran pada tiket
Sistem SHALL mengizinkan helpdesk untuk menambahkan lampiran pada tiket (misal: screenshot solusi, dokumen panduan).

#### Scenario: Helpdesk upload lampiran solusi
- **GIVEN** helpdesk sedang menangani tiket
- **WHEN** helpdesk menambahkan komentar dengan lampiran
- **THEN** sistem mengupload file lampiran
- **AND** mengaitkan lampiran dengan tiket dan komentar
- **AND** notifikasi ke pembuat tiket mencakup informasi lampiran baru

### Requirement: Menghapus lampiran
Sistem SHALL mengizinkan pengguna untuk menghapus lampiran yang mereka upload (sebelum tiket diproses) atau admin dapat menghapus lampiran apapun.

#### Scenario: Pengguna menghapus lampiran sendiri
- **GIVEN** tiket dengan status "TERBUKA" memiliki lampiran dari pembuat
- **WHEN** pembuat menekan tombol hapus pada lampiran
- **THEN** sistem menghapus file dari Supabase Storage
- **AND** menghapus referensi dari database
- **AND** menampilkan konfirmasi "Lampiran berhasil dihapus"

#### Scenario: Tidak dapat menghapus lampiran tiket yang sudah diproses
- **GIVEN** tiket dengan status "DIPROSES" atau "SELESAI"
- **WHEN** pembuat mencoba menghapus lampiran
- **THEN** sistem menolak dengan pesan "Tidak dapat menghapus lampiran pada tiket yang sedang/sudah diproses"
- **AND** hanya admin yang dapat menghapus dalam kondisi ini

### Requirement: Storage policies untuk lampiran
Sistem SHALL menerapkan access policies pada Supabase Storage bucket "lampiran_tiket".

#### Scenario: Pengguna dapat mengakses lampiran tiket mereka
- **GIVEN** pengguna memiliki tiket dengan lampiran
- **WHEN** pengguna mencoba download lampiran
- **THEN** sistem mengizinkan akses dan mengembalikan file

#### Scenario: Helpdesk dapat mengakses semua lampiran
- **GIVEN** helpdesk mengakses tiket manapun
- **WHEN** helpdesk mencoba download lampiran tiket
- **THEN** sistem mengizinkan akses karena helpdesk memiliki hak akses ke tiket

#### Scenario: Pengguna tidak dapat mengakses lampiran tiket orang lain
- **GIVEN** pengguna A memiliki tiket dengan lampiran
- **WHEN** pengguna B (bukan helpdesk/admin) mencoba akses lampiran
- **THEN** sistem menolak akses dengan error 403
