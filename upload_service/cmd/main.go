package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"webapi/api"
	"webapi/background"
	"webapi/common"
	"webapi/utils"

	"golang.org/x/sync/errgroup"
)

var interruptSignals = []os.Signal{
	os.Interrupt,
	syscall.SIGTERM,
	syscall.SIGINT,
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), interruptSignals...)
	defer stop()

	communicator := make(chan common.UploadDto, 100)
	receiver := make(chan string, 100)

	cfg, _ := utils.LoadConfig("..")

	// worker := service.NewUploadWorker(cfg.DbConn, receiver, communicator)
	publisher := background.NewPublisher(cfg, receiver)
	server := api.NewServer(cfg, communicator)

	// errgroup with root context allows graceful cancel on fatal error
	group, subCtx := errgroup.WithContext(ctx)

	// HTTP server
	group.Go(func() error {
		return server.Start(subCtx)
	})

	group.Go(func() error {
		return publisher.Start(subCtx)
	})

	// Wait for any fatal error or shutdown signal
	if err := group.Wait(); err != nil {
		fmt.Println("Exited due to fatal error:", err)
	} else {
		fmt.Println("Exited gracefully.")
	}

	// Block until OS signal truly finishes
	<-ctx.Done()
}
