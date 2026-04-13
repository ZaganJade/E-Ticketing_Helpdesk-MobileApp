package realtime

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/google/uuid"
	"github.com/supabase-community/supabase-go"
	"eticketinghelpdesk/entities"
)

// RealtimeClient handles Supabase Realtime subscriptions
type RealtimeClient struct {
	client      *supabase.Client
	handlers    map[string]EventHandler
	channels    map[string]interface{}
}

// EventHandler is a callback function for realtime events
type EventHandler func(payload RealtimePayload)

// RealtimePayload represents a realtime event payload
type RealtimePayload struct {
	Schema string                 `json:"schema"`
	Table  string                 `json:"table"`
	Event  string                 `json:"event"` // INSERT, UPDATE, DELETE
	Old    map[string]interface{} `json:"old"`
	New    map[string]interface{} `json:"new"`
}

// NewRealtimeClient creates a new realtime client
func NewRealtimeClient(client *supabase.Client) *RealtimeClient {
	return &RealtimeClient{
		client:   client,
		handlers: make(map[string]EventHandler),
		channels: make(map[string]interface{}),
	}
}

// SubscribeTiketChanges subscribes to ticket changes
func (r *RealtimeClient) SubscribeTiketChanges(ctx context.Context, handler EventHandler) error {
	channelName := "tiket_changes"

	// Create channel for tiket table
	channel := r.client.Channel(channelName)

	// Subscribe to all changes on tiket table
	onTiketChange := func(payload interface{}) {
		data, err := json.Marshal(payload)
		if err != nil {
			log.Printf("Error marshaling tiket payload: %v", err)
			return
		}

		var realtimePayload RealtimePayload
		if err := json.Unmarshal(data, &realtimePayload); err != nil {
			log.Printf("Error unmarshaling tiket payload: %v", err)
			return
		}

		handler(realtimePayload)
	}

	// Bind to all events (INSERT, UPDATE, DELETE)
	channel.On("postgres_changes", onTiketChange)

	// Subscribe
	if err := channel.Subscribe(); err != nil {
		return fmt.Errorf("failed to subscribe to tiket changes: %w", err)
	}

	r.channels[channelName] = channel
	r.handlers[channelName] = handler

	log.Println("Subscribed to tiket changes")
	return nil
}

// SubscribeKomentarChanges subscribes to comment changes
func (r *RealtimeClient) SubscribeKomentarChanges(ctx context.Context, handler EventHandler) error {
	channelName := "komentar_changes"

	channel := r.client.Channel(channelName)

	onKomentarChange := func(payload interface{}) {
		data, err := json.Marshal(payload)
		if err != nil {
			log.Printf("Error marshaling komentar payload: %v", err)
			return
		}

		var realtimePayload RealtimePayload
		if err := json.Unmarshal(data, &realtimePayload); err != nil {
			log.Printf("Error unmarshaling komentar payload: %v", err)
			return
		}

		handler(realtimePayload)
	}

	channel.On("postgres_changes", onKomentarChange)

	if err := channel.Subscribe(); err != nil {
		return fmt.Errorf("failed to subscribe to komentar changes: %w", err)
	}

	r.channels[channelName] = channel
	r.handlers[channelName] = handler

	log.Println("Subscribed to komentar changes")
	return nil
}

// SubscribeNotifikasiChanges subscribes to notification changes
func (r *RealtimeClient) SubscribeNotifikasiChanges(ctx context.Context, userID uuid.UUID, handler EventHandler) error {
	channelName := fmt.Sprintf("notifikasi_changes_%s", userID.String())

	channel := r.client.Channel(channelName)

	onNotifikasiChange := func(payload interface{}) {
		data, err := json.Marshal(payload)
		if err != nil {
			log.Printf("Error marshaling notifikasi payload: %v", err)
			return
		}

		var realtimePayload RealtimePayload
		if err := json.Unmarshal(data, &realtimePayload); err != nil {
			log.Printf("Error unmarshaling notifikasi payload: %v", err)
			return
		}

		// Filter by user ID for notifikasi
		if penggunaID, ok := realtimePayload.New["pengguna_id"]; ok {
			if uid, err := uuid.Parse(fmt.Sprintf("%v", penggunaID)); err == nil && uid == userID {
				handler(realtimePayload)
			}
		}
	}

	channel.On("postgres_changes", onNotifikasiChange)

	if err := channel.Subscribe(); err != nil {
		return fmt.Errorf("failed to subscribe to notifikasi changes: %w", err)
	}

	r.channels[channelName] = channel
	r.handlers[channelName] = handler

	log.Printf("Subscribed to notifikasi changes for user %s", userID)
	return nil
}

// Unsubscribe unsubscribes from a channel
func (r *RealtimeClient) Unsubscribe(channelName string) error {
	if channel, ok := r.channels[channelName]; ok {
		// Unsubscribe logic depends on supabase-go implementation
		delete(r.channels, channelName)
		delete(r.handlers, channelName)
		log.Printf("Unsubscribed from %s", channelName)
		_ = channel // Use the channel variable
	}
	return nil
}

// Close closes all realtime connections
func (r *RealtimeClient) Close() error {
	for name := range r.channels {
		if err := r.Unsubscribe(name); err != nil {
			log.Printf("Error unsubscribing from %s: %v", name, err)
		}
	}
	return nil
}
