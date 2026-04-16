package usecases

import (
	"context"
	"fmt"
	"io"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// Allowed image extensions for profile photo
var allowedFotoProfilExtensions = []string{".jpg", ".jpeg", ".png"}

// Max file size 5MB
const maxFotoProfilSize = 5 * 1024 * 1024

// UploadFotoProfilInput holds upload input
type UploadFotoProfilInput struct {
	UserID   uuid.UUID
	FileName string
	FileSize int64
	Content  io.Reader
}

// UploadFotoProfilOutput holds upload output
type UploadFotoProfilOutput struct {
	FotoProfilURL string
	Nama          string
}

// UploadFotoProfilUseCase handles profile photo uploads
type UploadFotoProfilUseCase struct {
	penggunaRepo  interfaces.PenggunaRepository
	storageRepo   interfaces.StorageRepository
	supabaseURL   string
}

// NewUploadFotoProfilUseCase creates a new use case instance
func NewUploadFotoProfilUseCase(penggunaRepo interfaces.PenggunaRepository, storageRepo interfaces.StorageRepository, supabaseURL string) *UploadFotoProfilUseCase {
	return &UploadFotoProfilUseCase{
		penggunaRepo: penggunaRepo,
		storageRepo:  storageRepo,
		supabaseURL:  supabaseURL,
	}
}

// Execute uploads a profile photo
func (uc *UploadFotoProfilUseCase) Execute(ctx context.Context, input UploadFotoProfilInput) (*UploadFotoProfilOutput, error) {
	// Validate file type
	if !isValidFotoProfilType(input.FileName) {
		return nil, entities.NewValidationError("file", "format file tidak didukung. Hanya JPG, JPEG, dan PNG yang diizinkan")
	}

	// Validate file size
	if input.FileSize > maxFotoProfilSize {
		return nil, entities.NewValidationError("file", "ukuran file maksimal 5MB")
	}

	// Get current user to check if exists
	pengguna, err := uc.penggunaRepo.GetByID(ctx, input.UserID)
	if err != nil {
		return nil, err
	}

	// Delete old photo if exists
	if pengguna.FotoProfil != "" {
		oldPath := fmt.Sprintf("foto_profil/%s/%s", input.UserID.String(), filepath.Base(pengguna.FotoProfil))
		_ = uc.storageRepo.DeleteFile(ctx, "profile-photos", oldPath)
	}

	// Generate unique filename
	ext := strings.ToLower(filepath.Ext(input.FileName))
	newFileName := fmt.Sprintf("%s_%d%s", input.UserID.String(), time.Now().Unix(), ext)
	path := fmt.Sprintf("foto_profil/%s/%s", input.UserID.String(), newFileName)

	// Upload to storage
	fileInfo := interfaces.FileInfo{
		Name:    newFileName,
		Size:    input.FileSize,
		Type:    getContentType(ext),
		Content: input.Content,
	}

	url, err := uc.storageRepo.UploadFile(ctx, "profile-photos", path, fileInfo)
	if err != nil {
		return nil, fmt.Errorf("failed to upload photo: %w", err)
	}

	// Update user record
	if err := uc.penggunaRepo.UpdateFotoProfil(ctx, input.UserID, url); err != nil {
		// Try to delete uploaded file if update fails
		_ = uc.storageRepo.DeleteFile(ctx, "profile-photos", path)
		return nil, fmt.Errorf("failed to update profile photo: %w", err)
	}

	return &UploadFotoProfilOutput{
		FotoProfilURL: url,
		Nama:          pengguna.Nama,
	}, nil
}

// isValidFotoProfilType checks if file type is allowed
func isValidFotoProfilType(filename string) bool {
	ext := strings.ToLower(filepath.Ext(filename))
	for _, allowed := range allowedFotoProfilExtensions {
		if ext == allowed {
			return true
		}
	}
	return false
}

// getContentType returns content type based on extension
func getContentType(ext string) string {
	switch ext {
	case ".jpg", ".jpeg":
		return "image/jpeg"
	case ".png":
		return "image/png"
	default:
		return "application/octet-stream"
	}
}
