package repository

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"github.com/supabase-community/postgrest-go"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// SupabaseNotifikasiRepository implements NotifikasiRepository using Supabase
type SupabaseNotifikasiRepository struct {
	client *SupabaseClient
}

// NewSupabaseNotifikasiRepository creates a new repository instance
func NewSupabaseNotifikasiRepository(client *SupabaseClient) interfaces.NotifikasiRepository {
	return &SupabaseNotifikasiRepository{client: client}
}

// Create creates a new notification
func (r *SupabaseNotifikasiRepository) Create(ctx context.Context, notifikasi *entities.Notifikasi) error {
	data := map[string]interface{}{
		"id":           notifikasi.ID,
		"pengguna_id":  notifikasi.PenggunaID,
		"tipe":         string(notifikasi.Tipe),
		"referensi_id": notifikasi.ReferensiID,
		"judul":        notifikasi.Judul,
		"pesan":        notifikasi.Pesan,
		"sudah_dibaca": notifikasi.SudahDibaca,
		"dibuat_pada":  notifikasi.DibuatPada,
	}

	_, _, err := r.client.GetTable("notifikasi").Insert(data, false, "", "", "").Execute()
	if err != nil {
		return fmt.Errorf("failed to create notification: %w", err)
	}

	return nil
}

// CreateBatch creates multiple notifications in batch
func (r *SupabaseNotifikasiRepository) CreateBatch(ctx context.Context, notifikasiList []*entities.Notifikasi) error {
	if len(notifikasiList) == 0 {
		return nil
	}

	var dataList []map[string]interface{}
	for _, n := range notifikasiList {
		dataList = append(dataList, map[string]interface{}{
			"id":           n.ID,
			"pengguna_id":  n.PenggunaID,
			"tipe":         string(n.Tipe),
			"referensi_id": n.ReferensiID,
			"judul":        n.Judul,
			"pesan":        n.Pesan,
			"sudah_dibaca": n.SudahDibaca,
			"dibuat_pada":  n.DibuatPada,
		})
	}

	_, _, err := r.client.GetTable("notifikasi").Insert(dataList, false, "", "", "").Execute()
	if err != nil {
		return fmt.Errorf("failed to create notifications batch: %w", err)
	}

	return nil
}

// GetByID retrieves a notification by ID
func (r *SupabaseNotifikasiRepository) GetByID(ctx context.Context, id uuid.UUID) (*entities.Notifikasi, error) {
	query := r.client.GetTable("notifikasi").
		Select("*", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return nil, entities.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get notification: %w", err)
	}

	return r.parseNotifikasi(resp)
}

// GetByUserID retrieves notifications for a user with pagination
func (r *SupabaseNotifikasiRepository) GetByUserID(ctx context.Context, userID uuid.UUID, onlyUnread bool, offset, limit int) ([]*entities.Notifikasi, error) {
	query := r.client.GetTable("notifikasi").
		Select("*", "", false).
		Eq("pengguna_id", userID.String())

	if onlyUnread {
		query = query.Eq("sudah_dibaca", "false")
	}

	query = query.
		Order("dibuat_pada", &postgrest.OrderOpts{Ascending: false}).
		Range(offset, offset+limit-1, "")

	resp, _, err := query.Execute()
	if err != nil {
		return nil, fmt.Errorf("failed to get notifications: %w", err)
	}

	return r.parseNotifikasiList(resp)
}

// MarkAsRead marks a notification as read
func (r *SupabaseNotifikasiRepository) MarkAsRead(ctx context.Context, id uuid.UUID) error {
	data := map[string]interface{}{
		"sudah_dibaca": true,
	}

	_, _, err := r.client.GetTable("notifikasi").
		Update(data, "", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to mark notification as read: %w", err)
	}

	return nil
}

// MarkAllAsRead marks all notifications for a user as read
func (r *SupabaseNotifikasiRepository) MarkAllAsRead(ctx context.Context, userID uuid.UUID) error {
	data := map[string]interface{}{
		"sudah_dibaca": true,
	}

	_, _, err := r.client.GetTable("notifikasi").
		Update(data, "", "").
		Eq("pengguna_id", userID.String()).
		Eq("sudah_dibaca", "false").
		Execute()

	if err != nil {
		return fmt.Errorf("failed to mark all notifications as read: %w", err)
	}

	return nil
}

// Delete deletes a notification
func (r *SupabaseNotifikasiRepository) Delete(ctx context.Context, id uuid.UUID) error {
	_, _, err := r.client.GetTable("notifikasi").
		Delete("", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to delete notification: %w", err)
	}

	return nil
}

// DeleteOld deletes notifications older than specified days
func (r *SupabaseNotifikasiRepository) DeleteOld(ctx context.Context, days int) error {
	// This would typically use a database function or raw SQL
	// For now, skip implementation
	return nil
}

// CountUnread returns count of unread notifications for a user
func (r *SupabaseNotifikasiRepository) CountUnread(ctx context.Context, userID uuid.UUID) (int64, error) {
	query := r.client.GetTable("notifikasi").
		Select("*", "exact", false).
		Eq("pengguna_id", userID.String()).
		Eq("sudah_dibaca", "false")

	resp, count, err := query.Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count unread notifications: %w", err)
	}

	_ = resp
	return count, nil
}

// CountByUser returns total count of notifications for a user
func (r *SupabaseNotifikasiRepository) CountByUser(ctx context.Context, userID uuid.UUID) (int64, error) {
	query := r.client.GetTable("notifikasi").
		Select("*", "exact", false).
		Eq("pengguna_id", userID.String())

	resp, count, err := query.Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count notifications: %w", err)
	}

	_ = resp
	return count, nil
}

// Helper methods

func (r *SupabaseNotifikasiRepository) parseNotifikasi(data []byte) (*entities.Notifikasi, error) {
	var n entities.Notifikasi
	if err := json.Unmarshal(data, &n); err != nil {
		return nil, fmt.Errorf("failed to parse notification: %w", err)
	}
	return &n, nil
}

func (r *SupabaseNotifikasiRepository) parseNotifikasiList(data []byte) ([]*entities.Notifikasi, error) {
	var notifications []*entities.Notifikasi
	if err := json.Unmarshal(data, &notifications); err != nil {
		return nil, fmt.Errorf("failed to parse notification list: %w", err)
	}
	return notifications, nil
}
