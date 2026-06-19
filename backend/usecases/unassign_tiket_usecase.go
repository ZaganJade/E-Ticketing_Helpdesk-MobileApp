package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// UnassignTiketInput holds pull-back input
type UnassignTiketInput struct {
	TiketID   uuid.UUID
	AdminID   uuid.UUID
	AdminRole entities.Role
}

// UnassignTiketUseCase returns a DIPROSES ticket to the pool. Admin only.
type UnassignTiketUseCase struct {
	tiketRepo      interfaces.TiketRepository
	notifikasiRepo interfaces.NotifikasiRepository
}

// NewUnassignTiketUseCase creates a new use case instance
func NewUnassignTiketUseCase(tiketRepo interfaces.TiketRepository, notifikasiRepo interfaces.NotifikasiRepository) *UnassignTiketUseCase {
	return &UnassignTiketUseCase{tiketRepo: tiketRepo, notifikasiRepo: notifikasiRepo}
}

// Execute pulls a DIPROSES ticket back to the pool
func (uc *UnassignTiketUseCase) Execute(ctx context.Context, input UnassignTiketInput) error {
	if input.AdminRole != entities.RoleAdmin {
		return entities.NewUnauthorizedError("menarik tiket kembali ke pool")
	}

	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		return err
	}
	if tiket.Status != entities.StatusDiproses {
		return entities.NewValidationError("status", "hanya tiket DIPROSES yang bisa ditarik kembali ke pool")
	}

	var oldAssignee *uuid.UUID
	if tiket.DitugaskanKepada != nil {
		prev := *tiket.DitugaskanKepada
		oldAssignee = &prev
	}

	if err := uc.tiketRepo.Unassign(ctx, input.TiketID); err != nil {
		return fmt.Errorf("failed to unassign ticket: %w", err)
	}

	if oldAssignee != nil {
		notif := &entities.Notifikasi{
			PenggunaID:  *oldAssignee,
			Tipe:        entities.NotifStatusChange,
			ReferensiID: tiket.ID,
			Judul:       "Tiket Ditarik Kembali",
			Pesan:       fmt.Sprintf("Tiket '%s' ditarik kembali ke pool oleh admin", tiket.Judul),
		}
		if err := uc.notifikasiRepo.Create(ctx, notif); err != nil {
			fmt.Printf("warning: failed to create unassign notification: %v\n", err)
		}
	}

	return nil
}
