package api

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"webapi/utils"

	_ "webapi/docs"

	"github.com/go-chi/chi/v5"
	"github.com/rs/zerolog/log"
	httpSwagger "github.com/swaggo/http-swagger"
)

type Server struct {
	httpServer *http.Server
}

func NewServer(cfg utils.Config) *Server {
	server := Server{}
	router := chi.NewMux()
	router.Get("/swagger/*", httpSwagger.Handler(
		httpSwagger.URL("swagger/doc.json"),
	))
	router.Post(uploadEndpoint, server.uploadHandler)
	server.httpServer = &http.Server{
		Addr:    cfg.HttpServerAddress,
		Handler: router,
	}
	return &server
}

func (server *Server) Start() {

	log.Info().Msgf("INFO: HTTP server started on %s\n", server.httpServer.Addr)
	if err := server.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal().Msgf("Could not start HTTP server: %s", err)
	}

}

func (server *Server) WaitForShutdown(ctx context.Context) {
	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	sig := <-signalChan
	log.Info().Msgf("Received signal: %s. Shutting down gracefully...", sig)

	if err := server.httpServer.Shutdown(ctx); err != nil {
		log.Fatal().Msgf("HTTP server Shutdown: %v", err)
	}

	log.Info().Msg("Server gracefully stopped")
}
