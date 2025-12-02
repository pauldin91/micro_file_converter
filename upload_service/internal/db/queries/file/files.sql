-- name: CreateFile :one
INSERT INTO files (upload_id,name, pages)
VALUES ($1,$2,COALESCE($3, 0))
RETURNING  id, name, pages, upload_id;

-- name: CreateFilesBatch :exec
WITH idx AS (
    SELECT generate_series(1, array_length($2::text[], 1)) AS i
)
INSERT INTO files (upload_id, name, pages)
SELECT
    $1::uuid AS upload_id,
    ($2::text[])[i] AS name,
    ($3::int[])[i] AS pages
FROM idx;

-- name: GetFilesByName :many
SELECT id, name, pages, upload_id
FROM files
WHERE name = $1;


-- name: GetFilesByUploadId :many
SELECT id, name, pages, upload_id
FROM files
WHERE upload_id = $1;

-- name: GetAllFiles :many
SELECT id, name, pages, upload_id
FROM files
LIMIT $1
OFFSET $2;

-- name: UpdateFile :one
UPDATE files
SET pages = $2
WHERE upload_id = $1
RETURNING  id, name, pages, upload_id;

-- name: DeleteFilesdByUploadId :one
DELETE FROM files
WHERE upload_id = $1
RETURNING  id, name, pages, upload_id;

