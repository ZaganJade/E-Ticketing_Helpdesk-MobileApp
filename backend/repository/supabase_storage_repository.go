package repository

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"eticketinghelpdesk/interfaces"
)

type SupabaseStorageRepository struct {
	client *SupabaseClient
}

func NewSupabaseStorageRepository(client *SupabaseClient) *SupabaseStorageRepository {
	return &SupabaseStorageRepository{client: client}
}

func (r *SupabaseStorageRepository) UploadFile(ctx context.Context, bucket, path string, file interfaces.FileInfo) (string, error) {
	
	content, err := io.ReadAll(file.Content)
	if err != nil {
		return "", fmt.Errorf("failed to read file content: %w", err)
	}

	uploadURL := fmt.Sprintf("%s/storage/v1/object/%s/%s",
		r.client.Config.SupabaseURL,
		bucket,
		path,
	)

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, uploadURL, bytes.NewReader(content))
	if err != nil {
		return "", fmt.Errorf("failed to create upload request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+r.client.Config.SupabaseServiceKey)
	if file.Type != "" {
		req.Header.Set("Content-Type", file.Type)
	} else {
		req.Header.Set("Content-Type", "application/octet-stream")
	}
	req.Header.Set("X-Upsert", "true")

	
	client := &http.Client{
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to upload file: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("upload failed with status %d: %s", resp.StatusCode, string(body))
	}

	// Get public URL
	publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s",
		r.client.Config.SupabaseURL,
		bucket,
		path,
	)

	return publicURL, nil
}

// DeleteFile deletes a file from Supabase Storage
func (r *SupabaseStorageRepository) DeleteFile(ctx context.Context, bucket, path string) error {
	// Build delete URL
	deleteURL := fmt.Sprintf("%s/storage/v1/object/%s/%s",
		r.client.Config.SupabaseURL,
		bucket,
		path,
	)

	// Create HTTP request
	req, err := http.NewRequestWithContext(ctx, http.MethodDelete, deleteURL, nil)
	if err != nil {
		return fmt.Errorf("failed to create delete request: %w", err)
	}

	// Set headers
	req.Header.Set("Authorization", "Bearer "+r.client.Config.SupabaseServiceKey)

	// Execute request with HTTP/1.1 only (avoid HTTP/2 nil pointer dereference on Windows)
	client := &http.Client{
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to delete file: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNotFound {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("delete failed with status %d: %s", resp.StatusCode, string(body))
	}

	return nil
}

// CreateSignedURL creates a signed URL for temporary access to a private file (using HTTP/1.1 only)
func (r *SupabaseStorageRepository) CreateSignedURL(ctx context.Context, bucket, path string, expiresIn int) (string, error) {
	// Use HTTP/1.1 only to avoid nil pointer dereference on Windows
	client := &http.Client{
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}

	// Build signed URL request
	signURL := fmt.Sprintf("%s/storage/v1/object/sign/%s/%s",
		r.client.Config.SupabaseURL,
		bucket,
		path,
	)

	reqBody, _ := json.Marshal(map[string]interface{}{
		"expiresIn": expiresIn,
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
