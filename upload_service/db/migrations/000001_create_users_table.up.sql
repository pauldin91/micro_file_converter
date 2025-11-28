CREATE TABLE users (
  email varchar PRIMARY KEY,
  username varchar NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by varchar NOT NULL DEFAULT 'system.migration',
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by varchar NOT NULL  DEFAULT 'system.migration'
);