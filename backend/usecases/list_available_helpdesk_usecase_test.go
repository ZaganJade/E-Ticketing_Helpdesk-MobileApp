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
	if byID[free.ID] {
		t.Fatal("free helpdesk should not be busy")
	}
	if !byID[busy.ID] {
		t.Fatal("busy helpdesk should be flagged busy")
	}
}
