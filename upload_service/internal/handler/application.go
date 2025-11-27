package api

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"webapi/common"
	"webapi/internal/config"

	_ "webapi/docs"

	"github.com/go-chi/chi/v5"
	"github.com/rs/zerolog/log"
	httpSwagger "github.com/swaggo/http-swagger"
)

type Application struct {
	httpServer *http.Server
	producer   chan common.UploadDto
}

func NewServer(cfg config.Config, producer chan common.UploadDto) *Application {
	server := Application{
		producer: producer,
	}
	router := server.registerRoutes()
	server.httpServer = &http.Server{
		Addr:    cfg.HttpServerAddress,
		Handler: router,
	}
	return &server
}

func (server *Application) Start(ctx context.Context) error {
	log.Info().Msgf("HTTP server starting on %s", server.httpServer.Addr)
	if err := server.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Error().Msgf("Error starting the http server: %s\n", err)

	}

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	<-quit

	return server.httpServer.Close()
}

func (server *Application) registerRoutes() *chi.Mux {
	router := chi.NewMux()
	router.Get(common.SwaggerEndpoint, httpSwagger.Handler(
		httpSwagger.URL("swagger/doc.json"),
	))
	var uploadHandler UploadHandler = NewUploadHandler()
	router.Post(common.UploadEndpoint, uploadHandler.createUpload)
	return router
}
