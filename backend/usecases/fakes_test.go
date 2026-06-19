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
	activeCount    map[uuid.UUID]int64
	lastListFilter interfaces.TiketFilter
	assignCalls    [][2]uuid.UUID
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
func (f *fakeNotifikasiRepo) MarkAsRead(ctx context.Context, id uuid.UUID) error { return nil }
func (f *fakeNotifikasiRepo) MarkAllAsRead(ctx context.Context, userID uuid.UUID) error {
	return nil
}
func (f *fakeNotifikasiRepo) Delete(ctx context.Context, id uuid.UUID) error { return nil }
func (f *fakeNotifikasiRepo) DeleteOld(ctx context.Context, days int) error  { return nil }
func (f *fakeNotifikasiRepo) CountUnread(ctx context.Context, userID uuid.UUID) (int64, error) {
	return 0, nil
}
func (f *fakeNotifikasiRepo) CountByUser(ctx context.Context, userID uuid.UUID) (int64, error) {
	return 0, nil
}

// ---- fakePenggunaRepo ----

type fakePenggunaRepo struct {
	byID   map[uuid.UUID]*entities.Pengguna
	byRole map[entities.Role][]*entities.Pengguna
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
