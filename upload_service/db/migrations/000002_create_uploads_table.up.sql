CREATE TYPE upload_status AS ENUM ('REJECTED','QUEUED', 'PROCESSED', 'FAIL');



CREATE TABLE uploads (
  id uuid PRIMARY KEY,
  status upload_status NOT NULL DEFAULT 'QUEUED',
  user_email varchar NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by varchar NOT NULL DEFAULT 'system.migration',
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by varchar NOT NULL DEFAULT 'system.migration'
);

ALTER TABLE uploads
  ADD CONSTRAINT fk_upload_user
  FOREIGN KEY (user_email)
  REFERENCES users (email);

ALTER TABLE uploads ADD CONSTRAINT fk_uploads_user_email FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE;
