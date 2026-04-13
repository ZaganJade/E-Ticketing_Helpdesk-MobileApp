package http

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/usecases"
)

// AuthHandler handles authentication HTTP requests
type AuthHandler struct {
	registerUC *usecases.RegisterUseCase
	loginUC    *usecases.LoginUseCase
	logoutUC   *usecases.LogoutUseCase
}

// NewAuthHandler creates a new handler instance
func NewAuthHandler(registerUC *usecases.RegisterUseCase, loginUC *usecases.LoginUseCase, logoutUC *usecases.LogoutUseCase) *AuthHandler {
	return &AuthHandler{
		registerUC: registerUC,
		loginUC:    loginUC,
		logoutUC:   logoutUC,
	}
}

// RegisterRequest represents registration request body
type RegisterRequest struct {
	Nama     string `json:"nama" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

// LoginRequest represents login request body
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse represents authentication response
type AuthResponse struct {
	Token    string `json:"token"`
	Refresh  string `json:"refresh_token,omitempty"`
	UserID   string `json:"user_id"`
	Nama     string `json:"nama"`
	Email    string `json:"email"`
	Peran    string `json:"peran"`
}

// Register handles user registration
func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	pengguna, err := h.registerUC.Execute(c.Request.Context(), usecases.RegisterInput{
		Nama:     req.Nama,
		Email:    req.Email,
		Password: req.Password,
	})
	if err != nil {
		if entities.IsValidation(err) {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Registrasi berhasil",
		"data": gin.H{
			"user_id": pengguna.ID.String(),
			"nama":    pengguna.Nama,
			"email":   pengguna.Email,
			"peran":   string(pengguna.Peran),
		},
	})
}

// Login handles user login
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	output, err := h.loginUC.Execute(c.Request.Context(), usecases.LoginInput{
		Email:    req.Email,
		Password: req.Password,
	})
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, AuthResponse{
		Token:   output.Token.AccessToken,
		Refresh: output.Token.RefreshToken,
		UserID:  output.UserID,
		Nama:    output.Nama,
		Email:   output.Email,
		Peran:   output.Peran,
	})
}

// Logout handles user logout
func (h *AuthHandler) Logout(c *gin.Context) {
	if err := h.logoutUC.Execute(c.Request.Context()); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Logout berhasil"})
}

// GetCurrentUser returns current authenticated user info
func (h *AuthHandler) GetCurrentUser(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "tidak terautentikasi"})
		return
	}

	peran, _ := c.Get("peran")
	email, _ := c.Get("email")
	nama, _ := c.Get("nama")

	c.JSON(http.StatusOK, gin.H{
		"user_id": userID,
		"nama":    nama,
		"email":   email,
		"peran":   peran,
	})
}
