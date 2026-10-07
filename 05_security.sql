-- Step 5: Least-privilege security
-- Run as a superuser (postgres) connected to `bootcamp`.
-- Usage: psql -U postgres -d bootcamp -v api_password="'change-me-please'" -f sql/05_security.sql

CREATE ROLE app_read;
CREATE ROLE app_write;

GRANT CONNECT ON DATABASE bootcamp TO app_read, app_write;
GRANT USAGE ON SCHEMA public TO app_read, app_write;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public TO app_write;

-- The lab text hard-codes 'strong-secret'; the password is passed in as a psql
-- variable here so no secret is committed to the repo.
CREATE USER api
LOGIN PASSWORD :api_password
IN ROLE app_write;
