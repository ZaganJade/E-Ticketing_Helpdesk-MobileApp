# Realtime Delivery Layer

This package handles Supabase Realtime subscriptions and broadcasting events to connected clients.

## Components

### RealtimeClient

Manages Supabase Realtime subscriptions to database changes:

```go
realtimeClient := realtime.NewRealtimeClient(supabaseClient)

// Subscribe to ticket changes
realtimeClient.SubscribeTiketChanges(ctx, handler)

// Subscribe to comment changes  
realtimeClient.SubscribeKomentarChanges(ctx, handler)

// Subscribe to notifications for specific user
realtimeClient.SubscribeNotifikasiChanges(ctx, userID, handler)
```

### BroadcastService

Manages WebSocket-like connections and broadcasts events to connected clients:

```go
broadcastService := realtime.NewBroadcastService(realtimeClient)
go broadcastService.Run() // Start in goroutine

// Register a client
client := &realtime.Client{
    ID:     uuid.New(),
    UserID: userID,
    Role:   role,
    Send:   make(chan []byte, 256),
}
broadcastService.Register(client)

// Broadcast to specific user
broadcastService.BroadcastToUser(userID, msg)

// Broadcast to ticket participants
broadcastService.BroadcastToTicketParticipants(tiket, msg)
```

### EventHandlers

Handles specific realtime events and determines who to notify:

| Event | Handler | Action |
|-------|---------|--------|
| tiket INSERT | HandleTiketChange | Notify creator + all helpdesk |
| tiket UPDATE | HandleTiketChange | Notify participants |
| tiket status change | HandleTiketChange | Send specific status notification |
| komentar INSERT | HandleKomentarChange | Notify ticket participants |
| notifikasi INSERT | HandleNotifikasiChange | Notify target user only |

## Event Flow

```
Database Change
    ↓
Supabase Realtime
    ↓
RealtimeClient (subscription)
    ↓
EventHandler
    ↓
BroadcastService
    ↓
Connected Clients (WebSocket/polling)
```

## Message Format

```json
{
  "type": "tiket|komentar|notifikasi",
  "event": "INSERT|UPDATE|DELETE|NEW_COMMENT|NEW_NOTIFICATION",
  "payload": { ...entity data... }
}
```

## Usage

```go
// Initialize
realtimeClient := realtime.NewRealtimeClient(supabaseClient)
broadcastService := realtime.NewBroadcastService(realtimeClient)
eventHandlers := realtime.NewEventHandlers(broadcastService)

// Start listeners
ctx := context.Background()
realtime.StartRealtimeListeners(ctx, realtimeClient, eventHandlers)

// Start broadcast service
 go broadcastService.Run()

// Cleanup on shutdown
realtimeClient.Close()
```
