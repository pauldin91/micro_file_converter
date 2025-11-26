package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"webapi/api"
	"webapi/common"
	"webapi/utils"

	"golang.org/x/sync/errgroup"
)

func main() {
	// Root context for whole application
	rootCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	communicator := make(chan common.UploadDto)
	// receiver := make(chan string)

	cfg, _ := utils.LoadConfig("..")

	// worker := service.NewUploadWorker(cfg.DbConn, receiver, communicator)
	// broker := service.NewPublisher(cfg.Amqp, cfg.BatchQueue, receiver)
	server := api.NewServer(cfg, communicator)

	// errgroup with root context allows graceful cancel on fatal error
	group, ctx := errgroup.WithContext(rootCtx)

	// HTTP server
	group.Go(func() error {
		return server.Start(ctx)
	})

	// Wait for any fatal error or shutdown signal
	if err := group.Wait(); err != nil {
		fmt.Println("Exited due to fatal error:", err)
	} else {
		fmt.Println("Exited gracefully.")
	}

	// Block until OS signal truly finishes
	<-rootCtx.Done()
}
