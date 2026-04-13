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

	// Initialize Supabase client wrapper
	if cfg.SupabaseURL == "" || cfg.SupabaseServiceKey == "" {
		log.Fatal("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
	}

	supabaseClient, err := repository.NewSupabaseClient(cfg)
	if err != nil {
		log.Fatalf("Failed to create Supabase client: %v", err)
	}

	// Initialize repositories
	authRepo := repository.NewSupabaseAuthRepository(supabaseClient, cfg)
	_ = repository.NewSupabasePenggunaRepository(supabaseClient) // penggunaRepo - for future use
	tiketRepo := repository.NewSupabaseTiketRepository(supabaseClient)
	komentarRepo := repository.NewSupabaseKomentarRepository(supabaseClient)
	notifikasiRepo := repository.NewSupabaseNotifikasiRepository(supabaseClient)
	lampiranRepo := repository.NewSupabaseLampiranRepository(supabaseClient)

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

	// Initialize JWT middleware
	jwtMiddleware := middleware.NewJWTMiddleware(authRepo)

	// Create handlers
	authHandler := httpDelivery.NewAuthHandler(registerUC, loginUC, logoutUC)
	tiketHandler := httpDelivery.NewTiketHandler(createTiketUC, getTiketListUC, getTiketDetailUC, updateTiketStatusUC, assignTiketUC)
	komentarHandler := httpDelivery.NewKomentarHandler(addKomentarUC)
	notifikasiHandler := httpDelivery.NewNotifikasiHandler(getNotifikasiListUC, markNotifikasiReadUC)
	lampiranHandler := httpDelivery.NewLampiranHandler(uploadLampiranUC, deleteLampiranUC, lampiranRepo)
	dashboardHandler := httpDelivery.NewDashboardHandler(getDashboardStatsUC)

	// Setup Gin router
	r := gin.Default()
	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.ErrorHandlingMiddleware())

	// API routes
	api := r.Group("/api")

	// Public routes
	auth := api.Group("/auth")
	{
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
		auth.POST("/logout", authHandler.Logout)
	}

	// Protected routes
	protected := api.Group("")
	protected.Use(jwtMiddleware.RequireAuth())
	{
		// Auth
		protected.GET("/auth/me", authHandler.GetCurrentUser)

		// Dashboard
		protected.GET("/dashboard/stats", dashboardHandler.GetStats)

		// Tiket routes (including nested komentar and lampiran)
		tikets := protected.Group("/tikets")
		{
			tikets.GET("", tiketHandler.GetTiketList)
			tikets.POST("", tiketHandler.CreateTiket)
			tikets.GET("/:id", tiketHandler.GetTiketDetail)
			tikets.PATCH("/:id/status", jwtMiddleware.RequireHelpdeskOrAdmin(), tiketHandler.UpdateTiketStatus)
			tikets.POST("/:id/assign", jwtMiddleware.RequireHelpdeskOrAdmin(), tiketHandler.AssignTiket)

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

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Printf("API endpoints available at http://localhost:%s/api", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
