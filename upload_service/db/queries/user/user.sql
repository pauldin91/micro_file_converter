-- name: CreateUser :one
INSERT INTO users (username, email)
VALUES ($1, $2)
RETURNING  username, email, created_at, created_by, updated_at, updated_by;

-- name: GetUser :one
SELECT  username, email, created_at, created_by, updated_at, updated_by
FROM users
WHERE email = $1;

-- name: GetAllUsers :many
SELECT  username, email, created_at, created_by, updated_at, updated_by
FROM users
ORDER BY email;

-- name: UpdateUser :one
UPDATE users
SET username = $2, updated_at = NOW()
WHERE email = $1
RETURNING  username, email, created_at, created_by, updated_at, updated_by;

-- name: DeleteUser :one
DELETE FROM users
WHERE email = $1
RETURNING  username, email, created_at, created_by, updated_at, updated_by;

-- name: GetUserByEmail :one
SELECT  username, email, created_at, created_by, updated_at, updated_by
FROM users
WHERE email = $1;