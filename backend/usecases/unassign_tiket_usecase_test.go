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
