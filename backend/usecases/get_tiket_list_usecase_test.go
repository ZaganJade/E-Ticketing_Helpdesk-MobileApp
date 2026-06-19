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
