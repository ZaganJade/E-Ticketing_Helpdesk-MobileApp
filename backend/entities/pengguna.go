package entities

import (
	"errors"
	"regexp"
	"time"

	"github.com/google/uuid"
)

// Role represents user role type
type Role string

const (
	RolePengguna Role = "pengguna"
	RoleHelpdesk Role = "helpdesk"
	RoleAdmin    Role = "admin"
)

// Pengguna represents a user in the system
type Pengguna struct {
	ID           uuid.UUID `json:"id"`
	Nama         string    `json:"nama"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"` // Never expose in JSON
	Peran        Role      `json:"peran"`
	FotoProfil   string    `json:"foto_profil,omitempty"`
	DibuatPada   time.Time `json:"dibuat_pada"`
	DiperbaruiPada time.Time `json:"diperbarui_pada"`
}

// NewPengguna creates a new user entity
func NewPengguna(nama, email, passwordHash string, peran Role) (*Pengguna, error) {
	if err := validatePengguna(nama, email, passwordHash, peran); err != nil {
		return nil, err
	}

	return &Pengguna{
		ID:           uuid.New(),
		Nama:         nama,
		Email:        email,
		PasswordHash: passwordHash,
		Peran:        peran,
		DibuatPada:   time.Now(),
		DiperbaruiPada: time.Now(),
	}, nil
}

// validatePengguna validates user fields
func validatePengguna(nama, email, passwordHash string, peran Role) error {
	if nama == "" {
		return errors.New("nama tidak boleh kosong")
	}
	if len(nama) > 100 {
		return errors.New("nama maksimal 100 karakter")
	}
	if email == "" {
		return errors.New("email tidak boleh kosong")
	}
	if !isValidEmail(email) {
		return errors.New("format email tidak valid")
	}
	if passwordHash == "" {
		return errors.New("password hash tidak boleh kosong")
	}
	if !isValidRole(peran) {
		return errors.New("peran tidak valid")
	}
	return nil
}

// isValidEmail checks if email format is valid
func isValidEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	re := regexp.MustCompile(pattern)
	return re.MatchString(email)
}

// isValidRole checks if role is valid
func isValidRole(role Role) bool {
	return role == RolePengguna || role == RoleHelpdesk || role == RoleAdmin
}

// CanAccessAllTickets checks if user can access all tickets
func (p *Pengguna) CanAccessAllTickets() bool {
	return p.Peran == RoleHelpdesk || p.Peran == RoleAdmin
}

// CanUpdateTicketStatus checks if user can update ticket status
func (p *Pengguna) CanUpdateTicketStatus() bool {
	return p.Peran == RoleHelpdesk || p.Peran == RoleAdmin
}

// CanDeleteTicket checks if user can delete tickets
func (p *Pengguna) CanDeleteTicket() bool {
	return p.Peran == RoleAdmin
}

// UpdateNama updates user's name
func (p *Pengguna) UpdateNama(nama string) error {
	if nama == "" {
		return errors.New("nama tidak boleh kosong")
	}
	if len(nama) > 100 {
		return errors.New("nama maksimal 100 karakter")
	}
	p.Nama = nama
	p.DiperbaruiPada = time.Now()
	return nil
}

// UpdateFotoProfil updates user's profile photo URL
func (p *Pengguna) UpdateFotoProfil(url string) error {
	p.FotoProfil = url
	p.DiperbaruiPada = time.Now()
	return nil
}

// DeleteFotoProfil removes user's profile photo
func (p *Pengguna) DeleteFotoProfil() {
	p.FotoProfil = ""
	p.DiperbaruiPada = time.Now()
}
