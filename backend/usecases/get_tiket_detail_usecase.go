package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// GetTiketDetailInput holds detail input
type GetTiketDetailInput struct {
	TiketID  uuid.UUID
	UserID   uuid.UUID
	UserRole entities.Role
}

// GetTiketDetailOutput holds detail output
type GetTiketDetailOutput struct {
	Tiket *entities.Tiket
}

// GetTiketDetailUseCase handles retrieving ticket details
type GetTiketDetailUseCase struct {
	tiketRepo interfaces.TiketRepository
}

// NewGetTiketDetailUseCase creates a new use case instance
func NewGetTiketDetailUseCase(tiketRepo interfaces.TiketRepository) *GetTiketDetailUseCase {
	return &GetTiketDetailUseCase{tiketRepo: tiketRepo}
}

// Execute retrieves ticket details
func (uc *GetTiketDetailUseCase) Execute(ctx context.Context, input GetTiketDetailInput) (*GetTiketDetailOutput, error) {
	// Get ticket with relations
	tiket, err := uc.tiketRepo.GetByIDWithRelations(ctx, input.TiketID)
	if err != nil {
		if err == entities.ErrNotFound {
			return nil, entities.NewNotFoundError("tiket")
		}
		return nil, fmt.Errorf("failed to get ticket: %w", err)
	}

	// Check access permission
	if input.UserRole == entities.RolePengguna && tiket.DibuatOleh != input.UserID {
		return nil, entities.NewUnauthorizedError("melihat tiket ini")
	}

	return &GetTiketDetailOutput{Tiket: tiket}, nil
}
