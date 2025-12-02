-- name: CreateFile :one
INSERT INTO files (upload_id,name, pages)
VALUES ($1,$2,COALESCE($3, 0))
RETURNING  id, name, pages, upload_id;

-- name: CreateFilesBatch :many
WITH idx AS (
    SELECT generate_series(1, array_length(sqlc.arg(names)::text[], 1)) AS i
),
ins AS (
    INSERT INTO files (upload_id, name, pages)
    SELECT
        sqlc.arg(upload_id)::uuid AS upload_id,
        (sqlc.arg(names)::text[])[i] AS name,
        (sqlc.arg(pages)::int[])[i] AS pages
    FROM idx
    RETURNING id, upload_id, name, pages
)
SELECT id, upload_id, name, pages FROM ins;


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

