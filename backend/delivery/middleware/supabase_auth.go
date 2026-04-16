package middleware

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"math/big"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// SupabaseAuthMiddleware validates Supabase JWT tokens
type SupabaseAuthMiddleware struct {
	supabaseURL       string
	supabaseJWTSecret string
	jwksCache         *JWKS
	jwksLastFetch     time.Time
}

// JWKS represents the JSON Web Key Set from Supabase
type JWKS struct {
	Keys []JWK `json:"keys"`
}

// JWK represents a single JSON Web Key
type JWK struct {
	Kty string `json:"kty"`
	Kid string `json:"kid"`
	Use string `json:"use"`
	Alg string `json:"alg"`
	Crv string `json:"crv"`
	X   string `json:"x"`
	Y   string `json:"y"`
}

// SupabaseClaims represents the JWT claims from Supabase
type SupabaseClaims struct {
	Sub      string                 `json:"sub"`          // User ID
	Email    string                 `json:"email"`        // User email
	Role     string                 `json:"role"`         // User role from metadata
	AppMeta  map[string]interface{} `json:"app_metadata"` // App metadata
	UserMeta map[string]interface{} `json:"user_metadata"` // User metadata
	jwt.RegisteredClaims
}

// NewSupabaseAuthMiddleware creates a new middleware instance
func NewSupabaseAuthMiddleware(supabaseJWTSecret string) *SupabaseAuthMiddleware {
	return &SupabaseAuthMiddleware{
		supabaseJWTSecret: supabaseJWTSecret,
	}
}

// NewSupabaseAuthMiddlewareWithURL creates a new middleware instance with Supabase URL
func NewSupabaseAuthMiddlewareWithURL(supabaseURL, supabaseJWTSecret string) *SupabaseAuthMiddleware {
	return &SupabaseAuthMiddleware{
		supabaseURL:       supabaseURL,
		supabaseJWTSecret: supabaseJWTSecret,
	}
}

// fetchJWKS fetches the JSON Web Key Set from Supabase
func (m *SupabaseAuthMiddleware) fetchJWKS() (*JWKS, error) {
	// Return cached JWKS if it's fresh (cache for 1 hour)
	if m.jwksCache != nil && time.Since(m.jwksLastFetch) < time.Hour {
		return m.jwksCache, nil
	}

	jwksURL := fmt.Sprintf("%s/auth/v1/.well-known/jwks.json", m.supabaseURL)
	log.Printf("[AUTH] Fetching JWKS from: %s", jwksURL)

	// Use HTTP/1.1 only to avoid nil pointer dereference on Windows
	client := &http.Client{
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}
	resp, err := client.Get(jwksURL)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch JWKS: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to fetch JWKS: status %d", resp.StatusCode)
	}

	var jwks JWKS
	if err := json.NewDecoder(resp.Body).Decode(&jwks); err != nil {
		return nil, fmt.Errorf("failed to decode JWKS: %w", err)
	}

	m.jwksCache = &jwks
	m.jwksLastFetch = time.Now()
	log.Printf("[AUTH] JWKS fetched successfully with %d keys", len(jwks.Keys))

	return &jwks, nil
}

// getPublicKeyForToken retrieves the appropriate public key for the token
func (m *SupabaseAuthMiddleware) getPublicKeyForToken(token *jwt.Token) (*ecdsa.PublicKey, error) {
	// Get the key ID from the token header
	kid, ok := token.Header["kid"].(string)
	if !ok {
		return nil, fmt.Errorf("token missing kid header")
	}

	// Fetch JWKS
	jwks, err := m.fetchJWKS()
	if err != nil {
		return nil, fmt.Errorf("failed to fetch JWKS: %w", err)
	}

	// Find the matching key
	for _, key := range jwks.Keys {
		if key.Kid == kid {
			return m.parseECDSAPublicKey(&key)
		}
	}

	return nil, fmt.Errorf("no matching key found for kid: %s", kid)
}

// parseECDSAPublicKey parses a JWK into an ECDSA public key
func (m *SupabaseAuthMiddleware) parseECDSAPublicKey(jwk *JWK) (*ecdsa.PublicKey, error) {
	if jwk.Crv != "P-256" {
		return nil, fmt.Errorf("unsupported curve: %s", jwk.Crv)
	}

	// Decode base64url encoded coordinates
	xBytes, err := base64.RawURLEncoding.DecodeString(jwk.X)
	if err != nil {
		return nil, fmt.Errorf("failed to decode x coordinate: %w", err)
	}

	yBytes, err := base64.RawURLEncoding.DecodeString(jwk.Y)
	if err != nil {
		return nil, fmt.Errorf("failed to decode y coordinate: %w", err)
	}

	x := new(big.Int).SetBytes(xBytes)
	y := new(big.Int).SetBytes(yBytes)

	curve := elliptic.P256()
	if !curve.IsOnCurve(x, y) {
		return nil, fmt.Errorf("point is not on curve")
	}

	return &ecdsa.PublicKey{
		Curve: curve,
		X:     x,
		Y:     y,
	}, nil
}

// VerifyJWT validates the JWT token and returns claims
func (m *SupabaseAuthMiddleware) VerifyJWT(tokenString string) (*SupabaseClaims, error) {
	// Parse the token to get the algorithm
	token, err := jwt.ParseWithClaims(
		tokenString,
		&SupabaseClaims{},
		func(token *jwt.Token) (interface{}, error) {
			// Check the signing method
			switch token.Method.(type) {
			case *jwt.SigningMethodHMAC:
				// HS256 - use the JWT secret directly
				return []byte(m.supabaseJWTSecret), nil

			case *jwt.SigningMethodECDSA:
				// ES256 - fetch the public key from JWKS
				if m.supabaseURL == "" {
					return nil, fmt.Errorf("supabase URL not configured for ES256 verification")
				}
				return m.getPublicKeyForToken(token)

			default:
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
		},
	)

	if err != nil {
		return nil, fmt.Errorf("failed to parse token: %w", err)
	}

	if !token.Valid {
		return nil, fmt.Errorf("invalid token")
	}

	claims, ok := token.Claims.(*SupabaseClaims)
	if !ok {
		return nil, fmt.Errorf("invalid claims structure")
	}

	// Check expiration
	if claims.ExpiresAt != nil && claims.ExpiresAt.Time.Before(time.Now()) {
		return nil, fmt.Errorf("token expired")
	}

	return claims, nil
}

// RequireAuth middleware validates Supabase JWT token and sets user context
func (m *SupabaseAuthMiddleware) RequireAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get token from header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			log.Println("[AUTH] No Authorization header")
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		// Extract bearer token
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			log.Println("[AUTH] Invalid authorization header format")
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization header format"})
			c.Abort()
			return
		}

		token := parts[1]
		log.Printf("[AUTH] Token received (first 50 chars): %s...", token[:min(50, len(token))])

		// Verify token
		claims, err := m.VerifyJWT(token)
		if err != nil {
			log.Printf("[AUTH] JWT verification failed: %v", err)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token", "details": err.Error()})
			c.Abort()
			return
		}
		log.Printf("[AUTH] JWT verified successfully for user: %s", claims.Sub)

		// Parse user ID
		userID, err := uuid.Parse(claims.Sub)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user ID in token"})
			c.Abort()
			return
		}

		// Extract role from user_metadata or app_metadata
		role := "pengguna" // default
		if claims.UserMeta != nil {
			if r, ok := claims.UserMeta["peran"].(string); ok {
				role = r
			}
			if r, ok := claims.UserMeta["role"].(string); ok {
				role = r
			}
		}

		// Set user context
		c.Set("userID", userID.String())
		c.Set("email", claims.Email)
		c.Set("peran", role)

		c.Next()
	}
}

// RequireRole middleware checks if user has required role
func (m *SupabaseAuthMiddleware) RequireRole(roles ...string) gin.HandlerFunc {
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
func (m *SupabaseAuthMiddleware) RequireHelpdeskOrAdmin() gin.HandlerFunc {
	return m.RequireRole("helpdesk", "admin")
}

// RequireAdmin middleware allows only admin
func (m *SupabaseAuthMiddleware) RequireAdmin() gin.HandlerFunc {
	return m.RequireRole("admin")
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
