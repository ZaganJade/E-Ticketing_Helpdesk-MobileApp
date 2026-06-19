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
