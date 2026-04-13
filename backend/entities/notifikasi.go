package entities

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

// NotifType represents notification type
type NotifType string

const (
	NotifStatusChange  NotifType = "status_change"
	NotifKomentarBaru NotifType = "komentar_baru"
)

// Notifikasi represents a notification to a user
type Notifikasi struct {
	ID           uuid.UUID `json:"id"`
	PenggunaID   uuid.UUID `json:"pengguna_id"`
	Tipe         NotifType `json:"tipe"`
	ReferensiID  uuid.UUID `json:"referensi_id"` // ID tiket terkait
	Judul        string    `json:"judul"`
	Pesan        string    `json:"pesan"`
	SudahDibaca  bool      `json:"sudah_dibaca"`
	DibuatPada   time.Time `json:"dibuat_pada"`
	// Transient fields
	TiketJudul   string    `json:"tiket_judul,omitempty"`
}

// NewNotifikasi creates a new notification
func NewNotifikasi(penggunaID uuid.UUID, tipe NotifType, referensiID uuid.UUID, judul, pesan string) (*Notifikasi, error) {
	if err := validateNotifikasi(judul, pesan); err != nil {
		return nil, err
	}

	if !isValidNotifType(tipe) {
		return nil, errors.New("tipe notifikasi tidak valid")
	}

	return &Notifikasi{
		ID:          uuid.New(),
		PenggunaID:  penggunaID,
		Tipe:        tipe,
		ReferensiID: referensiID,
		Judul:       judul,
		Pesan:       pesan,
		SudahDibaca: false,
		DibuatPada:  time.Now(),
	}, nil
}

// CreateStatusChangeNotif creates notification for status change
func CreateStatusChangeNotif(penggunaID, tiketID uuid.UUID, tiketJudul string, newStatus Status) *Notifikasi {
	var pesan string
	switch newStatus {
	case StatusDiproses:
		pesan = "Tiket sedang diproses oleh tim helpdesk"
	case StatusSelesai:
		pesan = "Tiket telah selesai ditangani"
	default:
		pesan = "Status tiket telah diperbarui"
	}

	return &Notifikasi{
		ID:          uuid.New(),
		PenggunaID:  penggunaID,
		Tipe:        NotifStatusChange,
		ReferensiID: tiketID,
		Judul:       "Tiket '" + tiketJudul + "' " + string(newStatus),
		Pesan:       pesan,
		SudahDibaca: false,
		DibuatPada:  time.Now(),
	}
}

// CreateKomentarNotif creates notification for new comment
func CreateKomentarNotif(penggunaID, tiketID uuid.UUID, tiketJudul, penulisNama string, isHelpdesk bool) *Notifikasi {
	var judul string
	if isHelpdesk {
		judul = "Komentar baru dari Helpdesk"
	} else {
		judul = "Komentar baru dari Pembuat Tiket"
	}

	return &Notifikasi{
		ID:          uuid.New(),
		PenggunaID:  penggunaID,
		Tipe:        NotifKomentarBaru,
		ReferensiID: tiketID,
		Judul:       judul,
		Pesan:       "Ada komentar baru pada tiket '" + tiketJudul + "'",
		SudahDibaca: false,
		DibuatPada:  time.Now(),
	}
}

// validateNotifikasi validates notification fields
func validateNotifikasi(judul, pesan string) error {
	if judul == "" {
		return errors.New("judul tidak boleh kosong")
	}
	if len(judul) > 255 {
		return errors.New("judul maksimal 255 karakter")
	}
	if pesan == "" {
		return errors.New("pesan tidak boleh kosong")
	}
	if len(pesan) > 1000 {
		return errors.New("pesan maksimal 1000 karakter")
	}
	return nil
}

// isValidNotifType checks if notification type is valid
func isValidNotifType(tipe NotifType) bool {
	return tipe == NotifStatusChange || tipe == NotifKomentarBaru
}

// MarkAsRead marks notification as read
func (n *Notifikasi) MarkAsRead() {
	n.SudahDibaca = true
}

// IsUnread checks if notification is unread
func (n *Notifikasi) IsUnread() bool {
	return !n.SudahDibaca
}

// BelongsTo checks if notification belongs to user
func (n *Notifikasi) BelongsTo(userID uuid.UUID) bool {
	return n.PenggunaID == userID
}
