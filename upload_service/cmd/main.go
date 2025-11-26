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
	receiver := make(chan string)
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	dbCtx, dbCancel := context.WithTimeout(context.Background(), 10*time.Second)
	brokerCtx, brokerCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	defer dbCancel()
	defer brokerCancel()

	cfg, _ := utils.LoadConfig("..")
	worker := service.NewUploadWorker(cfg.DbConn, receiver, communicator)
	httpServer := api.NewServer(cfg, communicator)
	broker := service.NewPublisher(cfg.Amqp, cfg.BatchQueue, receiver)
	worker.Start(ctx)
	broker.Start(brokerCtx)
	httpServer.Start(dbCtx)
	<-ctx.Done()
}
