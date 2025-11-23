package db

import (
	"log"
	db "webapi/db/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type DbConn struct {
	DB *gorm.DB
}

func NewDbConn(dsn string) DbConn {

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
		DB: database,
	}
}
