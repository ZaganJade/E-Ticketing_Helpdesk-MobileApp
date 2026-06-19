package http

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/usecases"
)

// NotifikasiHandler handles notification HTTP requests
type NotifikasiHandler struct {
	getNotifikasiListUC   *usecases.GetNotifikasiListUseCase
	markNotifikasiReadUC  *usecases.MarkNotifikasiReadUseCase
}

// NewNotifikasiHandler creates a new handler instance
func NewNotifikasiHandler(listUC *usecases.GetNotifikasiListUseCase, markReadUC *usecases.MarkNotifikasiReadUseCase) *NotifikasiHandler {
	return &NotifikasiHandler{
		getNotifikasiListUC:  listUC,
		markNotifikasiReadUC: markReadUC,
	}
}

// GetNotifikasiList handles listing notifications
func (h *NotifikasiHandler) GetNotifikasiList(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	// Parse query params - support both "unread" and "sudah_dibaca" parameters
	onlyUnread := c.Query("unread") == "true"
	if sudahDibaca := c.Query("sudah_dibaca"); sudahDibaca != "" {
		onlyUnread = sudahDibaca == "false"
	}
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	output, err := h.getNotifikasiListUC.Execute(c.Request.Context(), usecases.GetNotifikasiListInput{
		UserID:     uid,
		OnlyUnread: onlyUnread,
		Offset:     offset,
		Limit:      limit,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":         output.Notifikasi,
		"total":        output.Total,
		"unread_count": output.UnreadCount,
	})
}

// MarkNotifikasiRead handles marking notification as read
func (h *NotifikasiHandler) MarkNotifikasiRead(c *gin.Context) {
	notifUID, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}

	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	if err := h.markNotifikasiReadUC.Execute(c.Request.Context(), usecases.MarkNotifikasiReadInput{
		NotifikasiID: notifUID,
		UserID:       uid,
		MarkAll:      false,
	}); err != nil {
		respondDomainError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notifikasi ditandai sebagai dibaca"})
}

// MarkAllNotifikasiRead handles marking all notifications as read
func (h *NotifikasiHandler) MarkAllNotifikasiRead(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	if err := h.markNotifikasiReadUC.Execute(c.Request.Context(), usecases.MarkNotifikasiReadInput{
		UserID:  uid,
		MarkAll: true,
	}); err != nil {
		respondDomainError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Semua notifikasi ditandai sebagai dibaca"})
}
