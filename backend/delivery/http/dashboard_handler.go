package http

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/usecases"
)

// DashboardHandler handles dashboard HTTP requests
type DashboardHandler struct {
	getDashboardStatsUC *usecases.GetDashboardStatsUseCase
}

// NewDashboardHandler creates a new handler instance
func NewDashboardHandler(statsUC *usecases.GetDashboardStatsUseCase) *DashboardHandler {
	return &DashboardHandler{getDashboardStatsUC: statsUC}
}

// GetStats handles getting dashboard statistics
func (h *DashboardHandler) GetStats(c *gin.Context) {
	userID := c.GetString("userID")
	peran := c.GetString("peran")

	output, err := h.getDashboardStatsUC.Execute(c.Request.Context(), usecases.GetDashboardStatsInput{
		UserID:   uuid.MustParse(userID),
		UserRole: entities.Role(peran),
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"total":    output.Total,
		"terbuka":  output.Terbuka,
		"diproses": output.Diproses,
		"selesai":  output.Selesai,
	})
}
