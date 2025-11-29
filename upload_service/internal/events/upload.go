package events

import "github.com/google/uuid"

type UploadedEvent struct {
	FileNames []string
	Email     string
	Id        uuid.UUID
}
