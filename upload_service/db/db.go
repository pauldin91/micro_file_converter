package db

import (
	"log"
	"webapi/common"
	db "webapi/db/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type DbConn struct {
	DB       *gorm.DB
	consumer chan common.UploadDto
}

func NewDbConn(dsn string, consumer chan common.UploadDto) DbConn {

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database: ", err)
	}
	database.AutoMigrate(
		&db.User{},
		&db.Upload{},
		&db.File{},
	)
	return DbConn{
		DB:       database,
		consumer: consumer,
	}
}
