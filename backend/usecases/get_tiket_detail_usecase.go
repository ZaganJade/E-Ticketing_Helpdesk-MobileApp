package usecases

import (
	"context"
	"fmt"
	"log"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// GetTiketDetailInput holds detail input
type GetTiketDetailInput struct {
	TiketID  uuid.UUID
	UserID   uuid.UUID
	UserRole entities.Role
}

// GetTiketDetailOutput holds detail output
type GetTiketDetailOutput struct {
	Tiket *entities.Tiket
}

// GetTiketDetailUseCase handles retrieving ticket details
type GetTiketDetailUseCase struct {
	tiketRepo interfaces.TiketRepository
}

// NewGetTiketDetailUseCase creates a new use case instance
func NewGetTiketDetailUseCase(tiketRepo interfaces.TiketRepository) *GetTiketDetailUseCase {
	return &GetTiketDetailUseCase{tiketRepo: tiketRepo}
}

// Execute retrieves ticket details
func (uc *GetTiketDetailUseCase) Execute(ctx context.Context, input GetTiketDetailInput) (*GetTiketDetailOutput, error) {
	// Debug logging
	log.Printf("[TICKET DETAIL] User ID: %s, Role: '%s', Ticket ID: %s",
		input.UserID, input.UserRole, input.TiketID)
	log.Printf("[TICKET DETAIL] Expected roles - RolePengguna: '%s', RoleHelpdesk: '%s', RoleAdmin: '%s'",
		entities.RolePengguna, entities.RoleHelpdesk, entities.RoleAdmin)

	// Get ticket with relations
	tiket, err := uc.tiketRepo.GetByIDWithRelations(ctx, input.TiketID)
	if err != nil {
		if err == entities.ErrNotFound {
			return nil, entities.NewNotFoundError("tiket")
		}
		return nil, fmt.Errorf("failed to get ticket: %w", err)
	}

	log.Printf("[TICKET DETAIL] Ticket found, created by: %s", tiket.DibuatOleh)

	// Check access permission
	// Regular users can only see their own tickets
	// Helpdesk and Admin can see all tickets
	isPengguna := input.UserRole == entities.RolePengguna
	isHelpdesk := input.UserRole == entities.RoleHelpdesk
	isAdmin := input.UserRole == entities.RoleAdmin

	log.Printf("[TICKET DETAIL] Role checks - isPengguna: %t, isHelpdesk: %t, isAdmin: %t",
		isPengguna, isHelpdesk, isAdmin)

	// Safety check: if role is unknown, treat as pengguna
	if !isPengguna && !isHelpdesk && !isAdmin {
		log.Printf("[TICKET DETAIL] UNKNOWN ROLE '%s' - treating as pengguna for safety", input.UserRole)
		isPengguna = true
	}

	if isPengguna && tiket.DibuatOleh != input.UserID {
		log.Printf("[TICKET DETAIL] ACCESS DENIED: User %s (role: %s) cannot access ticket %s (created by %s)",
			input.UserID, input.UserRole, input.TiketID, tiket.DibuatOleh)
		return nil, entities.NewUnauthorizedError("melihat tiket ini")
	}

	log.Printf("[TICKET DETAIL] ACCESS GRANTED: User %s (role: %s) can access ticket %s",
		input.UserID, input.UserRole, input.TiketID)

	return &GetTiketDetailOutput{Tiket: tiket}, nil
}
