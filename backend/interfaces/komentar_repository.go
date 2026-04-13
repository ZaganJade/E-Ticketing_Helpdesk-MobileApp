package interfaces

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// KomentarRepository defines the interface for comment data access
type KomentarRepository interface {
	// Create creates a new comment
	Create(ctx context.Context, komentar *entities.Komentar) error

	// GetByID retrieves a comment by ID
	GetByID(ctx context.Context, id uuid.UUID) (*entities.Komentar, error)

	// GetByTiketID retrieves all comments for a ticket
	GetByTiketID(ctx context.Context, tiketID uuid.UUID) ([]*entities.Komentar, error)

	// Delete deletes a comment
	Delete(ctx context.Context, id uuid.UUID) error

	// CountByTiketID returns count of comments for a ticket
	CountByTiketID(ctx context.Context, tiketID uuid.UUID) (int64, error)
}
