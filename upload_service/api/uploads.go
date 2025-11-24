package api

import (
	"encoding/json"
	"net/http"
	db "webapi/db/models"

	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
)

var tempUUID, _ = uuid.NewUUID()

// uploadHandler handles multiple file uploads
// @Summary      Upload multiple files
// @Description  Upload one or more files via multipart/form-data
// @Tags         files
// @Accept       multipart/form-data
// @Produce      json
// @Param        files  formData  file   true  "Files to upload" collectionFormat
// @Success      200 {object} map[string]interface{}
// @Router       /api/uploads [post]
func (server *Application) uploadHandler(w http.ResponseWriter, r *http.Request) {
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

	var files []db.File = make([]db.File, 0)
	for _, i := range fileNames {
		files = append(files, db.File{Name: i})
	}

	// user := db.User{
	// 	Name:  "papajas",
	// 	Email: "papajas@email.com",
	// }

	// err := gorm.G[db.User](server.dbConn.DB).Create(context.Background(), &user)
	// if err != nil {
	// 	http.Error(w, fmt.Sprintf("Error: %s", err.Error()), http.StatusBadRequest)
	// 	return
	// }
	// err = gorm.G[db.Upload](server.dbConn.DB).Create(context.Background(), &db.Upload{UserID: user.ID, Status: "Queued", Files: files})
	// if err != nil {
	// 	http.Error(w, fmt.Sprintf("Error: %s", err.Error()), http.StatusBadRequest)
	// 	return
	// }

	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": http.StatusOK,
		"files":  fileNames,
	})
}
