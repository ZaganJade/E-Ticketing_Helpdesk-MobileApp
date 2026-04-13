package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"eticketinghelpdesk/interfaces"
)

// AuthMiddleware validates JWT token and sets user context
func AuthMiddleware(authRepo interfaces.AuthRepository) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header tidak ditemukan"})
			c.Abort()
			return
		}

		// Extract Bearer token
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization header format"})
			c.Abort()
			return
		}
		token := parts[1]

		// Verify token and get user ID
		userID, err := authRepo.VerifyToken(c.Request.Context(), token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token tidak valid"})
			c.Abort()
			return
		}

		// Create new context with userID
		ctx := context.WithValue(c.Request.Context(), "userID", userID.String())

		// Get user details using the enriched context
		user, err := authRepo.GetCurrentUser(ctx)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Gagal mengambil data pengguna"})
			c.Abort()
			return
		}

		// Set user context
		c.Set("userID", userID.String())
		c.Set("email", user.Email)
		c.Set("nama", user.Nama)
		c.Set("peran", string(user.Peran))

		c.Next()
	}
}

// HelpdeskOrAdminMiddleware restricts access to helpdesk or admin only
func HelpdeskOrAdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		peran := c.GetString("peran")
		if peran != "helpdesk" && peran != "admin" {
			c.JSON(http.StatusForbidden, gin.H{"error": "Akses ditolak. Hanya helpdesk atau admin."})
			c.Abort()
			return
		}
		c.Next()
	}
}

// AdminMiddleware restricts access to admin only
func AdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		peran := c.GetString("peran")
		if peran != "admin" {
			c.JSON(http.StatusForbidden, gin.H{"error": "Akses ditolak. Hanya admin."})
			c.Abort()
			return
		}
		c.Next()
	}
}

// GetUserID extracts user ID from context
func GetUserID(c *gin.Context) uuid.UUID {
	idStr, _ := c.Get("userID")
	return uuid.MustParse(idStr.(string))
}

// GetUserRole extracts user role from context
func GetUserRole(c *gin.Context) string {
	peran, _ := c.Get("peran")
	return peran.(string)
}
