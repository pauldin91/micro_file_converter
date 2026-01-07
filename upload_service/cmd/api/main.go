package main

import (
	"common/config"
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
	cfg := config.NewConfig()
	err := cfg.LoadConfig("../../")
	if err != nil {
		log.Panicf("unable to read cfg: %s\n", err.Error())
	}
	group, subCtx := errgroup.WithContext(ctx)
	server := api.NewServer(subCtx, cfg)

	group.Go(func() error {
		return server.Start()
	})
	if err := group.Wait(); err != nil {
		fmt.Println("Exited due to fatal error:", err)
	} else {
		fmt.Println("Exited gracefully.")
	}

	<-ctx.Done()
}
