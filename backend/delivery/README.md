# Delivery Layer (HTTP)

This package contains HTTP handlers and middleware for the REST API.

## Handlers

- `auth_handler.go` - Authentication endpoints (register, login, logout, me)
- `tiket_handler.go` - Ticket endpoints (CRUD, status update, assign)
- `komentar_handler.go` - Comment endpoints (add)
- `notifikasi_handler.go` - Notification endpoints (list, mark read)
- `lampiran_handler.go` - Attachment endpoints (upload, download, delete)
- `dashboard_handler.go` - Dashboard endpoints (stats)

## Middleware

- `auth_middleware.go` - JWT validation, role-based access

## Router

- `router.go` - Route definitions and middleware setup

## API Endpoints

### Auth
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/me` - Get current user info (protected)

### Dashboard
- `GET /api/v1/dashboard/stats` - Get dashboard statistics (protected)

### Tiket
- `POST /api/v1/tiket` - Create ticket (protected)
- `GET /api/v1/tiket` - List tickets (protected)
- `GET /api/v1/tiket/:id` - Get ticket detail (protected)
- `PATCH /api/v1/tiket/:id/status` - Update status (helpdesk/admin only)
- `POST /api/v1/tiket/:id/assign` - Assign ticket (helpdesk/admin only)

### Komentar
- `POST /api/v1/tiket/:tiket_id/komentar` - Add comment (protected)

### Notifikasi
- `GET /api/v1/notifikasi` - List notifications (protected)
- `PATCH /api/v1/notifikasi/:id/read` - Mark as read (protected)
- `PATCH /api/v1/notifikasi/read-all` - Mark all as read (protected)

### Lampiran
- `POST /api/v1/tiket/:tiket_id/lampiran` - Upload file (protected)
- `GET /api/v1/tiket/:tiket_id/lampiran` - List attachments (protected)
- `GET /api/v1/lampiran/:id/download` - Get download URL (protected)
- `DELETE /api/v1/lampiran/:id` - Delete attachment (protected)

## Middleware Chain

1. **AuthMiddleware** - Validates JWT token, sets user context
2. **HelpdeskOrAdminMiddleware** - Restricts to helpdesk/admin only
3. **AdminMiddleware** - Restricts to admin only
