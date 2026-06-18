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
