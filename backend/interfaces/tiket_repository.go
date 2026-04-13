package interfaces

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// TiketFilter defines filter options for listing tickets
type TiketFilter struct {
	Status          *entities.Status
	DibuatOleh      *uuid.UUID
	DitugaskanKepada *uuid.UUID
	SearchQuery     string
}

// TiketRepository defines the interface for ticket data access
type TiketRepository interface {
	// Create creates a new ticket
	Create(ctx context.Context, tiket *entities.Tiket) error

	// GetByID retrieves a ticket by ID
	GetByID(ctx context.Context, id uuid.UUID) (*entities.Tiket, error)

	// GetByIDWithRelations retrieves ticket with creator and assignee info
	GetByIDWithRelations(ctx context.Context, id uuid.UUID) (*entities.Tiket, error)

	// List retrieves tickets with filter and pagination
	List(ctx context.Context, filter TiketFilter, offset, limit int) ([]*entities.Tiket, error)

	// Count returns total tickets matching filter
	Count(ctx context.Context, filter TiketFilter) (int64, error)

	// Update updates ticket data
	Update(ctx context.Context, tiket *entities.Tiket) error

	// UpdateStatus updates only ticket status
	UpdateStatus(ctx context.Context, id uuid.UUID, status entities.Status) error

	// Assign assigns ticket to helpdesk
	Assign(ctx context.Context, id uuid.UUID, helpdeskID uuid.UUID) error

	// Delete deletes a ticket
	Delete(ctx context.Context, id uuid.UUID) error

	// Exists checks if ticket exists
	Exists(ctx context.Context, id uuid.UUID) (bool, error)

	// GetStats returns ticket statistics
	GetStats(ctx context.Context) (*TiketStats, error)

	// GetStatsByUser returns ticket statistics for a specific user
	GetStatsByUser(ctx context.Context, userID uuid.UUID) (*TiketStats, error)
}

// TiketStats holds ticket statistics
type TiketStats struct {
	Total     int64
	Terbuka   int64
	Diproses  int64
	Selesai   int64
}

// GetOpenTickets returns tickets with TERBUKA status
func (r *TiketFilter) GetOpenTickets() {
	status := entities.StatusTerbuka
	r.Status = &status
}

// GetInProgressTickets returns tickets with DIPROSES status
func (r *TiketFilter) GetInProgressTickets() {
	status := entities.StatusDiproses
	r.Status = &status
}

// GetCompletedTickets returns tickets with SELESAI status
func (r *TiketFilter) GetCompletedTickets() {
	status := entities.StatusSelesai
	r.Status = &status
}
