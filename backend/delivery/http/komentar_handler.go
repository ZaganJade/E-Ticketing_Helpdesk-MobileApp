package http

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/usecases"
)

// KomentarHandler handles comment HTTP requests
type KomentarHandler struct {
	addKomentarUC *usecases.AddKomentarUseCase
}

// NewKomentarHandler creates a new handler instance
func NewKomentarHandler(addUC *usecases.AddKomentarUseCase) *KomentarHandler {
	return &KomentarHandler{addKomentarUC: addUC}
}

// AddKomentarRequest represents add comment request
type AddKomentarRequest struct {
	IsiPesan string `json:"isi_pesan" binding:"required"`
}

// GetKomentarListResponse represents comment list response
type GetKomentarListResponse struct {
	Data []*entities.Komentar `json:"data"`
}

// GetKomentarList handles listing comments for a ticket
func (h *KomentarHandler) GetKomentarList(c *gin.Context) {
	tiketID := c.Param("id")

	tuid, err := uuid.Parse(tiketID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid tiket ID format"})
		return
	}

	userID := c.GetString("userID")
	peran := c.GetString("peran")

	komentarList, err := h.addKomentarUC.GetKomentarByTiketID(c.Request.Context(), tuid, uuid.MustParse(userID), entities.Role(peran))
	if err != nil {
		if entities.IsUnauthorized(err) {
			c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke tiket ini"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": komentarList,
	})
}

// AddKomentar handles adding a comment
func (h *KomentarHandler) AddKomentar(c *gin.Context) {
	tiketID := c.Param("id")

	tuid, err := uuid.Parse(tiketID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid tiket ID format"})
		return
	}

	var req AddKomentarRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetString("userID")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in token"})
		return
	}

	uid, err := uuid.Parse(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	output, execErr := h.addKomentarUC.Execute(c.Request.Context(), usecases.AddKomentarInput{
		TiketID:   tuid,
		PenulisID: uid,
		IsiPesan:  req.IsiPesan,
	})
	if execErr != nil {
		if entities.IsValidation(execErr) {
			c.JSON(http.StatusBadRequest, gin.H{"error": execErr.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal menambahkan komentar",
		})
		return
	}

	c.JSON(http.StatusCreated, output.Komentar)
}
