package handlers

import (
	"encoding/json"
	"net/http"
	"webapi/internal/config"
	"webapi/internal/events"
	"webapi/pkg/rabbitmq"

	"github.com/rs/zerolog/log"
)

type UploadHandler struct {
	publisher *rabbitmq.Publisher
}

func NewUploadHandler(cfg config.Config) UploadHandler {
	return UploadHandler{
		publisher: rabbitmq.NewPublisher(cfg),
	}
}

// uploadHandler handles multiple file uploads
// @Summary      Upload multiple files
// @Description  Upload one or more files via multipart/form-data
// @Tags         files
// @Accept       multipart/form-data
// @Produce      json
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
	fileNames := make([]string, 0, len(uploadedFiles))

	for _, f := range uploadedFiles {
		fileNames = append(fileNames, f.Filename)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	var dto events.UploadedEvent = events.UploadedEvent{
		Email:     "papajas@email.com",
		FileNames: fileNames,
	}

	handler.publisher.Publish(dto)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": http.StatusOK,
		"files":  fileNames,
	})
}
