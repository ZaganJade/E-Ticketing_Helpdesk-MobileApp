package usecases

import (
	"context"
	"fmt"

	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// RegisterInput holds registration input data
type RegisterInput struct {
	Nama     string
	Email    string
	Password string
}

// RegisterUseCase handles user registration
type RegisterUseCase struct {
	authRepo interfaces.AuthRepository
}

// NewRegisterUseCase creates a new use case instance
func NewRegisterUseCase(authRepo interfaces.AuthRepository) *RegisterUseCase {
	return &RegisterUseCase{authRepo: authRepo}
}

// Execute performs user registration
func (uc *RegisterUseCase) Execute(ctx context.Context, input RegisterInput) (*entities.Pengguna, error) {
	// Validate input
	if err := validateRegisterInput(input); err != nil {
		return nil, err
	}

	// Register user through auth repository
	pengguna, err := uc.authRepo.Register(ctx, input.Nama, input.Email, input.Password)
	if err != nil {
		return nil, fmt.Errorf("registration failed: %w", err)
	}

	return pengguna, nil
}

func validateRegisterInput(input RegisterInput) error {
	if input.Nama == "" {
		return entities.NewValidationError("nama", "nama tidak boleh kosong")
	}
	if len(input.Nama) > 100 {
		return entities.NewValidationError("nama", "nama maksimal 100 karakter")
	}
	if input.Email == "" {
		return entities.NewValidationError("email", "email tidak boleh kosong")
	}
	if input.Password == "" {
		return entities.NewValidationError("password", "password tidak boleh kosong")
	}
	if len(input.Password) < 8 {
		return entities.NewValidationError("password", "password minimal 8 karakter")
	}
	return nil
}
