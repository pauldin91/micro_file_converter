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
	_ = db.NewDbConn(cfg.DbConn, communicator)

	httpServer := api.NewServer(cfg)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	httpServer.Start()
	httpServer.WaitForShutdown(ctx)

}
