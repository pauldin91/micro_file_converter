CREATE TABLE files (
  id uuid PRIMARY KEY,
  name varchar NOT NULL,
  pages int DEFAULT 0,
  upload_id uuid NOT NULL
);
CREATE INDEX ON files ("name");
ALTER TABLE "files" ADD FOREIGN KEY ("upload_id") REFERENCES "uploads" ("id");
ALTER TABLE files ADD CONSTRAINT fk_files_upload_id FOREIGN KEY (upload_id) REFERENCES uploads(id) ON DELETE CASCADE;