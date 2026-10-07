-- Verify least privilege. Run as superuser; SET ROLE impersonates each role.
\set ON_ERROR_STOP off
\echo '--- role memberships ---'
SELECT r.rolname AS member, g.rolname AS member_of
FROM pg_auth_members m
JOIN pg_roles r ON r.oid = m.member
JOIN pg_roles g ON g.oid = m.roleid
WHERE r.rolname IN ('api','app_read','app_write');

\echo '--- app_read: SELECT should WORK ---'
SET ROLE app_read;
SELECT count(*) FROM students;
\echo '--- app_read: INSERT should FAIL (permission denied) ---'
INSERT INTO students (name) VALUES ('Should Fail');
RESET ROLE;

\echo '--- api (app_write): INSERT/UPDATE should WORK ---'
SET ROLE api;
INSERT INTO students (name, email) VALUES ('API Test', 'api@example.com');
UPDATE students SET name = 'API Test 2' WHERE email = 'api@example.com';
\echo '--- api: DROP / CREATE TABLE should FAIL ---'
DROP TABLE categories;
CREATE TABLE evil (x int);
\echo '--- api: tampering with audit_log should FAIL (needs 05b) ---'
DELETE FROM audit_log;
RESET ROLE;

\echo '--- audit captured the api user ---'
SELECT op, new_row->>'name' AS name, changed_by FROM audit_log ORDER BY id DESC LIMIT 3;
