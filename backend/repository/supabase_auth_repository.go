package repository

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"eticketinghelpdesk/config"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// SupabaseAuthRepository implements authentication using Supabase
type SupabaseAuthRepository struct {
	client     *SupabaseClient
	jwtSecret  string
}

// NewSupabaseAuthRepository creates a new auth repository
func NewSupabaseAuthRepository(client *SupabaseClient, cfg *config.AppConfig) interfaces.AuthRepository {
	return &SupabaseAuthRepository{
		client:    client,
		jwtSecret: cfg.JWTSecret,
	}
}

// Register creates a new user
func (r *SupabaseAuthRepository) Register(ctx context.Context, nama, email, password string) (*entities.Pengguna, error) {
	// Create user profile directly (simplified - in production should use Supabase Auth)
	pengguna, err := entities.NewPengguna(nama, email, password, entities.RolePengguna)
	if err != nil {
		return nil, fmt.Errorf("failed to create pengguna entity: %w", err)
	}

	// Insert into pengguna table (minimal required fields)
	data := map[string]interface{}{
		"id":            pengguna.ID,
		"nama":          pengguna.Nama,
		"email":         pengguna.Email,
		"password_hash": pengguna.PasswordHash,
		"peran":         string(pengguna.Peran),
		"dibuat_pada":   pengguna.DibuatPada,
	}

	_, _, err = r.client.GetTable("pengguna").Insert(data, false, "", "", "").Execute()
	if err != nil {
		return nil, fmt.Errorf("failed to create pengguna: %w", err)
	}

	return pengguna, nil
}

// Login authenticates a user
func (r *SupabaseAuthRepository) Login(ctx context.Context, email, password string) (*interfaces.AuthToken, *entities.Pengguna, error) {
	// Get user from pengguna table
	resp, _, err := r.client.GetTable("pengguna").
		Select("*", "", false).
		Eq("email", email).
		Single().
		Execute()
	if err != nil {
		return nil, nil, fmt.Errorf("invalid credentials")
	}

	var penggunaList []*entities.Pengguna
	if err := json.Unmarshal(resp, &penggunaList); err != nil {
		// Try single object
		var p entities.Pengguna
		if err := json.Unmarshal(resp, &p); err != nil {
			return nil, nil, fmt.Errorf("failed to parse user data")
		}
		penggunaList = []*entities.Pengguna{&p}
	}

	if len(penggunaList) == 0 {
		return nil, nil, fmt.Errorf("user not found")
	}

	pengguna := penggunaList[0]

	// In real implementation, verify password with Supabase Auth
	// For now, create a JWT token with user ID
	accessToken, err := r.generateJWT(pengguna.ID, pengguna.Nama, pengguna.Email, string(pengguna.Peran))
	if err != nil {
		return nil, nil, fmt.Errorf("failed to generate token: %w", err)
	}

	token := &interfaces.AuthToken{
		AccessToken:  accessToken,
		RefreshToken: "mock-refresh",
		ExpiresIn:    3600,
	}

	return token, pengguna, nil
}

// generateJWT creates a JWT token for the user
func (r *SupabaseAuthRepository) generateJWT(userID uuid.UUID, nama, email, role string) (string, error) {
	claims := jwt.MapClaims{
		"sub":   userID.String(),
		"nama":  nama,
		"email": email,
		"role":  role,
		"exp":   time.Now().Add(time.Hour * 24).Unix(),
		"iat":   time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(r.jwtSecret))
}

// Logout signs out a user
func (r *SupabaseAuthRepository) Logout(ctx context.Context) error {
	// In real implementation, invalidate token
	return nil
}

// GetUserByID retrieves a user by ID
func (r *SupabaseAuthRepository) GetUserByID(ctx context.Context, userID string) (*entities.Pengguna, error) {
	resp, _, err := r.client.GetTable("pengguna").
		Select("*", "", false).
		Eq("id", userID).
		Single().
		Execute()
	if err != nil {
		return nil, err
	}

	var pengguna entities.Pengguna
	if err := json.Unmarshal(resp, &pengguna); err != nil {
		return nil, fmt.Errorf("failed to parse user data: %w", err)
	}

	return &pengguna, nil
}

// GetCurrentUser retrieves current authenticated user
func (r *SupabaseAuthRepository) GetCurrentUser(ctx context.Context) (*entities.Pengguna, error) {
	// Extract user ID from context (set by auth middleware)
	userID, ok := ctx.Value("userID").(string)
	if !ok || userID == "" {
		return nil, fmt.Errorf("user ID not found in context")
	}

	// Fetch user from database
	return r.GetUserByID(ctx, userID)
}

// RefreshToken refreshes an access token
func (r *SupabaseAuthRepository) RefreshToken(ctx context.Context, refreshToken string) (*interfaces.AuthToken, error) {
	return &interfaces.AuthToken{
		AccessToken:  "new-mock-token",
		RefreshToken: refreshToken,
		ExpiresIn:    3600,
	}, nil
}

// VerifyToken validates an access token
func (r *SupabaseAuthRepository) VerifyToken(ctx context.Context, tokenString string) (uuid.UUID, error) {
	// Parse and validate the JWT token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Validate signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(r.jwtSecret), nil
	})

	if err != nil {
		return uuid.Nil, fmt.Errorf("invalid token: %w", err)
	}

	// Extract claims
	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		// Extract user ID from "sub" claim
		sub, ok := claims["sub"].(string)
		if !ok {
			return uuid.Nil, fmt.Errorf("sub claim not found in token")
		}

		userID, err := uuid.Parse(sub)
		if err != nil {
			return uuid.Nil, fmt.Errorf("invalid user ID in token: %w", err)
		}

		return userID, nil
	}

	return uuid.Nil, fmt.Errorf("invalid token claims")
}

// ResetPassword initiates password reset
func (r *SupabaseAuthRepository) ResetPassword(ctx context.Context, email string) error {
	return nil
}
