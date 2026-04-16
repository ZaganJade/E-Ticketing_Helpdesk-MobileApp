package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	"eticketinghelpdesk/config"
	httpDelivery "eticketinghelpdesk/delivery/http"
	"eticketinghelpdesk/delivery/middleware"
	"eticketinghelpdesk/repository"
	"eticketinghelpdesk/usecases"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment")
	}

	// Set Gin mode
	if os.Getenv("ENV") == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Load config
	cfg := config.LoadConfig()

	// Validate required Supabase configuration
	if cfg.SupabaseURL == "" || cfg.SupabaseServiceKey == "" {
		log.Fatal("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
	}
	if cfg.SupabaseJWTSecret == "" {
		log.Fatal("SUPABASE_JWT_SECRET must be set for auth middleware")
	}

	// Initialize Supabase client wrapper
	supabaseClient, err := repository.NewSupabaseClient(cfg)
	if err != nil {
		log.Fatalf("Failed to create Supabase client: %v", err)
	}

	// Initialize repositories
	authRepo := repository.NewSupabaseAuthRepository(supabaseClient, cfg)
	penggunaRepo := repository.NewSupabasePenggunaRepository(supabaseClient)
	tiketRepo := repository.NewSupabaseTiketRepository(supabaseClient)
	komentarRepo := repository.NewSupabaseKomentarRepository(supabaseClient)
	notifikasiRepo := repository.NewSupabaseNotifikasiRepository(supabaseClient)
	lampiranRepo := repository.NewSupabaseLampiranRepository(supabaseClient)
	storageRepo := repository.NewSupabaseStorageRepository(supabaseClient)

	// Initialize usecases
	registerUC := usecases.NewRegisterUseCase(authRepo)
	loginUC := usecases.NewLoginUseCase(authRepo)
	logoutUC := usecases.NewLogoutUseCase(authRepo)
	createTiketUC := usecases.NewCreateTiketUseCase(tiketRepo)
	getTiketListUC := usecases.NewGetTiketListUseCase(tiketRepo)
	getTiketDetailUC := usecases.NewGetTiketDetailUseCase(tiketRepo)
	updateTiketStatusUC := usecases.NewUpdateTiketStatusUseCase(tiketRepo, notifikasiRepo)
	assignTiketUC := usecases.NewAssignTiketUseCase(tiketRepo, notifikasiRepo)
	addKomentarUC := usecases.NewAddKomentarUseCase(komentarRepo, tiketRepo, notifikasiRepo)
	getNotifikasiListUC := usecases.NewGetNotifikasiListUseCase(notifikasiRepo)
	markNotifikasiReadUC := usecases.NewMarkNotifikasiReadUseCase(notifikasiRepo)
	uploadLampiranUC := usecases.NewUploadLampiranUseCase(lampiranRepo, tiketRepo)
	deleteLampiranUC := usecases.NewDeleteLampiranUseCase(lampiranRepo, tiketRepo)
	getDashboardStatsUC := usecases.NewGetDashboardStatsUseCase(tiketRepo)
	uploadFotoProfilUC := usecases.NewUploadFotoProfilUseCase(penggunaRepo, storageRepo, cfg.SupabaseURL)
	deleteFotoProfilUC := usecases.NewDeleteFotoProfilUseCase(penggunaRepo, storageRepo)

	// Initialize middleware
	jwtMiddleware := middleware.NewJWTMiddleware(authRepo)
	supabaseAuthMiddleware := middleware.NewSupabaseAuthMiddlewareWithURL(cfg.SupabaseURL, cfg.SupabaseJWTSecret)

	// Create handlers
	authHandler := httpDelivery.NewAuthHandler(registerUC, loginUC, logoutUC, uploadFotoProfilUC, deleteFotoProfilUC)
	tiketHandler := httpDelivery.NewTiketHandler(createTiketUC, getTiketListUC, getTiketDetailUC, updateTiketStatusUC, assignTiketUC)
	komentarHandler := httpDelivery.NewKomentarHandler(addKomentarUC)
	notifikasiHandler := httpDelivery.NewNotifikasiHandler(getNotifikasiListUC, markNotifikasiReadUC)
	lampiranHandler := httpDelivery.NewLampiranHandler(uploadLampiranUC, deleteLampiranUC, lampiranRepo)
	dashboardHandler := httpDelivery.NewDashboardHandler(getDashboardStatsUC)
	webhookHandler := httpDelivery.NewWebhookHandler(penggunaRepo, cfg.SupabaseWebhookSecret)

	// Setup Gin router
	r := gin.Default()
	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.ErrorHandlingMiddleware())

	// API routes
	api := r.Group("/api")

	// Public routes - Webhooks from Supabase (must be before auth middleware)
	webhooks := api.Group("/webhooks")
	{
		// Single endpoint for all user events (INSERT, UPDATE, DELETE)
		webhooks.POST("/user-events", webhookHandler.HandleUserEvents)
		// Legacy separate endpoints (kept for backward compatibility)
		webhooks.POST("/user-created", webhookHandler.HandleUserCreated)
		webhooks.POST("/user-updated", webhookHandler.HandleUserUpdated)
		webhooks.POST("/user-deleted", webhookHandler.HandleUserDeleted)
	}

	// Public routes - Auth (deprecated, kept for backward compatibility)
	auth := api.Group("/auth")
	{
		// DEPRECATED: Use Supabase Auth directly from Flutter
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
		auth.POST("/logout", authHandler.Logout)
	}

	// Protected routes using Supabase JWT middleware
	protected := api.Group("")
	protected.Use(supabaseAuthMiddleware.RequireAuth())
	{
		// Auth - User info and profile photo
		protected.GET("/auth/me", authHandler.GetCurrentUser)
		protected.POST("/auth/me/photo", authHandler.UploadFotoProfil)
		protected.DELETE("/auth/me/photo", authHandler.DeleteFotoProfil)

		// Dashboard
		protected.GET("/dashboard/stats", dashboardHandler.GetStats)

		// Tiket routes (including nested komentar and lampiran)
		tikets := protected.Group("/tikets")
		{
			tikets.GET("", tiketHandler.GetTiketList)
			tikets.POST("", tiketHandler.CreateTiket)
			tikets.GET("/:id", tiketHandler.GetTiketDetail)
			tikets.PATCH("/:id/status", supabaseAuthMiddleware.RequireHelpdeskOrAdmin(), tiketHandler.UpdateTiketStatus)
			tikets.POST("/:id/assign", supabaseAuthMiddleware.RequireHelpdeskOrAdmin(), tiketHandler.AssignTiket)

			// Komentar (nested under tikets/:id)
			tikets.GET("/:id/komentars", komentarHandler.GetKomentarList)
			tikets.POST("/:id/komentars", komentarHandler.AddKomentar)

			// Lampiran (nested under tikets/:id)
			tikets.GET("/:id/lampirans", lampiranHandler.GetLampiranList)
			tikets.POST("/:id/lampirans/upload", lampiranHandler.UploadLampiran)
			tikets.GET("/:id/lampirans/:lampiran_id/download", lampiranHandler.DownloadLampiran)
			tikets.DELETE("/:id/lampirans/:lampiran_id", lampiranHandler.DeleteLampiran)
		}

		// Notifikasi
		notifs := protected.Group("/notifikasis")
		{
			notifs.GET("", notifikasiHandler.GetNotifikasiList)
			notifs.PATCH("/:id/read", notifikasiHandler.MarkNotifikasiRead)
			notifs.PATCH("/read-all", notifikasiHandler.MarkAllNotifikasiRead)
		}
	}

	// Legacy protected routes using old JWT middleware (for backward compatibility)
	// These can be removed once all clients have migrated to Supabase Auth
	legacyProtected := api.Group("/legacy")
	legacyProtected.Use(jwtMiddleware.RequireAuth())
	{
		legacyProtected.GET("/auth/me", authHandler.GetCurrentUser)
		legacyProtected.POST("/auth/me/photo", authHandler.UploadFotoProfil)
		legacyProtected.DELETE("/auth/me/photo", authHandler.DeleteFotoProfil)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Printf("API endpoints available at http://localhost:%s/api", port)
	log.Printf("Supabase webhooks available at http://localhost:%s/api/webhooks", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
