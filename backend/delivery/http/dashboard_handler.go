package http

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/usecases"
)

// DashboardHandler handles dashboard HTTP requests
type DashboardHandler struct {
	getDashboardStatsUC       *usecases.GetDashboardStatsUseCase
	getHelpdeskDashboardUC    *usecases.GetHelpdeskDashboardUseCase
}

// NewDashboardHandler creates a new handler instance
func NewDashboardHandler(statsUC *usecases.GetDashboardStatsUseCase, helpdeskUC *usecases.GetHelpdeskDashboardUseCase) *DashboardHandler {
	return &DashboardHandler{
		getDashboardStatsUC: statsUC,
		getHelpdeskDashboardUC: helpdeskUC,
	}
}

// GetStats handles getting dashboard statistics
func (h *DashboardHandler) GetStats(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}
	peran := c.GetString("peran")

	output, err := h.getDashboardStatsUC.Execute(c.Request.Context(), usecases.GetDashboardStatsInput{
		UserID:   uid,
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

// GetHelpdeskStats handles getting helpdesk dashboard statistics
func (h *DashboardHandler) GetHelpdeskStats(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	output, err := h.getHelpdeskDashboardUC.Execute(c.Request.Context(), usecases.GetHelpdeskDashboardInput{
		HelpdeskID: uid,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Convert recent tickets to JSON format
	tiketTerbaru := make([]gin.H, len(output.TiketTerbaru))
	for i, tiket := range output.TiketTerbaru {
		tiketTerbaru[i] = gin.H{
			"id":               tiket.ID,
			"judul":            tiket.Judul,
			"deskripsi":        tiket.Deskripsi,
			"status":           tiket.Status,
			"dibuat_oleh":      tiket.DibuatOleh,
			"ditugaskan_kepada": tiket.DitugaskanKepada,
			"dibuat_pada":      tiket.DibuatPada,
			"diperbarui_pada":  tiket.DiperbaruiPada,
			"selesai_pada":     tiket.SelesaiPada,
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"total_ditangani": output.TotalDitangani,
			"tiket_terbuka":   output.TiketTerbuka,
			"tiket_saya":      output.TiketSaya,
			"tiket_selesai":   output.TiketSelesai,
			"tiket_terbaru":   tiketTerbaru,
			"rata_rata_jam":   output.RataRataJam,
		},
	})
}

// GetTiketTerbuka handles getting open tickets list
func (h *DashboardHandler) GetTiketTerbuka(c *gin.Context) {
	// Get open tickets (status = TERBUKA)
	openTickets, err := h.getHelpdeskDashboardUC.GetTiketTerbuka(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Convert to JSON format
	tickets := make([]gin.H, 0, len(openTickets))
	for _, tiket := range openTickets {
		tickets = append(tickets, gin.H{
			"id":                tiket.ID,
			"judul":             tiket.Judul,
			"deskripsi":         tiket.Deskripsi,
			"status":            tiket.Status,
			"dibuat_oleh":       tiket.DibuatOleh,
			"ditugaskan_kepada": tiket.DitugaskanKepada,
			"dibuat_pada":       tiket.DibuatPada,
			"diperbarui_pada":   tiket.DiperbaruiPada,
			"selesai_pada":      tiket.SelesaiPada,
			"pengguna":          tiket.Pengguna,
			"assigned":          tiket.Assigned,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": tickets})
}

// GetTiketSaya handles getting tickets assigned to current helpdesk
func (h *DashboardHandler) GetTiketSaya(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	// Team-wide monitoring view: all assigned, non-open tickets (intentional — see use case).
	myTickets, err := h.getHelpdeskDashboardUC.GetTiketSaya(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Convert to JSON format
	tickets := make([]gin.H, 0, len(myTickets))
	for _, tiket := range myTickets {
		tickets = append(tickets, gin.H{
			"id":                tiket.ID,
			"judul":             tiket.Judul,
			"deskripsi":         tiket.Deskripsi,
			"status":            tiket.Status,
			"dibuat_oleh":       tiket.DibuatOleh,
			"ditugaskan_kepada": tiket.DitugaskanKepada,
			"dibuat_pada":       tiket.DibuatPada,
			"diperbarui_pada":   tiket.DiperbaruiPada,
			"selesai_pada":      tiket.SelesaiPada,
			"pengguna":          tiket.Pengguna,
			"assigned":          tiket.Assigned,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": tickets})
}
