package main

import (
	"context"
	"fmt"
	"os/signal"
	api "webapi/cmd"

	"github.com/joho/godotenv"
	"golang.org/x/sync/errgroup"
)

func main() {
	_ = godotenv.Load()
	ctx, stop := signal.NotifyContext(context.Background(), api.InterruptSignals...)
	defer stop()

	group, subCtx := errgroup.WithContext(ctx)
	server := api.NewServer(subCtx)

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
