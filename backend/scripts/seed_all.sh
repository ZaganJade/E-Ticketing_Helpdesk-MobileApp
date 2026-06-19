#!/usr/bin/env bash
# Apply Supabase SQL migrations and seed admin user.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/backend"

echo "==> Applying RLS migration (rls_assignment_flow.sql)"
go run ./cmd/apply_rls

echo "==> Seeding admin user (Supabase Auth + pengguna)"
: "${ADMIN_NAMA:=Administrator}"
: "${ADMIN_EMAIL:=admin@helpdesk.local}"
: "${ADMIN_PASSWORD:?Set ADMIN_PASSWORD before running seed_all.sh}"

ADMIN_NAMA="$ADMIN_NAMA" ADMIN_EMAIL="$ADMIN_EMAIL" ADMIN_PASSWORD="$ADMIN_PASSWORD" \
  go run ./cmd/seed_admin

echo "==> Verifying database state"
go run ./cmd/apply_rls -verify

echo "Done. Admin login: $ADMIN_EMAIL"
