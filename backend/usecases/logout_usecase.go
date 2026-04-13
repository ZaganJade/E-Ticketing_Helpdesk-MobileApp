package usecases

import (
	"context"
	"fmt"

	"eticketinghelpdesk/interfaces"
)

// LogoutUseCase handles user logout
type LogoutUseCase struct {
	authRepo interfaces.AuthRepository
}

// NewLogoutUseCase creates a new use case instance
func NewLogoutUseCase(authRepo interfaces.AuthRepository) *LogoutUseCase {
	return &LogoutUseCase{authRepo: authRepo}
}

// Execute performs user logout
func (uc *LogoutUseCase) Execute(ctx context.Context) error {
	if err := uc.authRepo.Logout(ctx); err != nil {
		return fmt.Errorf("logout failed: %w", err)
	}
	return nil
}
