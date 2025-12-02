package db

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Store defines all functions to execute db queries and transactions
type Store interface {
	Querier
}

// SQLStore provides all functions to execute SQL queries and transactions
type SQLStore struct {
	connPool *pgxpool.Pool
	*Queries
}

// NewStore creates a new store
func NewStore(connPool *pgxpool.Pool) Store {
	return &SQLStore{
		connPool: connPool,
		Queries:  New(connPool),
	}
}

type UserStore interface {
	CreateUser(ctx context.Context, arg CreateUserParams) (CreateUserRow, error)
	DeleteUser(ctx context.Context, email string) (DeleteUserRow, error)
	GetAllUsers(ctx context.Context) ([]GetAllUsersRow, error)
	GetUser(ctx context.Context, email string) (GetUserRow, error)
	GetUserByEmail(ctx context.Context, email string) (GetUserByEmailRow, error)
	UpdateUser(ctx context.Context, arg UpdateUserParams) (UpdateUserRow, error)
}

type UploadStore interface {
	CreateUpload(ctx context.Context, arg CreateUploadParams) (CreateUploadRow, error)
	DeleteUploadByEmail(ctx context.Context, userEmail string) (DeleteUploadByEmailRow, error)
	GetAllUploads(ctx context.Context, arg GetAllUploadsParams) ([]GetAllUploadsRow, error)
	GetUploadByEmail(ctx context.Context, userEmail string) (GetUploadByEmailRow, error)
	GetUploadByEmailWithDocuments(ctx context.Context, userEmail string) ([]GetUploadByEmailWithDocumentsRow, error)
	UpdateUpload(ctx context.Context, arg UpdateUploadParams) (UpdateUploadRow, error)
}

type FileStore interface {
	CreateFile(ctx context.Context, arg CreateFileParams) (File, error)
	DeleteFilesdByUploadId(ctx context.Context, uploadID uuid.UUID) (File, error)
	GetAllFiles(ctx context.Context, arg GetAllFilesParams) ([]File, error)
	GetFilesByName(ctx context.Context, name string) ([]File, error)
	GetFilesByUploadId(ctx context.Context, uploadID uuid.UUID) ([]File, error)
	UpdateFile(ctx context.Context, arg UpdateFileParams) (File, error)
}
