package db

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type File struct {
	gorm.Model
	Name     string
	UploadID uuid.UUID `gorm:"type:uuid"`
}
