package usecases

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// GetTiketListInput holds list filter input
type GetTiketListInput struct {
	UserID     uuid.UUID
	UserRole   entities.Role
	Status     *entities.Status
	SearchQuery string
	Offset     int
	Limit      int
}

// GetTiketListOutput holds list output
type GetTiketListOutput struct {
	Tikets []*entities.Tiket
	Total  int64
}

// GetTiketListUseCase handles listing tickets with filters
type GetTiketListUseCase struct {
	tiketRepo interfaces.TiketRepository
}

// NewGetTiketListUseCase creates a new use case instance
func NewGetTiketListUseCase(tiketRepo interfaces.TiketRepository) *GetTiketListUseCase {
	return &GetTiketListUseCase{tiketRepo: tiketRepo}
}

// Execute retrieves ticket list based on filters
func (uc *GetTiketListUseCase) Execute(ctx context.Context, input GetTiketListInput) (*GetTiketListOutput, error) {
	// Build filter based on user role
	filter := interfaces.TiketFilter{
		Status:      input.Status,
		SearchQuery: input.SearchQuery,
	}

	// Regular users can only see their own tickets
	if input.UserRole == entities.RolePengguna {
		filter.DibuatOleh = &input.UserID
	}
	// Helpdesk can see all tickets (optionally filtered by assignment)
	if input.UserRole == entities.RoleHelpdesk {
		// Could add filter for assigned tickets only
	}

	// Get tickets
	tikets, err := uc.tiketRepo.List(ctx, filter, input.Offset, input.Limit)
	if err != nil {
		return nil, err
	}

	// Get total count
	total, err := uc.tiketRepo.Count(ctx, filter)
	if err != nil {
		return nil, err
	}

	return &GetTiketListOutput{
		Tikets: tikets,
		Total:  total,
	}, nil
}
