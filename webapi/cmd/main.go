package main

import (
	"context"
	"time"
	"webapi/api"
	"webapi/db"
	"webapi/utils"
)

func main() {
	cfg, _ := utils.LoadConfig("..")
	_ = db.NewDbConn(cfg.DbConn)

	httpServer := api.NewServer(cfg)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	httpServer.Start()
	httpServer.WaitForShutdown(ctx)

}
