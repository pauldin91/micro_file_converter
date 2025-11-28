package api

import (
	"context"
	"net/http"
	"os"
	"syscall"
	"webapi/common"
	"webapi/internal/config"
	"webapi/internal/handlers"

	_ "webapi/docs"

	"github.com/go-chi/chi/v5"
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

func NewServer(cfg config.Config) *Application {
	server := Application{}
	router := server.registerRoutes(cfg)
	server.httpServer = &http.Server{
		Addr:    cfg.HttpServerAddress,
		Handler: router,
	}
	return &server
}

func (server *Application) Start(ctx context.Context) error {
	log.Info().Msgf("HTTP server starting on %s", server.httpServer.Addr)

	go func() {
		<-ctx.Done()
		log.Info().Msg("Shutting down HTTP server...")
		if err := server.httpServer.Shutdown(context.Background()); err != nil {
			log.Error().Err(err).Msg("HTTP server shutdown failed")
		}
	}()

	err := server.httpServer.ListenAndServe()

	if err != nil && err != http.ErrServerClosed {
		return err
	}

	return nil
}

func (server *Application) registerRoutes(cfg config.Config) *chi.Mux {
	router := chi.NewMux()
	router.Get(common.SwaggerEndpoint, httpSwagger.Handler(
		httpSwagger.URL("swagger/doc.json"),
	))

	var uploadHandler handlers.UploadHandler = handlers.NewUploadHandler(cfg)
	router.Post(common.UploadEndpoint, uploadHandler.CreateUpload)
	return router
}
