CREATE TABLE files (
  id uuid PRIMARY KEY,
  name varchar NOT NULL,
  pages int DEFAULT 0,
  upload_id uuid NOT NULL
);
ALTER TABLE "files" ADD FOREIGN KEY ("upload_id") REFERENCES "uploads" ("id");
CREATE INDEX ON files ("name");