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
	tr.activeCount[hd.ID] = 1
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
