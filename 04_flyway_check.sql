-- Step 4 (after `flyway migrate`): confirm the migrated database matches the lab
\dt
SELECT installed_rank, version, description, success
FROM flyway_schema_history
ORDER BY installed_rank;
SELECT count(*) AS students FROM students;
SELECT count(*) AS categories FROM categories;
SELECT tgname FROM pg_trigger WHERE tgname = 'trg_audit';
