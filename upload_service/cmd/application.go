package api

import (
	"common/messages"
	"context"
	"net/http"
	"os"
	"syscall"
	db "webapi/db/sqlc"
	"webapi/internal/domain"
	"webapi/internal/handlers"

	_ "webapi/docs"

	"github.com/go-chi/chi/v5"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"

	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jackc/pgx/v5/pgxpool"
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
	ctx        context.Context
}

func NewServer(ctx context.Context) *Application {
	server := Application{
		ctx: ctx,
	}
	router := server.registerRoutes()
	server.httpServer = &http.Server{
		Addr:    os.Getenv(domain.HttpServerAddress),
		Handler: router,
	}
	return &server
}

func (server *Application) Start() error {
	log.Info().Msgf("HTTP server starting on %s", server.httpServer.Addr)

	go func() {
		<-server.ctx.Done()
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

func (server *Application) registerRoutes() *chi.Mux {
	router := chi.NewMux()
	router.Get(domain.SwaggerEndpoint, httpSwagger.Handler(
		httpSwagger.URL("swagger/doc.json"),
	))

	connPool, err := pgxpool.New(server.ctx, os.Getenv(domain.DbConn))
	if err != nil {
		log.Fatal().Err(err).Msg("cannot connect to db")
	}

	store := db.NewStore(connPool)

	publisher, err := messages.NewRabbitMQPublisher(os.Getenv(domain.RabbitMQHost), os.Getenv(domain.ConversionQueue))
	if err != nil {
		log.Fatal().Err(err).Msg("cannot connect to RabbitMQ")
	}
	var uploadHandler handlers.UploadHandler = handlers.NewUploadHandler(store, publisher)
	router.Post(domain.UploadEndpoint, uploadHandler.CreateUpload)
	return router
}
