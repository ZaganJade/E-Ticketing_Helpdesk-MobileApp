package entities

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

// Komentar represents a comment on a ticket
type Komentar struct {
	ID         uuid.UUID `json:"id"`
	TiketID    uuid.UUID `json:"tiket_id"`
	PenulisID  uuid.UUID `json:"penulis_id"`
	IsiPesan   string    `json:"isi_pesan"`
	DibuatPada time.Time `json:"dibuat_pada"`
	// Transient fields (not stored in DB)
	PenulisNama   string `json:"penulis_nama,omitempty"`
	PenulisPeran  Role   `json:"penulis_peran,omitempty"`
}

// NewKomentar creates a new comment
func NewKomentar(tiketID, penulisID uuid.UUID, isiPesan string) (*Komentar, error) {
	if err := validateKomentar(isiPesan); err != nil {
		return nil, err
	}

	return &Komentar{
		ID:         uuid.New(),
		TiketID:    tiketID,
		PenulisID:  penulisID,
		IsiPesan:   isiPesan,
		DibuatPada: time.Now(),
	}, nil
}

// validateKomentar validates comment fields
func validateKomentar(isiPesan string) error {
	if isiPesan == "" {
		return errors.New("isi pesan tidak boleh kosong")
	}
	if len(isiPesan) > 5000 {
		return errors.New("isi pesan maksimal 5000 karakter")
	}
	return nil
}

// CanDelete checks if user can delete this comment
func (k *Komentar) CanDelete(userID uuid.UUID, userRole Role) bool {
	// Admin can delete any comment
	if userRole == RoleAdmin {
		return true
	}
	// Author can delete their own comment
	if k.PenulisID == userID {
		return true
	}
	return false
}

// IsFromHelpdesk checks if comment is from helpdesk/admin
func (k *Komentar) IsFromHelpdesk() bool {
	return k.PenulisPeran == RoleHelpdesk || k.PenulisPeran == RoleAdmin
}

// IsFromCreator checks if comment is from ticket creator
func (k *Komentar) IsFromCreator(tiketDibuatOleh uuid.UUID) bool {
	return k.PenulisID == tiketDibuatOleh
}

// GetPenulisLabel returns label for comment author
func (k *Komentar) GetPenulisLabel() string {
	switch k.PenulisPeran {
	case RoleHelpdesk:
		return "Helpdesk"
	case RoleAdmin:
		return "Admin"
	default:
		return "Pengguna"
	}
}
