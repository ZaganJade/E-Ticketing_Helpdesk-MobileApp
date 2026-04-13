package usecases

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// GetDashboardStatsInput holds stats input
type GetDashboardStatsInput struct {
	UserID   uuid.UUID
	UserRole entities.Role
}

// GetDashboardStatsOutput holds stats output
type GetDashboardStatsOutput struct {
	Total    int64
	Terbuka  int64
	Diproses int64
	Selesai  int64
}

// GetDashboardStatsUseCase handles dashboard statistics
type GetDashboardStatsUseCase struct {
	tiketRepo interfaces.TiketRepository
}

// NewGetDashboardStatsUseCase creates a new use case instance
func NewGetDashboardStatsUseCase(tiketRepo interfaces.TiketRepository) *GetDashboardStatsUseCase {
	return &GetDashboardStatsUseCase{tiketRepo: tiketRepo}
}

// Execute retrieves dashboard statistics
func (uc *GetDashboardStatsUseCase) Execute(ctx context.Context, input GetDashboardStatsInput) (*GetDashboardStatsOutput, error) {
	var stats *interfaces.TiketStats
	var err error

	// Helpdesk/Admin see all stats, users see only their own
	if input.UserRole == entities.RoleHelpdesk || input.UserRole == entities.RoleAdmin {
		stats, err = uc.tiketRepo.GetStats(ctx)
	} else {
		stats, err = uc.tiketRepo.GetStatsByUser(ctx, input.UserID)
	}

	if err != nil {
		return nil, err
	}

	return &GetDashboardStatsOutput{
		Total:    stats.Total,
		Terbuka:  stats.Terbuka,
		Diproses: stats.Diproses,
		Selesai:  stats.Selesai,
	}, nil
}
