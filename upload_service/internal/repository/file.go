package repository

import db "webapi/db/sqlc"

type FileService struct {
	store db.FileStore
}

func NewFileService(store db.FileStore) *FileService {
	return &FileService{
		store: store,
	}
}
