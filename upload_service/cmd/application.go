package api

import (
	"context"
	"net/http"
	"os"
	"syscall"
	"webapi/internal/domain"
	"webapi/internal/handlers"

	_ "webapi/docs"

	"github.com/go-chi/chi/v5"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"

	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/rs/zerolog/log"
	httpSwagger "github.com/swaggo/http-swagger"
)

var InterruptSignals = []os.Signal{
	os.Interrupt,
	syscall.SIGTERM,
	syscall.SIGINT,
}

type Application struct {
	httpServer *http.Server
}

func NewServer(uploadHandler handlers.UploadHandler) *Application {
	server := Application{}
	router := server.registerRoutes(uploadHandler)
	server.httpServer = &http.Server{
		Addr:    os.Getenv(domain.HttpServerAddress),
		Handler: router,
	}
	return &server
}

func (server *Application) Start(ctx context.Context) {
	log.Info().Msgf("HTTP server starting on %s", server.httpServer.Addr)
	err := server.httpServer.ListenAndServe()
	if err != nil {
		log.Error().Err(err).Msg("could not start server")
		return
	}
}

func (server *Application) Shutdown() {
	log.Info().Msg("Shutting down HTTP server...")
	if err := server.httpServer.Shutdown(context.Background()); err != nil {
		log.Error().Err(err).Msg("HTTP server shutdown failed")
	}
}

func (server *Application) registerRoutes(uploadHandler handlers.UploadHandler) *chi.Mux {
	router := chi.NewMux()
	router.Get(domain.SwaggerEndpoint, httpSwagger.Handler(
		httpSwagger.URL("swagger/doc.json"),
	))
	router.Post(domain.UploadEndpoint, uploadHandler.CreateUpload)
	return router
}
