## ADDED Requirements

### Requirement: Pengguna dapat membuat tiket baru
Sistem SHALL mengizinkan pengguna yang sudah login untuk membuat tiket baru dengan judul dan deskripsi. Tiket baru SHALL memiliki status default "TERBUKA".

#### Scenario: Membuat tiket berhasil dengan data lengkap
- **WHEN** pengguna mengisi form tiket dengan judul dan deskripsi
- **THEN** sistem membuat tiket baru dengan status "TERBUKA"
- **AND** mengaitkan tiket dengan pengguna yang membuatnya
- **AND** menampilkan detail tiket yang baru dibuat
- **AND** tiket muncul di daftar tiket pengguna

#### Scenario: Membuat tiket gagal dengan judul kosong
- **WHEN** pengguna mengisi form tiket dengan judul kosong
- **THEN** sistem menampilkan error "Judul wajib diisi"
- **AND** tiket tidak dibuat

#### Scenario: Membuat tiket gagal dengan deskripsi kosong
- **WHEN** pengguna mengisi form tiket dengan deskripsi kosong
- **THEN** sistem menampilkan error "Deskripsi wajib diisi"
- **AND** tiket tidak dibuat

#### Scenario: Membuat tiket dengan lampiran
- **GIVEN** pengguna sedang mengisi form tiket
- **WHEN** pengguna mengupload file lampiran dan submit form
- **THEN** sistem membuat tiket baru
- **AND** menyimpan file lampiran di Supabase Storage
- **AND** mengaitkan lampiran dengan tiket

### Requirement: Pengguna dapat melihat daftar tiket mereka
Sistem SHALL menampilkan daftar tiket milik pengguna yang sedang login, terurut berdasarkan tanggal pembuatan terbaru.

#### Scenario: Melihat daftar tiket dengan data
- **GIVEN** pengguna memiliki beberapa tiket
- **WHEN** pengguna mengakses halaman daftar tiket
- **THEN** sistem menampilkan semua tiket milik pengguna
- **AND** menampilkan judul, status, dan tanggal pembuatan untuk setiap tiket
- **AND** tiket diurutkan dari yang terbaru

#### Scenario: Melihat daftar tiket kosong
- **GIVEN** pengguna belum memiliki tiket
- **WHEN** pengguna mengakses halaman daftar tiket
- **THEN** sistem menampilkan pesan "Belum ada tiket. Buat tiket pertama Anda."
- **AND** menampilkan tombol untuk membuat tiket baru

#### Scenario: Filter tiket berdasarkan status
- **GIVEN** pengguna memiliki tiket dengan berbagai status
- **WHEN** pengguna memilih filter status "TERBUKA"
- **THEN** sistem hanya menampilkan tiket dengan status "TERBUKA"

### Requirement: Pengguna dapat melihat detail tiket
Sistem SHALL menampilkan detail lengkap tiket termasuk judul, deskripsi, status, pembuat, penanggung jawab, tanggal pembuatan, dan riwayat komentar.

#### Scenario: Melihat detail tiket lengkap
- **WHEN** pengguna memilih tiket dari daftar
- **THEN** sistem menampilkan detail lengkap tiket
- **AND** menampilkan semua komentar pada tiket tersebut
- **AND** menampilkan lampiran jika ada

#### Scenario: Update real-time pada detail tiket
- **GIVEN** pengguna sedang melihat detail tiket
- **WHEN** ada perubahan pada tiket (status, komentar baru) oleh helpdesk
- **THEN** sistem secara otomatis memperbarui tampilan tanpa refresh
- **AND** menampilkan notifikasi perubahan

### Requirement: Helpdesk dapat melihat semua tiket
Sistem SHALL mengizinkan pengguna dengan peran helpdesk atau admin untuk melihat semua tiket di sistem, bukan hanya milik mereka.

#### Scenario: Helpdesk melihat semua tiket
- **GIVEN** pengguna dengan peran "helpdesk" sudah login
- **WHEN** helpdesk mengakses halaman daftar tiket
- **THEN** sistem menampilkan semua tiket dari semua pengguna
- **AND** menampilkan informasi pembuat tiket

#### Scenario: Search dan filter tiket
- **GIVEN** helpdesk sedang melihat daftar semua tiket
- **WHEN** helpdesk memasukkan kata kunci di search box
- **THEN** sistem menampilkan hanya tiket yang mengandung kata kunci di judul atau deskripsi

### Requirement: Helpdesk dapat menugaskan tiket
Sistem SHALL mengizinkan helpdesk untuk menugaskan tiket kepada diri mereka sendiri atau helpdesk lain.

#### Scenario: Menugaskan tiket ke diri sendiri
- **GIVEN** tiket dengan status "TERBUKA" belum ditugaskan
- **WHEN** helpdesk menekan tombol "Ambil Tiket"
- **THEN** sistem mengupdate field ditugaskan_kepada dengan ID helpdesk
- **AND** mengubah status menjadi "DIPROSES"
- **AND** mengirim notifikasi ke pembuat tiket

#### Scenario: Menugaskan tiket ke helpdesk lain
- **GIVEN** tiket belum ditugaskan atau sudah ditugaskan
- **WHEN** admin memilih helpdesk lain dari dropdown assignment
- **THEN** sistem mengupdate field ditugaskan_kepada
- **AND** mengirim notifikasi ke helpdesk yang ditugaskan

### Requirement: Helpdesk dan admin dapat mengubah status tiket
Sistem SHALL mengizinkan helpdesk dan admin untuk mengubah status tiket sesuai workflow yang valid.

#### Scenario: Mengubah status dari TERBUKA ke DIPROSES
- **GIVEN** tiket dengan status "TERBUKA"
- **WHEN** helpdesk mengubah status menjadi "DIPROSES"
- **THEN** sistem mengupdate status tiket
- **AND** mencatat timestamp perubahan
- **AND** mengirim notifikasi ke pembuat tiket

#### Scenario: Mengubah status dari DIPROSES ke SELESAI
- **GIVEN** tiket dengan status "DIPROSES"
- **WHEN** helpdesk mengubah status menjadi "SELESAI"
- **THEN** sistem mengupdate status tiket
- **AND** mengirim notifikasi ke pembuat tiket
- **AND** menampilkan badge "Selesai" pada tiket

#### Scenario: Mengembalikan status dari SELESAI ke DIPROSES
- **GIVEN** tiket dengan status "SELESAI"
- **WHEN** admin mengubah status menjadi "DIPROSES"
- **THEN** sistem mengupdate status tiket
- **AND** mencatat alasan perubahan (opsional)
- **AND** mengirim notifikasi ke pembuat tiket

### Requirement: Row Level Security untuk tiket
Sistem SHALL menerapkan RLS policies sehingga pengguna hanya dapat mengakses tiket sesuai dengan hak akses mereka.

#### Scenario: Pengguna tidak dapat melihat tiket orang lain
- **GIVEN** pengguna A memiliki tiket X
- **WHEN** pengguna B (bukan helpdesk/admin) mencoba mengakses tiket X
- **THEN** sistem menolak akses dengan error "Tiket tidak ditemukan"

#### Scenario: Helpdesk dapat mengakses semua tiket
- **GIVEN** pengguna dengan peran "helpdesk"
- **WHEN** helpdesk mencoba mengakses tiket milik pengguna lain
- **THEN** sistem mengizinkan akses dengan data lengkap
