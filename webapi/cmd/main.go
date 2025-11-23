package main

import (
	"webapi/db"
	"webapi/utils"
)

func main() {
	cfg, _ := utils.LoadConfig(".")
	_ = db.NewDbConn(cfg.DbConn)

}
