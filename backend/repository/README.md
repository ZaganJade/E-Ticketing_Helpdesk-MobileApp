# Repository Layer

This package contains Supabase implementations of repository interfaces.

## Files

- `supabase_client.go` - Supabase client wrapper
- `supabase_auth_repository.go` - Authentication operations
- `supabase_pengguna_repository.go` - User data access
- `supabase_tiket_repository.go` - Ticket data access with filters and stats
- `supabase_komentar_repository.go` - Comment data access
- `supabase_notifikasi_repository.go` - Notification data access
- `supabase_lampiran_repository.go` - File attachment operations

## Usage

Repositories are instantiated with a SupabaseClient:

```go
client, err := repository.NewSupabaseClient(cfg)
if err != nil {
    log.Fatal(err)
}

authRepo := repository.NewSupabaseAuthRepository(client)
tiketRepo := repository.NewSupabaseTiketRepository(client)
```

## Supabase Features Used

- **PostgREST** - CRUD operations
- **Supabase Auth** - Authentication
- **Supabase Storage** - File uploads
- **RLS Policies** - Security (enforced at database level)
- **Foreign Table Selection** - Relations (e.g., `penulis:pengguna(nama, peran)`)
