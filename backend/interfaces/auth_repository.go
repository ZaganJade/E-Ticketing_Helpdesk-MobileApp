package interfaces

import (
	"context"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// AuthCredentials holds login credentials
type AuthCredentials struct {
	Email    string
	Password string
}

// AuthToken holds authentication tokens
type AuthToken struct {
	AccessToken  string
	RefreshToken string
	ExpiresIn    int
}

// AuthRepository defines the interface for authentication
type AuthRepository interface {
	// Register creates a new user with Supabase Auth
	Register(ctx context.Context, nama, email, password string) (*entities.Pengguna, error)

	// Login authenticates user and returns tokens
	Login(ctx context.Context, email, password string) (*AuthToken, *entities.Pengguna, error)

	// Logout invalidates user session
	Logout(ctx context.Context) error

	// RefreshToken refreshes access token
	RefreshToken(ctx context.Context, refreshToken string) (*AuthToken, error)

	// ResetPassword sends password reset email
	ResetPassword(ctx context.Context, email string) error

	// GetCurrentUser retrieves current authenticated user
	GetCurrentUser(ctx context.Context) (*entities.Pengguna, error)

	// GetUserByID retrieves user by ID
	GetUserByID(ctx context.Context, userID string) (*entities.Pengguna, error)

	// VerifyToken verifies JWT token and returns user ID
	VerifyToken(ctx context.Context, token string) (uuid.UUID, error)
}
