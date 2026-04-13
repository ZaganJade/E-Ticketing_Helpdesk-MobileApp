# Supabase Configuration

This folder contains database schema and configuration for the E-Ticketing Helpdesk application.

## Files

- `schema.sql` - Database schema (tables, enums, indexes, RLS policies)
- `storage_policies.sql` - Storage bucket policies for file attachments
- `seed.sql` - Sample data for development/testing

## Setup Instructions

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your project URL and anon key

### 2. Run Schema
Execute `schema.sql` in Supabase Dashboard:
- Go to SQL Editor
- New query
- Paste contents of `schema.sql`
- Run

### 3. Create Storage Bucket
Create bucket named `lampiran_tiket`:
- Go to Storage
- New bucket
- Name: `lampiran_tiket`
- Public: true (files accessible with signed URLs)

### 4. Setup Storage Policies
Execute `storage_policies.sql` in SQL Editor.

### 5. Enable Realtime
Realtime is already configured in schema.sql for tables:
- `tiket` - Realtime ticket updates
- `komentar` - Realtime comments
- `notifikasi` - Realtime notifications

### 6. Seed Data (Optional)
Execute `seed.sql` to create sample users for testing.

## Environment Variables

Add these to your `.env` files:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Database Schema Overview

### Tables
- `pengguna` - Users with roles (pengguna, helpdesk, admin)
- `tiket` - Tickets with status workflow (TERBUKA → DIPROSES → SELESAI)
- `komentar` - Comments on tickets
- `notifikasi` - User notifications
- `lampiran` - File attachments metadata

### Enums
- `user_role` - pengguna | helpdesk | admin
- `ticket_status` - TERBUKA | DIPROSES | SELESAI
- `notif_type` - STATUS_CHANGE | KOMENTAR_BARU

### RLS Policies
All tables have Row Level Security enabled with policies based on user roles and ownership.
