package repository

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/supabase-community/postgrest-go"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// SupabaseKomentarRepository implements KomentarRepository using Supabase
type SupabaseKomentarRepository struct {
	client *SupabaseClient
}

// NewSupabaseKomentarRepository creates a new repository instance
func NewSupabaseKomentarRepository(client *SupabaseClient) interfaces.KomentarRepository {
	return &SupabaseKomentarRepository{client: client}
}

// Create creates a new comment
func (r *SupabaseKomentarRepository) Create(ctx context.Context, komentar *entities.Komentar) error {
	data := map[string]interface{}{
		"id":          komentar.ID,
		"tiket_id":    komentar.TiketID,
		"penulis_id":  komentar.PenulisID,
		"isi_pesan":   komentar.IsiPesan,
		"dibuat_pada": komentar.DibuatPada,
	}

	_, _, err := r.client.GetTable("komentar").Insert(data, false, "", "", "").Execute()
	if err != nil {
		return fmt.Errorf("failed to create comment: %w", err)
	}

	return nil
}

// GetByID retrieves a comment by ID
func (r *SupabaseKomentarRepository) GetByID(ctx context.Context, id uuid.UUID) (*entities.Komentar, error) {
	query := r.client.GetTable("komentar").
		Select("*, pengguna!inner(nama, peran)", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return nil, entities.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get comment: %w", err)
	}

	return r.parseKomentar(resp)
}

// GetByTiketID retrieves all comments for a ticket
func (r *SupabaseKomentarRepository) GetByTiketID(ctx context.Context, tiketID uuid.UUID) ([]*entities.Komentar, error) {
	query := r.client.GetTable("komentar").
		Select("*, pengguna!inner(nama, peran)", "", false).
		Eq("tiket_id", tiketID.String()).
		Order("dibuat_pada", &postgrest.OrderOpts{Ascending: true})

	resp, _, err := query.Execute()
	if err != nil {
		return nil, fmt.Errorf("failed to get comments: %w", err)
	}

	return r.parseKomentarList(resp)
}

// Delete deletes a comment
func (r *SupabaseKomentarRepository) Delete(ctx context.Context, id uuid.UUID) error {
	_, _, err := r.client.GetTable("komentar").
		Delete("", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to delete comment: %w", err)
	}

	return nil
}

// CountByTiketID returns count of comments for a ticket
func (r *SupabaseKomentarRepository) CountByTiketID(ctx context.Context, tiketID uuid.UUID) (int64, error) {
	query := r.client.GetTable("komentar").
		Select("*", "exact", false).
		Eq("tiket_id", tiketID.String())

	resp, count, err := query.Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count comments: %w", err)
	}

	_ = resp
	return count, nil
}

// Helper struct to parse nested pengguna data from Supabase join
type komentarWithPengguna struct {
	ID         string                 `json:"id"`
	TiketID    string                 `json:"tiket_id"`
	PenulisID  string                 `json:"penulis_id"`
	IsiPesan   string                 `json:"isi_pesan"`
	DibuatPada string                 `json:"dibuat_pada"`
	Pengguna   map[string]interface{} `json:"pengguna"`
}

func (r *SupabaseKomentarRepository) parseKomentar(data []byte) (*entities.Komentar, error) {
	var raw komentarWithPengguna
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("failed to parse comment: %w", err)
	}
	return r.convertToEntity(&raw), nil
}

func (r *SupabaseKomentarRepository) parseKomentarList(data []byte) ([]*entities.Komentar, error) {
	var rawList []*komentarWithPengguna
	if err := json.Unmarshal(data, &rawList); err != nil {
		return nil, fmt.Errorf("failed to parse comment list: %w", err)
	}

	comments := make([]*entities.Komentar, len(rawList))
	for i, raw := range rawList {
		comments[i] = r.convertToEntity(raw)
	}
	return comments, nil
}

func (r *SupabaseKomentarRepository) convertToEntity(raw *komentarWithPengguna) *entities.Komentar {
	// Parse UUIDs
	id, _ := uuid.Parse(raw.ID)
	tiketID, _ := uuid.Parse(raw.TiketID)
	penulisID, _ := uuid.Parse(raw.PenulisID)

	// Parse timestamp
	dibuatPada, _ := time.Parse(time.RFC3339, raw.DibuatPada)

	// Extract pengguna data
	nama := "Unknown"
	peranStr := "pengguna"
	if raw.Pengguna != nil {
		if n, ok := raw.Pengguna["nama"].(string); ok && n != "" {
			nama = n
		}
		if p, ok := raw.Pengguna["peran"].(string); ok && p != "" {
			peranStr = p
		}
	}

	return &entities.Komentar{
		ID:           id,
		TiketID:      tiketID,
		PenulisID:    penulisID,
		IsiPesan:     raw.IsiPesan,
		DibuatPada:   dibuatPada,
		PenulisNama:  nama,
		PenulisPeran: entities.Role(peranStr),
	}
}
