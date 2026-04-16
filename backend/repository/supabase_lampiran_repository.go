package repository

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"

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

// Create creates attachment record and uploads file (using HTTP/1.1 only)
func (r *SupabaseLampiranRepository) Create(ctx context.Context, lampiran *entities.Lampiran, file interfaces.FileInfo) error {
	// Validate file content
	if file.Content == nil {
		return fmt.Errorf("file content is nil")
	}

	// Read file content
	content, err := io.ReadAll(file.Content)
	if err != nil {
		return fmt.Errorf("failed to read file content: %w", err)
	}

	fmt.Printf("[DEBUG] Uploading file: %s, size: %d bytes\n", file.Name, len(content))

	// Use HTTP/1.1 only to avoid nil pointer dereference on Windows
	client := &http.Client{
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}

	// Build upload path with URL-encoded bucket name
	path := fmt.Sprintf("%s/%s", lampiran.TiketID, lampiran.NamaFile)
	bucketName := url.PathEscape("Lampiran E-Ticket")
	uploadURL := fmt.Sprintf("%s/storage/v1/object/%s/%s",
		r.client.Config.SupabaseURL,
		bucketName,
		path,
	)

	// Create HTTP request
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, uploadURL, bytes.NewReader(content))
	if err != nil {
		return fmt.Errorf("failed to create upload request: %w", err)
	}

	// Set headers
	req.Header.Set("Authorization", "Bearer "+r.client.Config.SupabaseServiceKey)
	if file.Type != "" {
		req.Header.Set("Content-Type", file.Type)
	} else {
		req.Header.Set("Content-Type", "application/octet-stream")
	}
	req.Header.Set("X-Upsert", "true")

	// Execute request
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to upload file: %w", err)
	}
	defer resp.Body.Close()

	fmt.Printf("[DEBUG] Upload response status: %d\n", resp.StatusCode)

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("[DEBUG] Upload error response: %s\n", string(body))
		return fmt.Errorf("upload failed with status %d: %s", resp.StatusCode, string(body))
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
		fmt.Printf("[DEBUG] Database insert error: %v\n", err)
		return fmt.Errorf("failed to create attachment record: %w", err)
	}

	fmt.Printf("[DEBUG] Successfully created lampiran record: %s\n", lampiran.ID)

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

// GetDownloadURL generates a signed URL for downloading (using HTTP/1.1 only)
func (r *SupabaseLampiranRepository) GetDownloadURL(ctx context.Context, lampiran *entities.Lampiran) (string, error) {
	// Use HTTP/1.1 only to avoid nil pointer dereference on Windows
	client := &http.Client{
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}

	// Build signed URL request with URL-encoded bucket name
	bucketName := url.PathEscape("Lampiran E-Ticket")
	signURL := fmt.Sprintf("%s/storage/v1/object/sign/%s/%s",
		r.client.Config.SupabaseURL,
		bucketName,
		lampiran.PathFile,
	)

	reqBody, _ := json.Marshal(map[string]interface{}{
		"expiresIn": 300, // 5 minutes
	})

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, signURL, bytes.NewReader(reqBody))
	if err != nil {
		return "", fmt.Errorf("failed to create sign request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+r.client.Config.SupabaseServiceKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to create signed URL: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("sign request failed with status %d: %s", resp.StatusCode, string(body))
	}

	var result struct {
		SignedURL string `json:"signedURL"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", fmt.Errorf("failed to decode signed URL response: %w", err)
	}

	return result.SignedURL, nil
}

// Delete deletes attachment record and file from storage (using HTTP/1.1 only)
func (r *SupabaseLampiranRepository) Delete(ctx context.Context, id uuid.UUID) error {
	// Get attachment info first
	lampiran, err := r.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Use HTTP/1.1 only to avoid nil pointer dereference on Windows
	client := &http.Client{
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}

	// Delete from storage using direct HTTP request with URL-encoded bucket name
	bucketName := url.PathEscape("Lampiran E-Ticket")
	deleteURL := fmt.Sprintf("%s/storage/v1/object/%s/%s",
		r.client.Config.SupabaseURL,
		bucketName,
		lampiran.PathFile,
	)

	req, err := http.NewRequestWithContext(ctx, http.MethodDelete, deleteURL, nil)
	if err != nil {
		fmt.Printf("warning: failed to create delete request: %v\n", err)
	} else {
		req.Header.Set("Authorization", "Bearer "+r.client.Config.SupabaseServiceKey)

		resp, err := client.Do(req)
		if err != nil {
			fmt.Printf("warning: failed to delete file from storage: %v\n", err)
		} else {
			resp.Body.Close()
		}
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
