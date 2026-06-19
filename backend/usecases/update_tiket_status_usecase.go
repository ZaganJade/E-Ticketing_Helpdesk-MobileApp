package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// UpdateTiketStatusInput holds status update input
type UpdateTiketStatusInput struct {
	TiketID   uuid.UUID
	NewStatus entities.Status
	UserID    uuid.UUID
	UserRole  entities.Role
}

// UpdateTiketStatusUseCase handles ticket status updates
type UpdateTiketStatusUseCase struct {
	tiketRepo      interfaces.TiketRepository
	notifikasiRepo interfaces.NotifikasiRepository
}

// NewUpdateTiketStatusUseCase creates a new use case instance
func NewUpdateTiketStatusUseCase(tiketRepo interfaces.TiketRepository, notifikasiRepo interfaces.NotifikasiRepository) *UpdateTiketStatusUseCase {
	return &UpdateTiketStatusUseCase{
		tiketRepo:      tiketRepo,
		notifikasiRepo: notifikasiRepo,
	}
}

// Execute updates ticket status
func (uc *UpdateTiketStatusUseCase) Execute(ctx context.Context, input UpdateTiketStatusInput) error {
	// Get current ticket
	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		return err
	}

	// Helpdesk may only change the status of a ticket assigned to them.
	if input.UserRole == entities.RoleHelpdesk {
		if tiket.DitugaskanKepada == nil || *tiket.DitugaskanKepada != input.UserID {
			return entities.NewUnauthorizedError("mengubah status tiket yang bukan ditugaskan kepada Anda")
		}
	}

	// Validate and update status
	if err := tiket.UpdateStatus(input.NewStatus, input.UserRole); err != nil {
		return err
	}

	// Save changes
	if err := uc.tiketRepo.Update(ctx, tiket); err != nil {
		return fmt.Errorf("failed to update ticket status: %w", err)
	}

	// Create notification for ticket creator
	notif := entities.CreateStatusChangeNotif(
		tiket.DibuatOleh,
		tiket.ID,
		tiket.Judul,
		input.NewStatus,
	)
	if err := uc.notifikasiRepo.Create(ctx, notif); err != nil {
		// Log error but don't fail the operation
		fmt.Printf("warning: failed to create notification: %v\n", err)
	}

	return nil
}
