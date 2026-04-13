# Features Module

This module contains all feature-specific code:

- `auth/` - Authentication feature (login, register, logout)
- `tiket/` - Ticket management feature (list, detail, create)
- `dashboard/` - Dashboard feature (statistics, overview)
- `notifikasi/` - Notifications feature
- `profil/` - Profile feature
- `komentar/` - Comments feature

Each feature follows Clean Architecture structure:
- `data/` - Repositories, data sources, models
- `domain/` - Entities, use cases, repository interfaces
- `presentation/` - UI (pages, widgets, cubits/blocs)
