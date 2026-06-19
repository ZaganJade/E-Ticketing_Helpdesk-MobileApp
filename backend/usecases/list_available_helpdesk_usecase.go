package usecases

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// HelpdeskAvailability describes a helpdesk and whether they are busy.
type HelpdeskAvailability struct {
	ID    uuid.UUID `json:"id"`
	Nama  string    `json:"nama"`
	Email string    `json:"email"`
	Sibuk bool      `json:"sibuk"`
}

// ListAvailableHelpdeskUseCase lists helpdesks with their busy/free status.
type ListAvailableHelpdeskUseCase struct {
	penggunaRepo interfaces.PenggunaRepository
	tiketRepo    interfaces.TiketRepository
}

// NewListAvailableHelpdeskUseCase creates a new use case instance
func NewListAvailableHelpdeskUseCase(penggunaRepo interfaces.PenggunaRepository, tiketRepo interfaces.TiketRepository) *ListAvailableHelpdeskUseCase {
	return &ListAvailableHelpdeskUseCase{penggunaRepo: penggunaRepo, tiketRepo: tiketRepo}
}

// Execute returns all helpdesks with their busy/free status
func (uc *ListAvailableHelpdeskUseCase) Execute(ctx context.Context) ([]HelpdeskAvailability, error) {
	helpdesks, err := uc.penggunaRepo.ListByRole(ctx, entities.RoleHelpdesk)
	if err != nil {
		return nil, err
	}

	out := make([]HelpdeskAvailability, 0, len(helpdesks))
	for _, h := range helpdesks {
		active, err := uc.tiketRepo.CountActiveByHelpdesk(ctx, h.ID)
		if err != nil {
			return nil, err
		}
		out = append(out, HelpdeskAvailability{
			ID:    h.ID,
			Nama:  h.Nama,
			Email: h.Email,
			Sibuk: active > 0,
		})
	}
	return out, nil
}
