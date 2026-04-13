package http

import (
	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/delivery/middleware"
	"eticketinghelpdesk/interfaces"
	"eticketinghelpdesk/usecases"
)

// Router sets up all HTTP routes
type Router struct {
	engine         *gin.Engine
	jwtMiddleware  *middleware.JWTMiddleware
	authHandler    *AuthHandler
	tiketHandler   *TiketHandler
	komentarHandler *KomentarHandler
	notifikasiHandler *NotifikasiHandler
	lampiranHandler  *LampiranHandler
	dashboardHandler *DashboardHandler
}

// NewRouter creates a new router instance
func NewRouter(
	authRepo interfaces.AuthRepository,
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
) *Router {
	r := gin.Default()

	// Apply global middleware
	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.ErrorHandlingMiddleware())

	jwtMiddleware := middleware.NewJWTMiddleware(authRepo)

	return &Router{
		engine:            r,
		jwtMiddleware:     jwtMiddleware,
		authHandler:       NewAuthHandler(registerUC, loginUC, logoutUC),
		tiketHandler:      NewTiketHandler(createTiketUC, getTiketListUC, getTiketDetailUC, updateTiketStatusUC, assignTiketUC),
		komentarHandler:   NewKomentarHandler(addKomentarUC),
		notifikasiHandler: NewNotifikasiHandler(getNotifikasiListUC, markNotifikasiReadUC),
		lampiranHandler:   NewLampiranHandler(uploadLampiranUC, deleteLampiranUC, lampiranRepo),
		dashboardHandler:  NewDashboardHandler(getDashboardStatsUC),
	}
}

// SetupRoutes configures all API routes
func (r *Router) SetupRoutes() {
	api := r.engine.Group("/api")

	// Public routes
	auth := api.Group("/auth")
	{
		auth.POST("/register", r.authHandler.Register)
		auth.POST("/login", r.authHandler.Login)
		auth.POST("/logout", r.authHandler.Logout)
	}

	// Protected routes
	protected := api.Group("")
	protected.Use(r.jwtMiddleware.RequireAuth())
	{
		// Auth
		protected.GET("/auth/me", r.authHandler.GetCurrentUser)

		// Dashboard
		protected.GET("/dashboard/stats", r.dashboardHandler.GetStats)

		// Tiket
		tikets := protected.Group("/tikets")
		{
			tikets.GET("", r.tiketHandler.GetTiketList)
			tikets.POST("", r.tiketHandler.CreateTiket)
			tikets.GET("/:id", r.tiketHandler.GetTiketDetail)
			tikets.PATCH("/:id/status", r.jwtMiddleware.RequireHelpdeskOrAdmin(), r.tiketHandler.UpdateTiketStatus)
			tikets.POST("/:id/assign", r.jwtMiddleware.RequireHelpdeskOrAdmin(), r.tiketHandler.AssignTiket)
		}

		// Komentar
		komentars := protected.Group("/tikets/:tiket_id/komentars")
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
		lampirans := protected.Group("/tikets/:tiket_id/lampirans")
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
