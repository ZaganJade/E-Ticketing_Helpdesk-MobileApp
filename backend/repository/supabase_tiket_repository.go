package repository

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"github.com/supabase-community/postgrest-go"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// SupabaseTiketRepository implements TiketRepository using Supabase
type SupabaseTiketRepository struct {
	client *SupabaseClient
}

// NewSupabaseTiketRepository creates a new repository instance
func NewSupabaseTiketRepository(client *SupabaseClient) interfaces.TiketRepository {
	return &SupabaseTiketRepository{client: client}
}

// Create creates a new ticket
func (r *SupabaseTiketRepository) Create(ctx context.Context, tiket *entities.Tiket) error {
	data := map[string]interface{}{
		"id":             tiket.ID,
		"judul":          tiket.Judul,
		"deskripsi":      tiket.Deskripsi,
		"status":         tiket.Status,
		"dibuat_oleh":    tiket.DibuatOleh,
		"dibuat_pada":    tiket.DibuatPada,
		"diperbarui_pada": tiket.DiperbaruiPada,
	}

	if tiket.DitugaskanKepada != nil {
		data["ditugaskan_kepada"] = *tiket.DitugaskanKepada
	}

	_, _, err := r.client.GetTable("tiket").Insert(data, false, "", "", "").Execute()
	if err != nil {
		return fmt.Errorf("failed to create ticket: %w", err)
	}

	return nil
}

// GetByID retrieves a ticket by ID with user info
func (r *SupabaseTiketRepository) GetByID(ctx context.Context, id uuid.UUID) (*entities.Tiket, error) {
	query := r.client.GetTable("tiket").
		Select("*, pengguna:dibuat_oleh(nama), assigned:pengguna!tiket_ditugaskan_kepada_fkey(nama)", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return nil, entities.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get ticket: %w", err)
	}

	return r.parseTiket(resp)
}

// GetByIDWithRelations retrieves ticket with creator and assignee info
func (r *SupabaseTiketRepository) GetByIDWithRelations(ctx context.Context, id uuid.UUID) (*entities.Tiket, error) {
	// Use Supabase's foreign table selection
	query := r.client.GetTable("tiket").
		Select("*, pengguna:dibuat_oleh(nama, peran), assigned:pengguna!tiket_ditugaskan_kepada_fkey(nama, peran)", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return nil, entities.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get ticket with relations: %w", err)
	}

	return r.parseTiket(resp)
}

// List retrieves tickets with filter and pagination
func (r *SupabaseTiketRepository) List(ctx context.Context, filter interfaces.TiketFilter, offset, limit int) ([]*entities.Tiket, error) {
	query := r.client.GetTable("tiket").Select("*, pengguna:dibuat_oleh(nama), assigned:pengguna!tiket_ditugaskan_kepada_fkey(nama)", "", false)

	// Apply filters
	if filter.Status != nil {
		query = query.Eq("status", string(*filter.Status))
	}
	if filter.DibuatOleh != nil {
		query = query.Eq("dibuat_oleh", filter.DibuatOleh.String())
	}
	if filter.DitugaskanKepada != nil {
		query = query.Eq("ditugaskan_kepada", filter.DitugaskanKepada.String())
	}
	if filter.SearchQuery != "" {
		// Full text search on judul and deskripsi
		query = query.Or(
			fmt.Sprintf("judul.ilike.%%%s%%", filter.SearchQuery),
			fmt.Sprintf("deskripsi.ilike.%%%s%%", filter.SearchQuery),
		)
	}

	// Apply pagination and ordering
	query = query.
		Order("dibuat_pada", &postgrest.OrderOpts{Ascending: false}).
		Range(offset, offset+limit-1, "")

	resp, _, err := query.Execute()
	if err != nil {
		return nil, fmt.Errorf("failed to list tickets: %w", err)
	}

	return r.parseTiketList(resp)
}

// Count returns total tickets matching filter
func (r *SupabaseTiketRepository) Count(ctx context.Context, filter interfaces.TiketFilter) (int64, error) {
	query := r.client.GetTable("tiket").Select("*", "exact", false)

	// Apply filters
	if filter.Status != nil {
		query = query.Eq("status", string(*filter.Status))
	}
	if filter.DibuatOleh != nil {
		query = query.Eq("dibuat_oleh", filter.DibuatOleh.String())
	}
	if filter.DitugaskanKepada != nil {
		query = query.Eq("ditugaskan_kepada", filter.DitugaskanKepada.String())
	}

	resp, count, err := query.Execute()
	if err != nil {
		return 0, fmt.Errorf("failed to count tickets: %w", err)
	}

	_ = resp
	return count, nil
}

// Update updates ticket data
func (r *SupabaseTiketRepository) Update(ctx context.Context, tiket *entities.Tiket) error {
	data := map[string]interface{}{
		"judul":       tiket.Judul,
		"deskripsi":   tiket.Deskripsi,
		"status":      tiket.Status,
		"diperbarui_pada": tiket.DiperbaruiPada,
	}

	if tiket.DitugaskanKepada != nil {
		data["ditugaskan_kepada"] = *tiket.DitugaskanKepada
	}

	if tiket.SelesaiPada != nil {
		data["selesai_pada"] = *tiket.SelesaiPada
	}

	_, _, err := r.client.GetTable("tiket").
		Update(data, "", "").
		Eq("id", tiket.ID.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to update ticket: %w", err)
	}

	return nil
}

// UpdateStatus updates only ticket status
func (r *SupabaseTiketRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status entities.Status) error {
	data := map[string]interface{}{
		"status": status,
	}

	if status == entities.StatusSelesai {
		data["selesai_pada"] = "now()"
	}

	_, _, err := r.client.GetTable("tiket").
		Update(data, "", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to update ticket status: %w", err)
	}

	return nil
}

// Assign assigns ticket to helpdesk
func (r *SupabaseTiketRepository) Assign(ctx context.Context, id uuid.UUID, helpdeskID uuid.UUID) error {
	data := map[string]interface{}{
		"ditugaskan_kepada": helpdeskID,
		"status":            entities.StatusDiproses,
	}

	_, _, err := r.client.GetTable("tiket").
		Update(data, "", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to assign ticket: %w", err)
	}

	return nil
}

// Delete deletes a ticket
func (r *SupabaseTiketRepository) Delete(ctx context.Context, id uuid.UUID) error {
	_, _, err := r.client.GetTable("tiket").
		Delete("", "").
		Eq("id", id.String()).
		Execute()

	if err != nil {
		return fmt.Errorf("failed to delete ticket: %w", err)
	}

	return nil
}

// Exists checks if ticket exists
func (r *SupabaseTiketRepository) Exists(ctx context.Context, id uuid.UUID) (bool, error) {
	query := r.client.GetTable("tiket").
		Select("id", "", false).
		Eq("id", id.String()).
		Single()

	resp, _, err := query.Execute()
	if err != nil {
		if isNotFoundError(err) {
			return false, nil
		}
		return false, fmt.Errorf("failed to check ticket existence: %w", err)
	}

	return len(resp) > 0, nil
}

// GetStats returns ticket statistics
func (r *SupabaseTiketRepository) GetStats(ctx context.Context) (*interfaces.TiketStats, error) {
	// Use RPC for efficient stats query
	params := map[string]interface{}{}
	resp, err := r.client.RPC("get_ticket_stats", params)
	if err != nil {
		// Fallback: manual count
		return r.getStatsManual(ctx, nil)
	}

	var stats interfaces.TiketStats
	if err := json.Unmarshal(resp, &stats); err != nil {
		return nil, fmt.Errorf("failed to parse stats: %w", err)
	}

	return &stats, nil
}

// GetStatsByUser returns ticket statistics for a specific user
func (r *SupabaseTiketRepository) GetStatsByUser(ctx context.Context, userID uuid.UUID) (*interfaces.TiketStats, error) {
	return r.getStatsManual(ctx, &userID)
}

// Helper methods

func (r *SupabaseTiketRepository) getStatsManual(ctx context.Context, userID *uuid.UUID) (*interfaces.TiketStats, error) {
	filter := interfaces.TiketFilter{}
	if userID != nil {
		filter.DibuatOleh = userID
	}

	total, _ := r.Count(ctx, filter)

	statusTerbuka := entities.StatusTerbuka
	filter.Status = &statusTerbuka
	terbuka, _ := r.Count(ctx, filter)

	statusDiproses := entities.StatusDiproses
	filter.Status = &statusDiproses
	diproses, _ := r.Count(ctx, filter)

	statusSelesai := entities.StatusSelesai
	filter.Status = &statusSelesai
	selesai, _ := r.Count(ctx, filter)

	return &interfaces.TiketStats{
		Total:    total,
		Terbuka:  terbuka,
		Diproses: diproses,
		Selesai:  selesai,
	}, nil
}

func (r *SupabaseTiketRepository) parseTiket(data []byte) (*entities.Tiket, error) {
	var t entities.Tiket
	if err := json.Unmarshal(data, &t); err != nil {
		return nil, fmt.Errorf("failed to parse ticket: %w", err)
	}
	return &t, nil
}

func (r *SupabaseTiketRepository) parseTiketList(data []byte) ([]*entities.Tiket, error) {
	var tickets []*entities.Tiket
	if err := json.Unmarshal(data, &tickets); err != nil {
		return nil, fmt.Errorf("failed to parse ticket list: %w", err)
	}
	return tickets, nil
}

