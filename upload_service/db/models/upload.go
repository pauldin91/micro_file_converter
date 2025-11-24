package db

import (
	"github.com/google/uuid"
)

type Upload struct {
	BaseModel
	UserID uuid.UUID `gorm:"type:uuid"`
	Status string
	Files  []File `gorm:"foreignKey:UploadID"`
}
