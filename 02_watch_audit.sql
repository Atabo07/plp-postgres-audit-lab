-- Step 2: Watch the audit log work
UPDATE students SET name = 'Kofi M.' WHERE id = 1;
DELETE FROM students WHERE id = 3;

SELECT
  tbl,
  op,
  old_row->>'name' AS was,
  new_row->>'name' AS now,
  at
FROM audit_log
ORDER BY at DESC, id DESC;

-- Bonus: the full JSON for one change
SELECT id, op, old_row, new_row, changed_by
FROM audit_log
WHERE op = 'UPDATE'
ORDER BY id DESC
LIMIT 1;
