package http

import (
	"fmt"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
	"eticketinghelpdesk/usecases"
)

// LampiranHandler handles file attachment HTTP requests
type LampiranHandler struct {
	uploadUC   *usecases.UploadLampiranUseCase
	deleteUC   *usecases.DeleteLampiranUseCase
	lampiranRepo interfaces.LampiranRepository
}

// NewLampiranHandler creates a new handler instance
func NewLampiranHandler(uploadUC *usecases.UploadLampiranUseCase, deleteUC *usecases.DeleteLampiranUseCase, repo interfaces.LampiranRepository) *LampiranHandler {
	return &LampiranHandler{
			uploadUC:   uploadUC,
			deleteUC:   deleteUC,
			lampiranRepo: repo,
	}
}

// UploadLampiran handles file upload with role-based authorization
func (h *LampiranHandler) UploadLampiran(c *gin.Context) {
	tiketID := c.Param("id")
	tuid := uuid.MustParse(tiketID)

	// Get uploaded file
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File tidak ditemukan"})
		return
	}
	defer file.Close()

	// Validate file type
	ext := filepath.Ext(header.Filename)
	if !entities.IsAllowedFileType(ext) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tipe file tidak diizinkan"})
		return
	}

	// Validate file size
	if header.Size > entities.MaxFileSize {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ukuran file maksimal 10MB"})
		return
	}

	userID := c.GetString("userID")
	uid := uuid.MustParse(userID)

	// Get user role for authorization
	peran := c.GetString("peran")
	userRole := entities.Role(peran)

	// Get MIME type for upload, but use extension for entity (entity stores extensions)
	mimeType := header.Header.Get("Content-Type")
	if mimeType == "" {
		mimeType = getMimeTypeFromExt(ext)
	}

	// Remove leading dot from extension for entity validation
	extForEntity := strings.TrimPrefix(ext, ".")

	fmt.Printf("[DEBUG] Uploading file: %s, ext: '%s', extForEntity: '%s', MIME: %s, size: %d\n", header.Filename, ext, extForEntity, mimeType, header.Size)

	output, err := h.uploadUC.Execute(c.Request.Context(), usecases.UploadLampiranInput{
		TiketID:     tuid,
		NamaFile:    header.Filename,
		Ukuran:      header.Size,
		TipeFile:    extForEntity,
		ContentType: mimeType,
		Content:     file,
		DibuatOleh:  uid,
		UserRole:    userRole,
	}, userRole)
	if err != nil {
		fmt.Printf("[DEBUG] Upload error: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, output.Lampiran)
}

// getMimeTypeFromExt converts file extension to MIME type
func getMimeTypeFromExt(ext string) string {
	ext = strings.ToLower(ext)
	switch ext {
	case ".jpg", ".jpeg":
		return "image/jpeg"
	case ".png":
		return "image/png"
	case ".gif":
		return "image/gif"
	case ".pdf":
		return "application/pdf"
	case ".doc":
		return "application/msword"
	case ".docx":
		return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
	case ".xls":
		return "application/vnd.ms-excel"
	case ".xlsx":
		return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
	case ".txt":
		return "text/plain"
	case ".zip":
		return "application/zip"
	default:
		return "application/octet-stream"
	}
}

// DownloadLampiran handles file download
func (h *LampiranHandler) DownloadLampiran(c *gin.Context) {
	lampiranID := c.Param("lampiran_id")
	luid := uuid.MustParse(lampiranID)

	lampiran, err := h.lampiranRepo.GetByID(c.Request.Context(), luid)
	if err != nil {
		if entities.IsNotFound(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Lampiran tidak ditemukan"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	signedURL, err := h.lampiranRepo.GetDownloadURL(c.Request.Context(), lampiran)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"download_url": signedURL})
}

// DeleteLampiran handles file deletion
func (h *LampiranHandler) DeleteLampiran(c *gin.Context) {
	lampiranID := c.Param("lampiran_id")
	luid := uuid.MustParse(lampiranID)

	userID := c.GetString("userID")
	uid := uuid.MustParse(userID)
	peran := c.GetString("peran")
	userRole := entities.Role(peran)

	err := h.deleteUC.Execute(c.Request.Context(), usecases.DeleteLampiranInput{
		LampiranID: luid,
		UserID:     uid,
		UserRole:   userRole,
	})
	if err != nil {
		if entities.IsUnauthorized(err) {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Lampiran berhasil dihapus"})
}

// GetLampiranList handles listing attachments for a ticket
func (h *LampiranHandler) GetLampiranList(c *gin.Context) {
	tiketID := c.Param("id")
	tuid := uuid.MustParse(tiketID)

	lampiranList, err := h.lampiranRepo.GetByTiketID(c.Request.Context(), tuid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": lampiranList,
	})
}
