# Admin-Mediated Ticket Assignment Flow — Backend Implementation Plan (Plan 1 of 2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make ticket assignment admin-only with a global pool, where admin assigns `TERBUKA` tickets only to free helpdesk (≤1 active `DIPROSES` each), helpdesk sees only their own assigned + completed tickets, and admin can reassign or pull a ticket back to the pool — plus seed a working admin account.

**Architecture:** Enforcement lives in Go usecases (backend uses Supabase `service_role`, so RLS is bypassed for API calls). RLS is updated as a second layer for direct/Realtime reads from Flutter. No DB schema change — the existing `status` + `ditugaskan_kepada` columns model the pool and busy-state. Admin is provisioned by a one-shot Go script that creates a Supabase Auth user (with `user_metadata.peran = "admin"`) and upserts the `pengguna` row to `peran = 'admin'`.

**Tech Stack:** Go 1.26 (Gin, postgrest-go, golang-jwt), Supabase (PostgreSQL + Auth + RLS), standard library `testing` with hand-rolled in-memory fakes (no new deps).

**Scope note:** This plan is backend + RLS + admin seed only. The Flutter UI (remove helpdesk self-assign; helpdesk "active + history" view; admin pool/assign/reassign/pull-back screens) is **Plan 2**, written after these endpoints land. Reference spec: `docs/superpowers/specs/2026-06-18-admin-ticket-assignment-flow-design.md`.

## Global Constraints

- **Role source of truth is dual:** API authorization reads role from the Supabase JWT `user_metadata.peran` (set in `delivery/middleware/supabase_auth.go`); DB-driven role queries (e.g. "list helpdesks") read `pengguna.peran`. Any account whose role matters must have **both** set consistently. The admin seed sets both.
- **Invariant:** one helpdesk has at most **one** `DIPROSES` ticket at a time. "Free/kosong" = `CountActiveByHelpdesk == 0`.
- **Status values (verbatim):** `TERBUKA`, `DIPROSES`, `SELESAI`. Roles (verbatim): `pengguna`, `helpdesk`, `admin`.
- **No new Go dependencies.** Tests use the standard `testing` package with in-memory fakes.
- **Working directory for all Go commands:** `C:\Projects\eticketinghelpdesk\backend`.
- **Branch:** continue on `feat/admin-ticket-assignment-flow`.
- **Error→HTTP mapping** is centralized in `delivery/http/helpers.go::respondDomainError` (validation→400, unauthorized→403, not-found→404, else→500). New domain errors must wrap `entities.ErrValidation` / `entities.ErrUnauthorized` / `entities.ErrNotFound` to map correctly.

---

## File Structure

**Modified:**
- `backend/entities/tiket.go` — `AssignTo` becomes admin-only.
- `backend/entities/errors.go` — add `ErrHelpdeskSibuk` + `IsHelpdeskSibuk`.
- `backend/interfaces/tiket_repository.go` — add `CountActiveByHelpdesk`, `Unassign`.
- `backend/interfaces/pengguna_repository.go` — add `ListByRole`.
- `backend/repository/supabase_tiket_repository.go` — implement the two new methods.
- `backend/repository/supabase_pengguna_repository.go` — implement `ListByRole`.
- `backend/usecases/assign_tiket_usecase.go` — add `penggunaRepo`; admin-only, target-is-helpdesk, free-check, reassign notifications.
- `backend/usecases/update_tiket_status_usecase.go` — helpdesk may only change status of a ticket assigned to them.
- `backend/usecases/get_tiket_list_usecase.go` — helpdesk sees only `DitugaskanKepada = self`.
- `backend/delivery/http/tiket_handler.go` — add `UnassignTiket`, `ListHelpdesks`; extend `NewTiketHandler`.
- `backend/main.go` — wire new usecases/handler args; route changes (assign → admin-only, add unassign + helpdesks).

**Created:**
- `backend/usecases/fakes_test.go` — shared in-memory fakes for usecase tests.
- `backend/usecases/assign_tiket_usecase_test.go`, `unassign_tiket_usecase_test.go`, `get_tiket_list_usecase_test.go`, `list_available_helpdesk_usecase.go` (+ `_test.go`), `update_tiket_status_usecase_test.go`.
- `backend/entities/tiket_test.go` — `AssignTo` role tests.
- `backend/usecases/unassign_tiket_usecase.go` — new usecase.
- `backend/usecases/list_available_helpdesk_usecase.go` — new usecase.
- `supabase/rls_assignment_flow.sql` — RLS tightening migration.
- `backend/cmd/seed_admin/main.go` — one-shot admin provisioning.

---

## Task 1: Domain — `AssignTo` admin-only + `ErrHelpdeskSibuk`

**Files:**
- Modify: `backend/entities/tiket.go:130-140` (`AssignTo`)
- Modify: `backend/entities/errors.go`
- Test: `backend/entities/tiket_test.go` (create)

**Interfaces:**
- Produces: `entities.ErrHelpdeskSibuk` (wrapped error var), `entities.IsHelpdeskSibuk(err) bool`, and `Tiket.AssignTo(helpdeskID uuid.UUID, assignerRole Role) error` now rejecting non-admin.

- [ ] **Step 1: Write the failing test**

Create `backend/entities/tiket_test.go`:

```go
package entities

import (
	"testing"

	"github.com/google/uuid"
)

func TestAssignTo_AdminOnly(t *testing.T) {
	mk := func() *Tiket {
		return &Tiket{ID: uuid.New(), Status: StatusTerbuka}
	}
	hd := uuid.New()

	if err := mk().AssignTo(hd, RoleAdmin); err != nil {
		t.Fatalf("admin assign should succeed, got %v", err)
	}

	tk := mk()
	if err := tk.AssignTo(hd, RoleHelpdesk); err == nil {
		t.Fatal("helpdesk assign should be rejected")
	}

	tk2 := mk()
	if err := tk2.AssignTo(hd, RolePengguna); err == nil {
		t.Fatal("pengguna assign should be rejected")
	}
}

func TestAssignTo_SetsDiprosesAndAssignee(t *testing.T) {
	tk := &Tiket{ID: uuid.New(), Status: StatusTerbuka}
	hd := uuid.New()
	if err := tk.AssignTo(hd, RoleAdmin); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if tk.Status != StatusDiproses {
		t.Fatalf("status = %s, want DIPROSES", tk.Status)
	}
	if tk.DitugaskanKepada == nil || *tk.DitugaskanKepada != hd {
		t.Fatal("assignee not set")
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `go test ./entities/ -run TestAssignTo -v`
Expected: `TestAssignTo_AdminOnly` FAILS ("helpdesk assign should be rejected") because current code allows helpdesk.

- [ ] **Step 3: Implement — restrict `AssignTo` to admin**

In `backend/entities/tiket.go`, replace the body of `AssignTo`:

```go
// AssignTo assigns ticket to a helpdesk user. Only an admin may assign.
func (t *Tiket) AssignTo(helpdeskID uuid.UUID, assignerRole Role) error {
	if assignerRole != RoleAdmin {
		return errors.New("hanya admin yang dapat menugaskan tiket")
	}

	t.DitugaskanKepada = &helpdeskID
	t.Status = StatusDiproses
	t.DiperbaruiPada = time.Now()

	return nil
}
```

- [ ] **Step 4: Add `ErrHelpdeskSibuk` to errors.go**

In `backend/entities/errors.go`, add to the `var (...)` block (after `ErrValidation`):

```go
	ErrHelpdeskSibuk      = errors.New("helpdesk sedang menangani tiket lain")
```

And add a checker near `IsValidation`:

```go
// IsHelpdeskSibuk checks if error indicates the target helpdesk is busy
func IsHelpdeskSibuk(err error) bool {
	return errors.Is(err, ErrHelpdeskSibuk)
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `go test ./entities/ -v`
Expected: PASS (all entity tests).

- [ ] **Step 6: Commit**

```bash
git add backend/entities/tiket.go backend/entities/errors.go backend/entities/tiket_test.go
git commit -m "feat(entities): restrict ticket assignment to admin, add ErrHelpdeskSibuk"
```

---

## Task 2: Repository interfaces + Supabase implementations

No unit tests here (thin DB adapters verified by `go build` + Task 9 manual curl). Folded together because the interface change and its implementation must land in one compilable commit.

**Files:**
- Modify: `backend/interfaces/tiket_repository.go` (add 2 methods)
- Modify: `backend/interfaces/pengguna_repository.go` (add 1 method)
- Modify: `backend/repository/supabase_tiket_repository.go`
- Modify: `backend/repository/supabase_pengguna_repository.go`

**Interfaces:**
- Produces:
  - `TiketRepository.CountActiveByHelpdesk(ctx context.Context, helpdeskID uuid.UUID) (int64, error)`
  - `TiketRepository.Unassign(ctx context.Context, id uuid.UUID) error`
  - `PenggunaRepository.ListByRole(ctx context.Context, role entities.Role) ([]*entities.Pengguna, error)`

- [ ] **Step 1: Extend `TiketRepository` interface**

In `backend/interfaces/tiket_repository.go`, add inside the `TiketRepository` interface (after `Assign`):

```go
	// CountActiveByHelpdesk returns how many DIPROSES tickets are assigned to a helpdesk
	CountActiveByHelpdesk(ctx context.Context, helpdeskID uuid.UUID) (int64, error)

	// Unassign returns a ticket to the pool (status TERBUKA, assignee cleared)
	Unassign(ctx context.Context, id uuid.UUID) error
```

- [ ] **Step 2: Implement them on `SupabaseTiketRepository`**

In `backend/repository/supabase_tiket_repository.go`, append:

```go
// CountActiveByHelpdesk returns count of DIPROSES tickets for a helpdesk
func (r *SupabaseTiketRepository) CountActiveByHelpdesk(ctx context.Context, helpdeskID uuid.UUID) (int64, error) {
	_, count, err := r.client.GetTable("tiket").
		Select("id", "exact", false).
		Eq("ditugaskan_kepada", helpdeskID.String()).
		Eq("status", string(entities.StatusDiproses)).
		Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count active tickets: %w", err)
	}
	return count, nil
}

// Unassign clears the assignee and returns the ticket to the pool (TERBUKA)
func (r *SupabaseTiketRepository) Unassign(ctx context.Context, id uuid.UUID) error {
	data := map[string]interface{}{
		"ditugaskan_kepada": nil,
		"status":            string(entities.StatusTerbuka),
	}
	_, _, err := r.client.GetTable("tiket").
		Update(data, "", "").
		Eq("id", id.String()).
		Execute()
	if err != nil {
		return fmt.Errorf("failed to unassign ticket: %w", err)
	}
	return nil
}
```

- [ ] **Step 3: Extend `PenggunaRepository` interface**

In `backend/interfaces/pengguna_repository.go`, add inside the interface (after `CountByRole`):

```go
	// ListByRole retrieves all users with a given role
	ListByRole(ctx context.Context, role entities.Role) ([]*entities.Pengguna, error)
```

- [ ] **Step 4: Implement `ListByRole` on `SupabasePenggunaRepository`**

In `backend/repository/supabase_pengguna_repository.go`, append (it can reuse `parsePenggunaList`):

```go
// ListByRole retrieves all users with a given role
func (r *SupabasePenggunaRepository) ListByRole(ctx context.Context, role entities.Role) ([]*entities.Pengguna, error) {
	resp, _, err := r.client.GetTable("pengguna").
		Select("*", "", false).
		Eq("peran", string(role)).
		Order("nama", &postgrest.OrderOpts{Ascending: true}).
		Execute()
	if err != nil {
		return nil, fmt.Errorf("failed to list users by role: %w", err)
	}
	return r.parsePenggunaList(resp)
}
```

Add the import `"github.com/supabase-community/postgrest-go"` to that file's import block (it is not currently imported there).

- [ ] **Step 5: Verify compilation**

Run: `go build ./...`
Expected: builds with no errors.

- [ ] **Step 6: Commit**

```bash
git add backend/interfaces/tiket_repository.go backend/interfaces/pengguna_repository.go backend/repository/supabase_tiket_repository.go backend/repository/supabase_pengguna_repository.go
git commit -m "feat(repo): add CountActiveByHelpdesk, Unassign, ListByRole"
```

---

## Task 3: Shared usecase test fakes

A single fakes file the package's usecase tests share. No behavior of its own; verified when the first test that uses it runs (Task 4).

**Files:**
- Create: `backend/usecases/fakes_test.go`

**Interfaces:**
- Produces (test-only): `fakeTiketRepo` (implements `interfaces.TiketRepository`), `fakeNotifikasiRepo` (implements `interfaces.NotifikasiRepository`), `fakePenggunaRepo` (implements `interfaces.PenggunaRepository`), plus constructors `newFakeTiketRepo()`, `newFakeNotifikasiRepo()`, `newFakePenggunaRepo()`.

- [ ] **Step 1: Write the fakes file**

Create `backend/usecases/fakes_test.go`:

```go
package usecases

import (
	"context"

	"github.com/google/uuid"

	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// ---- fakeTiketRepo ----

type fakeTiketRepo struct {
	tikets         map[uuid.UUID]*entities.Tiket
	activeCount    map[uuid.UUID]int64 // helpdeskID -> DIPROSES count
	lastListFilter interfaces.TiketFilter
	assignCalls    [][2]uuid.UUID // {tiketID, helpdeskID}
	unassignCalls  []uuid.UUID
	updateCalls    []*entities.Tiket
}

func newFakeTiketRepo() *fakeTiketRepo {
	return &fakeTiketRepo{
		tikets:      map[uuid.UUID]*entities.Tiket{},
		activeCount: map[uuid.UUID]int64{},
	}
}

func (f *fakeTiketRepo) Create(ctx context.Context, t *entities.Tiket) error {
	f.tikets[t.ID] = t
	return nil
}
func (f *fakeTiketRepo) GetByID(ctx context.Context, id uuid.UUID) (*entities.Tiket, error) {
	if t, ok := f.tikets[id]; ok {
		return t, nil
	}
	return nil, entities.ErrNotFound
}
func (f *fakeTiketRepo) GetByIDWithRelations(ctx context.Context, id uuid.UUID) (*entities.Tiket, error) {
	return f.GetByID(ctx, id)
}
func (f *fakeTiketRepo) List(ctx context.Context, filter interfaces.TiketFilter, offset, limit int) ([]*entities.Tiket, error) {
	f.lastListFilter = filter
	out := []*entities.Tiket{}
	for _, t := range f.tikets {
		out = append(out, t)
	}
	return out, nil
}
func (f *fakeTiketRepo) Count(ctx context.Context, filter interfaces.TiketFilter) (int64, error) {
	f.lastListFilter = filter
	return int64(len(f.tikets)), nil
}
func (f *fakeTiketRepo) Update(ctx context.Context, t *entities.Tiket) error {
	f.updateCalls = append(f.updateCalls, t)
	f.tikets[t.ID] = t
	return nil
}
func (f *fakeTiketRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status entities.Status) error {
	if t, ok := f.tikets[id]; ok {
		t.Status = status
	}
	return nil
}
func (f *fakeTiketRepo) Assign(ctx context.Context, id, helpdeskID uuid.UUID) error {
	f.assignCalls = append(f.assignCalls, [2]uuid.UUID{id, helpdeskID})
	return nil
}
func (f *fakeTiketRepo) Unassign(ctx context.Context, id uuid.UUID) error {
	f.unassignCalls = append(f.unassignCalls, id)
	return nil
}
func (f *fakeTiketRepo) CountActiveByHelpdesk(ctx context.Context, helpdeskID uuid.UUID) (int64, error) {
	return f.activeCount[helpdeskID], nil
}
func (f *fakeTiketRepo) Delete(ctx context.Context, id uuid.UUID) error { return nil }
func (f *fakeTiketRepo) Exists(ctx context.Context, id uuid.UUID) (bool, error) {
	_, ok := f.tikets[id]
	return ok, nil
}
func (f *fakeTiketRepo) GetStats(ctx context.Context) (*interfaces.TiketStats, error) {
	return &interfaces.TiketStats{}, nil
}
func (f *fakeTiketRepo) GetStatsByUser(ctx context.Context, userID uuid.UUID) (*interfaces.TiketStats, error) {
	return &interfaces.TiketStats{}, nil
}

// ---- fakeNotifikasiRepo ----

type fakeNotifikasiRepo struct {
	created []*entities.Notifikasi
}

func newFakeNotifikasiRepo() *fakeNotifikasiRepo { return &fakeNotifikasiRepo{} }

func (f *fakeNotifikasiRepo) Create(ctx context.Context, n *entities.Notifikasi) error {
	f.created = append(f.created, n)
	return nil
}
func (f *fakeNotifikasiRepo) CreateBatch(ctx context.Context, list []*entities.Notifikasi) error {
	f.created = append(f.created, list...)
	return nil
}
func (f *fakeNotifikasiRepo) GetByID(ctx context.Context, id uuid.UUID) (*entities.Notifikasi, error) {
	return nil, entities.ErrNotFound
}
func (f *fakeNotifikasiRepo) GetByUserID(ctx context.Context, userID uuid.UUID, onlyUnread bool, offset, limit int) ([]*entities.Notifikasi, error) {
	return nil, nil
}
func (f *fakeNotifikasiRepo) MarkAsRead(ctx context.Context, id uuid.UUID) error    { return nil }
func (f *fakeNotifikasiRepo) MarkAllAsRead(ctx context.Context, userID uuid.UUID) error { return nil }
func (f *fakeNotifikasiRepo) Delete(ctx context.Context, id uuid.UUID) error        { return nil }
func (f *fakeNotifikasiRepo) DeleteOld(ctx context.Context, days int) error         { return nil }
func (f *fakeNotifikasiRepo) CountUnread(ctx context.Context, userID uuid.UUID) (int64, error) {
	return 0, nil
}
func (f *fakeNotifikasiRepo) CountByUser(ctx context.Context, userID uuid.UUID) (int64, error) {
	return 0, nil
}

// ---- fakePenggunaRepo ----

type fakePenggunaRepo struct {
	byID    map[uuid.UUID]*entities.Pengguna
	byRole  map[entities.Role][]*entities.Pengguna
}

func newFakePenggunaRepo() *fakePenggunaRepo {
	return &fakePenggunaRepo{
		byID:   map[uuid.UUID]*entities.Pengguna{},
		byRole: map[entities.Role][]*entities.Pengguna{},
	}
}

func (f *fakePenggunaRepo) add(p *entities.Pengguna) {
	f.byID[p.ID] = p
	f.byRole[p.Peran] = append(f.byRole[p.Peran], p)
}

func (f *fakePenggunaRepo) Create(ctx context.Context, p *entities.Pengguna) error {
	f.add(p)
	return nil
}
func (f *fakePenggunaRepo) GetByID(ctx context.Context, id uuid.UUID) (*entities.Pengguna, error) {
	if p, ok := f.byID[id]; ok {
		return p, nil
	}
	return nil, entities.ErrNotFound
}
func (f *fakePenggunaRepo) GetByEmail(ctx context.Context, email string) (*entities.Pengguna, error) {
	return nil, entities.ErrNotFound
}
func (f *fakePenggunaRepo) Update(ctx context.Context, p *entities.Pengguna) error { return nil }
func (f *fakePenggunaRepo) UpdateFotoProfil(ctx context.Context, id uuid.UUID, url string) error {
	return nil
}
func (f *fakePenggunaRepo) Delete(ctx context.Context, id uuid.UUID) error { return nil }
func (f *fakePenggunaRepo) List(ctx context.Context, offset, limit int) ([]*entities.Pengguna, error) {
	return nil, nil
}
func (f *fakePenggunaRepo) Count(ctx context.Context) (int64, error) { return 0, nil }
func (f *fakePenggunaRepo) CountByRole(ctx context.Context, role entities.Role) (int64, error) {
	return int64(len(f.byRole[role])), nil
}
func (f *fakePenggunaRepo) ListByRole(ctx context.Context, role entities.Role) ([]*entities.Pengguna, error) {
	return f.byRole[role], nil
}
```

- [ ] **Step 2: Verify it compiles (no test yet to run)**

Run: `go vet ./usecases/`
Expected: no errors (fakes satisfy all three interfaces). If a method signature mismatch is reported, fix it to match the interface.

- [ ] **Step 3: Commit**

```bash
git add backend/usecases/fakes_test.go
git commit -m "test(usecases): add in-memory repository fakes"
```

---

## Task 4: `AssignTiketUseCase` — admin-only, helpdesk target, free-check, reassign

**Files:**
- Modify: `backend/usecases/assign_tiket_usecase.go`
- Modify: `backend/main.go:65` (constructor call)
- Test: `backend/usecases/assign_tiket_usecase_test.go` (create)

**Interfaces:**
- Consumes: `fakeTiketRepo`, `fakeNotifikasiRepo`, `fakePenggunaRepo` (Task 3); `entities.ErrHelpdeskSibuk` (Task 1); `tiketRepo.CountActiveByHelpdesk` (Task 2).
- Produces: `NewAssignTiketUseCase(tiketRepo interfaces.TiketRepository, notifikasiRepo interfaces.NotifikasiRepository, penggunaRepo interfaces.PenggunaRepository) *AssignTiketUseCase`. `AssignTiketInput` unchanged (`TiketID, HelpdeskID, AssignerID, AssignerRole`).

- [ ] **Step 1: Write failing tests**

Create `backend/usecases/assign_tiket_usecase_test.go`:

```go
package usecases

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"eticketinghelpdesk/entities"
)

func seedHelpdesk(p *fakePenggunaRepo) *entities.Pengguna {
	h := &entities.Pengguna{ID: uuid.New(), Nama: "HD", Email: "hd@x.io", Peran: entities.RoleHelpdesk}
	p.add(h)
	return h
}

func TestAssign_SuccessToFreeHelpdesk(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	pr := newFakePenggunaRepo()
	hd := seedHelpdesk(pr)
	creator := uuid.New()
	tk := &entities.Tiket{ID: uuid.New(), Judul: "J", Status: entities.StatusTerbuka, DibuatOleh: creator}
	tr.tikets[tk.ID] = tk

	uc := NewAssignTiketUseCase(tr, nr, pr)
	err := uc.Execute(context.Background(), AssignTiketInput{
		TiketID: tk.ID, HelpdeskID: hd.ID, AssignerID: uuid.New(), AssignerRole: entities.RoleAdmin,
	})
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
	if len(tr.assignCalls) != 1 {
		t.Fatalf("expected 1 assign call, got %d", len(tr.assignCalls))
	}
}

func TestAssign_RejectsBusyHelpdesk(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	pr := newFakePenggunaRepo()
	hd := seedHelpdesk(pr)
	tr.activeCount[hd.ID] = 1 // busy
	tk := &entities.Tiket{ID: uuid.New(), Status: entities.StatusTerbuka}
	tr.tikets[tk.ID] = tk

	uc := NewAssignTiketUseCase(tr, nr, pr)
	err := uc.Execute(context.Background(), AssignTiketInput{
		TiketID: tk.ID, HelpdeskID: hd.ID, AssignerRole: entities.RoleAdmin,
	})
	if !entities.IsHelpdeskSibuk(err) {
		t.Fatalf("expected ErrHelpdeskSibuk, got %v", err)
	}
	if len(tr.assignCalls) != 0 {
		t.Fatal("must not assign to a busy helpdesk")
	}
}

func TestAssign_RejectsNonAdmin(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	pr := newFakePenggunaRepo()
	hd := seedHelpdesk(pr)
	tk := &entities.Tiket{ID: uuid.New(), Status: entities.StatusTerbuka}
	tr.tikets[tk.ID] = tk

	uc := NewAssignTiketUseCase(tr, nr, pr)
	err := uc.Execute(context.Background(), AssignTiketInput{
		TiketID: tk.ID, HelpdeskID: hd.ID, AssignerRole: entities.RoleHelpdesk,
	})
	if err == nil {
		t.Fatal("non-admin assign must be rejected")
	}
}

func TestAssign_RejectsNonHelpdeskTarget(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	pr := newFakePenggunaRepo()
	target := &entities.Pengguna{ID: uuid.New(), Peran: entities.RolePengguna}
	pr.add(target)
	tk := &entities.Tiket{ID: uuid.New(), Status: entities.StatusTerbuka}
	tr.tikets[tk.ID] = tk

	uc := NewAssignTiketUseCase(tr, nr, pr)
	err := uc.Execute(context.Background(), AssignTiketInput{
		TiketID: tk.ID, HelpdeskID: target.ID, AssignerRole: entities.RoleAdmin,
	})
	if err == nil {
		t.Fatal("assigning to a non-helpdesk must be rejected")
	}
}

func TestAssign_ReassignNotifiesOldHelpdesk(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	pr := newFakePenggunaRepo()
	oldHD := seedHelpdesk(pr)
	newHD := seedHelpdesk(pr)
	old := oldHD.ID
	tk := &entities.Tiket{ID: uuid.New(), Judul: "J", Status: entities.StatusDiproses, DibuatOleh: uuid.New(), DitugaskanKepada: &old}
	tr.tikets[tk.ID] = tk

	uc := NewAssignTiketUseCase(tr, nr, pr)
	err := uc.Execute(context.Background(), AssignTiketInput{
		TiketID: tk.ID, HelpdeskID: newHD.ID, AssignerRole: entities.RoleAdmin,
	})
	if err != nil {
		t.Fatalf("reassign should succeed, got %v", err)
	}
	// Expect a notification addressed to the old helpdesk.
	found := false
	for _, n := range nr.created {
		if n.PenggunaID == oldHD.ID {
			found = true
		}
	}
	if !found {
		t.Fatal("old helpdesk should be notified on reassign")
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `go test ./usecases/ -run TestAssign -v`
Expected: compile error / FAIL — `NewAssignTiketUseCase` currently takes 2 args, not 3.

- [ ] **Step 3: Implement the new usecase logic**

Replace the contents of `backend/usecases/assign_tiket_usecase.go` with:

```go
package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// AssignTiketInput holds assignment input
type AssignTiketInput struct {
	TiketID      uuid.UUID
	HelpdeskID   uuid.UUID
	AssignerID   uuid.UUID
	AssignerRole entities.Role
}

// AssignTiketUseCase handles ticket assignment (and reassignment)
type AssignTiketUseCase struct {
	tiketRepo      interfaces.TiketRepository
	notifikasiRepo interfaces.NotifikasiRepository
	penggunaRepo   interfaces.PenggunaRepository
}

// NewAssignTiketUseCase creates a new use case instance
func NewAssignTiketUseCase(
	tiketRepo interfaces.TiketRepository,
	notifikasiRepo interfaces.NotifikasiRepository,
	penggunaRepo interfaces.PenggunaRepository,
) *AssignTiketUseCase {
	return &AssignTiketUseCase{
		tiketRepo:      tiketRepo,
		notifikasiRepo: notifikasiRepo,
		penggunaRepo:   penggunaRepo,
	}
}

// Execute assigns (or reassigns) a ticket to a free helpdesk. Admin only.
func (uc *AssignTiketUseCase) Execute(ctx context.Context, input AssignTiketInput) error {
	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		return err
	}

	// Validate target is a real helpdesk.
	target, err := uc.penggunaRepo.GetByID(ctx, input.HelpdeskID)
	if err != nil {
		return entities.NewNotFoundError("helpdesk")
	}
	if target.Peran != entities.RoleHelpdesk {
		return entities.NewValidationError("helpdesk_id", "target bukan helpdesk")
	}

	// Free-check: the target helpdesk must have no active DIPROSES ticket.
	active, err := uc.tiketRepo.CountActiveByHelpdesk(ctx, input.HelpdeskID)
	if err != nil {
		return err
	}
	if active > 0 {
		return entities.ErrHelpdeskSibuk
	}

	// Capture previous assignee (for reassignment notification).
	var oldAssignee *uuid.UUID
	if tiket.DitugaskanKepada != nil {
		prev := *tiket.DitugaskanKepada
		oldAssignee = &prev
	}

	// Domain rule: admin-only + sets DIPROSES + assignee.
	if err := tiket.AssignTo(input.HelpdeskID, input.AssignerRole); err != nil {
		return err
	}

	if err := uc.tiketRepo.Assign(ctx, input.TiketID, input.HelpdeskID); err != nil {
		return fmt.Errorf("failed to assign ticket: %w", err)
	}

	// Notify ticket creator.
	creatorNotif := entities.CreateStatusChangeNotif(tiket.DibuatOleh, tiket.ID, tiket.Judul, entities.StatusDiproses)
	if err := uc.notifikasiRepo.Create(ctx, creatorNotif); err != nil {
		fmt.Printf("warning: failed to create creator notification: %v\n", err)
	}

	// Notify the newly assigned helpdesk.
	newHDNotif := &entities.Notifikasi{
		PenggunaID:  input.HelpdeskID,
		Tipe:        entities.NotifStatusChange,
		ReferensiID: tiket.ID,
		Judul:       "Tiket Ditugaskan ke Anda",
		Pesan:       fmt.Sprintf("Tiket '%s' telah ditugaskan kepada Anda", tiket.Judul),
	}
	if err := uc.notifikasiRepo.Create(ctx, newHDNotif); err != nil {
		fmt.Printf("warning: failed to create helpdesk notification: %v\n", err)
	}

	// On reassignment, notify the previous helpdesk too.
	if oldAssignee != nil && *oldAssignee != input.HelpdeskID {
		oldHDNotif := &entities.Notifikasi{
			PenggunaID:  *oldAssignee,
			Tipe:        entities.NotifStatusChange,
			ReferensiID: tiket.ID,
			Judul:       "Tiket Dipindahkan",
			Pesan:       fmt.Sprintf("Tiket '%s' dipindahkan dari Anda ke helpdesk lain oleh admin", tiket.Judul),
		}
		if err := uc.notifikasiRepo.Create(ctx, oldHDNotif); err != nil {
			fmt.Printf("warning: failed to create reassign notification: %v\n", err)
		}
	}

	return nil
}
```

- [ ] **Step 4: Update DI wiring in main.go**

In `backend/main.go`, change line 65:

```go
	assignTiketUC := usecases.NewAssignTiketUseCase(tiketRepo, notifikasiRepo, penggunaRepo)
```

- [ ] **Step 5: Run tests + build**

Run: `go test ./usecases/ -run TestAssign -v && go build ./...`
Expected: all `TestAssign*` PASS; build clean.

- [ ] **Step 6: Commit**

```bash
git add backend/usecases/assign_tiket_usecase.go backend/usecases/assign_tiket_usecase_test.go backend/main.go
git commit -m "feat(assign): admin-only assignment with free-helpdesk check and reassign notifications"
```

---

## Task 5: `UnassignTiketUseCase` — admin pull-back to pool

**Files:**
- Create: `backend/usecases/unassign_tiket_usecase.go`
- Modify: `backend/main.go` (add wiring line)
- Test: `backend/usecases/unassign_tiket_usecase_test.go` (create)

**Interfaces:**
- Consumes: `fakeTiketRepo`, `fakeNotifikasiRepo`; `tiketRepo.Unassign` (Task 2).
- Produces: `NewUnassignTiketUseCase(tiketRepo interfaces.TiketRepository, notifikasiRepo interfaces.NotifikasiRepository) *UnassignTiketUseCase` and `UnassignTiketInput{ TiketID uuid.UUID; AdminID uuid.UUID; AdminRole entities.Role }`.

- [ ] **Step 1: Write failing tests**

Create `backend/usecases/unassign_tiket_usecase_test.go`:

```go
package usecases

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"eticketinghelpdesk/entities"
)

func TestUnassign_Success(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	hd := uuid.New()
	tk := &entities.Tiket{ID: uuid.New(), Judul: "J", Status: entities.StatusDiproses, DitugaskanKepada: &hd}
	tr.tikets[tk.ID] = tk

	uc := NewUnassignTiketUseCase(tr, nr)
	err := uc.Execute(context.Background(), UnassignTiketInput{TiketID: tk.ID, AdminRole: entities.RoleAdmin})
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
	if len(tr.unassignCalls) != 1 {
		t.Fatalf("expected 1 unassign call, got %d", len(tr.unassignCalls))
	}
	// old helpdesk notified
	found := false
	for _, n := range nr.created {
		if n.PenggunaID == hd {
			found = true
		}
	}
	if !found {
		t.Fatal("old helpdesk should be notified")
	}
}

func TestUnassign_RejectsNonAdmin(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	hd := uuid.New()
	tk := &entities.Tiket{ID: uuid.New(), Status: entities.StatusDiproses, DitugaskanKepada: &hd}
	tr.tikets[tk.ID] = tk

	uc := NewUnassignTiketUseCase(tr, nr)
	err := uc.Execute(context.Background(), UnassignTiketInput{TiketID: tk.ID, AdminRole: entities.RoleHelpdesk})
	if !entities.IsUnauthorized(err) {
		t.Fatalf("expected unauthorized, got %v", err)
	}
}

func TestUnassign_RejectsNonDiproses(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	tk := &entities.Tiket{ID: uuid.New(), Status: entities.StatusTerbuka}
	tr.tikets[tk.ID] = tk

	uc := NewUnassignTiketUseCase(tr, nr)
	err := uc.Execute(context.Background(), UnassignTiketInput{TiketID: tk.ID, AdminRole: entities.RoleAdmin})
	if !entities.IsValidation(err) {
		t.Fatalf("expected validation error, got %v", err)
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `go test ./usecases/ -run TestUnassign -v`
Expected: compile error — `NewUnassignTiketUseCase` / `UnassignTiketInput` undefined.

- [ ] **Step 3: Implement the usecase**

Create `backend/usecases/unassign_tiket_usecase.go`:

```go
package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// UnassignTiketInput holds pull-back input
type UnassignTiketInput struct {
	TiketID   uuid.UUID
	AdminID   uuid.UUID
	AdminRole entities.Role
}

// UnassignTiketUseCase returns a DIPROSES ticket to the pool. Admin only.
type UnassignTiketUseCase struct {
	tiketRepo      interfaces.TiketRepository
	notifikasiRepo interfaces.NotifikasiRepository
}

func NewUnassignTiketUseCase(tiketRepo interfaces.TiketRepository, notifikasiRepo interfaces.NotifikasiRepository) *UnassignTiketUseCase {
	return &UnassignTiketUseCase{tiketRepo: tiketRepo, notifikasiRepo: notifikasiRepo}
}

func (uc *UnassignTiketUseCase) Execute(ctx context.Context, input UnassignTiketInput) error {
	if input.AdminRole != entities.RoleAdmin {
		return entities.NewUnauthorizedError("menarik tiket kembali ke pool")
	}

	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		return err
	}
	if tiket.Status != entities.StatusDiproses {
		return entities.NewValidationError("status", "hanya tiket DIPROSES yang bisa ditarik kembali ke pool")
	}

	var oldAssignee *uuid.UUID
	if tiket.DitugaskanKepada != nil {
		prev := *tiket.DitugaskanKepada
		oldAssignee = &prev
	}

	if err := uc.tiketRepo.Unassign(ctx, input.TiketID); err != nil {
		return fmt.Errorf("failed to unassign ticket: %w", err)
	}

	if oldAssignee != nil {
		notif := &entities.Notifikasi{
			PenggunaID:  *oldAssignee,
			Tipe:        entities.NotifStatusChange,
			ReferensiID: tiket.ID,
			Judul:       "Tiket Ditarik Kembali",
			Pesan:       fmt.Sprintf("Tiket '%s' ditarik kembali ke pool oleh admin", tiket.Judul),
		}
		if err := uc.notifikasiRepo.Create(ctx, notif); err != nil {
			fmt.Printf("warning: failed to create unassign notification: %v\n", err)
		}
	}

	return nil
}
```

- [ ] **Step 4: Wire in main.go**

In `backend/main.go`, after the `assignTiketUC := ...` line, add:

```go
	unassignTiketUC := usecases.NewUnassignTiketUseCase(tiketRepo, notifikasiRepo)
```

(`unassignTiketUC` is consumed by the handler in Task 9. If your editor/linter flags it as unused before Task 9, complete Task 9 in the same working session — it is wired there.)

- [ ] **Step 5: Run tests**

Run: `go test ./usecases/ -run TestUnassign -v`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add backend/usecases/unassign_tiket_usecase.go backend/usecases/unassign_tiket_usecase_test.go backend/main.go
git commit -m "feat(unassign): admin pull-back of a ticket to the pool"
```

---

## Task 6: `GetTiketListUseCase` — helpdesk sees only assigned tickets

**Files:**
- Modify: `backend/usecases/get_tiket_list_usecase.go:71-79`
- Test: `backend/usecases/get_tiket_list_usecase_test.go` (create)

**Interfaces:**
- Consumes: `fakeTiketRepo` (records `lastListFilter`).
- Produces: behavior change only — same `Execute` signature.

- [ ] **Step 1: Write failing tests**

Create `backend/usecases/get_tiket_list_usecase_test.go`:

```go
package usecases

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"eticketinghelpdesk/entities"
)

func TestGetList_HelpdeskSeesOnlyAssigned(t *testing.T) {
	tr := newFakeTiketRepo()
	uc := NewGetTiketListUseCase(tr)
	uid := uuid.New()

	_, err := uc.Execute(context.Background(), GetTiketListInput{
		UserID: uid, UserRole: entities.RoleHelpdesk, Limit: 20,
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if tr.lastListFilter.DitugaskanKepada == nil || *tr.lastListFilter.DitugaskanKepada != uid {
		t.Fatal("helpdesk list must be filtered by DitugaskanKepada = self")
	}
	if tr.lastListFilter.DibuatOleh != nil {
		t.Fatal("helpdesk list must not filter by DibuatOleh")
	}
}

func TestGetList_AdminSeesAll(t *testing.T) {
	tr := newFakeTiketRepo()
	uc := NewGetTiketListUseCase(tr)

	_, err := uc.Execute(context.Background(), GetTiketListInput{
		UserID: uuid.New(), UserRole: entities.RoleAdmin, Limit: 20,
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if tr.lastListFilter.DibuatOleh != nil || tr.lastListFilter.DitugaskanKepada != nil {
		t.Fatal("admin list must not be filtered by owner or assignee")
	}
}

func TestGetList_PenggunaSeesOwn(t *testing.T) {
	tr := newFakeTiketRepo()
	uc := NewGetTiketListUseCase(tr)
	uid := uuid.New()

	_, err := uc.Execute(context.Background(), GetTiketListInput{
		UserID: uid, UserRole: entities.RolePengguna, Limit: 20,
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if tr.lastListFilter.DibuatOleh == nil || *tr.lastListFilter.DibuatOleh != uid {
		t.Fatal("pengguna list must be filtered by DibuatOleh = self")
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `go test ./usecases/ -run TestGetList -v`
Expected: `TestGetList_HelpdeskSeesOnlyAssigned` FAILS (current code leaves both filters nil for helpdesk).

- [ ] **Step 3: Implement the role branch change**

In `backend/usecases/get_tiket_list_usecase.go`, replace the role branch (currently lines ~71-79):

```go
	switch normalizedRole {
	case entities.RoleAdmin:
		// Admin sees all tickets — no owner/assignee filter.
	case entities.RoleHelpdesk:
		// Helpdesk sees only tickets assigned to them (active + their history).
		filter.DitugaskanKepada = &input.UserID
	default:
		// Regular users (and unknown roles for safety) see only their own tickets.
		filter.DibuatOleh = &input.UserID
	}
```

- [ ] **Step 4: Run tests + build**

Run: `go test ./usecases/ -run TestGetList -v && go build ./...`
Expected: all PASS; build clean.

- [ ] **Step 5: Commit**

```bash
git add backend/usecases/get_tiket_list_usecase.go backend/usecases/get_tiket_list_usecase_test.go
git commit -m "feat(list): helpdesk sees only tickets assigned to them"
```

---

## Task 7: `ListAvailableHelpdeskUseCase` — helpdesk list with busy flag

**Files:**
- Create: `backend/usecases/list_available_helpdesk_usecase.go`
- Modify: `backend/main.go` (add wiring line)
- Test: `backend/usecases/list_available_helpdesk_usecase_test.go` (create)

**Interfaces:**
- Consumes: `fakePenggunaRepo.ListByRole`, `fakeTiketRepo.CountActiveByHelpdesk`.
- Produces:
  - `type HelpdeskAvailability struct { ID uuid.UUID; Nama string; Email string; Sibuk bool }`
  - `NewListAvailableHelpdeskUseCase(penggunaRepo interfaces.PenggunaRepository, tiketRepo interfaces.TiketRepository) *ListAvailableHelpdeskUseCase`
  - `(uc *ListAvailableHelpdeskUseCase) Execute(ctx context.Context) ([]HelpdeskAvailability, error)`

- [ ] **Step 1: Write failing tests**

Create `backend/usecases/list_available_helpdesk_usecase_test.go`:

```go
package usecases

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"eticketinghelpdesk/entities"
)

func TestListAvailableHelpdesk_FlagsBusy(t *testing.T) {
	tr := newFakeTiketRepo()
	pr := newFakePenggunaRepo()
	free := &entities.Pengguna{ID: uuid.New(), Nama: "Free", Email: "f@x.io", Peran: entities.RoleHelpdesk}
	busy := &entities.Pengguna{ID: uuid.New(), Nama: "Busy", Email: "b@x.io", Peran: entities.RoleHelpdesk}
	pr.add(free)
	pr.add(busy)
	tr.activeCount[busy.ID] = 1

	uc := NewListAvailableHelpdeskUseCase(pr, tr)
	out, err := uc.Execute(context.Background())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(out) != 2 {
		t.Fatalf("expected 2 helpdesks, got %d", len(out))
	}
	byID := map[uuid.UUID]bool{}
	for _, h := range out {
		byID[h.ID] = h.Sibuk
	}
	if byID[free.ID] != false {
		t.Fatal("free helpdesk should not be busy")
	}
	if byID[busy.ID] != true {
		t.Fatal("busy helpdesk should be flagged busy")
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `go test ./usecases/ -run TestListAvailableHelpdesk -v`
Expected: compile error — symbols undefined.

- [ ] **Step 3: Implement the usecase**

Create `backend/usecases/list_available_helpdesk_usecase.go`:

```go
package usecases

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// HelpdeskAvailability describes a helpdesk and whether they are busy.
type HelpdeskAvailability struct {
	ID    uuid.UUID `json:"id"`
	Nama  string    `json:"nama"`
	Email string    `json:"email"`
	Sibuk bool      `json:"sibuk"`
}

// ListAvailableHelpdeskUseCase lists helpdesks with their busy/free status.
type ListAvailableHelpdeskUseCase struct {
	penggunaRepo interfaces.PenggunaRepository
	tiketRepo    interfaces.TiketRepository
}

func NewListAvailableHelpdeskUseCase(penggunaRepo interfaces.PenggunaRepository, tiketRepo interfaces.TiketRepository) *ListAvailableHelpdeskUseCase {
	return &ListAvailableHelpdeskUseCase{penggunaRepo: penggunaRepo, tiketRepo: tiketRepo}
}

func (uc *ListAvailableHelpdeskUseCase) Execute(ctx context.Context) ([]HelpdeskAvailability, error) {
	helpdesks, err := uc.penggunaRepo.ListByRole(ctx, entities.RoleHelpdesk)
	if err != nil {
		return nil, err
	}

	out := make([]HelpdeskAvailability, 0, len(helpdesks))
	for _, h := range helpdesks {
		active, err := uc.tiketRepo.CountActiveByHelpdesk(ctx, h.ID)
		if err != nil {
			return nil, err
		}
		out = append(out, HelpdeskAvailability{
			ID:    h.ID,
			Nama:  h.Nama,
			Email: h.Email,
			Sibuk: active > 0,
		})
	}
	return out, nil
}
```

- [ ] **Step 4: Wire in main.go**

In `backend/main.go`, after the `unassignTiketUC := ...` line, add:

```go
	listHelpdeskUC := usecases.NewListAvailableHelpdeskUseCase(penggunaRepo, tiketRepo)
```

(Consumed by the handler in Task 9.)

- [ ] **Step 5: Run tests**

Run: `go test ./usecases/ -run TestListAvailableHelpdesk -v`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add backend/usecases/list_available_helpdesk_usecase.go backend/usecases/list_available_helpdesk_usecase_test.go backend/main.go
git commit -m "feat(helpdesk): list available helpdesks with busy flag"
```

---

## Task 8: Harden `UpdateTiketStatusUseCase` — helpdesk may only update their own ticket

**Files:**
- Modify: `backend/usecases/update_tiket_status_usecase.go`
- Test: `backend/usecases/update_tiket_status_usecase_test.go` (create)

**Interfaces:**
- Consumes: `fakeTiketRepo`, `fakeNotifikasiRepo`.
- Produces: behavior change only — same `Execute` signature.

- [ ] **Step 1: Write failing tests**

Create `backend/usecases/update_tiket_status_usecase_test.go`:

```go
package usecases

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"eticketinghelpdesk/entities"
)

func TestUpdateStatus_HelpdeskCanUpdateOwn(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	hd := uuid.New()
	tk := &entities.Tiket{ID: uuid.New(), Judul: "J", Status: entities.StatusDiproses, DitugaskanKepada: &hd}
	tr.tikets[tk.ID] = tk

	uc := NewUpdateTiketStatusUseCase(tr, nr)
	err := uc.Execute(context.Background(), UpdateTiketStatusInput{
		TiketID: tk.ID, NewStatus: entities.StatusSelesai, UserID: hd, UserRole: entities.RoleHelpdesk,
	})
	if err != nil {
		t.Fatalf("helpdesk should update own ticket, got %v", err)
	}
}

func TestUpdateStatus_HelpdeskCannotUpdateOthers(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	owner := uuid.New()
	other := uuid.New()
	tk := &entities.Tiket{ID: uuid.New(), Status: entities.StatusDiproses, DitugaskanKepada: &owner}
	tr.tikets[tk.ID] = tk

	uc := NewUpdateTiketStatusUseCase(tr, nr)
	err := uc.Execute(context.Background(), UpdateTiketStatusInput{
		TiketID: tk.ID, NewStatus: entities.StatusSelesai, UserID: other, UserRole: entities.RoleHelpdesk,
	})
	if !entities.IsUnauthorized(err) {
		t.Fatalf("expected unauthorized, got %v", err)
	}
}

func TestUpdateStatus_AdminCanUpdateAny(t *testing.T) {
	tr := newFakeTiketRepo()
	nr := newFakeNotifikasiRepo()
	owner := uuid.New()
	tk := &entities.Tiket{ID: uuid.New(), Judul: "J", Status: entities.StatusDiproses, DitugaskanKepada: &owner}
	tr.tikets[tk.ID] = tk

	uc := NewUpdateTiketStatusUseCase(tr, nr)
	err := uc.Execute(context.Background(), UpdateTiketStatusInput{
		TiketID: tk.ID, NewStatus: entities.StatusSelesai, UserID: uuid.New(), UserRole: entities.RoleAdmin,
	})
	if err != nil {
		t.Fatalf("admin should update any ticket, got %v", err)
	}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `go test ./usecases/ -run TestUpdateStatus -v`
Expected: `TestUpdateStatus_HelpdeskCannotUpdateOthers` FAILS (no ownership check yet).

- [ ] **Step 3: Implement the ownership guard**

In `backend/usecases/update_tiket_status_usecase.go`, insert immediately after the `GetByID` block (before `tiket.UpdateStatus`):

```go
	// Helpdesk may only change the status of a ticket assigned to them.
	if input.UserRole == entities.RoleHelpdesk {
		if tiket.DitugaskanKepada == nil || *tiket.DitugaskanKepada != input.UserID {
			return entities.NewUnauthorizedError("mengubah status tiket yang bukan ditugaskan kepada Anda")
		}
	}
```

- [ ] **Step 4: Run tests + build**

Run: `go test ./usecases/ -v && go build ./...`
Expected: all usecase tests PASS; build clean.

- [ ] **Step 5: Commit**

```bash
git add backend/usecases/update_tiket_status_usecase.go backend/usecases/update_tiket_status_usecase_test.go
git commit -m "feat(status): helpdesk can only update status of their assigned ticket"
```

---

## Task 9: HTTP handlers + routes (unassign, list helpdesks, admin-only assign)

**Files:**
- Modify: `backend/delivery/http/tiket_handler.go`
- Modify: `backend/main.go` (handler constructor + routes)

**Interfaces:**
- Consumes: `usecases.UnassignTiketUseCase`, `usecases.ListAvailableHelpdeskUseCase`, the `unassignTiketUC` / `listHelpdeskUC` wired in Tasks 5/7, and `supabaseAuthMiddleware.RequireAdmin()` (already exists in `delivery/middleware/supabase_auth.go`).
- Produces: routes `POST /api/tikets/:id/unassign`, `GET /api/helpdesks`; `POST /api/tikets/:id/assign` becomes admin-only.

- [ ] **Step 1: Extend `TiketHandler` struct + constructor**

In `backend/delivery/http/tiket_handler.go`, add two fields to `TiketHandler`:

```go
	unassignTiketUC    *usecases.UnassignTiketUseCase
	listHelpdeskUC     *usecases.ListAvailableHelpdeskUseCase
```

Update `NewTiketHandler` signature and body to accept and assign them (append the two params after `assignUC`):

```go
func NewTiketHandler(
	createUC *usecases.CreateTiketUseCase,
	listUC *usecases.GetTiketListUseCase,
	detailUC *usecases.GetTiketDetailUseCase,
	updateUC *usecases.UpdateTiketStatusUseCase,
	assignUC *usecases.AssignTiketUseCase,
	unassignUC *usecases.UnassignTiketUseCase,
	listHelpdeskUC *usecases.ListAvailableHelpdeskUseCase,
	uploadUC *usecases.UploadLampiranUseCase,
) *TiketHandler {
	return &TiketHandler{
		createTiketUC:       createUC,
		getTiketListUC:      listUC,
		getTiketDetailUC:    detailUC,
		updateTiketStatusUC: updateUC,
		assignTiketUC:       assignUC,
		unassignTiketUC:     unassignUC,
		listHelpdeskUC:      listHelpdeskUC,
		uploadLampiranUC:    uploadUC,
	}
}
```

- [ ] **Step 2: Add the two handler methods**

Append to `backend/delivery/http/tiket_handler.go`:

```go
// UnassignTiket returns a DIPROSES ticket to the pool (admin only).
func (h *TiketHandler) UnassignTiket(c *gin.Context) {
	tuid, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}
	uid, ok := currentUserID(c)
	if !ok {
		return
	}
	peran := c.GetString("peran")

	if err := h.unassignTiketUC.Execute(c.Request.Context(), usecases.UnassignTiketInput{
		TiketID:   tuid,
		AdminID:   uid,
		AdminRole: entities.Role(peran),
	}); err != nil {
		respondDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Tiket dikembalikan ke pool"})
}

// ListHelpdesks returns all helpdesks with their busy/free status (admin only).
func (h *TiketHandler) ListHelpdesks(c *gin.Context) {
	out, err := h.listHelpdeskUC.Execute(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": out})
}
```

Also harden the existing `AssignTiket` handler's error mapping so `ErrHelpdeskSibuk` returns 400 (it already falls through to 400 via the final `c.JSON(http.StatusBadRequest, ...)`, so no change is required — but if you refactor it to `respondDomainError`, note that `ErrHelpdeskSibuk` is not validation/unauthorized/not-found and would map to 500; therefore **keep the existing explicit 400 fallback in `AssignTiket`**).

- [ ] **Step 3: Update DI + routes in main.go**

In `backend/main.go`, update the handler construction (line ~82):

```go
	tiketHandler := httpDelivery.NewTiketHandler(createTiketUC, getTiketListUC, getTiketDetailUC, updateTiketStatusUC, assignTiketUC, unassignTiketUC, listHelpdeskUC, uploadLampiranUC)
```

Change the assign route and add the new routes inside the `tikets` group (replace the current assign line ~139):

```go
			tikets.POST("/:id/assign", supabaseAuthMiddleware.RequireAdmin(), tiketHandler.AssignTiket)
			tikets.POST("/:id/unassign", supabaseAuthMiddleware.RequireAdmin(), tiketHandler.UnassignTiket)
```

And add a helpdesks listing route inside the `protected` group (e.g. just after the dashboard routes, ~line 130):

```go
		protected.GET("/helpdesks", supabaseAuthMiddleware.RequireAdmin(), tiketHandler.ListHelpdesks)
```

- [ ] **Step 4: Build + run + smoke test**

Run: `go build ./... && go vet ./...`
Expected: clean build, no unused-variable errors (all of `unassignTiketUC`, `listHelpdeskUC` are now consumed).

Manual smoke test (requires `.env` with Supabase creds and an admin token from Task 11; run after Task 11 if needed):

```bash
go run .
# in another shell (replace $TOKEN with an admin JWT, $TID with a TERBUKA ticket id, $HID with a free helpdesk id):
curl -s localhost:8080/api/helpdesks -H "Authorization: Bearer $TOKEN"
curl -s -X POST localhost:8080/api/tikets/$TID/assign -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"helpdesk_id\":\"$HID\"}"
curl -s -X POST localhost:8080/api/tikets/$TID/unassign -H "Authorization: Bearer $TOKEN"
```
Expected: `helpdesks` returns a `data` array with `sibuk` flags; assign returns `Tiket berhasil ditugaskan`; a second assign to the same (now busy) helpdesk returns HTTP 400 `helpdesk sedang menangani tiket lain`; unassign returns `Tiket dikembalikan ke pool`.

- [ ] **Step 5: Commit**

```bash
git add backend/delivery/http/tiket_handler.go backend/main.go
git commit -m "feat(http): admin-only assign, add unassign and helpdesks endpoints"
```

---

## Task 10: RLS — tighten helpdesk visibility for direct/Realtime reads

**Files:**
- Create: `supabase/rls_assignment_flow.sql`

**Interfaces:** none (SQL migration applied in the Supabase SQL editor). This is the second-layer defense; backend API correctness is already covered by Tasks 4–8.

- [ ] **Step 1: Write the migration SQL**

Create `supabase/rls_assignment_flow.sql`:

```sql
-- RLS update for admin-mediated assignment flow.
-- Helpdesk now only sees tickets ASSIGNED to them (active + their history).
-- Admin sees everything; pengguna sees their own. Run in Supabase SQL editor.

-- 1) Tiket SELECT
DROP POLICY IF EXISTS "tiket_select_policy" ON tiket;
CREATE POLICY "tiket_select_policy" ON tiket
    FOR SELECT TO authenticated
    USING (
        dibuat_oleh::text = auth.uid()::text
        OR ditugaskan_kepada::text = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM pengguna
            WHERE id::text = auth.uid()::text AND peran = 'admin'
        )
    );

-- 2) Komentar SELECT (helpdesk only on tickets assigned to them)
DROP POLICY IF EXISTS "komentar_select_policy" ON komentar;
CREATE POLICY "komentar_select_policy" ON komentar
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM tiket t
            WHERE t.id = tiket_id
            AND (
                t.dibuat_oleh::text = auth.uid()::text
                OR t.ditugaskan_kepada::text = auth.uid()::text
                OR EXISTS (
                    SELECT 1 FROM pengguna
                    WHERE id::text = auth.uid()::text AND peran = 'admin'
                )
            )
        )
    );

-- 3) Lampiran SELECT (helpdesk only on tickets assigned to them)
DROP POLICY IF EXISTS "lampiran_select_policy" ON lampiran;
CREATE POLICY "lampiran_select_policy" ON lampiran
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM tiket t
            WHERE t.id = tiket_id
            AND (
                t.dibuat_oleh::text = auth.uid()::text
                OR t.ditugaskan_kepada::text = auth.uid()::text
                OR EXISTS (
                    SELECT 1 FROM pengguna
                    WHERE id::text = auth.uid()::text AND peran = 'admin'
                )
            )
        )
    );
```

- [ ] **Step 2: Apply in Supabase**

Open the Supabase Dashboard → SQL Editor → paste the file contents → Run.
Expected: "Success. No rows returned."

- [ ] **Step 3: Verify**

In the SQL editor, confirm the policy bodies updated:

```sql
SELECT polname, pg_get_expr(polqual, polrelid) AS using_expr
FROM pg_policy
WHERE polname IN ('tiket_select_policy','komentar_select_policy','lampiran_select_policy');
```
Expected: each `using_expr` now contains `ditugaskan_kepada` and no longer grants blanket `helpdesk` SELECT (only `admin` in the role EXISTS clause).

- [ ] **Step 4: Commit**

```bash
git add supabase/rls_assignment_flow.sql
git commit -m "feat(rls): restrict helpdesk reads to assigned tickets"
```

---

## Task 11: One-shot admin seed script

**Files:**
- Create: `backend/cmd/seed_admin/main.go`

**Interfaces:**
- Consumes: `config.LoadConfig()`, `repository.NewSupabaseClient`, the Supabase Auth Admin REST API.
- Produces: an admin usable for login (auth user with `user_metadata.peran="admin"`) and a `pengguna` row with `peran='admin'`.

- [ ] **Step 1: Write the seed program**

Create `backend/cmd/seed_admin/main.go`:

```go
package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"

	"eticketinghelpdesk/config"
	"eticketinghelpdesk/repository"
)

func main() {
	_ = godotenv.Load()
	cfg := config.LoadConfig()
	if cfg.SupabaseURL == "" || cfg.SupabaseServiceKey == "" {
		log.Fatal("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
	}

	nama := envOr("ADMIN_NAMA", "Administrator")
	email := envOr("ADMIN_EMAIL", "admin@helpdesk.local")
	password := os.Getenv("ADMIN_PASSWORD")
	if password == "" {
		log.Fatal("ADMIN_PASSWORD must be set (the admin login password)")
	}

	userID, err := createOrGetAuthUser(cfg.SupabaseURL, cfg.SupabaseServiceKey, nama, email, password)
	if err != nil {
		log.Fatalf("failed to create/find auth user: %v", err)
	}
	log.Printf("auth user id: %s", userID)

	if err := upsertPenggunaAdmin(cfg, userID, nama, email); err != nil {
		log.Fatalf("failed to upsert pengguna admin: %v", err)
	}

	log.Printf("✅ admin ready: %s (id=%s, peran=admin)", email, userID)
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func httpClient() *http.Client {
	// HTTP/1.1 only (matches the rest of the codebase; avoids a Windows HTTP/2 crash).
	return &http.Client{
		Timeout: 30 * time.Second,
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}
}

// createOrGetAuthUser creates a Supabase Auth user (admin role in metadata),
// or returns the existing user's id if the email already exists. Idempotent.
func createOrGetAuthUser(baseURL, serviceKey, nama, email, password string) (string, error) {
	body := map[string]interface{}{
		"email":         email,
		"password":      password,
		"email_confirm": true,
		"user_metadata": map[string]interface{}{
			"nama":  nama,
			"peran": "admin",
		},
	}
	raw, _ := json.Marshal(body)

	req, _ := http.NewRequest(http.MethodPost, baseURL+"/auth/v1/admin/users", bytes.NewReader(raw))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("apikey", serviceKey)
	req.Header.Set("Authorization", "Bearer "+serviceKey)

	resp, err := httpClient().Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusCreated {
		var out struct {
			ID string `json:"id"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
			return "", fmt.Errorf("decode create response: %w", err)
		}
		if out.ID == "" {
			return "", fmt.Errorf("auth create returned empty id")
		}
		return out.ID, nil
	}

	// Already exists (422) or other: try to find the user by email.
	if resp.StatusCode == http.StatusUnprocessableEntity || resp.StatusCode == http.StatusConflict {
		id, err := findAuthUserByEmail(baseURL, serviceKey, email)
		if err != nil {
			return "", fmt.Errorf("user exists but lookup failed: %w", err)
		}
		return id, nil
	}

	var errBody bytes.Buffer
	_, _ = errBody.ReadFrom(resp.Body)
	return "", fmt.Errorf("auth admin create failed: status %d: %s", resp.StatusCode, errBody.String())
}

// findAuthUserByEmail pages through admin users to find one by email.
func findAuthUserByEmail(baseURL, serviceKey, email string) (string, error) {
	for page := 1; page <= 20; page++ {
		url := fmt.Sprintf("%s/auth/v1/admin/users?page=%d&per_page=200", baseURL, page)
		req, _ := http.NewRequest(http.MethodGet, url, nil)
		req.Header.Set("apikey", serviceKey)
		req.Header.Set("Authorization", "Bearer "+serviceKey)

		resp, err := httpClient().Do(req)
		if err != nil {
			return "", err
		}
		var out struct {
			Users []struct {
				ID    string `json:"id"`
				Email string `json:"email"`
			} `json:"users"`
		}
		dErr := json.NewDecoder(resp.Body).Decode(&out)
		resp.Body.Close()
		if dErr != nil {
			return "", dErr
		}
		if len(out.Users) == 0 {
			break
		}
		for _, u := range out.Users {
			if u.Email == email {
				return u.ID, nil
			}
		}
	}
	return "", fmt.Errorf("auth user with email %s not found", email)
}

// upsertPenggunaAdmin upserts the pengguna row to peran='admin', keyed on id.
func upsertPenggunaAdmin(cfg *config.AppConfig, userID, nama, email string) error {
	client, err := repository.NewSupabaseClient(cfg)
	if err != nil {
		return err
	}
	data := map[string]interface{}{
		"id":            userID,
		"nama":          nama,
		"email":         email,
		"peran":         "admin",
		"password_hash": "managed_by_supabase_auth", // schema requires NOT NULL; auth is handled by Supabase
		"dibuat_pada":   time.Now(),
	}
	// upsert=true, onConflict="id" -> updates existing row's peran to admin.
	_, _, err = client.GetTable("pengguna").Insert(data, true, "id", "", "").Execute()
	if err != nil {
		return fmt.Errorf("pengguna upsert: %w", err)
	}
	return nil
}
```

- [ ] **Step 2: Build the command**

Run: `go build ./cmd/seed_admin`
Expected: clean build.

- [ ] **Step 3: Run the seeder**

Run (from `backend/`, with `.env` present or env exported):

```bash
ADMIN_NAMA=Administrator ADMIN_EMAIL=admin@helpdesk.local ADMIN_PASSWORD=12345678 go run ./cmd/seed_admin
```

Expected output ends with: `✅ admin ready: admin@helpdesk.local (id=... , peran=admin)`.

- [ ] **Step 4: Verify**

In Supabase Dashboard → Authentication → Users: confirm `admin@helpdesk.local` exists and is confirmed. In SQL editor:

```sql
SELECT id, nama, email, peran FROM pengguna WHERE email = 'admin@helpdesk.local';
```
Expected: one row with `peran = 'admin'`. Re-running the seeder must not error (idempotent).

- [ ] **Step 5: Commit**

```bash
git add backend/cmd/seed_admin/main.go
git commit -m "feat(seed): one-shot admin account provisioning via Supabase Auth Admin API"
```

> Security note: `ADMIN_PASSWORD=12345678` is a weak test-only password. Rotate it (and re-run the seeder, which updates the auth user) before any non-test environment.

---

## Final verification

- [ ] Run the whole backend test suite: `go test ./... -v` → all PASS.
- [ ] Build everything: `go build ./...` → clean.
- [ ] Confirm RLS policies updated (Task 10 Step 3 query).
- [ ] Confirm admin login works end-to-end (log in via the Flutter app or Supabase with `admin@helpdesk.local` / the test password) and that `GET /api/helpdesks` returns 200 for that admin and 403 for a non-admin token.

## What Plan 2 (Flutter UI) will cover

- Remove helpdesk self-assign ("Ambil Tiket") everywhere.
- Helpdesk view: "Sedang Dikerjakan" (their DIPROSES) + "Riwayat Saya" (their SELESAI), action = mark SELESAI.
- Admin screens: pool of TERBUKA tickets with "Tugaskan" (free-helpdesk dropdown from `GET /helpdesks`), plus "Pindahkan" and "Tarik balik ke pool" on DIPROSES tickets.
- `tiket_cubit` + repository wiring for the new endpoints and role-based fetching.
