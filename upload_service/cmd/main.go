package main

import (
	"context"
	"os"
	"os/signal"
	"time"
	"webapi/api"
	"webapi/common"
	service "webapi/service"
	"webapi/utils"
)

func main() {

	communicator := make(chan common.UploadDto)
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	cfg, _ := utils.LoadConfig("..")
	worker := service.NewUploadWorker(cfg.DbConn, communicator)
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	httpServer := api.NewServer(cfg, communicator)
	worker.Start(ctx)
	httpServer.Start(shutdownCtx)
	<-ctx.Done()
}
