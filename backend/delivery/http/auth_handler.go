package http

import (
	"bytes"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/entities"
	"eticketinghelpdesk/interfaces"
	"eticketinghelpdesk/usecases"
)

// AuthHandler handles authentication HTTP requests
type AuthHandler struct {
	registerUC           *usecases.RegisterUseCase
	loginUC              *usecases.LoginUseCase
	logoutUC             *usecases.LogoutUseCase
	uploadFotoProfilUC   *usecases.UploadFotoProfilUseCase
	deleteFotoProfilUC   *usecases.DeleteFotoProfilUseCase
	penggunaRepo         interfaces.PenggunaRepository
}

// NewAuthHandler creates a new handler instance
func NewAuthHandler(
	registerUC *usecases.RegisterUseCase,
	loginUC *usecases.LoginUseCase,
	logoutUC *usecases.LogoutUseCase,
	uploadFotoProfilUC *usecases.UploadFotoProfilUseCase,
	deleteFotoProfilUC *usecases.DeleteFotoProfilUseCase,
	penggunaRepo interfaces.PenggunaRepository,
) *AuthHandler {
	return &AuthHandler{
		registerUC:         registerUC,
		loginUC:            loginUC,
		logoutUC:           logoutUC,
		uploadFotoProfilUC: uploadFotoProfilUC,
		deleteFotoProfilUC: deleteFotoProfilUC,
		penggunaRepo:       penggunaRepo,
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

// GetCurrentUser returns current authenticated user info.
// It loads the full profile (nama, foto_profil) from the database rather than
// relying on the JWT context, which only carries user_id, email and peran.
func (h *AuthHandler) GetCurrentUser(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	// JWT-derived values, used as a fallback if the profile can't be loaded.
	email := c.GetString("email")
	peran := c.GetString("peran")

	pengguna, err := h.penggunaRepo.GetByID(c.Request.Context(), uid)
	if err != nil {
		// Profile row not synced yet (or DB unavailable): return what the token carries.
		c.JSON(http.StatusOK, gin.H{
			"user_id":     uid.String(),
			"nama":        nil,
			"email":       email,
			"peran":       peran,
			"foto_profil": nil,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":     pengguna.ID.String(),
		"nama":        pengguna.Nama,
		"email":       pengguna.Email,
		"peran":       string(pengguna.Peran),
		"foto_profil": pengguna.FotoProfil,
	})
}

// UploadFotoProfil handles profile photo upload (hanya JPG/PNG)
func (h *AuthHandler) UploadFotoProfil(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	// Parse multipart form
	if err := c.Request.ParseMultipartForm(5 << 20); err != nil { // 5MB max
		c.JSON(http.StatusBadRequest, gin.H{"error": "ukuran file terlalu besar (maksimal 5MB)"})
		return
	}

	// Get file from form
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "file tidak ditemukan"})
		return
	}

	// Read file content into memory (file will be closed after this)
	fileContent, err := io.ReadAll(file)
	file.Close()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "gagal membaca file"})
		return
	}

	// Execute upload use case with in-memory content
	output, err := h.uploadFotoProfilUC.Execute(c.Request.Context(), usecases.UploadFotoProfilInput{
		UserID:   uid,
		FileName: header.Filename,
		FileSize: header.Size,
		Content:  bytes.NewReader(fileContent),
	})
	if err != nil {
		if entities.IsValidation(err) {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Foto profil berhasil diupload",
		"data": gin.H{
			"foto_profil": output.FotoProfilURL,
			"nama":        output.Nama,
		},
	})
}

// DeleteFotoProfil handles profile photo deletion
func (h *AuthHandler) DeleteFotoProfil(c *gin.Context) {
	uid, ok := currentUserID(c)
	if !ok {
		return
	}

	// Execute delete use case
	_, err := h.deleteFotoProfilUC.Execute(c.Request.Context(), usecases.DeleteFotoProfilInput{
		UserID: uid,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Foto profil berhasil dihapus",
	})
}
