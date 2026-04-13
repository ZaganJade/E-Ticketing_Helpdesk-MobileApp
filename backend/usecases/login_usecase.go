package usecases

import (
	"context"
	"fmt"

	"eticketinghelpdesk/interfaces"
)

// LoginInput holds login input data
type LoginInput struct {
	Email    string
	Password string
}

// LoginOutput holds login output data
type LoginOutput struct {
	Token    *interfaces.AuthToken
	UserID   string
	Nama     string
	Email    string
	Peran    string
}

// LoginUseCase handles user login
type LoginUseCase struct {
	authRepo interfaces.AuthRepository
}

// NewLoginUseCase creates a new use case instance
func NewLoginUseCase(authRepo interfaces.AuthRepository) *LoginUseCase {
	return &LoginUseCase{authRepo: authRepo}
}

// Execute performs user login
func (uc *LoginUseCase) Execute(ctx context.Context, input LoginInput) (*LoginOutput, error) {
	// Validate input
	if input.Email == "" {
		return nil, fmt.Errorf("email tidak boleh kosong")
	}
	if input.Password == "" {
		return nil, fmt.Errorf("password tidak boleh kosong")
	}

	// Authenticate user
	token, pengguna, err := uc.authRepo.Login(ctx, input.Email, input.Password)
	if err != nil {
		return nil, fmt.Errorf("email atau password salah")
	}

	return &LoginOutput{
		Token:    token,
		UserID:   pengguna.ID.String(),
		Nama:     pengguna.Nama,
		Email:    pengguna.Email,
		Peran:    string(pengguna.Peran),
	}, nil
}
