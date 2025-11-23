package api

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"webapi/db"
	"webapi/utils"

	_ "webapi/docs"

	"github.com/go-chi/chi/v5"
	"github.com/rs/zerolog/log"
	httpSwagger "github.com/swaggo/http-swagger"
)

type Application struct {
	httpServer *http.Server
	dbConn     *db.DbConn
}

func (server *Application) WithDBConn(dbConn db.DbConn) *Application {
	server.dbConn = &dbConn
	return server
}

func NewServer(cfg utils.Config) *Application {
	server := Application{}
	router := chi.NewMux()
	router.Get(swaggerEndpoint, httpSwagger.Handler(
		httpSwagger.URL("swagger/doc.json"),
	))
	router.Post(uploadEndpoint, server.uploadHandler)
	server.httpServer = &http.Server{
		Addr:    cfg.HttpServerAddress,
		Handler: router,
	}
	return &server
}

func (server *Application) Start() {

	go func() {

		log.Info().Msgf("INFO: HTTP server started on %s\n", server.httpServer.Addr)
		if err := server.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal().Msgf("Could not start HTTP server: %s", err)
		}
	}()

}

func (server *Application) WaitForShutdown(ctx context.Context) {
	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	sig := <-signalChan
	log.Info().Msgf("Received signal: %s. Shutting down gracefully...", sig)

	if err := server.httpServer.Shutdown(ctx); err != nil {
		log.Fatal().Msgf("HTTP server Shutdown: %v", err)
	}

	log.Info().Msg("Server gracefully stopped")
}
