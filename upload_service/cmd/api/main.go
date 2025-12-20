package main

import (
	"common/pkg/config"
	"context"
	"fmt"
	"log"
	"os/signal"
	api "webapi/cmd"

	"golang.org/x/sync/errgroup"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), api.InterruptSignals...)
	defer stop()

	cfg, err := config.LoadConfig("../../")
	if err != nil {
		log.Panicf("unable to read cfg: %s\n", err.Error())
	}
	// errgroup with root context allows graceful cancel on fatal error
	group, subCtx := errgroup.WithContext(ctx)
	// worker := service.NewUploadWorker(cfg.DbConn, receiver, communicator)
	server := api.NewServer(subCtx, cfg)

	// HTTP server
	group.Go(func() error {
		return server.Start()
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
