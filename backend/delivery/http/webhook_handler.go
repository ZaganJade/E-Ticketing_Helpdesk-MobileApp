package http

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
)

// WebhookHandler handles Supabase auth webhooks
type WebhookHandler struct {
	penggunaRepo  interfaces.PenggunaRepository
	webhookSecret string
}

// NewWebhookHandler creates a new handler instance
func NewWebhookHandler(
	penggunaRepo interfaces.PenggunaRepository,
	webhookSecret string,
) *WebhookHandler {
	return &WebhookHandler{
		penggunaRepo:  penggunaRepo,
		webhookSecret: webhookSecret,
	}
}

// UserWebhookPayload represents the payload from Supabase auth webhook
type UserWebhookPayload struct {
	Type   string `json:"type"` // INSERT, UPDATE, DELETE
	Table  string `json:"table"`
	Record struct {
		ID              string                 `json:"id"`
		Email           string                 `json:"email"`
		RawUserMetaData map[string]interface{} `json:"raw_user_meta_data"`
		CreatedAt       time.Time              `json:"created_at"`
		UpdatedAt       time.Time              `json:"updated_at"`
	} `json:"record"`
	OldRecord *struct {
		ID string `json:"id"`
	} `json:"old_record,omitempty"`
}

// HandleUserEvents handles all user events (CREATE, UPDATE, DELETE) from single webhook
type HandleUserEvents struct {
	penggunaRepo  interfaces.PenggunaRepository
	webhookSecret string
}

// NewHandleUserEvents creates a new handler instance
func NewHandleUserEvents(
	penggunaRepo interfaces.PenggunaRepository,
	webhookSecret string,
) *HandleUserEvents {
	return &HandleUserEvents{
		penggunaRepo:  penggunaRepo,
		webhookSecret: webhookSecret,
	}
}

// VerifyWebhookSignature verifies the HMAC signature from Supabase
func (h *WebhookHandler) VerifyWebhookSignature(c *gin.Context) bool {
	signature := c.GetHeader("X-Supabase-Signature")
	if signature == "" {
		return false
	}

	body, err := c.GetRawData()
	if err != nil {
		return false
	}

	mac := hmac.New(sha256.New, []byte(h.webhookSecret))
	mac.Write(body)
	expectedSignature := hex.EncodeToString(mac.Sum(nil))

	return hmac.Equal([]byte(signature), []byte(expectedSignature))
}

// HandleUserCreated handles user.created webhook from Supabase
func (h *WebhookHandler) HandleUserCreated(c *gin.Context) {
	// Verify signature if secret is configured
	if h.webhookSecret != "" && !h.VerifyWebhookSignature(c) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid signature"})
		return
	}

	var payload UserWebhookPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Extract user data
	userID, err := uuid.Parse(payload.Record.ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	// Extract nama from metadata
	nama := "Pengguna"
	if payload.Record.RawUserMetaData != nil {
		if n, ok := payload.Record.RawUserMetaData["nama"].(string); ok {
			nama = n
		}
	}

	// Extract role from metadata (default to pengguna)
	peran := entities.RolePengguna
	if payload.Record.RawUserMetaData != nil {
		if r, ok := payload.Record.RawUserMetaData["peran"].(string); ok {
			peran = entities.Role(r)
		}
		if r, ok := payload.Record.RawUserMetaData["role"].(string); ok {
			peran = entities.Role(r)
		}
	}

	// Create pengguna entity
	pengguna := &entities.Pengguna{
		ID:             userID,
		Email:          payload.Record.Email,
		Nama:           nama,
		Peran:          peran,
		DibuatPada:     payload.Record.CreatedAt,
		DiperbaruiPada: payload.Record.UpdatedAt,
	}

	// Upsert to database (insert if not exists, update if exists)
	existing, err := h.penggunaRepo.GetByID(c.Request.Context(), userID)
	if err != nil {
		// User doesn't exist, create new
		if err := h.penggunaRepo.Create(c.Request.Context(), pengguna); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	} else {
		// User exists, update
		pengguna.DibuatPada = existing.DibuatPada // Preserve original created_at
		if err := h.penggunaRepo.Update(c.Request.Context(), pengguna); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User synced successfully",
		"user_id": userID.String(),
	})
}

// HandleUserUpdated handles user.updated webhook
func (h *WebhookHandler) HandleUserUpdated(c *gin.Context) {
	if h.webhookSecret != "" && !h.VerifyWebhookSignature(c) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid signature"})
		return
	}

	var payload UserWebhookPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, err := uuid.Parse(payload.Record.ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	// Get existing user
	existing, err := h.penggunaRepo.GetByID(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// Update fields
	existing.Email = payload.Record.Email
	if payload.Record.RawUserMetaData != nil {
		if n, ok := payload.Record.RawUserMetaData["nama"].(string); ok {
			existing.Nama = n
		}
		if r, ok := payload.Record.RawUserMetaData["peran"].(string); ok {
			existing.Peran = entities.Role(r)
		}
		if r, ok := payload.Record.RawUserMetaData["role"].(string); ok {
			existing.Peran = entities.Role(r)
		}
	}
	existing.DiperbaruiPada = payload.Record.UpdatedAt

	if err := h.penggunaRepo.Update(c.Request.Context(), existing); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User updated successfully",
		"user_id": userID.String(),
	})
}

// HandleUserDeleted handles user.deleted webhook
func (h *WebhookHandler) HandleUserDeleted(c *gin.Context) {
	if h.webhookSecret != "" && !h.VerifyWebhookSignature(c) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid signature"})
		return
	}

	var payload UserWebhookPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDStr := payload.Record.ID
	if userIDStr == "" && payload.OldRecord != nil {
		userIDStr = payload.OldRecord.ID
	}

	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID not found"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	// Hard delete from database
	if err := h.penggunaRepo.Delete(c.Request.Context(), userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User deleted successfully",
		"user_id": userID.String(),
	})
}

// HandleUserEvents handles all user events (INSERT, UPDATE, DELETE) from a single webhook endpoint
func (h *WebhookHandler) HandleUserEvents(c *gin.Context) {
	// Verify signature if secret is configured
	if h.webhookSecret != "" && !h.VerifyWebhookSignature(c) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid signature"})
		return
	}

	var payload UserWebhookPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Route based on event type
	switch payload.Type {
	case "INSERT":
		h.handleInsert(c, payload)
	case "UPDATE":
		h.handleUpdate(c, payload)
	case "DELETE":
		h.handleDelete(c, payload)
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Unknown event type: " + payload.Type})
	}
}

// handleInsert processes INSERT events
func (h *WebhookHandler) handleInsert(c *gin.Context, payload UserWebhookPayload) {
	userID, err := uuid.Parse(payload.Record.ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	nama := "Pengguna"
	if payload.Record.RawUserMetaData != nil {
		if n, ok := payload.Record.RawUserMetaData["nama"].(string); ok {
			nama = n
		}
	}

	peran := entities.RolePengguna
	if payload.Record.RawUserMetaData != nil {
		if r, ok := payload.Record.RawUserMetaData["peran"].(string); ok {
			peran = entities.Role(r)
		}
		if r, ok := payload.Record.RawUserMetaData["role"].(string); ok {
			peran = entities.Role(r)
		}
	}

	pengguna := &entities.Pengguna{
		ID:             userID,
		Email:          payload.Record.Email,
		Nama:           nama,
		Peran:          peran,
		DibuatPada:     payload.Record.CreatedAt,
		DiperbaruiPada: payload.Record.UpdatedAt,
	}

	existing, err := h.penggunaRepo.GetByID(c.Request.Context(), userID)
	if err != nil {
		if err := h.penggunaRepo.Create(c.Request.Context(), pengguna); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	} else {
		pengguna.DibuatPada = existing.DibuatPada
		if err := h.penggunaRepo.Update(c.Request.Context(), pengguna); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User created/updated successfully",
		"user_id": userID.String(),
		"event":   "INSERT",
	})
}

// handleUpdate processes UPDATE events
func (h *WebhookHandler) handleUpdate(c *gin.Context, payload UserWebhookPayload) {
	userID, err := uuid.Parse(payload.Record.ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	existing, err := h.penggunaRepo.GetByID(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	existing.Email = payload.Record.Email
	if payload.Record.RawUserMetaData != nil {
		if n, ok := payload.Record.RawUserMetaData["nama"].(string); ok {
			existing.Nama = n
		}
		if r, ok := payload.Record.RawUserMetaData["peran"].(string); ok {
			existing.Peran = entities.Role(r)
		}
		if r, ok := payload.Record.RawUserMetaData["role"].(string); ok {
			existing.Peran = entities.Role(r)
		}
	}
	existing.DiperbaruiPada = payload.Record.UpdatedAt

	if err := h.penggunaRepo.Update(c.Request.Context(), existing); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User updated successfully",
		"user_id": userID.String(),
		"event":   "UPDATE",
	})
}

// handleDelete processes DELETE events
func (h *WebhookHandler) handleDelete(c *gin.Context, payload UserWebhookPayload) {
	userIDStr := payload.Record.ID
	if userIDStr == "" && payload.OldRecord != nil {
		userIDStr = payload.OldRecord.ID
	}

	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID not found"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	if err := h.penggunaRepo.Delete(c.Request.Context(), userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User deleted successfully",
		"user_id": userID.String(),
		"event":   "DELETE",
	})
}
