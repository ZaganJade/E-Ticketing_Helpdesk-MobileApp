//+build wireinject

package config

import (
	"github.com/google/wire"
)

// InitializeApp initializes the application with all dependencies
// Run `wire` command to generate wire_gen.go
func InitializeApp() (*App, error) {
	wire.Build(
		LoadConfig,
		// TODO: Add providers for repositories, usecases, handlers
	)
	return &App{}, nil
}

type App struct {
	Config *AppConfig
	// TODO: Add router, database client, etc.
}
