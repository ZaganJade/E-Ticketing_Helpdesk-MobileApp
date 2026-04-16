package interfaces

import (
	"context"
)

// StorageRepository defines storage operations for file uploads
type StorageRepository interface {
	// UploadFile uploads a file to storage and returns the URL
	UploadFile(ctx context.Context, bucket, path string, file FileInfo) (string, error)

	// DeleteFile deletes a file from storage
	DeleteFile(ctx context.Context, bucket, path string) error

	// CreateSignedURL creates a signed URL for temporary access
	CreateSignedURL(ctx context.Context, bucket, path string, expiresIn int) (string, error)
}
