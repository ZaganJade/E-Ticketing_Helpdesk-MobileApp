package usecases

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// DeleteLampiranInput holds delete input
type DeleteLampiranInput struct {
	LampiranID uuid.UUID
	UserID     uuid.UUID
	UserRole   entities.Role
}

// DeleteLampiranUseCase handles file deletion
type DeleteLampiranUseCase struct {
	lampiranRepo interfaces.LampiranRepository
	tiketRepo    interfaces.TiketRepository
}

// NewDeleteLampiranUseCase creates a new use case instance
func NewDeleteLampiranUseCase(lampiranRepo interfaces.LampiranRepository, tiketRepo interfaces.TiketRepository) *DeleteLampiranUseCase {
	return &DeleteLampiranUseCase{
		lampiranRepo: lampiranRepo,
		tiketRepo:    tiketRepo,
	}
}

// Execute deletes a file attachment
func (uc *DeleteLampiranUseCase) Execute(ctx context.Context, input DeleteLampiranInput) error {
	// Get lampiran
	lampiran, err := uc.lampiranRepo.GetByID(ctx, input.LampiranID)
	if err != nil {
		return err
	}

	// Get ticket status for permission check
	tiket, err := uc.tiketRepo.GetByID(ctx, lampiran.TiketID)
	if err != nil {
		return err
	}

	// Check permission
	if !lampiran.CanDelete(input.UserID, input.UserRole, tiket.Status) {
		return entities.NewUnauthorizedError("menghapus lampiran ini")
	}

	// Delete
	return uc.lampiranRepo.Delete(ctx, input.LampiranID)
}
