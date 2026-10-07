-- Step 5b (extra credit): gaps the basic grants leave open
-- Run as superuser on `bootcamp` after 05_security.sql.

-- 1. SERIAL columns call nextval(); app_write needs sequence usage to INSERT.
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_write;

-- 2. app_write got UPDATE/DELETE on audit_log via "ALL TABLES".
--    An audit trail the app can rewrite is not an audit trail.
REVOKE UPDATE, DELETE, TRUNCATE ON audit_log FROM app_write;
GRANT SELECT, INSERT ON audit_log TO app_write;

-- 3. "ALL TABLES" only covers tables that exist today. Cover future ones too.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO app_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_write;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO app_write;

-- 4. Don't let everyone connect by default, and stop roles creating objects in public.
REVOKE CONNECT ON DATABASE bootcamp FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- 5. Flyway (schema owner) keeps DDL rights; the `api` login never does.
