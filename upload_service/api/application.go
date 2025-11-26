package api

import (
	"context"
	"net/http"
	"webapi/common"
	"webapi/utils"

	_ "webapi/docs"

	"github.com/go-chi/chi/v5"
	"github.com/rs/zerolog/log"
	httpSwagger "github.com/swaggo/http-swagger"
)

type Application struct {
	httpServer *http.Server
	producer   chan common.UploadDto
}

func NewServer(cfg utils.Config, producer chan common.UploadDto) *Application {
	server := Application{
		producer: producer,
	}
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

func (server *Application) Start(ctx context.Context) error {
	errChan := make(chan error, 1)

	go func() {
		log.Info().Msgf("HTTP server started on %s", server.httpServer.Addr)
		if err := server.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errChan <- err
		}
		close(errChan)
	}()
	return <-errChan

}
