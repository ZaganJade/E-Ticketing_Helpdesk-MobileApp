package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// AssignTiketInput holds assignment input
type AssignTiketInput struct {
	TiketID    uuid.UUID
	HelpdeskID uuid.UUID
	AssignerID uuid.UUID
	AssignerRole entities.Role
}

// AssignTiketUseCase handles ticket assignment
type AssignTiketUseCase struct {
	tiketRepo      interfaces.TiketRepository
	notifikasiRepo interfaces.NotifikasiRepository
}

// NewAssignTiketUseCase creates a new use case instance
func NewAssignTiketUseCase(tiketRepo interfaces.TiketRepository, notifikasiRepo interfaces.NotifikasiRepository) *AssignTiketUseCase {
	return &AssignTiketUseCase{
		tiketRepo:      tiketRepo,
		notifikasiRepo: notifikasiRepo,
	}
}

// Execute assigns ticket to helpdesk
func (uc *AssignTiketUseCase) Execute(ctx context.Context, input AssignTiketInput) error {
	// Get current ticket
	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		return err
	}

	// Assign ticket
	if err := tiket.AssignTo(input.HelpdeskID, input.AssignerRole); err != nil {
		return err
	}

	// Save changes
	if err := uc.tiketRepo.Assign(ctx, input.TiketID, input.HelpdeskID); err != nil {
		return fmt.Errorf("failed to assign ticket: %w", err)
	}

	// Notify ticket creator
	notif := entities.CreateStatusChangeNotif(
		tiket.DibuatOleh,
		tiket.ID,
		tiket.Judul,
		entities.StatusDiproses,
	)
	if err := uc.notifikasiRepo.Create(ctx, notif); err != nil {
		fmt.Printf("warning: failed to create notification: %v\n", err)
	}

	// Notify assigned helpdesk
	helpdeskNotif := &entities.Notifikasi{
		PenggunaID:  input.HelpdeskID,
		Tipe:        entities.NotifStatusChange,
		ReferensiID: tiket.ID,
		Judul:       "Tiket Ditugaskan ke Anda",
		Pesan:       fmt.Sprintf("Tiket '%s' telah ditugaskan kepada Anda", tiket.Judul),
	}
	if err := uc.notifikasiRepo.Create(ctx, helpdeskNotif); err != nil {
		fmt.Printf("warning: failed to create helpdesk notification: %v\n", err)
	}

	return nil
}
