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
	TiketID      uuid.UUID
	HelpdeskID   uuid.UUID
	AssignerID   uuid.UUID
	AssignerRole entities.Role
}

// AssignTiketUseCase handles ticket assignment (and reassignment)
type AssignTiketUseCase struct {
	tiketRepo      interfaces.TiketRepository
	notifikasiRepo interfaces.NotifikasiRepository
	penggunaRepo   interfaces.PenggunaRepository
}

// NewAssignTiketUseCase creates a new use case instance
func NewAssignTiketUseCase(
	tiketRepo interfaces.TiketRepository,
	notifikasiRepo interfaces.NotifikasiRepository,
	penggunaRepo interfaces.PenggunaRepository,
) *AssignTiketUseCase {
	return &AssignTiketUseCase{
		tiketRepo:      tiketRepo,
		notifikasiRepo: notifikasiRepo,
		penggunaRepo:   penggunaRepo,
	}
}

// Execute assigns (or reassigns) a ticket to a free helpdesk. Admin only.
func (uc *AssignTiketUseCase) Execute(ctx context.Context, input AssignTiketInput) error {
	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		return err
	}

	target, err := uc.penggunaRepo.GetByID(ctx, input.HelpdeskID)
	if err != nil {
		return entities.NewNotFoundError("helpdesk")
	}
	if target.Peran != entities.RoleHelpdesk {
		return entities.NewValidationError("helpdesk_id", "target bukan helpdesk")
	}

	active, err := uc.tiketRepo.CountActiveByHelpdesk(ctx, input.HelpdeskID)
	if err != nil {
		return err
	}
	if active > 0 {
		return entities.ErrHelpdeskSibuk
	}

	var oldAssignee *uuid.UUID
	if tiket.DitugaskanKepada != nil {
		prev := *tiket.DitugaskanKepada
		oldAssignee = &prev
	}

	if err := tiket.AssignTo(input.HelpdeskID, input.AssignerRole); err != nil {
		return err
	}

	if err := uc.tiketRepo.Assign(ctx, input.TiketID, input.HelpdeskID); err != nil {
		return fmt.Errorf("failed to assign ticket: %w", err)
	}

	creatorNotif := entities.CreateStatusChangeNotif(tiket.DibuatOleh, tiket.ID, tiket.Judul, entities.StatusDiproses)
	if err := uc.notifikasiRepo.Create(ctx, creatorNotif); err != nil {
		fmt.Printf("warning: failed to create creator notification: %v\n", err)
	}

	newHDNotif := &entities.Notifikasi{
		PenggunaID:  input.HelpdeskID,
		Tipe:        entities.NotifStatusChange,
		ReferensiID: tiket.ID,
		Judul:       "Tiket Ditugaskan ke Anda",
		Pesan:       fmt.Sprintf("Tiket '%s' telah ditugaskan kepada Anda", tiket.Judul),
	}
	if err := uc.notifikasiRepo.Create(ctx, newHDNotif); err != nil {
		fmt.Printf("warning: failed to create helpdesk notification: %v\n", err)
	}

	if oldAssignee != nil && *oldAssignee != input.HelpdeskID {
		oldHDNotif := &entities.Notifikasi{
			PenggunaID:  *oldAssignee,
			Tipe:        entities.NotifStatusChange,
			ReferensiID: tiket.ID,
			Judul:       "Tiket Dipindahkan",
			Pesan:       fmt.Sprintf("Tiket '%s' dipindahkan dari Anda ke helpdesk lain oleh admin", tiket.Judul),
		}
		if err := uc.notifikasiRepo.Create(ctx, oldHDNotif); err != nil {
			fmt.Printf("warning: failed to create reassign notification: %v\n", err)
		}
	}

	return nil
}
