package usecases

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// GetNotifikasiListInput holds list input
type GetNotifikasiListInput struct {
	UserID     uuid.UUID
	OnlyUnread bool
	Offset     int
	Limit      int
}

// GetNotifikasiListOutput holds list output
type GetNotifikasiListOutput struct {
	Notifikasi []*entities.Notifikasi
	Total      int64
	UnreadCount int64
}

// GetNotifikasiListUseCase handles listing notifications
type GetNotifikasiListUseCase struct {
	notifikasiRepo interfaces.NotifikasiRepository
}

// NewGetNotifikasiListUseCase creates a new use case instance
func NewGetNotifikasiListUseCase(notifikasiRepo interfaces.NotifikasiRepository) *GetNotifikasiListUseCase {
	return &GetNotifikasiListUseCase{notifikasiRepo: notifikasiRepo}
}

// Execute retrieves notification list
func (uc *GetNotifikasiListUseCase) Execute(ctx context.Context, input GetNotifikasiListInput) (*GetNotifikasiListOutput, error) {
	// Get notifications
	notifikasi, err := uc.notifikasiRepo.GetByUserID(ctx, input.UserID, input.OnlyUnread, input.Offset, input.Limit)
	if err != nil {
		return nil, err
	}

	// Get counts
	total, err := uc.notifikasiRepo.CountByUser(ctx, input.UserID)
	if err != nil {
		return nil, err
	}

	unreadCount, err := uc.notifikasiRepo.CountUnread(ctx, input.UserID)
	if err != nil {
		return nil, err
	}

	return &GetNotifikasiListOutput{
		Notifikasi:  notifikasi,
		Total:       total,
		UnreadCount: unreadCount,
	}, nil
}
