package entities

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

// Status represents ticket status type
type Status string

const (
	StatusTerbuka  Status = "TERBUKA"
	StatusDiproses Status = "DIPROSES"
	StatusSelesai  Status = "SELESAI"
)

// Tiket represents a support ticket
type Tiket struct {
	ID                uuid.UUID  `json:"id"`
	Judul             string     `json:"judul"`
	Deskripsi         string     `json:"deskripsi"`
	Status            Status     `json:"status"`
	DibuatOleh        uuid.UUID  `json:"dibuat_oleh"`
	DitugaskanKepada  *uuid.UUID `json:"ditugaskan_kepada,omitempty"`
	DibuatPada        time.Time  `json:"dibuat_pada"`
	DiperbaruiPada    time.Time  `json:"diperbarui_pada"`
	SelesaiPada       *time.Time `json:"selesai_pada,omitempty"`
	// Nested relations from Supabase
	Pengguna  *PenggunaInfo  `json:"pengguna,omitempty"`
	Assigned  *PenggunaInfo  `json:"assigned,omitempty"`
}

// PenggunaInfo holds basic user info from relations
type PenggunaInfo struct {
	Nama string `json:"nama"`
}

// NewTiket creates a new ticket
func NewTiket(judul, deskripsi string, dibuatOleh uuid.UUID) (*Tiket, error) {
	if err := validateTiket(judul, deskripsi); err != nil {
		return nil, err
	}

	return &Tiket{
		ID:         uuid.New(),
		Judul:      judul,
		Deskripsi:  deskripsi,
		Status:     StatusTerbuka,
		DibuatOleh: dibuatOleh,
		DibuatPada: time.Now(),
		DiperbaruiPada: time.Now(),
	}, nil
}

// validateTiket validates ticket fields
func validateTiket(judul, deskripsi string) error {
	if judul == "" {
		return errors.New("judul tidak boleh kosong")
	}
	if len(judul) > 255 {
		return errors.New("judul maksimal 255 karakter")
	}
	if deskripsi == "" {
		return errors.New("deskripsi tidak boleh kosong")
	}
	if len(deskripsi) < 10 {
		return errors.New("deskripsi minimal 10 karakter")
	}
	if len(deskripsi) > 10000 {
		return errors.New("deskripsi maksimal 10000 karakter")
	}
	return nil
}

// IsValidStatus checks if status transition is valid
func IsValidStatus(status Status) bool {
	return status == StatusTerbuka || status == StatusDiproses || status == StatusSelesai
}

// CanTransitionTo checks if current status can transition to target status
func (t *Tiket) CanTransitionTo(target Status) bool {
	switch t.Status {
	case StatusTerbuka:
		return target == StatusDiproses || target == StatusSelesai
	case StatusDiproses:
		return target == StatusSelesai || target == StatusTerbuka // Can reopen
	case StatusSelesai:
		return target == StatusDiproses || target == StatusTerbuka // Can reopen
	}
	return false
}

// UpdateStatus updates ticket status
func (t *Tiket) UpdateStatus(newStatus Status, updaterRole Role) error {
	if !IsValidStatus(newStatus) {
		return errors.New("status tidak valid")
	}

	// Only helpdesk/admin can update status
	if updaterRole != RoleHelpdesk && updaterRole != RoleAdmin {
		return ErrUnauthorized
	}

	if !t.CanTransitionTo(newStatus) {
		return errors.New("transisi status tidak valid")
	}

	t.Status = newStatus
	t.DiperbaruiPada = time.Now()

	if newStatus == StatusSelesai {
		now := time.Now()
		t.SelesaiPada = &now
	}

	return nil
}

// AssignTo assigns ticket to a helpdesk user
func (t *Tiket) AssignTo(helpdeskID uuid.UUID, assignerRole Role) error {
	if assignerRole != RoleHelpdesk && assignerRole != RoleAdmin {
		return errors.New("hanya helpdesk atau admin yang dapat menugaskan tiket")
	}

	t.DitugaskanKepada = &helpdeskID
	t.Status = StatusDiproses
	t.DiperbaruiPada = time.Now()

	return nil
}

// CanEdit checks if user can edit this ticket
func (t *Tiket) CanEdit(userID uuid.UUID, userRole Role) bool {
	// Creator can edit if still TERBUKA
	if t.DibuatOleh == userID && t.Status == StatusTerbuka {
		return true
	}
	// Helpdesk/Admin can always edit
	if userRole == RoleHelpdesk || userRole == RoleAdmin {
		return true
	}
	return false
}

// CanDelete checks if user can delete this ticket
func (t *Tiket) CanDelete(userRole Role) bool {
	return userRole == RoleAdmin
}

// GetPembuatNama returns creator name from nested relation
func (t *Tiket) GetPembuatNama() string {
	if t.Pengguna != nil {
		return t.Pengguna.Nama
	}
	return ""
}

// GetPenanggungJawabNama returns assignee name from nested relation
func (t *Tiket) GetPenanggungJawabNama() string {
	if t.Assigned != nil {
		return t.Assigned.Nama
	}
	return ""
}

// IsAssigned checks if ticket is assigned to someone
func (t *Tiket) IsAssigned() bool {
	return t.DitugaskanKepada != nil
}
