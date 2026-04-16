package entities

import (
	"errors"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
)

// Allowed file types
var AllowedFileTypes = []string{"jpg", "jpeg", "png", "pdf", "doc", "docx"}

// Max file size: 10MB
const MaxFileSize int64 = 10 * 1024 * 1024

// Lampiran represents a file attachment
type Lampiran struct {
	ID         uuid.UUID `json:"id"`
	TiketID    uuid.UUID `json:"tiket_id"`
	NamaFile   string    `json:"nama_file"`
	PathFile   string    `json:"path_file"`
	Ukuran     int64     `json:"ukuran"`
	TipeFile   string    `json:"tipe_file"`
	DibuatOleh uuid.UUID `json:"dibuat_oleh"`
	DibuatPada time.Time `json:"dibuat_pada"`
}

// NewLampiran creates a new attachment
func NewLampiran(tiketID uuid.UUID, namaFile string, ukuran int64, tipeFile string, dibuatOleh uuid.UUID) (*Lampiran, error) {
	if err := validateLampiran(namaFile, ukuran, tipeFile); err != nil {
		return nil, err
	}

	return &Lampiran{
		ID:         uuid.New(),
		TiketID:    tiketID,
		NamaFile:   namaFile,
		Ukuran:     ukuran,
		TipeFile:   strings.ToLower(tipeFile),
		DibuatOleh: dibuatOleh,
		DibuatPada: time.Now(),
	}, nil
}

// validateLampiran validates attachment fields
func validateLampiran(namaFile string, ukuran int64, tipeFile string) error {
	if namaFile == "" {
		return errors.New("nama file tidak boleh kosong")
	}
	if len(namaFile) > 255 {
		return errors.New("nama file maksimal 255 karakter")
	}
	if ukuran <= 0 {
		return errors.New("ukuran file tidak valid")
	}
	if ukuran > MaxFileSize {
		return errors.New("ukuran file maksimal 10MB")
	}
	if !IsAllowedFileType(tipeFile) {
		return errors.New("tipe file tidak diizinkan")
	}
	return nil
}

// IsAllowedFileType checks if file type is allowed
// Accepts: "jpg", ".jpg", "file.jpg", "image/jpeg"
func IsAllowedFileType(tipeFile string) bool {
	tipeFile = strings.ToLower(strings.TrimSpace(tipeFile))
	if tipeFile == "" {
		return false
	}

	// If it contains a slash, it's a MIME type - extract extension
	if strings.Contains(tipeFile, "/") {
		tipeFile = mimeToExt(tipeFile)
	}

	// Remove leading dot if present
	ext := strings.TrimPrefix(tipeFile, ".")

	// If ext contains a dot, extract the extension properly
	if strings.Contains(ext, ".") {
		ext = strings.ToLower(strings.TrimPrefix(filepath.Ext(ext), "."))
	}

	for _, allowed := range AllowedFileTypes {
		if ext == allowed {
			return true
		}
	}
	return false
}

// mimeToExt converts common MIME types to file extensions
func mimeToExt(mimeType string) string {
	switch mimeType {
	case "image/jpeg":
		return "jpg"
	case "image/png":
		return "png"
	case "image/gif":
		return "gif"
	case "application/pdf":
		return "pdf"
	case "application/msword":
		return "doc"
	case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
		return "docx"
	default:
		return ""
	}
}

// GetFileExtension returns file extension
func GetFileExtension(namaFile string) string {
	return strings.ToLower(strings.TrimPrefix(filepath.Ext(namaFile), "."))
}

// IsImage checks if file is an image
func (l *Lampiran) IsImage() bool {
	return l.TipeFile == "jpg" || l.TipeFile == "jpeg" || l.TipeFile == "png"
}

// CanDelete checks if user can delete this attachment
func (l *Lampiran) CanDelete(userID uuid.UUID, userRole Role, tiketStatus Status) bool {
	// Admin can delete any attachment
	if userRole == RoleAdmin {
		return true
	}
	// Creator can delete if ticket is still TERBUKA
	if l.DibuatOleh == userID && tiketStatus == StatusTerbuka {
		return true
	}
	return false
}

// FormatSize returns human-readable file size
func (l *Lampiran) FormatSize() string {
	const (
		KB = 1024
		MB = 1024 * KB
	)

	switch {
	case l.Ukuran >= MB:
		return formatFloat(float64(l.Ukuran)/float64(MB)) + " MB"
	case l.Ukuran >= KB:
		return formatFloat(float64(l.Ukuran)/float64(KB)) + " KB"
	default:
		return formatFloat(float64(l.Ukuran)) + " B"
	}
}

func formatFloat(f float64) string {
	return strings.TrimRight(strings.TrimRight(strconv.FormatFloat(f, 'f', 2, 64), "0"), ".")
}
