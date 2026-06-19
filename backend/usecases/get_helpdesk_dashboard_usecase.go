package usecases

import (
	"context"
	"log"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// GetHelpdeskDashboardInput holds helpdesk dashboard input
type GetHelpdeskDashboardInput struct {
	HelpdeskID uuid.UUID
}

// GetHelpdeskDashboardOutput holds helpdesk dashboard output
type GetHelpdeskDashboardOutput struct {
	TotalDitangani    int64   // The calling helpdesk's own completed tickets (personal)
	TiketTerbuka      int64   // ALL open (TERBUKA) tickets — team-wide
	TiketSaya         int64   // ALL in-progress (DIPROSES) tickets — team-wide, despite the "saya" name (intentional)
	TiketSelesai      int64   // ALL completed (SELESAI) tickets — team-wide
	TiketTerbaru      []*entities.Tiket
	RataRataJam       float64 // Average resolution time (hours) for the caller's own completed tickets (personal)
}

// GetHelpdeskDashboardUseCase handles helpdesk dashboard data
type GetHelpdeskDashboardUseCase struct {
	tiketRepo interfaces.TiketRepository
}

// NewGetHelpdeskDashboardUseCase creates a new use case instance
func NewGetHelpdeskDashboardUseCase(tiketRepo interfaces.TiketRepository) *GetHelpdeskDashboardUseCase {
	return &GetHelpdeskDashboardUseCase{tiketRepo: tiketRepo}
}

// Execute retrieves helpdesk dashboard data
func (uc *GetHelpdeskDashboardUseCase) Execute(ctx context.Context, input GetHelpdeskDashboardInput) (*GetHelpdeskDashboardOutput, error) {
	log.Printf("[DASHBOARD] Calculating stats for helpdesk ID: %s", input.HelpdeskID)

	// Count ALL tickets by status (not filtered by helpdesk user)
	// Status cards show OVERALL statistics, not personal ones

	// Count ALL open tickets
	openStatus := entities.StatusTerbuka
	openTicketsCount, err := uc.tiketRepo.Count(ctx, interfaces.TiketFilter{
		Status: &openStatus,
	})
	if err != nil {
		return nil, err
	}
	log.Printf("[DASHBOARD] ALL Open tickets count: %d", openTicketsCount)

	// Count ALL Diproses tickets (not just assigned to me)
	inProgressStatus := entities.StatusDiproses
	allDiprosesCount, err := uc.tiketRepo.Count(ctx, interfaces.TiketFilter{
		Status: &inProgressStatus,
	})
	if err != nil {
		return nil, err
	}
	log.Printf("[DASHBOARD] ALL Diproses tickets count: %d", allDiprosesCount)

	// Count ALL Selesai tickets (not just assigned to me)
	completedStatus := entities.StatusSelesai
	allSelesaiCount, err := uc.tiketRepo.Count(ctx, interfaces.TiketFilter{
		Status: &completedStatus,
	})
	if err != nil {
		return nil, err
	}
	log.Printf("[DASHBOARD] ALL Selesai tickets count: %d", allSelesaiCount)

	// For personal statistics, count tickets assigned to THIS helpdesk
	myInProgressFilter := interfaces.TiketFilter{
		DitugaskanKepada: &input.HelpdeskID,
		Status:          &inProgressStatus,
	}
	myDiprosesCount, err := uc.tiketRepo.Count(ctx, myInProgressFilter)
	if err != nil {
		return nil, err
	}

	myCompletedFilter := interfaces.TiketFilter{
		DitugaskanKepada: &input.HelpdeskID,
		Status:          &completedStatus,
	}
	mySelesaiCount, err := uc.tiketRepo.Count(ctx, myCompletedFilter)
	if err != nil {
		return nil, err
	}

	// Get completed tickets for calculating average time (my tickets only)
	completedTickets, err := uc.tiketRepo.List(ctx, myCompletedFilter, 0, 1000)
	if err != nil {
		return nil, err
	}

	// Calculate average completion time in hours
	var totalHours float64
	for _, tiket := range completedTickets {
		if tiket.SelesaiPada != nil {
			duration := tiket.SelesaiPada.Sub(tiket.DibuatPada)
			totalHours += duration.Hours()
		}
	}

	var avgHours float64
	if len(completedTickets) > 0 {
		avgHours = totalHours / float64(len(completedTickets))
	}

	// Get recent tickets (last 5) for display
	recentTickets, err := uc.tiketRepo.List(ctx, interfaces.TiketFilter{}, 0, 5)
	if err != nil {
		return nil, err
	}

	log.Printf("[DASHBOARD] FINAL STATS - Open: %d, Diproses: %d, Selesai: %d (ALL tickets)", openTicketsCount, allDiprosesCount, allSelesaiCount)
	log.Printf("[DASHBOARD] MY STATS - My Diproses: %d, My Selesai: %d", myDiprosesCount, mySelesaiCount)

	return &GetHelpdeskDashboardOutput{
		TotalDitangani: int64(len(completedTickets)), // Only count my completed tickets
		TiketTerbuka:   openTicketsCount,              // ALL open tickets
		TiketSaya:      allDiprosesCount,              // ALL Diproses tickets (changed from my count)
		TiketSelesai:   allSelesaiCount,              // ALL Selesai tickets (changed from my count)
		TiketTerbaru:   recentTickets,
		RataRataJam:    avgHours,                      // Only calculate my average time
	}, nil
}

// GetTiketTerbuka returns list of open tickets (status = TERBUKA)
func (uc *GetHelpdeskDashboardUseCase) GetTiketTerbuka(ctx context.Context) ([]*entities.Tiket, error) {
	openStatus := entities.StatusTerbuka
	return uc.tiketRepo.List(ctx, interfaces.TiketFilter{
		Status: &openStatus,
	}, 0, 50) // Get up to 50 open tickets
}

// GetTiketSaya returns assigned tickets (DIPROSES + SELESAI) across ALL helpdesk
// agents for a team-wide monitoring view. This is intentional: the helpdeskID is
// not used for filtering (only logged). The Flutter app separates the results
// into "Diproses" and "Selesai" tabs.
func (uc *GetHelpdeskDashboardUseCase) GetTiketSaya(ctx context.Context, helpdeskID uuid.UUID) ([]*entities.Tiket, error) {
	// Get all tickets, then filter to only include assigned ones
	allTickets, err := uc.tiketRepo.List(ctx, interfaces.TiketFilter{}, 0, 200)
	if err != nil {
		return nil, err
	}

	// Filter to only return assigned tickets (exclude TERBUKA/unassigned)
	var assignedTickets []*entities.Tiket
	for _, tiket := range allTickets {
		// Include tickets that are assigned (have ditugaskan_kepada) and are not TERBUKA
		if tiket.DitugaskanKepada != nil && tiket.Status != entities.StatusTerbuka {
			assignedTickets = append(assignedTickets, tiket)
		}
	}

	log.Printf("[DASHBOARD] GetTiketSaya: Total tickets=%d, Assigned tickets=%d", len(allTickets), len(assignedTickets))

	return assignedTickets, nil
}
