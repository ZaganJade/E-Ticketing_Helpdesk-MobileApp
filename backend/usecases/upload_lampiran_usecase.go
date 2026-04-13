package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// UploadLampiranInput holds upload input
type UploadLampiranInput struct {
	TiketID    uuid.UUID
	NamaFile   string
	Ukuran     int64
	TipeFile   string
	Content    interface{} // Will be io.Reader
	DibuatOleh uuid.UUID
}

// UploadLampiranOutput holds upload output
type UploadLampiranOutput struct {
	Lampiran *entities.Lampiran
}

// UploadLampiranUseCase handles file uploads
type UploadLampiranUseCase struct {
	lampiranRepo interfaces.LampiranRepository
	tiketRepo    interfaces.TiketRepository
}

// NewUploadLampiranUseCase creates a new use case instance
func NewUploadLampiranUseCase(lampiranRepo interfaces.LampiranRepository, tiketRepo interfaces.TiketRepository) *UploadLampiranUseCase {
	return &UploadLampiranUseCase{
		lampiranRepo: lampiranRepo,
		tiketRepo:    tiketRepo,
	}
}

// Execute uploads a file attachment
func (uc *UploadLampiranUseCase) Execute(ctx context.Context, input UploadLampiranInput) (*UploadLampiranOutput, error) {
	// Verify ticket exists
	_, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		return nil, err
	}

	// Create attachment entity
	lampiran, err := entities.NewLampiran(input.TiketID, input.NamaFile, input.Ukuran, input.TipeFile, input.DibuatOleh)
	if err != nil {
		return nil, err
	}

	// Prepare file info - in real implementation, this would be io.Reader
	fileInfo := interfaces.FileInfo{
		Name:    input.NamaFile,
		Size:    input.Ukuran,
		Type:    input.TipeFile,
		Content: nil, // Would be set by handler
	}

	// Save to repository (includes upload to storage)
	if err := uc.lampiranRepo.Create(ctx, lampiran, fileInfo); err != nil {
		return nil, fmt.Errorf("failed to upload attachment: %w", err)
	}

	return &UploadLampiranOutput{Lampiran: lampiran}, nil
}
