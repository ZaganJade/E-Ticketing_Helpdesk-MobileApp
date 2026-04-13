-- Fix for notifikasi enum issue
-- This adds a helper function to create notifications with proper enum handling

-- First, let's verify the current enum values
-- Run this to check: SELECT enum_range(NULL::notif_type);

-- Create a function to insert notifications that handles the enum properly
CREATE OR REPLACE FUNCTION create_notifikasi(
    p_pengguna_id UUID,
    p_tipe TEXT,
    p_referensi_id UUID,
    p_judul VARCHAR(255),
    p_pesan TEXT
) RETURNS UUID AS $$
DECLARE
    v_id UUID := gen_random_uuid();
    v_enum_value notif_type;
BEGIN
    -- Convert text to enum (this will validate and raise an error if invalid)
    v_enum_value := p_tipe::notif_type;

    INSERT INTO notifikasi (id, pengguna_id, tipe, referensi_id, judul, pesan, sudah_dibaca, dibuat_pada)
    VALUES (v_id, p_pengguna_id, v_enum_value, p_referensi_id, p_judul, p_pesan, FALSE, NOW());

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Alternative: Create function with explicit enum parameter
CREATE OR REPLACE FUNCTION create_notifikasi_enum(
    p_pengguna_id UUID,
    p_tipe notif_type,
    p_referensi_id UUID,
    p_judul VARCHAR(255),
    p_pesan TEXT
) RETURNS UUID AS $$
DECLARE
    v_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO notifikasi (id, pengguna_id, tipe, referensi_id, judul, pesan, sudah_dibaca, dibuat_pada)
    VALUES (v_id, p_pengguna_id, p_tipe, p_referensi_id, p_judul, p_pesan, FALSE, NOW());

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Query to check current constraint definition
-- SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'notifikasi'::regclass;

-- Query to check enum values
-- SELECT typname, enumlabel FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid WHERE typname = 'notif_type';
