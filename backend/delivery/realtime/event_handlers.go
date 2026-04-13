package realtime

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// EventHandlers contains handlers for different realtime events
type EventHandlers struct {
	broadcastService *BroadcastService
}

// NewEventHandlers creates new event handlers
func NewEventHandlers(broadcastService *BroadcastService) *EventHandlers {
	return &EventHandlers{broadcastService: broadcastService}
}

// HandleTiketChange handles ticket change events
func (h *EventHandlers) HandleTiketChange(ctx context.Context, payload RealtimePayload) {
	log.Printf("Tiket change event: %s", payload.Event)

	// Parse ticket data
	tiketData, err := json.Marshal(payload.New)
	if err != nil {
		log.Printf("Error marshaling tiket data: %v", err)
		return
	}

	var tiket entities.Tiket
	if err := json.Unmarshal(tiketData, &tiket); err != nil {
		log.Printf("Error parsing tiket data: %v", err)
		return
	}

	// Broadcast to relevant clients based on event type
	msg := BroadcastMessage{
		Type:    "tiket",
		Event:   payload.Event,
		Payload: tiket,
	}

	switch payload.Event {
	case "INSERT":
		// Notify creator and all helpdesk
		h.broadcastService.BroadcastToTicketParticipants(&tiket, msg)

	case "UPDATE":
		// Notify participants
		h.broadcastService.BroadcastToTicketParticipants(&tiket, msg)

		// If status changed, send specific notification
		if oldData, ok := payload.Old["status"]; ok {
			if oldStatus := fmt.Sprintf("%v", oldData); oldStatus != string(tiket.Status) {
				statusMsg := BroadcastMessage{
					Type:  "tiket_status_change",
					Event: string(tiket.Status),
					Payload: map[string]interface{}{
						"tiket_id":    tiket.ID,
						"judul":       tiket.Judul,
						"new_status":  tiket.Status,
						"old_status":  oldStatus,
					},
				}
				h.broadcastService.BroadcastToTicketParticipants(&tiket, statusMsg)
			}
		}

	case "DELETE":
		// Notify participants that ticket was deleted
		if payload.Old != nil {
			if dibuatOleh, ok := payload.Old["dibuat_oleh"]; ok {
				if uid, err := uuid.Parse(fmt.Sprintf("%v", dibuatOleh)); err == nil {
					msg.Payload = map[string]interface{}{
						"tiket_id": payload.Old["id"],
						"message":  "Tiket telah dihapus",
					}
					h.broadcastService.BroadcastToUser(uid, msg)
				}
			}
		}
	}
}

// HandleKomentarChange handles comment change events
func (h *EventHandlers) HandleKomentarChange(ctx context.Context, payload RealtimePayload) {
	log.Printf("Komentar change event: %s", payload.Event)

	if payload.Event != "INSERT" {
		return // Only handle new comments
	}

	// Parse comment data
	komentarData, err := json.Marshal(payload.New)
	if err != nil {
		log.Printf("Error marshaling komentar data: %v", err)
		return
	}

	var komentar entities.Komentar
	if err := json.Unmarshal(komentarData, &komentar); err != nil {
		log.Printf("Error parsing komentar data: %v", err)
		return
	}

	// Broadcast to ticket participants
	msg := BroadcastMessage{
		Type:    "komentar",
		Event:   "NEW_COMMENT",
		Payload: komentar,
	}

	// Get tiket_id from comment
	tiketID := komentar.TiketID

	// Create a minimal tiket for broadcasting
	tiket := entities.Tiket{ID: tiketID}

	// Get penulis info
	if penulisID, ok := payload.New["penulis_id"]; ok {
		if uid, err := uuid.Parse(fmt.Sprintf("%v", penulisID)); err == nil {
			komentar.PenulisID = uid
		}
	}

	h.broadcastService.BroadcastToTicketParticipants(&tiket, msg)
}

// HandleNotifikasiChange handles notification change events
func (h *EventHandlers) HandleNotifikasiChange(ctx context.Context, payload RealtimePayload) {
	log.Printf("Notifikasi change event: %s", payload.Event)

	if payload.Event != "INSERT" {
		return // Only handle new notifications
	}

	// Parse notification data
	notifData, err := json.Marshal(payload.New)
	if err != nil {
		log.Printf("Error marshaling notifikasi data: %v", err)
		return
	}

	var notifikasi entities.Notifikasi
	if err := json.Unmarshal(notifData, &notifikasi); err != nil {
		log.Printf("Error parsing notifikasi data: %v", err)
		return
	}

	// Broadcast only to the specific user
	msg := BroadcastMessage{
		Type:    "notifikasi",
		Event:   "NEW_NOTIFICATION",
		Payload: notifikasi,
	}

	h.broadcastService.BroadcastToUser(notifikasi.PenggunaID, msg)
}

// StartRealtimeListeners starts all realtime event listeners
func StartRealtimeListeners(ctx context.Context, realtimeClient *RealtimeClient, handlers *EventHandlers) error {
	// Subscribe to tiket changes
	if err := realtimeClient.SubscribeTiketChanges(ctx, func(payload RealtimePayload) {
		handlers.HandleTiketChange(ctx, payload)
	}); err != nil {
		return fmt.Errorf("failed to subscribe to tiket changes: %w", err)
	}

	// Subscribe to komentar changes
	if err := realtimeClient.SubscribeKomentarChanges(ctx, func(payload RealtimePayload) {
		handlers.HandleKomentarChange(ctx, payload)
	}); err != nil {
		return fmt.Errorf("failed to subscribe to komentar changes: %w", err)
	}

	return nil
}

// StartUserNotificationListener starts notification listener for a specific user
func StartUserNotificationListener(ctx context.Context, realtimeClient *RealtimeClient, userID uuid.UUID, handlers *EventHandlers) error {
	return realtimeClient.SubscribeNotifikasiChanges(ctx, userID, func(payload RealtimePayload) {
		handlers.HandleNotifikasiChange(ctx, payload)
	})
}
