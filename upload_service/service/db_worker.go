package service

import (
	"context"
	"errors"
	"strings"
	"webapi/common"
	db "webapi/db/models"

	"github.com/rs/zerolog/log"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type UploadWorker struct {
	DB       *gorm.DB
	consumer chan common.UploadDto
	receiver chan string
	errors   chan error
}

func NewUploadWorker(dsn string, receiver chan string, consumer chan common.UploadDto) UploadWorker {

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal().Msgf("Failed to connect to database: %s\n", err)
	}
	database.AutoMigrate(
		&db.User{},
		&db.Upload{},
		&db.File{},
	)
	return UploadWorker{
		DB:       database,
		consumer: consumer,
		receiver: receiver,
		errors:   make(chan error),
	}
}

func (dbConn *UploadWorker) Start(ctx context.Context) {

	go func() {

		for {
			select {
			case upload := <-dbConn.consumer:

				var files []db.File = make([]db.File, 0)
				for _, i := range upload.FileNames {
					files = append(files, db.File{Name: i})
				}

				user := dbConn.getOrAddUser(ctx, upload)
				batch := &db.Upload{UserID: user.ID, Status: "Queued", Files: files}
				err := gorm.G[db.Upload](dbConn.DB).Create(context.Background(), batch)
				if err != nil {
					dbConn.errors <- err
				} else {
					dbConn.receiver <- batch.ID.String()
				}

			case err := <-dbConn.errors:
				log.Error().Msgf("error %s\n", err)
			}
		}
	}()
}

func (worker *UploadWorker) getOrAddUser(ctx context.Context, upload common.UploadDto) db.User {
	user := db.User{
		Email: upload.Email,
	}
	user, err := gorm.G[db.User](worker.DB).Where("email = ?", user.Email).First(ctx)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		user = db.User{
			Email: upload.Email,
			Name:  strings.Split(upload.Email, "@")[0],
		}

		err = gorm.G[db.User](worker.DB).Create(ctx, &user)
		if err != nil {
			worker.errors <- err
		}
	} else if err != nil {
		worker.errors <- err
	}
	return user
}
