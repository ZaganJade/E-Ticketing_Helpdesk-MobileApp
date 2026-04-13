package interfaces

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// PenggunaRepository defines the interface for user data access
type PenggunaRepository interface {
	// Create creates a new user
	Create(ctx context.Context, pengguna *entities.Pengguna) error

	// GetByID retrieves a user by ID
	GetByID(ctx context.Context, id uuid.UUID) (*entities.Pengguna, error)

	// GetByEmail retrieves a user by email
	GetByEmail(ctx context.Context, email string) (*entities.Pengguna, error)

	// Update updates user data
	Update(ctx context.Context, pengguna *entities.Pengguna) error

	// Delete deletes a user (admin only)
	Delete(ctx context.Context, id uuid.UUID) error

	// List retrieves users with pagination
	List(ctx context.Context, offset, limit int) ([]*entities.Pengguna, error)

	// Count returns total user count
	Count(ctx context.Context) (int64, error)

	// CountByRole returns count of users by role
	CountByRole(ctx context.Context, role entities.Role) (int64, error)
}
