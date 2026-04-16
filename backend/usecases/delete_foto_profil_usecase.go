package usecases

import (
	"context"
	"fmt"
	"path/filepath"

	"github.com/google/uuid"
	"eticketinghelpdesk/interfaces"
)

// DeleteFotoProfilUseCase handles profile photo deletion
type DeleteFotoProfilUseCase struct {
	penggunaRepo interfaces.PenggunaRepository
	storageRepo  interfaces.StorageRepository
}

// NewDeleteFotoProfilUseCase creates a new use case instance
func NewDeleteFotoProfilUseCase(penggunaRepo interfaces.PenggunaRepository, storageRepo interfaces.StorageRepository) *DeleteFotoProfilUseCase {
	return &DeleteFotoProfilUseCase{
		penggunaRepo: penggunaRepo,
		storageRepo:  storageRepo,
	}
}

// DeleteFotoProfilInput holds delete input
type DeleteFotoProfilInput struct {
	UserID uuid.UUID
}

// DeleteFotoProfilOutput holds delete output
type DeleteFotoProfilOutput struct {
	Success bool
}

// Execute deletes a profile photo
func (uc *DeleteFotoProfilUseCase) Execute(ctx context.Context, input DeleteFotoProfilInput) (*DeleteFotoProfilOutput, error) {
	// Get current user
	pengguna, err := uc.penggunaRepo.GetByID(ctx, input.UserID)
	if err != nil {
		return nil, err
	}

	// If no photo exists, just return success
	if pengguna.FotoProfil == "" {
		return &DeleteFotoProfilOutput{Success: true}, nil
	}

	// Delete file from storage
	path := fmt.Sprintf("foto_profil/%s/%s", input.UserID.String(), filepath.Base(pengguna.FotoProfil))
	if err := uc.storageRepo.DeleteFile(ctx, "profile-photos", path); err != nil {
		// Log error but continue to update DB
		fmt.Printf("warning: failed to delete file from storage: %v\n", err)
	}

	// Update user record to remove photo URL
	if err := uc.penggunaRepo.UpdateFotoProfil(ctx, input.UserID, ""); err != nil {
		return nil, fmt.Errorf("failed to remove profile photo: %w", err)
	}

	return &DeleteFotoProfilOutput{Success: true}, nil
}
