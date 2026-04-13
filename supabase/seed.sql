-- Seed data for E-Ticketing Helpdesk
-- Run this after schema is created to populate initial data

-- Insert sample users (password should be hashed by application layer)
-- Note: In production, use Supabase Auth to create users and sync to pengguna table

-- Insert admin user
INSERT INTO pengguna (id, nama, email, password_hash, peran, dibuat_pada)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'Administrator',
    'admin@eticketing.id',
    '$2a$10$hashed_password_here', -- Replace with actual bcrypt hash
    'admin',
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Insert helpdesk users
INSERT INTO pengguna (id, nama, email, password_hash, peran, dibuat_pada)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Helpdesk A', 'helpdesk1@eticketing.id', '$2a$10$hashed_password_here', 'helpdesk', NOW()),
    ('550e8400-e29b-41d4-a716-446655440002', 'Helpdesk B', 'helpdesk2@eticketing.id', '$2a$10$hashed_password_here', 'helpdesk', NOW())
ON CONFLICT (email) DO NOTHING;

-- Insert sample regular user
INSERT INTO pengguna (id, nama, email, password_hash, peran, dibuat_pada)
VALUES (
    '550e8400-e29b-41d4-a716-446655440003',
    'User Demo',
    'user@eticketing.id',
    '$2a$10$hashed_password_here',
    'pengguna',
    NOW()
) ON CONFLICT (email) DO NOTHING;
