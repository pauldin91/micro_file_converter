package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"
	"time"
	db "webapi/db/sqlc"
	"webapi/internal/config"
	"webapi/internal/events"
	"webapi/pkg/rabbitmq"

	"github.com/rs/zerolog/log"
)

type UploadHandler struct {
	publisher   *rabbitmq.Publisher
	uploadStore db.UploadStore
	userStore   db.UserStore
}

func NewUploadHandler(cfg config.Config, store db.Store) UploadHandler {
	return UploadHandler{
		publisher:   rabbitmq.NewPublisher(cfg),
		uploadStore: store,
		userStore:   store,
	}
}

// uploadHandler handles multiple file uploads
// @Summary      Upload multiple files
// @Description  Upload one or more files via multipart/form-data
// @Tags         files
// @Accept       multipart/form-data
// @Produce      json
// @Param email formData string true "User email"
// @Param        files  formData  file   true  "Files to upload" collectionFormat
// @Success      200 {object} map[string]interface{}
// @Router       /api/uploads [post]
func (handler UploadHandler) CreateUpload(w http.ResponseWriter, r *http.Request) {
	log.Info().Msg("Upload handler called")

	if err := r.ParseMultipartForm(0); err != nil {
		http.Error(w, "Unable to parse multipart form", http.StatusBadRequest)
		return
	}

	uploadedFiles := r.MultipartForm.File["files"]
	email := r.FormValue("email")
	fileNames := make([]string, 0, len(uploadedFiles))

	for _, f := range uploadedFiles {
		fileNames = append(fileNames, f.Filename)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()
	user, err := handler.userStore.GetUserByEmail(ctx, email)
	if err != nil {
		toCreate := db.CreateUserParams{Email: email, Username: strings.Split(email, "@")[0]}
		created, err := handler.userStore.CreateUser(ctx, toCreate)
		if err != nil {
			http.Error(w, "Could not create resource", http.StatusBadRequest)
			return
		}
		user.Email = created.Email
	}

	upload, err := handler.uploadStore.CreateUpload(ctx, db.CreateUploadParams{UserEmail: user.Email, Status: "QUEUED"})
	if err != nil {
		http.Error(w, "Could not create resource", http.StatusBadRequest)
		return
	}
	var dto events.UploadedEvent = events.UploadedEvent{
		FileNames: fileNames,
		Email:     email,
		Id:        upload.ID,
	}
	handler.publisher.Publish(dto)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": http.StatusCreated,
		"id":     upload.ID,
	})
}
