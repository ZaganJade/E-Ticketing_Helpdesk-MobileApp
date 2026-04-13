package usecases

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// AddKomentarInput holds comment input
type AddKomentarInput struct {
	TiketID   uuid.UUID
	PenulisID uuid.UUID
	IsiPesan  string
}

// AddKomentarOutput holds comment output
type AddKomentarOutput struct {
	Komentar *entities.Komentar
}

// AddKomentarUseCase handles adding comments
type AddKomentarUseCase struct {
	komentarRepo   interfaces.KomentarRepository
	tiketRepo      interfaces.TiketRepository
	notifikasiRepo interfaces.NotifikasiRepository
}

// NewAddKomentarUseCase creates a new use case instance
func NewAddKomentarUseCase(komentarRepo interfaces.KomentarRepository, tiketRepo interfaces.TiketRepository, notifikasiRepo interfaces.NotifikasiRepository) *AddKomentarUseCase {
	return &AddKomentarUseCase{
		komentarRepo:   komentarRepo,
		tiketRepo:      tiketRepo,
		notifikasiRepo: notifikasiRepo,
	}
}

// Execute adds a new comment
func (uc *AddKomentarUseCase) Execute(ctx context.Context, input AddKomentarInput) (*AddKomentarOutput, error) {
	// Get ticket to verify it exists and get creator info
	tiket, err := uc.tiketRepo.GetByID(ctx, input.TiketID)
	if err != nil {
		if entities.IsNotFound(err) {
			return nil, entities.NewNotFoundError("tiket")
		}
		return nil, fmt.Errorf("gagal mengambil data tiket: %w", err)
	}

	// Create comment entity
	komentar, err := entities.NewKomentar(input.TiketID, input.PenulisID, input.IsiPesan)
	if err != nil {
		return nil, entities.ErrValidation
	}

	// Save to repository
	if err := uc.komentarRepo.Create(ctx, komentar); err != nil {
		return nil, fmt.Errorf("gagal menambahkan komentar: %w", err)
	}

	// Notify ticket participants
	uc.notifyParticipants(ctx, tiket, input.PenulisID, komentar)

	return &AddKomentarOutput{Komentar: komentar}, nil
}

// GetKomentarByTiketID retrieves all comments for a ticket with authorization check
func (uc *AddKomentarUseCase) GetKomentarByTiketID(ctx context.Context, tiketID uuid.UUID, userID uuid.UUID, userRole entities.Role) ([]*entities.Komentar, error) {
	// Get the ticket first to check authorization
	tiket, err := uc.tiketRepo.GetByID(ctx, tiketID)
	if err != nil {
		return nil, err
	}

	// Check if user can view comments on this ticket
	// - Ticket creator can view their own ticket's comments
	// - Helpdesk/Admin can view any ticket's comments
	if tiket.DibuatOleh != userID && userRole != entities.RoleHelpdesk && userRole != entities.RoleAdmin {
		return nil, entities.ErrUnauthorized
	}

	return uc.komentarRepo.GetByTiketID(ctx, tiketID)
}

func (uc *AddKomentarUseCase) notifyParticipants(ctx context.Context, tiket *entities.Tiket, penulisID uuid.UUID, komentar *entities.Komentar) {
	isFromHelpdesk := penulisID != tiket.DibuatOleh
	isFromCreator := penulisID == tiket.DibuatOleh

	// If comment from helpdesk, notify creator
	if isFromHelpdesk {
		notif := entities.CreateKomentarNotif(
			tiket.DibuatOleh,
			tiket.ID,
			tiket.Judul,
			"Helpdesk",
			true,
		)
		if err := uc.notifikasiRepo.Create(ctx, notif); err != nil {
			fmt.Printf("warning: failed to notify creator: %v\n", err)
		}
	}

	// If comment from creator and ticket is assigned, notify helpdesk
	if isFromCreator && tiket.DitugaskanKepada != nil {
		notif := entities.CreateKomentarNotif(
			*tiket.DitugaskanKepada,
			tiket.ID,
			tiket.Judul,
			"Pembuat Tiket",
			false,
		)
		if err := uc.notifikasiRepo.Create(ctx, notif); err != nil {
			fmt.Printf("warning: failed to notify helpdesk: %v\n", err)
		}
	}
}
