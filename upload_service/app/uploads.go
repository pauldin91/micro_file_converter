package app

import (
	"common/messages"
	"context"
	"encoding/json"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
	db "webapi/db/sqlc"
	"webapi/domain"
	"webapi/events"

	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
)

type UploadHandler struct {
	publisher   messages.Publisher
	uploadStore db.UploadStore
	userStore   db.UserStore
	fileStore   db.FileStore
	uploadDir   string
}

func NewUploadHandler(store db.Store, publisher messages.Publisher) UploadHandler {
	var uploadDir string = os.Getenv(domain.UploadDir)
	if len(uploadDir) == 0 {
		cwd, _ := os.Getwd()
		uploadDir = filepath.Join(filepath.Dir(filepath.Dir(filepath.Dir(cwd))), "uploads")
	}

	log.Info().Msgf("upload path is: %s\n", uploadDir)
	return UploadHandler{
		publisher:   publisher,
		uploadStore: store,
		userStore:   store,
		fileStore:   store,
		uploadDir:   uploadDir,
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
	log.Info().Msgf("upload path is: %s\n", handler.uploadDir)

	if err := r.ParseMultipartForm(0); err != nil {
		http.Error(w, "Unable to parse multipart form", http.StatusBadRequest)
		return
	}

	uploadedFiles := r.MultipartForm.File["files"]
	email := r.FormValue("email")
	batchId, _ := uuid.NewUUID()

	go func(uploads []*multipart.FileHeader) {

		for _, fh := range uploads {
			src, err := fh.Open()
			if err != nil {
				log.Error().Msgf("Could not copy file %s %s\n", fh.Filename, err)
			}
			defer src.Close()
			os.Mkdir(filepath.Join(handler.uploadDir, batchId.String()), 0755)
			dst, err := os.Create(filepath.Join(handler.uploadDir, batchId.String(), fh.Filename))
			if err != nil {
				log.Error().Msgf("Could not copy file %s %s\n", fh.Filename, err)
			}
			defer dst.Close()

			io.Copy(dst, src)
		}
	}(uploadedFiles)

	filenames := make([]string, 0)
	for _, f := range uploadedFiles {
		filenames = append(filenames, f.Filename)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
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

	upload, err := handler.uploadStore.CreateUpload(ctx, db.CreateUploadParams{ID: batchId, UserEmail: user.Email, Status: "QUEUED"})
	if err != nil {
		http.Error(w, "Could not create upload resource", http.StatusBadRequest)
		return
	}
	var createBatchFiles = db.CreateFilesBatchParams{
		UploadID: upload.ID,
		Names:    filenames,
	}
	_, err = handler.fileStore.CreateFilesBatch(ctx, createBatchFiles)
	if err != nil {
		http.Error(w, "Could not create file resources", http.StatusBadRequest)
		return
	}
	var dto events.UploadedEvent = events.UploadedEvent{
		Email: email,
		Id:    batchId,
	}
	searialized, _ := json.Marshal(dto)

	go func() {
		handler.publisher.Publish(ctx, searialized)
	}()

	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": http.StatusCreated,
		"id":     batchId,
	})
}
