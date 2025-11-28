CREATE TYPE upload_status AS ENUM ('QUEUED', 'PROCESSING', 'PROCESSED', 'FAIL');

CREATE TABLE uploads (
  id uuid PRIMARY KEY,
  owner varchar NOT NULL,
  status upload_status NOT NULL,
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
