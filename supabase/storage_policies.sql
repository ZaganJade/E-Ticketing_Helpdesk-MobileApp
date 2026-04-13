-- Supabase Storage Configuration for E-Ticketing Helpdesk

-- Create bucket for ticket attachments
-- Note: This should be run in Supabase Dashboard > Storage > New Bucket
-- Or using Supabase CLI: supabase storage create lampiran_tiket --public

-- Storage Policies for bucket 'lampiran_tiket'

-- Policy: Users can upload files to their own tickets or if helpdesk/admin
CREATE POLICY "upload_lampiran_policy" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'lampiran_tiket'
        AND (
            -- Check if user owns the ticket or is helpdesk/admin
            EXISTS (
                SELECT 1 FROM tiket t
                WHERE t.id::text = (storage.foldername(name))[1]  -- Assuming folder structure: /tiket_id/filename
                AND (
                    t.dibuat_oleh::text = auth.uid()::text
                    OR EXISTS (
                        SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
                    )
                )
            )
        )
    );

-- Policy: Users can view files if they have access to the ticket
CREATE POLICY "select_lampiran_policy" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'lampiran_tiket'
        AND EXISTS (
            SELECT 1 FROM tiket t
            WHERE t.id::text = (storage.foldername(name))[1]
            AND (
                t.dibuat_oleh::text = auth.uid()::text
                OR EXISTS (
                    SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran IN ('helpdesk', 'admin')
                )
            )
        )
    );

-- Policy: Users can delete their own files if ticket is still TERBUKA, or admin can delete any
CREATE POLICY "delete_lampiran_policy" ON storage.objects
    FOR DELETE TO authenticated
    USING (
        bucket_id = 'lampiran_tiket'
        AND (
            -- Owner can delete if ticket is still open
            (EXISTS (
                SELECT 1 FROM tiket t
                JOIN lampiran l ON l.path_file = name
                WHERE t.id = l.tiket_id
                AND l.dibuat_oleh::text = auth.uid()::text
                AND t.status = 'TERBUKA'
            )
            OR EXISTS (
                SELECT 1 FROM pengguna WHERE id::text = auth.uid()::text AND peran = 'admin'
            ))
        )
    );

-- Enable Realtime for tables
BEGIN;

-- Add tables to realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE tiket;
ALTER PUBLICATION supabase_realtime ADD TABLE komentar;
ALTER PUBLICATION supabase_realtime ADD TABLE notifikasi;

COMMIT;

-- Note: Clients will subscribe using:
-- supabase.channel('tiket_changes').on('postgres_changes', { event: '*', schema: 'public', table: 'tiket' }, callback).subscribe()
