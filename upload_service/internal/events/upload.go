package events

import "github.com/google/uuid"

type UploadedEvent struct {
	Email string
	Id    uuid.UUID
}
