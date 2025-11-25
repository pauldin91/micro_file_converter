package main

import (
	"context"
	"time"
	"webapi/api"
	"webapi/common"
	"webapi/db"
	"webapi/utils"
)

func main() {

	communicator := make(chan common.UploadDto)

	cfg, _ := utils.LoadConfig("..")
	worker := db.NewUploadWorker(cfg.DbConn, communicator)

	httpServer := api.NewServer(cfg, communicator)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	worker.Start(ctx)
	httpServer.Start(ctx)
}
