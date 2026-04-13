package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// CreateTiketInput holds ticket creation input
type CreateTiketInput struct {
	Judul      string
	Deskripsi  string
	DibuatOleh uuid.UUID
}

// CreateTiketOutput holds ticket creation output
type CreateTiketOutput struct {
	Tiket *entities.Tiket
}

// CreateTiketUseCase handles ticket creation
type CreateTiketUseCase struct {
	tiketRepo interfaces.TiketRepository
}

// NewCreateTiketUseCase creates a new use case instance
func NewCreateTiketUseCase(tiketRepo interfaces.TiketRepository) *CreateTiketUseCase {
	return &CreateTiketUseCase{tiketRepo: tiketRepo}
}

// Execute creates a new ticket
func (uc *CreateTiketUseCase) Execute(ctx context.Context, input CreateTiketInput) (*CreateTiketOutput, error) {
	// Create ticket entity
	tiket, err := entities.NewTiket(input.Judul, input.Deskripsi, input.DibuatOleh)
	if err != nil {
		return nil, err
	}

	// Save to repository
	if err := uc.tiketRepo.Create(ctx, tiket); err != nil {
		return nil, fmt.Errorf("failed to create ticket: %w", err)
	}

	return &CreateTiketOutput{Tiket: tiket}, nil
}
