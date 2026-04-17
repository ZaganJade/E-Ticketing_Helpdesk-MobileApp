package http

import (
	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/delivery/middleware"
	"eticketinghelpdesk/interfaces"
	"eticketinghelpdesk/usecases"
)

// Router sets up all HTTP routes
type Router struct {
	engine               *gin.Engine
	supabaseAuthMiddleware *middleware.SupabaseAuthMiddleware
	jwtMiddleware          *middleware.JWTMiddleware // Kept for backward compatibility during migration
	authHandler            *AuthHandler
	tiketHandler           *TiketHandler
	komentarHandler        *KomentarHandler
	notifikasiHandler      *NotifikasiHandler
	lampiranHandler        *LampiranHandler
	dashboardHandler       *DashboardHandler
	webhookHandler         *WebhookHandler
}

// NewRouter creates a new router instance
func NewRouter(
	authRepo interfaces.AuthRepository,
	penggunaRepo interfaces.PenggunaRepository,
	registerUC *usecases.RegisterUseCase,
	loginUC *usecases.LoginUseCase,
	logoutUC *usecases.LogoutUseCase,
	createTiketUC *usecases.CreateTiketUseCase,
	getTiketListUC *usecases.GetTiketListUseCase,
	getTiketDetailUC *usecases.GetTiketDetailUseCase,
	updateTiketStatusUC *usecases.UpdateTiketStatusUseCase,
	assignTiketUC *usecases.AssignTiketUseCase,
	addKomentarUC *usecases.AddKomentarUseCase,
	getNotifikasiListUC *usecases.GetNotifikasiListUseCase,
	markNotifikasiReadUC *usecases.MarkNotifikasiReadUseCase,
	uploadLampiranUC *usecases.UploadLampiranUseCase,
	deleteLampiranUC *usecases.DeleteLampiranUseCase,
	lampiranRepo interfaces.LampiranRepository,
	getDashboardStatsUC *usecases.GetDashboardStatsUseCase,
	uploadFotoProfilUC *usecases.UploadFotoProfilUseCase,
	deleteFotoProfilUC *usecases.DeleteFotoProfilUseCase,
	supabaseURL string,
	supabaseJWTSecret string,
	supabaseWebhookSecret string,
) *Router {
	r := gin.Default()

	// Apply global middleware
	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.ErrorHandlingMiddleware())

	// Initialize middleware
	jwtMiddleware := middleware.NewJWTMiddleware(authRepo)
	supabaseAuthMiddleware := middleware.NewSupabaseAuthMiddlewareWithURL(supabaseURL, supabaseJWTSecret)

	// Initialize webhook handler
	webhookHandler := NewWebhookHandler(penggunaRepo, supabaseWebhookSecret)

	return &Router{
		engine:                 r,
		jwtMiddleware:          jwtMiddleware,
		supabaseAuthMiddleware: supabaseAuthMiddleware,
		authHandler:            NewAuthHandler(registerUC, loginUC, logoutUC, uploadFotoProfilUC, deleteFotoProfilUC),
		tiketHandler:           NewTiketHandler(createTiketUC, getTiketListUC, getTiketDetailUC, updateTiketStatusUC, assignTiketUC, uploadLampiranUC),
		komentarHandler:        NewKomentarHandler(addKomentarUC),
		notifikasiHandler:      NewNotifikasiHandler(getNotifikasiListUC, markNotifikasiReadUC),
		lampiranHandler:        NewLampiranHandler(uploadLampiranUC, deleteLampiranUC, lampiranRepo),
		dashboardHandler:       NewDashboardHandler(getDashboardStatsUC),
		webhookHandler:         webhookHandler,
	}
}

// SetupRoutes configures all API routes
func (r *Router) SetupRoutes() {
	api := r.engine.Group("/api")

	// Public routes - Webhooks from Supabase
	webhooks := api.Group("/webhooks")
	{
		webhooks.POST("/user-created", r.webhookHandler.HandleUserCreated)
		webhooks.POST("/user-updated", r.webhookHandler.HandleUserUpdated)
		webhooks.POST("/user-deleted", r.webhookHandler.HandleUserDeleted)
	}

	// Public routes - Auth (kept for backward compatibility during migration)
	// These will be removed once Flutter fully migrates to Supabase Auth
	auth := api.Group("/auth")
	{
		// Deprecated: These endpoints should not be used by new clients
		// Use Supabase Auth directly from Flutter instead
		auth.POST("/register", r.authHandler.Register) // DEPRECATED
		auth.POST("/login", r.authHandler.Login)       // DEPRECATED
		auth.POST("/logout", r.authHandler.Logout)     // DEPRECATED
	}

	// Protected routes using Supabase JWT middleware
	protected := api.Group("")
	protected.Use(r.supabaseAuthMiddleware.RequireAuth())
	{
		// Auth - User info (now uses Supabase JWT claims)
		protected.GET("/auth/me", r.authHandler.GetCurrentUser)
		protected.POST("/auth/me/photo", r.authHandler.UploadFotoProfil)
		protected.DELETE("/auth/me/photo", r.authHandler.DeleteFotoProfil)

		// Dashboard
		protected.GET("/dashboard/stats", r.dashboardHandler.GetStats)

		// Tiket
		tikets := protected.Group("/tikets")
		{
			tikets.GET("", r.tiketHandler.GetTiketList)
			tikets.POST("", r.tiketHandler.CreateTiket)
			tikets.GET("/:id", r.tiketHandler.GetTiketDetail)
			tikets.PATCH("/:id/status", r.supabaseAuthMiddleware.RequireHelpdeskOrAdmin(), r.tiketHandler.UpdateTiketStatus)
			tikets.POST("/:id/assign", r.supabaseAuthMiddleware.RequireHelpdeskOrAdmin(), r.tiketHandler.AssignTiket)
		}

		// Komentar
		komentars := protected.Group("/tikets/:id/komentars")
		{
			komentars.GET("", r.komentarHandler.GetKomentarList)
			komentars.POST("", r.komentarHandler.AddKomentar)
		}

		// Notifikasi
		notifs := protected.Group("/notifikasis")
		{
			notifs.GET("", r.notifikasiHandler.GetNotifikasiList)
			notifs.PATCH("/:id/read", r.notifikasiHandler.MarkNotifikasiRead)
			notifs.PATCH("/read-all", r.notifikasiHandler.MarkAllNotifikasiRead)
		}

		// Lampiran
		lampirans := protected.Group("/tikets/:id/lampirans")
		{
			lampirans.GET("", r.lampiranHandler.GetLampiranList)
			lampirans.POST("/upload", r.lampiranHandler.UploadLampiran)
			lampirans.GET("/:id/download", r.lampiranHandler.DownloadLampiran)
			lampirans.DELETE("/:id", r.lampiranHandler.DeleteLampiran)
		}
	}
}

// GetEngine returns the gin engine
func (r *Router) GetEngine() *gin.Engine {
	return r.engine
}
