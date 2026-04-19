package usecases

import (
	"context"
	"fmt"
	"io"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

type UploadLampiranInput struct {
	TiketID     uuid.UUID
	NamaFile    string
	Ukuran      int64
	TipeFile    string
	ContentType string
	Content     any
	DibuatOleh  uuid.UUID
	UserRole    entities.Role // Added for authorization check
}

type UploadLampiranOutput struct {
	Lampiran *entities.Lampiran
}

type UploadLampiranUseCase struct {
	lampiranRepo interfaces.LampiranRepository
	tiketRepo    interfaces.TiketRepository
}

func NewUploadLampiranUseCase(lampiranRepo interfaces.LampiranRepository, tiketRepo interfaces.TiketRepository) *UploadLampiranUseCase {
	return &UploadLampiranUseCase{
		lampiranRepo: lampiranRepo,
		tiketRepo:    tiketRepo,
	}
}

func (uc *UploadLampiranUseCase) Execute(ctx context.Context, input UploadLampiranInput, userRole entities.Role) (*UploadLampiranOutput, error) {
	fmt.Printf("[DEBUG UC] Starting upload for ticket %s, file: %s, user role: %s, content nil: %v\n", input.TiketID, input.NamaFile, userRole, input.Content == nil)

	// Get ticket details for authorization check
	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		fmt.Printf("[DEBUG UC] Ticket not found: %v\n", err)
		return nil, err
	}

	// Authorization check: Users can only upload attachments to tickets they have access to
	// Rule: Each role can only upload lampiran to tickets they created
	// - Pengguna can upload to their own tickets (tickets where DibuatOleh == userID)
	// - Helpdesk can upload to their own tickets (tickets where DibuatOleh == userID)
	// - Admin can upload to any ticket
	if userRole != entities.RoleAdmin {
		if tiket.DibuatOleh != input.DibuatOleh {
			return nil, entities.ErrUnauthorized
		}
	}

	lampiran, err := entities.NewLampiran(input.TiketID, input.NamaFile, input.Ukuran, input.TipeFile, input.DibuatOleh)
	if err != nil {
		fmt.Printf("[DEBUG UC] Failed to create lampiran entity: %v\n", err)
		return nil, err
	}

	// Prepare file info with actual content (type assert from interface{})
	var contentReader io.Reader
	if input.Content != nil {
		if r, ok := input.Content.(io.Reader); ok {
			contentReader = r
			fmt.Printf("[DEBUG UC] Content is io.Reader\n")
		} else {
			fmt.Printf("[DEBUG UC] Content is NOT io.Reader, type: %T\n", input.Content)
		}
	} else {
		fmt.Printf("[DEBUG UC] Content is nil\n")
	}

	fileInfo := interfaces.FileInfo{
		Name:    input.NamaFile,
		Size:    input.Ukuran,
		Type:    input.ContentType, // Use MIME type for HTTP upload
		Content: contentReader,
	}

	fmt.Printf("[DEBUG UC] Calling repository Create with fileInfo.Content nil: %v\n", fileInfo.Content == nil)

	// Save to repository (includes upload to storage)
	if err := uc.lampiranRepo.Create(ctx, lampiran, fileInfo); err != nil {
		fmt.Printf("[DEBUG UC] Repository Create failed: %v\n", err)
		return nil, fmt.Errorf("failed to upload attachment: %w", err)
	}

	fmt.Printf("[DEBUG UC] Upload successful\n")
	return &UploadLampiranOutput{Lampiran: lampiran}, nil
}
