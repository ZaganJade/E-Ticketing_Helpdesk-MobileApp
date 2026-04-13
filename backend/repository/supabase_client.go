package repository

import (
	"encoding/json"
	"fmt"

	"github.com/supabase-community/postgrest-go"
	"github.com/supabase-community/supabase-go"
	"eticketinghelpdesk/config"
)

// SupabaseClient wraps the supabase client for database operations
type SupabaseClient struct {
	Client *supabase.Client
	Config *config.AppConfig
}

// NewSupabaseClient creates a new Supabase client
func NewSupabaseClient(cfg *config.AppConfig) (*SupabaseClient, error) {
	client, err := supabase.NewClient(cfg.SupabaseURL, cfg.SupabaseServiceKey, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create supabase client: %w", err)
	}

	return &SupabaseClient{
		Client: client,
		Config: cfg,
	}, nil
}

// GetTable returns a PostgREST query builder for a table
func (s *SupabaseClient) GetTable(tableName string) *postgrest.QueryBuilder {
	return s.Client.From(tableName)
}

// RPC executes a stored procedure and returns the response as bytes
func (s *SupabaseClient) RPC(name string, params map[string]interface{}) ([]byte, error) {
	result := s.Client.Rpc(name, "", params)
	// Rpc returns a string, convert to bytes
	return []byte(result), nil
}

// RpcTo executes a stored procedure and decodes result into target
func (s *SupabaseClient) RpcTo(name string, params map[string]interface{}, target interface{}) error {
	result := s.Client.Rpc(name, "", params)
	return json.Unmarshal([]byte(result), target)
}
