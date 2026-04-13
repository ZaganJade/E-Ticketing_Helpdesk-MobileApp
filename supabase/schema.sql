-- E-Ticketing Helpdesk Database Schema
-- Database: helpdesk_tiket

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enum types
CREATE TYPE user_role AS ENUM ('pengguna', 'helpdesk', 'admin');
CREATE TYPE ticket_status AS ENUM ('TERBUKA', 'DIPROSES', 'SELESAI');
CREATE TYPE notif_type AS ENUM ('STATUS_CHANGE', 'KOMENTAR_BARU');

-- Tabel Pengguna
CREATE TABLE pengguna (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    peran user_role NOT NULL DEFAULT 'pengguna',
    dibuat_pada TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Tiket
CREATE TABLE tiket (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    judul VARCHAR(255) NOT NULL,
    deskripsi TEXT NOT NULL,
    status ticket_status NOT NULL DEFAULT 'TERBUKA',
    dibuat_oleh UUID NOT NULL REFERENCES pengguna(id) ON DELETE CASCADE,
    ditugaskan_kepada UUID REFERENCES pengguna(id) ON DELETE SET NULL,
    dibuat_pada TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    selesai_pada TIMESTAMP WITH TIME ZONE
);

-- Tabel Komentar
CREATE TABLE komentar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tiket_id UUID NOT NULL REFERENCES tiket(id) ON DELETE CASCADE,
    penulis_id UUID NOT NULL REFERENCES pengguna(id) ON DELETE CASCADE,
    isi_pesan TEXT NOT NULL,
    dibuat_pada TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Notifikasi
CREATE TABLE notifikasi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pengguna_id UUID NOT NULL REFERENCES pengguna(id) ON DELETE CASCADE,
    tipe notif_type NOT NULL,
    referensi_id UUID NOT NULL, -- ID tiket yang terkait
    judul VARCHAR(255) NOT NULL,
    pesan TEXT NOT NULL,
    sudah_dibaca BOOLEAN DEFAULT FALSE,
    dibuat_pada TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Lampiran
CREATE TABLE lampiran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tiket_id UUID NOT NULL REFERENCES tiket(id) ON DELETE CASCADE,
    nama_file VARCHAR(255) NOT NULL,
    path_file TEXT NOT NULL,
    ukuran BIGINT NOT NULL, -- dalam bytes
    tipe_file VARCHAR(100) NOT NULL,
    dibuat_oleh UUID NOT NULL REFERENCES pengguna(id) ON DELETE CASCADE,
    dibuat_pada TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes untuk performa
CREATE INDEX idx_tiket_dibuat_oleh ON tiket(dibuat_oleh);
CREATE INDEX idx_tiket_ditugaskan_kepada ON tiket(ditugaskan_kepada);
CREATE INDEX idx_tiket_status ON tiket(status);
CREATE INDEX idx_tiket_dibuat_pada ON tiket(dibuat_pada DESC);
CREATE INDEX idx_komentar_tiket_id ON komentar(tiket_id);
CREATE INDEX idx_komentar_dibuat_pada ON komentar(dibuat_pada ASC);
CREATE INDEX idx_notifikasi_pengguna_id ON notifikasi(pengguna_id);
CREATE INDEX idx_notifikasi_sudah_dibaca ON notifikasi(sudah_dibaca);
CREATE INDEX idx_notifikasi_dibuat_pada ON notifikasi(dibuat_pada DESC);
CREATE INDEX idx_lampiran_tiket_id ON lampiran(tiket_id);

-- Trigger untuk updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_pengguna_updated_at BEFORE UPDATE ON pengguna
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tiket_updated_at BEFORE UPDATE ON tiket
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE pengguna ENABLE ROW LEVEL SECURITY;
ALTER TABLE tiket ENABLE ROW LEVEL SECURITY;
ALTER TABLE komentar ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifikasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE lampiran ENABLE ROW LEVEL SECURITY;

-- RLS Policies untuk pengguna (authenticated users)

-- Pengguna: Hanya lihat data sendiri
CREATE POLICY "pengguna_lihat_diri_sendiri" ON pengguna
    FOR SELECT TO authenticated
    USING (auth.uid()::text = id::text);

-- Pengguna: Bisa update data sendiri (nama saja)
CREATE POLICY "pengguna_update_diri_sendiri" ON pengguna
    FOR UPDATE TO authenticated
    USING (auth.uid()::text = id::text)
    WITH CHECK (auth.uid()::text = id::text);

-- Tiket: Pengguna hanya lihat tiket miliknya, Helpdesk/Admin lihat semua
CREATE POLICY "tiket_select_policy" ON tiket
    FOR SELECT TO authenticated
    USING (
        dibuat_oleh::text = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
        )
    );

-- Tiket: Pengguna hanya insert untuk diri sendiri
CREATE POLICY "tiket_insert_policy" ON tiket
    FOR INSERT TO authenticated
    WITH CHECK (dibuat_oleh::text = auth.uid()::text);

-- Tiket: Hanya Helpdesk/Admin yang bisa update status dan assignment
CREATE POLICY "tiket_update_policy" ON tiket
    FOR UPDATE TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
        )
        OR (
            -- Pembuat bisa update tiket mereka yang masih TERBUKA (misal: edit deskripsi sebelum diproses)
            dibuat_oleh::text = auth.uid()::text
            AND status = 'TERBUKA'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
        )
        OR (
            dibuat_oleh::text = auth.uid()::text
            AND status = 'TERBUKA'
        )
    );

-- Tiket: Hanya Admin yang bisa delete
CREATE POLICY "tiket_delete_policy" ON tiket
    FOR DELETE TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran = 'admin'
        )
    );

-- Komentar: Bisa dilihat jika tiket bisa dilihat oleh user
CREATE POLICY "komentar_select_policy" ON komentar
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM tiket t
            WHERE t.id = tiket_id
            AND (
                t.dibuat_oleh::text = auth.uid()::text
                OR EXISTS (
                    SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
                )
            )
        )
    );

-- Komentar: Bisa insert jika tiket bisa diakses
CREATE POLICY "komentar_insert_policy" ON komentar
    FOR INSERT TO authenticated
    WITH CHECK (
        penulis_id::text = auth.uid()::text
        AND EXISTS (
            SELECT 1 FROM tiket t
            WHERE t.id = tiket_id
            AND (
                t.dibuat_oleh::text = auth.uid()::text
                OR EXISTS (
                    SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
                )
            )
        )
    );

-- Notifikasi: Hanya pengguna terkait yang bisa lihCAT
CREATE POLICY "notifikasi_select_policy" ON notifikasi
    FOR SELECT TO authenticated
    USING (pengguna_id::text = auth.uid()::text);

-- Notifikasi: Update hanya untuk mark as read (tidak bisa update field lain)
CREATE POLICY "notifikasi_update_policy" ON notifikasi
    FOR UPDATE TO authenticated
    USING (pengguna_id::text = auth.uid()::text)
    WITH CHECK (pengguna_id::text = auth.uid()::text);

-- Lampiran: Bisa dilihat jika tiket bisa dilihat
CREATE POLICY "lampiran_select_policy" ON lampiran
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM tiket t
            WHERE t.id = tiket_id
            AND (
                t.dibuat_oleh::text = auth.uid()::text
                OR EXISTS (
                    SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
                )
            )
        )
    );

-- Lampiran: Insert jika tiket milik user atau user adalah helpdesk/admin
CREATE POLICY "lampiran_insert_policy" ON lampiran
    FOR INSERT TO authenticated
    WITH CHECK (
        dibuat_oleh::text = auth.uid()::text
        AND EXISTS (
            SELECT 1 FROM tiket t
            WHERE t.id = tiket_id
            AND (
                t.dibuat_oleh::text = auth.uid()::text
                OR EXISTS (
                    SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
                )
            )
        )
    );

-- Lampiran: Delete hanya oleh pembuat dan jika tiket masih TERBUKA, atau oleh admin
CREATE POLICY "lampiran_delete_policy" ON lampiran
    FOR DELETE TO authenticated
    USING (
        (dibuat_oleh::text = auth.uid()::text
         AND EXISTS (
             SELECT 1 FROM tiket t WHERE t.id = tiket_id AND t.status = 'TERBUKA'
         ))
        OR EXISTS (
            SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran = 'admin'
        )
    );
