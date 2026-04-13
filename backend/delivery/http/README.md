# HTTP Delivery Layer

This package contains HTTP handlers and routing for the REST API.

## Handlers

| Handler | File | Endpoints |
|---------|------|-----------|
| AuthHandler | `auth_handler.go` | POST /auth/register, POST /auth/login, POST /auth/logout, GET /auth/me |
| TiketHandler | `tiket_handler.go` | GET /tikets, POST /tikets, GET /tikets/:id, PATCH /tikets/:id/status, POST /tikets/:id/assign |
| KomentarHandler | `komentar_handler.go` | POST /tikets/:tiket_id/komentars |
| NotifikasiHandler | `notifikasi_handler.go` | GET /notifikasis, PATCH /notifikasis/:id/read, PATCH /notifikasis/read-all |
| LampiranHandler | `lampiran_handler.go` | POST /tikets/:tiket_id/lampirans/upload, GET /lampirans/:id/download, DELETE /lampirans/:id |
| DashboardHandler | `dashboard_handler.go` | GET /dashboard/stats |

## Middleware

| Middleware | File | Description |
|------------|------|-------------|
| JWTMiddleware | `jwt_middleware.go` | Token validation, role checking |
| CORS | `cors_middleware.go` | Cross-origin request handling |
| ErrorHandling | `cors_middleware.go` | Panic recovery |

## Routes

```
/api
├── /auth
│   ├── POST /register          (public)
│   ├── POST /login             (public)
│   ├── POST /logout            (protected)
│   └── GET  /me               (protected)
├── /dashboard
│   └── GET  /stats            (protected)
├── /tikets
│   ├── GET    /               (protected)
│   ├── POST   /               (protected)
│   ├── GET    /:id            (protected)
│   ├── PATCH  /:id/status     (protected, helpdesk/admin)
│   └── POST   /:id/assign     (protected, helpdesk/admin)
├── /tikets/:tiket_id/komentars
│   └── POST   /               (protected)
├── /notifikasis
│   ├── GET    /               (protected)
│   ├── PATCH  /:id/read       (protected)
│   └── PATCH  /read-all       (protected)
└── /tikets/:tiket_id/lampirans
    ├── POST   /upload         (protected)
    ├── GET    /:id/download   (protected)
    └── DELETE /:id            (protected)
```

## Usage

```go
// Setup router with all dependencies
router := http.NewRouter(
    authRepo, registerUC, loginUC, logoutUC,
    createTiketUC, getTiketListUC, getTiketDetailUC,
    updateTiketStatusUC, assignTiketUC,
    addKomentarUC,
    getNotifikasiListUC, markNotifikasiReadUC,
    uploadLampiranUC, deleteLampiranUC, lampiranRepo,
    getDashboardStatsUC,
)

router.SetupRoutes()

// Run server
router.GetEngine().Run(":8080")
```
