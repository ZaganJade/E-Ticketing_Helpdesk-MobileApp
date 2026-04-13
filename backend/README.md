# E-Ticketing Helpdesk Backend

Backend API built with Go using Clean Architecture.

## Architecture

```
backend/
├── entities/          # Domain models
├── usecases/          # Business logic
├── interfaces/        # Repository interfaces
├── delivery/          # HTTP handlers
│   ├── http/         # Route handlers
│   └── middleware/   # Auth, CORS, etc.
├── repository/        # Supabase implementations
├── config/           # Configuration
└── utils/            # Helper functions
```

## Setup

1. Copy `.env.example` to `.env` and fill in values
2. Run `go mod tidy` to download dependencies
3. Run `go run main.go` to start server

## Environment Variables

- `PORT` - Server port (default: 8080)
- `ENV` - Environment (development/production)
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_KEY` - Supabase service role key
- `JWT_SECRET` - JWT signing secret
