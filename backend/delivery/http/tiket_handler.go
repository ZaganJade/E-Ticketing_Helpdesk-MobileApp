package http

import (
	"fmt"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/usecases"
)

// TiketHandler handles ticket HTTP requests
type TiketHandler struct {
	createTiketUC      *usecases.CreateTiketUseCase
	getTiketListUC     *usecases.GetTiketListUseCase
	getTiketDetailUC   *usecases.GetTiketDetailUseCase
	updateTiketStatusUC *usecases.UpdateTiketStatusUseCase
	assignTiketUC      *usecases.AssignTiketUseCase
	uploadLampiranUC    *usecases.UploadLampiranUseCase
}

// NewTiketHandler creates a new handler instance
func NewTiketHandler(createUC *usecases.CreateTiketUseCase, listUC *usecases.GetTiketListUseCase, detailUC *usecases.GetTiketDetailUseCase, updateUC *usecases.UpdateTiketStatusUseCase, assignUC *usecases.AssignTiketUseCase, uploadUC *usecases.UploadLampiranUseCase) *TiketHandler {
	return &TiketHandler{
		createTiketUC:      createUC,
		getTiketListUC:     listUC,
		getTiketDetailUC:   detailUC,
		updateTiketStatusUC: updateUC,
		assignTiketUC:      assignUC,
		uploadLampiranUC:    uploadUC,
	}
}

// CreateTiketRequest represents create ticket request
type CreateTiketRequest struct {
	Judul     string `form:"judul" binding:"required"`
	Deskripsi string `form:"deskripsi" binding:"required,min=10"`
}

// UpdateStatusRequest represents status update request
type UpdateStatusRequest struct {
	Status string `json:"status" binding:"required,oneof=TERBUKA DIPROSES SELESAI"`
}

// AssignRequest represents assignment request
type AssignRequest struct {
	HelpdeskID string `json:"helpdesk_id" binding:"required,uuid"`
}

// CreateTiket handles ticket creation
func (h *TiketHandler) CreateTiket(c *gin.Context) {
	// Parse multipart form - Gin will automatically parse it
	// Don't call ParseMultipartForm() manually, use c.MultipartForm()

	judul := c.PostForm("judul")
	deskripsi := c.PostForm("deskripsi")

	// Validate required fields
	if judul == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Judul is required"})
		return
	}
	if len(deskripsi) < 10 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Deskripsi must be at least 10 characters"})
		return
	}

	userID := c.GetString("userID")
	uid := uuid.MustParse(userID)

	fmt.Printf("[DEBUG CREATE TICKET] Creating ticket for user: %s\n", userID)
	fmt.Printf("[DEBUG CREATE TICKET] Judul: %s\n", judul)

	// Create ticket first
	output, err := h.createTiketUC.Execute(c.Request.Context(), usecases.CreateTiketInput{
		Judul:      judul,
		Deskripsi:  deskripsi,
		DibuatOleh: uid,
	})
	if err != nil {
		if entities.IsValidation(err) {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	tiketID := output.Tiket.ID
	fmt.Printf("[DEBUG CREATE TICKET] Ticket created with ID: %s\n", tiketID)

	// Upload files if provided
	form, err := c.MultipartForm()
	if err != nil {
		fmt.Printf("[DEBUG CREATE TICKET] No multipart form: %v\n", err)
	} else if form != nil && len(form.File["files"]) > 0 {
		files := form.File["files"]
		fmt.Printf("[DEBUG CREATE TICKET] Processing %d files...\n", len(files))
		var uploadedLampiran []*entities.Lampiran

		for i, fileHeader := range files {
			fmt.Printf("[DEBUG CREATE TICKET] Processing file %d/%d: %s\n", i+1, len(files), fileHeader.Filename)

			// Validate file type
			ext := filepath.Ext(fileHeader.Filename)
			if !entities.IsAllowedFileType(ext) {
				fmt.Printf("[DEBUG CREATE TICKET] Invalid file type: %s\n", ext)
				continue
			}

			// Validate file size
			if fileHeader.Size > entities.MaxFileSize {
				fmt.Printf("[DEBUG CREATE TICKET] File too large: %d bytes\n", fileHeader.Size)
				continue
			}

			// Open the file
			file, err := fileHeader.Open()
			if err != nil {
				fmt.Printf("[DEBUG CREATE TICKET] Failed to open file: %v\n", err)
				continue
			}

			// Get MIME type
			mimeType := fileHeader.Header.Get("Content-Type")
			if mimeType == "" {
				// Simple MIME type detection from extension
				extLower := strings.ToLower(ext)
				switch extLower {
				case ".jpg", ".jpeg":
					mimeType = "image/jpeg"
				case ".png":
					mimeType = "image/png"
				case ".gif":
					mimeType = "image/gif"
				case ".pdf":
					mimeType = "application/pdf"
				case ".doc", ".docx":
					mimeType = "application/msword"
				case ".xls", ".xlsx":
					mimeType = "application/vnd.ms-excel"
				case ".txt":
					mimeType = "text/plain"
				default:
					mimeType = "application/octet-stream"
				}
			}

			// Remove leading dot from extension for entity validation
			extForEntity := strings.TrimPrefix(ext, ".")

			lampiranOutput, err := h.uploadLampiranUC.Execute(c.Request.Context(), usecases.UploadLampiranInput{
				TiketID:     tiketID,
				NamaFile:    fileHeader.Filename,
				Ukuran:      fileHeader.Size,
				TipeFile:    extForEntity,
				ContentType: mimeType,
				Content:     file,
				DibuatOleh:  uid,
			})

			file.Close()

			if err != nil {
				fmt.Printf("[DEBUG CREATE TICKET] Failed to upload lampiran: %v\n", err)
				continue
			}

			uploadedLampiran = append(uploadedLampiran, lampiranOutput.Lampiran)
			fmt.Printf("[DEBUG CREATE TICKET] Lampiran uploaded: %s\n", lampiranOutput.Lampiran.ID)
		}

		// Attach lampiran to response
		// Convert Lampiran to LampiranInfo for response
		if len(uploadedLampiran) > 0 {
			lampiranInfo := make([]*entities.LampiranInfo, len(uploadedLampiran))
			for i, l := range uploadedLampiran {
				lampiranInfo[i] = &entities.LampiranInfo{
					ID:       l.ID,
					NamaFile: l.NamaFile,
					URL:      "",
				}
			}
			output.Tiket.Lampiran = lampiranInfo
		}
		fmt.Printf("[DEBUG CREATE TICKET] Successfully uploaded %d/%d lampiran\n", len(uploadedLampiran), len(files))
	}

	c.JSON(http.StatusCreated, output.Tiket)
}


// GetTiketList handles listing tickets
func (h *TiketHandler) GetTiketList(c *gin.Context) {
	userID := c.GetString("userID")
	peran := c.GetString("peran")

	// Parse query params
	status := c.Query("status")
	search := c.Query("search")
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	var statusPtr *entities.Status
	if status != "" {
		s := entities.Status(status)
		statusPtr = &s
	}

	output, err := h.getTiketListUC.Execute(c.Request.Context(), usecases.GetTiketListInput{
		UserID:      uuid.MustParse(userID),
		UserRole:    entities.Role(peran),
		Status:      statusPtr,
		SearchQuery: search,
		Offset:      offset,
		Limit:       limit,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":  output.Tikets,
		"total": output.Total,
	})
}

// GetTiketDetail handles getting ticket details
func (h *TiketHandler) GetTiketDetail(c *gin.Context) {
	tiketID := c.Param("id")
	uid := uuid.MustParse(tiketID)

	userID := c.GetString("userID")
	peran := c.GetString("peran")

	output, err := h.getTiketDetailUC.Execute(c.Request.Context(), usecases.GetTiketDetailInput{
		TiketID:  uid,
		UserID:   uuid.MustParse(userID),
		UserRole: entities.Role(peran),
	})
	if err != nil {
		if entities.IsNotFound(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tiket tidak ditemukan"})
			return
		}
		if entities.IsUnauthorized(err) {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, output.Tiket)
}

// UpdateTiketStatus handles status updates
func (h *TiketHandler) UpdateTiketStatus(c *gin.Context) {
	tiketID := c.Param("id")
	uid := uuid.MustParse(tiketID)

	var req UpdateStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "received_status": req.Status})
		return
	}

	userID := c.GetString("userID")
	peran := c.GetString("peran")

	if err := h.updateTiketStatusUC.Execute(c.Request.Context(), usecases.UpdateTiketStatusInput{
		TiketID:   uid,
		NewStatus: entities.Status(req.Status),
		UserID:    uuid.MustParse(userID),
		UserRole:  entities.Role(peran),
	}); err != nil {
		if entities.IsUnauthorized(err) {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Status tiket berhasil diperbarui"})
}

// AssignTiket handles ticket assignment
func (h *TiketHandler) AssignTiket(c *gin.Context) {
	tiketID := c.Param("id")
	uid := uuid.MustParse(tiketID)

	var req AssignRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetString("userID")
	peran := c.GetString("peran")

	if err := h.assignTiketUC.Execute(c.Request.Context(), usecases.AssignTiketInput{
		TiketID:      uid,
		HelpdeskID:   uuid.MustParse(req.HelpdeskID),
		AssignerID:   uuid.MustParse(userID),
		AssignerRole: entities.Role(peran),
	}); err != nil {
		if entities.IsUnauthorized(err) {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Tiket berhasil ditugaskan"})
}
