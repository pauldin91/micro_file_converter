package main

import (
	"context"
	"fmt"
	"log"
	"os/signal"
	api "webapi/cmd"
	"webapi/internal/config"

	"golang.org/x/sync/errgroup"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), api.InterruptSignals...)
	defer stop()

	cfg, err := config.LoadConfig()
	if err != nil {
		log.Panicf("unable to read cfg: %s\n", err.Error())
	}
	// worker := service.NewUploadWorker(cfg.DbConn, receiver, communicator)
	server := api.NewServer(cfg)

	// errgroup with root context allows graceful cancel on fatal error
	group, subCtx := errgroup.WithContext(ctx)

	// HTTP server
	group.Go(func() error {
		return server.Start(subCtx)
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
