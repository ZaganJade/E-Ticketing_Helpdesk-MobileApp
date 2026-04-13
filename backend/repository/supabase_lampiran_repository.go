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

// SupabaseLampiranRepository implements LampiranRepository using Supabase
type SupabaseLampiranRepository struct {
	client *SupabaseClient
}

// NewSupabaseLampiranRepository creates a new repository instance
func NewSupabaseLampiranRepository(client *SupabaseClient) interfaces.LampiranRepository {
	return &SupabaseLampiranRepository{client: client}
}

// Create creates attachment record and uploads file
func (r *SupabaseLampiranRepository) Create(ctx context.Context, lampiran *entities.Lampiran, file interfaces.FileInfo) error {
	// Upload file to Supabase Storage
	path := fmt.Sprintf("%s/%s", lampiran.TiketID, lampiran.NamaFile)
	_, err := r.client.Client.Storage.UploadFile("lampiran_tiket", path, file.Content)
	if err != nil {
		return fmt.Errorf("failed to upload file: %w", err)
	}

	// Store path reference
	lampiran.PathFile = path

	// Create database record
	data := map[string]interface{}{
		"id":          lampiran.ID,
		"tiket_id":    lampiran.TiketID,
		"nama_file":   lampiran.NamaFile,
		"path_file":   lampiran.PathFile,
		"ukuran":      lampiran.Ukuran,
		"tipe_file":   lampiran.TipeFile,
		"dibuat_oleh": lampiran.DibuatOleh,
		"dibuat_pada": lampiran.DibuatPada,
	}

	_, _, err = r.client.GetTable("lampiran").Insert(data, false, "", "", "").Execute()
	if err != nil {
		return fmt.Errorf("failed to create attachment record: %w", err)
	}

	return nil
}

// GetByID retrieves an attachment by ID
func (r *SupabaseLampiranRepository) GetByID(ctx context.Context, id uuid.UUID) (*entities.Lampiran, error) {
	query := r.client.GetTable("lampiran").
		Select("*", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return nil, entities.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get attachment: %w", err)
	}

	return r.parseLampiran(resp)
}

// GetByTiketID retrieves all attachments for a ticket
func (r *SupabaseLampiranRepository) GetByTiketID(ctx context.Context, tiketID uuid.UUID) ([]*entities.Lampiran, error) {
	query := r.client.GetTable("lampiran").
		Select("*", "", false).
		Eq("tiket_id", tiketID.String()).
		Order("dibuat_pada", &postgrest.OrderOpts{Ascending: true})

	resp, _, err := query.Execute()
	if err != nil {
		return nil, fmt.Errorf("failed to get attachments: %w", err)
	}

	return r.parseLampiranList(resp)
}

// GetDownloadURL generates a signed URL for downloading
func (r *SupabaseLampiranRepository) GetDownloadURL(ctx context.Context, lampiran *entities.Lampiran) (string, error) {
	// Generate signed URL with 5 minute expiration
	signedURL, err := r.client.Client.Storage.CreateSignedUrl("lampiran_tiket", lampiran.PathFile, 300)
	if err != nil {
		return "", fmt.Errorf("failed to create signed URL: %w", err)
	}

	return signedURL.SignedURL, nil
}

// Delete deletes attachment record and file from storage
func (r *SupabaseLampiranRepository) Delete(ctx context.Context, id uuid.UUID) error {
	// Get attachment info first
	lampiran, err := r.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Delete from storage
	_, err = r.client.Client.Storage.RemoveFile("lampiran_tiket", []string{lampiran.PathFile})
	if err != nil {
		// Log error but continue to delete DB record
		fmt.Printf("warning: failed to delete file from storage: %v\n", err)
	}

	// Delete from database
	_, _, err = r.client.GetTable("lampiran").
		Delete("", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to delete attachment record: %w", err)
	}

	return nil
}

// Exists checks if attachment exists
func (r *SupabaseLampiranRepository) Exists(ctx context.Context, id uuid.UUID) (bool, error) {
	query := r.client.GetTable("lampiran").
		Select("id", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return false, nil
		}
		return false, fmt.Errorf("failed to check attachment existence: %w", err)
	}

	return len(resp) > 0, nil
}

// CountByTiketID returns count of attachments for a ticket
func (r *SupabaseLampiranRepository) CountByTiketID(ctx context.Context, tiketID uuid.UUID) (int64, error) {
	query := r.client.GetTable("lampiran").
		Select("*", "exact", false).
		Eq("tiket_id", tiketID.String())

	resp, count, err := query.Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count attachments: %w", err)
	}

	_ = resp
	return count, nil
}

// GetTotalSize returns total size of attachments for a ticket
func (r *SupabaseLampiranRepository) GetTotalSize(ctx context.Context, tiketID uuid.UUID) (int64, error) {
	// Get all attachments and sum up sizes
	attachments, err := r.GetByTiketID(ctx, tiketID)
	if err != nil {
		return 0, err
	}

	var totalSize int64
	for _, a := range attachments {
		totalSize += a.Ukuran
	}

	return totalSize, nil
}

// Helper methods

func (r *SupabaseLampiranRepository) parseLampiran(data []byte) (*entities.Lampiran, error) {
	var l entities.Lampiran
	if err := json.Unmarshal(data, &l); err != nil {
		return nil, fmt.Errorf("failed to parse attachment: %w", err)
	}
	return &l, nil
}

func (r *SupabaseLampiranRepository) parseLampiranList(data []byte) ([]*entities.Lampiran, error) {
	var attachments []*entities.Lampiran
	if err := json.Unmarshal(data, &attachments); err != nil {
		return nil, fmt.Errorf("failed to parse attachment list: %w", err)
	}
	return attachments, nil
}
