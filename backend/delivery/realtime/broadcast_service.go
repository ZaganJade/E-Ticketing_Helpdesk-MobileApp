package realtime

import (
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// BroadcastMessage represents a message to broadcast
type BroadcastMessage struct {
	Type    string      `json:"type"`
	Event   string      `json:"event"`
	Payload interface{} `json:"payload"`
}

// Client represents a connected client (WebSocket or other)
type Client struct {
	ID     uuid.UUID
	UserID uuid.UUID
	Role   entities.Role
	Send   chan []byte
}

// BroadcastService handles broadcasting events to connected clients
type BroadcastService struct {
	clients    map[uuid.UUID]*Client
	register   chan *Client
	unregister chan *Client
	broadcast  chan BroadcastMessage
	hub        *RealtimeClient
}

// NewBroadcastService creates a new broadcast service
func NewBroadcastService(hub *RealtimeClient) *BroadcastService {
	return &BroadcastService{
		clients:    make(map[uuid.UUID]*Client),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan BroadcastMessage),
		hub:        hub,
	}
}

// Run starts the broadcast service
func (s *BroadcastService) Run() {
	for {
		select {
		case client := <-s.register:
			s.clients[client.ID] = client
			fmt.Printf("Client registered: %s (User: %s)\n", client.ID, client.UserID)

		case client := <-s.unregister:
			if _, ok := s.clients[client.ID]; ok {
				delete(s.clients, client.ID)
				close(client.Send)
				fmt.Printf("Client unregistered: %s\n", client.ID)
			}

		case message := <-s.broadcast:
			s.handleBroadcast(message)
		}
	}
}

// Register registers a new client
func (s *BroadcastService) Register(client *Client) {
	s.register <- client
}

// Unregister unregisters a client
func (s *BroadcastService) Unregister(client *Client) {
	s.unregister <- client
}

// Broadcast sends a message to all relevant clients
func (s *BroadcastService) Broadcast(msg BroadcastMessage) {
	s.broadcast <- msg
}

// BroadcastToUser sends a message to a specific user
func (s *BroadcastService) BroadcastToUser(userID uuid.UUID, msg BroadcastMessage) {
	for _, client := range s.clients {
		if client.UserID == userID {
			select {
			case client.Send <- s.encodeMessage(msg):
			default:
				// Client buffer full, close connection
				close(client.Send)
				delete(s.clients, client.ID)
			}
		}
	}
}

// BroadcastToTicketParticipants sends to ticket creator and assigned helpdesk
func (s *BroadcastService) BroadcastToTicketParticipants(tiket *entities.Tiket, msg BroadcastMessage) {
	// Notify creator
	for _, client := range s.clients {
		if client.UserID == tiket.DibuatOleh {
			select {
			case client.Send <- s.encodeMessage(msg):
			default:
				close(client.Send)
				delete(s.clients, client.ID)
			}
		}
	}

	// Notify assigned helpdesk if any
	if tiket.DitugaskanKepada != nil {
		for _, client := range s.clients {
			if client.UserID == *tiket.DitugaskanKepada {
				select {
				case client.Send <- s.encodeMessage(msg):
				default:
					close(client.Send)
					delete(s.clients, client.ID)
				}
			}
		}
	}

	// Also notify all helpdesk/admin users for new tickets
	if msg.Event == "INSERT" && msg.Type == "tiket" {
		for _, client := range s.clients {
			if client.Role == entities.RoleHelpdesk || client.Role == entities.RoleAdmin {
				// Skip if already notified (creator or assigned)
				if client.UserID != tiket.DibuatOleh && (tiket.DitugaskanKepada == nil || client.UserID != *tiket.DitugaskanKepada) {
					select {
					case client.Send <- s.encodeMessage(msg):
					default:
						close(client.Send)
						delete(s.clients, client.ID)
					}
				}
			}
		}
	}
}

func (s *BroadcastService) handleBroadcast(msg BroadcastMessage) {
	// Broadcast to all connected clients
	for _, client := range s.clients {
		select {
		case client.Send <- s.encodeMessage(msg):
		default:
			// Client buffer full, close connection
			close(client.Send)
			delete(s.clients, client.ID)
		}
	}
}

func (s *BroadcastService) encodeMessage(msg BroadcastMessage) []byte {
	data, _ := json.Marshal(msg)
	return data
}

// GetClientsCount returns number of connected clients
func (s *BroadcastService) GetClientsCount() int {
	return len(s.clients)
}
