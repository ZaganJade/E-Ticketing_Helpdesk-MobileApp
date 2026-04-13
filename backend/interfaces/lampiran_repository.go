package interfaces

import (
	"context"
	"io"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// FileInfo holds file metadata for upload
type FileInfo struct {
	Name     string
	Size     int64
	Type     string
	Content  io.Reader
}

// LampiranRepository defines the interface for attachment data access
type LampiranRepository interface {
	// Create creates attachment record and uploads file
	Create(ctx context.Context, lampiran *entities.Lampiran, file FileInfo) error

	// GetByID retrieves an attachment by ID
	GetByID(ctx context.Context, id uuid.UUID) (*entities.Lampiran, error)

	// GetByTiketID retrieves all attachments for a ticket
	GetByTiketID(ctx context.Context, tiketID uuid.UUID) ([]*entities.Lampiran, error)

	// GetDownloadURL generates a signed URL for downloading
	GetDownloadURL(ctx context.Context, lampiran *entities.Lampiran) (string, error)

	// Delete deletes attachment record and file from storage
	Delete(ctx context.Context, id uuid.UUID) error

	// Exists checks if attachment exists
	Exists(ctx context.Context, id uuid.UUID) (bool, error)

	// CountByTiketID returns count of attachments for a ticket
	CountByTiketID(ctx context.Context, tiketID uuid.UUID) (int64, error)

	// GetTotalSize returns total size of attachments for a ticket
	GetTotalSize(ctx context.Context, tiketID uuid.UUID) (int64, error)
}
