package usecases

import (
	"context"
	"log"

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

// Execute retrieves ticket list based on filters (optimized)
func (uc *GetTiketListUseCase) Execute(ctx context.Context, input GetTiketListInput) (*GetTiketListOutput, error) {
	// Normalize role to handle both "helpdesk" and "Peran.helpdesk" formats
	roleMap := map[string]entities.Role{
		"pengguna":       entities.RolePengguna,
		"helpdesk":       entities.RoleHelpdesk,
		"admin":          entities.RoleAdmin,
		"Peran.pengguna":  entities.RolePengguna,
		"Peran.helpdesk":  entities.RoleHelpdesk,
		"Peran.admin":     entities.RoleAdmin,
		"entities.pengguna": entities.RolePengguna,
		"entities.helpdesk": entities.RoleHelpdesk,
		"entities.admin":    entities.RoleAdmin,
	}
	normalizedRole := input.UserRole
	if r, ok := roleMap[string(input.UserRole)]; ok {
		normalizedRole = r
		log.Printf("[TICKET LIST] Role normalized from %q to %q", string(input.UserRole), string(normalizedRole))
	}

	// // Debug logging (reduced for performance)
	// log.Printf("[TICKET LIST] User: %s, Role: %s", input.UserID, input.UserRole)

	// Build filter based on user role
	filter := interfaces.TiketFilter{
		Status:      input.Status,
		SearchQuery: input.SearchQuery,
	}

	// Apply filter based on user role
	switch normalizedRole {
	case entities.RoleAdmin:
		// Admin sees all tickets — no owner/assignee filter.
	case entities.RoleHelpdesk:
		// Helpdesk sees only tickets assigned to them (active + their history).
		filter.DitugaskanKepada = &input.UserID
	default:
		// Regular users (and unknown roles for safety) see only their own tickets.
		filter.DibuatOleh = &input.UserID
	}

	// Execute queries in parallel for better performance
	type result struct {
		tikets []*entities.Tiket
		total  int64
		err    error
	}

	resultChan := make(chan result, 2)

	// Fetch tickets
	go func() {
		t, e := uc.tiketRepo.List(ctx, filter, input.Offset, input.Limit)
		resultChan <- result{tikets: t, err: e}
	}()

	// Fetch count
	go func() {
		c, e := uc.tiketRepo.Count(ctx, filter)
		resultChan <- result{total: c, err: e}
	}()

	// Collect results
	var tikets []*entities.Tiket
	var total int64
	var tiketsErr, countErr error

	for i := 0; i < 2; i++ {
		r := <-resultChan
		if r.tikets != nil {
			tikets = r.tikets
			tiketsErr = r.err
		}
		if r.err != nil {
			countErr = r.err
		} else {
			total = r.total
		}
	}

	// Handle errors - prioritize tiket error over count error
	if tiketsErr != nil {
		return nil, tiketsErr
	}
	if countErr != nil {
		return nil, countErr
	}

	return &GetTiketListOutput{
		Tikets: tikets,
		Total:  total,
	}, nil
}
