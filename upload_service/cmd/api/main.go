package main

import (
	"common/messages"
	"context"
	"log"

	"os"
	"os/signal"
	api "webapi/cmd"
	db "webapi/db/sqlc"
	"webapi/internal/domain"
	"webapi/internal/handlers"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()
	ctx, stop := signal.NotifyContext(context.Background(), api.InterruptSignals...)
	defer stop()

	connPool, err := pgxpool.New(ctx, os.Getenv(domain.DbConn))
	if err != nil {
		log.Fatal("cannot connect to db")
	}

	store := db.NewStore(connPool)

	publisher, err := messages.NewRabbitMQPublisher(os.Getenv(domain.RabbitMQHost), os.Getenv(domain.ConversionQueue))
	if err != nil {
		log.Fatal("cannot connect to RabbitMQ")
	}
	var uploadHandler handlers.UploadHandler = handlers.NewUploadHandler(store, publisher)

	server := api.NewServer(uploadHandler)
	server.Start(ctx)
	defer server.Shutdown()
	<-ctx.Done()
}
