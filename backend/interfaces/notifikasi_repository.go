package interfaces

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// NotifikasiRepository defines the interface for notification data access
type NotifikasiRepository interface {
	// Create creates a new notification
	Create(ctx context.Context, notifikasi *entities.Notifikasi) error

	// CreateBatch creates multiple notifications in batch
	CreateBatch(ctx context.Context, notifikasiList []*entities.Notifikasi) error

	// GetByID retrieves a notification by ID
	GetByID(ctx context.Context, id uuid.UUID) (*entities.Notifikasi, error)

	// GetByUserID retrieves notifications for a user with pagination
	GetByUserID(ctx context.Context, userID uuid.UUID, onlyUnread bool, offset, limit int) ([]*entities.Notifikasi, error)

	// MarkAsRead marks a notification as read
	MarkAsRead(ctx context.Context, id uuid.UUID) error

	// MarkAllAsRead marks all notifications for a user as read
	MarkAllAsRead(ctx context.Context, userID uuid.UUID) error

	// Delete deletes a notification
	Delete(ctx context.Context, id uuid.UUID) error

	// DeleteOld deletes notifications older than specified days
	DeleteOld(ctx context.Context, days int) error

	// CountUnread returns count of unread notifications for a user
	CountUnread(ctx context.Context, userID uuid.UUID) (int64, error)

	// CountByUser returns total count of notifications for a user
	CountByUser(ctx context.Context, userID uuid.UUID) (int64, error)
}
