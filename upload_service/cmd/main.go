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
	dbConn := db.NewDbConn(cfg.DbConn)

	httpServer := api.NewServer(cfg).
		WithDBConn(dbConn)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	httpServer.Start()
	httpServer.WaitForShutdown(ctx)

}
