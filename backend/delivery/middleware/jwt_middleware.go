package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/interfaces"
)

// JWTMiddleware validates JWT tokens
type JWTMiddleware struct {
	authRepo interfaces.AuthRepository
}

// NewJWTMiddleware creates a new middleware instance
func NewJWTMiddleware(authRepo interfaces.AuthRepository) *JWTMiddleware {
	return &JWTMiddleware{authRepo: authRepo}
}

// RequireAuth middleware validates JWT token and sets user context
func (m *JWTMiddleware) RequireAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get token from header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		// Extract bearer token
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization header format"})
			c.Abort()
			return
		}

		token := parts[1]

		// Verify token and get user ID
		userID, err := m.authRepo.VerifyToken(c.Request.Context(), token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		// Get user details from repository
		pengguna, err := m.authRepo.GetUserByID(c.Request.Context(), userID.String())
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
			c.Abort()
			return
		}

		// Set user context
		c.Set("userID", pengguna.ID.String())
		c.Set("email", pengguna.Email)
		c.Set("nama", pengguna.Nama)
		c.Set("peran", string(pengguna.Peran))

		c.Next()
	}
}

// RequireRole middleware checks if user has required role
func (m *JWTMiddleware) RequireRole(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole := c.GetString("peran")

		// Check if user's role is in allowed roles
		allowed := false
		for _, role := range roles {
			if userRole == role {
				allowed = true
				break
			}
		}

		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient permissions"})
			c.Abort()
			return
		}

		c.Next()
	}
}

// RequireHelpdeskOrAdmin middleware allows only helpdesk and admin
func (m *JWTMiddleware) RequireHelpdeskOrAdmin() gin.HandlerFunc {
	return m.RequireRole("helpdesk", "admin")
}

// RequireAdmin middleware allows only admin
func (m *JWTMiddleware) RequireAdmin() gin.HandlerFunc {
	return m.RequireRole("admin")
}

