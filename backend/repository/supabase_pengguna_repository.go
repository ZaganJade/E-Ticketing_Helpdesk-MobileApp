package repository

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// SupabasePenggunaRepository implements PenggunaRepository using Supabase
type SupabasePenggunaRepository struct {
	client *SupabaseClient
}

// NewSupabasePenggunaRepository creates a new repository instance
func NewSupabasePenggunaRepository(client *SupabaseClient) interfaces.PenggunaRepository {
	return &SupabasePenggunaRepository{client: client}
}

// Create creates a new user
func (r *SupabasePenggunaRepository) Create(ctx context.Context, pengguna *entities.Pengguna) error {
	// Note: User creation is typically done through Auth, this is for direct inserts if needed
	data := map[string]interface{}{
		"id":            pengguna.ID,
		"nama":          pengguna.Nama,
		"email":         pengguna.Email,
		"password_hash": pengguna.PasswordHash,
		"peran":         pengguna.Peran,
		"dibuat_pada":   pengguna.DibuatPada,
		"diperbarui_pada": pengguna.DiperbaruiPada,
	}

	_, _, err := r.client.GetTable("pengguna").Insert(data, false, "", "", "").Execute()
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}

	return nil
}

// GetByID retrieves a user by ID
func (r *SupabasePenggunaRepository) GetByID(ctx context.Context, id uuid.UUID) (*entities.Pengguna, error) {
	query := r.client.GetTable("pengguna").
		Select("*", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return nil, entities.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return r.parsePengguna(resp)
}

// GetByEmail retrieves a user by email
func (r *SupabasePenggunaRepository) GetByEmail(ctx context.Context, email string) (*entities.Pengguna, error) {
	query := r.client.GetTable("pengguna").
		Select("*", "", false).
		Eq("email", email).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return nil, entities.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get user by email: %w", err)
	}

	return r.parsePengguna(resp)
}

// Update updates user data
func (r *SupabasePenggunaRepository) Update(ctx context.Context, pengguna *entities.Pengguna) error {
	// Only allow updating nama (other fields should be updated through specific methods)
	data := map[string]interface{}{
		"nama":       pengguna.Nama,
		"diperbarui_pada": pengguna.DiperbaruiPada,
	}

	_, _, err := r.client.GetTable("pengguna").
		Update(data, "", "").
		Eq("id", pengguna.ID.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}

	return nil
}

// UpdateFotoProfil updates user's profile photo URL
func (r *SupabasePenggunaRepository) UpdateFotoProfil(ctx context.Context, id uuid.UUID, fotoProfilURL string) error {
	data := map[string]interface{}{
		"foto_profil":     fotoProfilURL,
		"diperbarui_pada": time.Now(),
	}

	_, _, err := r.client.GetTable("pengguna").
		Update(data, "", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to update profile photo: %w", err)
	}

	return nil
}

// Delete deletes a user (admin only)
func (r *SupabasePenggunaRepository) Delete(ctx context.Context, id uuid.UUID) error {
	_, _, err := r.client.GetTable("pengguna").
		Delete("", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	return nil
}

// List retrieves users with pagination
func (r *SupabasePenggunaRepository) List(ctx context.Context, offset, limit int) ([]*entities.Pengguna, error) {
	query := r.client.GetTable("pengguna").
		Select("*", "", false).
		Range(offset, offset+limit-1, "")

	resp, _, err := query.Execute()
	if err != nil {
		return nil, fmt.Errorf("failed to list users: %w", err)
	}

	return r.parsePenggunaList(resp)
}

// Count returns total user count
func (r *SupabasePenggunaRepository) Count(ctx context.Context) (int64, error) {
	query := r.client.GetTable("pengguna").
		Select("*", "exact", false)

	resp, count, err := query.Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}

	_ = resp
	return count, nil
}

// CountByRole returns count of users by role
func (r *SupabasePenggunaRepository) CountByRole(ctx context.Context, role entities.Role) (int64, error) {
	query := r.client.GetTable("pengguna").
		Select("*", "exact", false).
		Eq("peran", string(role))

	resp, count, err := query.Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count users by role: %w", err)
	}

	_ = resp
	return count, nil
}

// Helper methods

func (r *SupabasePenggunaRepository) parsePengguna(data []byte) (*entities.Pengguna, error) {
	var p entities.Pengguna
	if err := json.Unmarshal(data, &p); err != nil {
		return nil, fmt.Errorf("failed to parse user: %w", err)
	}
	return &p, nil
}

func (r *SupabasePenggunaRepository) parsePenggunaList(data []byte) ([]*entities.Pengguna, error) {
	var users []*entities.Pengguna
	if err := json.Unmarshal(data, &users); err != nil {
		return nil, fmt.Errorf("failed to parse user list: %w", err)
	}
	return users, nil
}

func isNotFoundError(err error) bool {
	// Check if error indicates not found
	// This depends on the actual error format from postgrest-go
	return err != nil && (err.Error() == "404" || contains(err.Error(), "not found"))
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > 0 && containsHelper(s, substr))
}

func containsHelper(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
