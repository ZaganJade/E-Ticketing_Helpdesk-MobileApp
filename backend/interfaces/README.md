# Repository Interfaces

This package defines the repository interfaces following the Repository Pattern from Clean Architecture.

## Interfaces

- `pengguna_repository.go` - User data access
- `tiket_repository.go` - Ticket data access
- `komentar_repository.go` - Comment data access
- `notifikasi_repository.go` - Notification data access
- `lampiran_repository.go` - Attachment data access
- `auth_repository.go` - Authentication operations

## Design Principles

1. **Dependency Inversion**: Domain layer depends on these interfaces, not concrete implementations
2. **Testability**: Easy to mock for unit testing
3. **Flexibility**: Can switch to different database implementations

## Usage

Implementations are in `backend/repository/` package.
