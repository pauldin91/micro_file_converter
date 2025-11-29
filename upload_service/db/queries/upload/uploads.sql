-- name: CreateUpload :one
INSERT INTO uploads (user_email, status)
VALUES ($1,$2)
RETURNING  id, user_email, status, created_at, created_by, updated_at, updated_by;

-- name: GetUploadByEmail :one
SELECT  id, user_email, status, created_at, created_by, updated_at, updated_by
FROM uploads
WHERE user_email = $1;

-- name: GetUploadByEmailWithDocuments :many
SELECT  u.id, u.user_email, u.status, u.created_at, u.created_by, u.updated_at, u.updated_by, d.name, d.pages, d.upload_id
FROM uploads u
JOIN files d ON u.id = d.upload_id
WHERE u.user_email = $1;

-- name: GetAllUploads :many
SELECT  id, user_email, status, created_at, created_by, updated_at, updated_by
FROM uploads
ORDER BY created_at
LIMIT $1
OFFSET $2;

-- name: UpdateUpload :one
UPDATE uploads
SET status = $2, updated_at = NOW()
WHERE user_email = $1
RETURNING  id, user_email, status, created_at, created_by, updated_at, updated_by;

-- name: DeleteUploadByEmail :one
DELETE FROM uploads
WHERE user_email = $1
RETURNING  id, user_email, status, created_at, created_by, updated_at, updated_by;


