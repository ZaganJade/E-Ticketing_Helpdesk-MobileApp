# Use Case Layer

This package contains business logic use cases following Clean Architecture.

## Use Cases

### Authentication
- `register_usecase.go` - User registration
- `login_usecase.go` - User login
- `logout_usecase.go` - User logout

### Ticket Management
- `create_tiket_usecase.go` - Create new ticket
- `get_tiket_list_usecase.go` - List tickets with filters
- `get_tiket_detail_usecase.go` - Get ticket details
- `update_tiket_status_usecase.go` - Update ticket status
- `assign_tiket_usecase.go` - Assign ticket to helpdesk

### Comments
- `add_komentar_usecase.go` - Add comment to ticket

### Notifications
- `get_notifikasi_list_usecase.go` - List notifications
- `mark_notifikasi_read_usecase.go` - Mark notification(s) as read

### Attachments
- `upload_lampiran_usecase.go` - Upload file attachment
- `delete_lampiran_usecase.go` - Delete file attachment

### Dashboard
- `get_dashboard_stats_usecase.go` - Get dashboard statistics

## Design Patterns

Each use case follows these patterns:
1. **Input/Output DTOs** - Data transfer objects for boundaries
2. **Single Responsibility** - Each use case does one thing
3. **Dependency Injection** - Repositories injected via constructor
4. **Error Handling** - Domain errors returned for proper handling

## Usage

```go
// Create use case with injected repositories
createTiketUC := usecases.NewCreateTiketUseCase(tiketRepo)

// Execute with input DTO
output, err := createTiketUC.Execute(ctx, usecases.CreateTiketInput{
    Judul:     "Judul Tiket",
    Deskripsi: "Deskripsi lengkap",
    DibuatOleh: userID,
})
```
