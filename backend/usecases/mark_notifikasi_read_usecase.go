package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// MarkNotifikasiReadInput holds mark read input
type MarkNotifikasiReadInput struct {
	NotifikasiID uuid.UUID
	UserID       uuid.UUID
	MarkAll      bool
}

// MarkNotifikasiReadUseCase handles marking notifications as read
type MarkNotifikasiReadUseCase struct {
	notifikasiRepo interfaces.NotifikasiRepository
}

// NewMarkNotifikasiReadUseCase creates a new use case instance
func NewMarkNotifikasiReadUseCase(notifikasiRepo interfaces.NotifikasiRepository) *MarkNotifikasiReadUseCase {
	return &MarkNotifikasiReadUseCase{notifikasiRepo: notifikasiRepo}
}

// Execute marks notification(s) as read
func (uc *MarkNotifikasiReadUseCase) Execute(ctx context.Context, input MarkNotifikasiReadInput) error {
	if input.MarkAll {
		// Mark all as read
		return uc.notifikasiRepo.MarkAllAsRead(ctx, input.UserID)
	}

	// Get notification to verify ownership
	notif, err := uc.notifikasiRepo.GetByID(ctx, input.NotifikasiID)
	if err != nil {
		return err
	}

	// Verify ownership
	if notif.PenggunaID != input.UserID {
		return entities.NewUnauthorizedError("menandai notifikasi ini")
	}

	// Mark as read
	if err := uc.notifikasiRepo.MarkAsRead(ctx, input.NotifikasiID); err != nil {
		return fmt.Errorf("failed to mark notification as read: %w", err)
	}

	return nil
}
