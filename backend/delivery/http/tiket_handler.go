package http

import (
	"net/http"
	"strconv"

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
}

// NewTiketHandler creates a new handler instance
func NewTiketHandler(createUC *usecases.CreateTiketUseCase, listUC *usecases.GetTiketListUseCase, detailUC *usecases.GetTiketDetailUseCase, updateUC *usecases.UpdateTiketStatusUseCase, assignUC *usecases.AssignTiketUseCase) *TiketHandler {
	return &TiketHandler{
		createTiketUC:      createUC,
		getTiketListUC:     listUC,
		getTiketDetailUC:   detailUC,
		updateTiketStatusUC: updateUC,
		assignTiketUC:      assignUC,
	}
}

// CreateTiketRequest represents create ticket request
type CreateTiketRequest struct {
	Judul     string `json:"judul" binding:"required"`
	Deskripsi string `json:"deskripsi" binding:"required,min=10"`
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
	var req CreateTiketRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetString("userID")
	uid := uuid.MustParse(userID)

	output, err := h.createTiketUC.Execute(c.Request.Context(), usecases.CreateTiketInput{
		Judul:      req.Judul,
		Deskripsi:  req.Deskripsi,
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
