package config

import (
	"os"
	"strconv"
)

// AppConfig holds application configuration
type AppConfig struct {
	Port                  string
	Env                   string
	SupabaseURL           string
	SupabaseKey           string
	SupabaseServiceKey    string
	SupabaseJWTSecret     string
	SupabaseWebhookSecret string
	JWTSecret             string
	JWTExpirationHours    int
	MaxUploadSize         int64
	AllowedFileTypes      []string
}

// LoadConfig loads configuration from environment variables
func LoadConfig() *AppConfig {
	jwtExpiration, _ := strconv.Atoi(getEnv("JWT_EXPIRATION_HOURS", "24"))
	maxUploadSize, _ := strconv.ParseInt(getEnv("MAX_UPLOAD_SIZE", "10485760"), 10, 64)

	return &AppConfig{
		Port:                  getEnv("PORT", "8080"),
		Env:                   getEnv("ENV", "development"),
		SupabaseURL:           getEnv("SUPABASE_URL", ""),
		SupabaseKey:           getEnv("SUPABASE_KEY", ""),
		SupabaseServiceKey:    getEnv("SUPABASE_SERVICE_ROLE_KEY", ""),
		SupabaseJWTSecret:     getEnv("SUPABASE_JWT_SECRET", ""),
		SupabaseWebhookSecret: getEnv("SUPABASE_WEBHOOK_SECRET", ""),
		JWTSecret:             getEnv("JWT_SECRET", ""),
		JWTExpirationHours:    jwtExpiration,
		MaxUploadSize:         maxUploadSize,
		AllowedFileTypes:      []string{"jpg", "jpeg", "png", "pdf", "doc", "docx"},
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
