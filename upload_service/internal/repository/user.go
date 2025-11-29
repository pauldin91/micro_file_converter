package repository

import db "webapi/db/sqlc"

type UserService struct {
	store db.UserStore
}

func NewUserService(store db.UserStore) *UserService {
	return &UserService{
		store: store,
	}
}
