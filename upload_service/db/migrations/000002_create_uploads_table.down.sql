drop table if exists uploads;

ALTER TABLE IF EXISTS "files" DROP CONSTRAINT IF EXISTS "uploads_upload_id_fkey";