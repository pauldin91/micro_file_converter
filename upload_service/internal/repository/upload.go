package repository

import db "webapi/db/sqlc"

type UploadService struct {
	store db.UploadStore
}

func NewUploadService(store db.UploadStore) *UploadService {
	return &UploadService{
		store: store,
	}
}
