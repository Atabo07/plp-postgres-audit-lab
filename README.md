# Audit Logging, Category Trees, and Safe Migrations (PostgreSQL)

Hands-on lab on the `bootcamp` database: trigger-based audit logging, a hierarchical
category tree with recursive CTEs, versioned Flyway migrations, and least-privilege roles.

## Repo layout

| Path | What it is |
|---|---|
| `migrations/V1__core_tables.sql` | `students`, `courses` + seed rows |
| `migrations/V2__audit_log.sql` | `audit_log`, `audit()` function, `trg_audit` trigger |
| `migrations/V3__categories.sql` | `categories` table + seed tree |
| `sql/01`-`03` | Lab Steps 1-3 exactly as written (plus small bonus queries) |
| `sql/04_flyway_check.sql` | Checks the Flyway-built database |
| `sql/05_security.sql` | Lab Step 5 (roles, grants, `api` user) |
| `sql/05b_hardening.sql` | Extra credit: gaps in the basic grants |
| `sql/06_verify_security.sql` | Proves each role can / cannot do what it should |
| `flyway.conf`, `run_lab.sh`, `docker-compose.yml` | Config and a one-shot runner |
| `REPORT.md` | Results, observations and screenshot checklist |

## How to run

```bash
# optional throwaway server
docker compose up -d

export PGPASSWORD=postgres
export API_PASSWORD='pick-a-real-secret'
./run_lab.sh            # runs everything in order, saves output to ./outputs/
```

Or run each step by hand, in order:

```bash
psql -U postgres -d bootcamp -f sql/00_setup_students.sql   # only if students doesn't exist
psql -U postgres -d bootcamp -f sql/01_audit_log.sql
psql -U postgres -d bootcamp -f sql/02_watch_audit.sql
psql -U postgres -d bootcamp -f sql/03_category_tree.sql

createdb -U postgres bootcamp_flyway
FLYWAY_PASSWORD=$PGPASSWORD flyway -configFiles=flyway.conf migrate
FLYWAY_PASSWORD=$PGPASSWORD flyway -configFiles=flyway.conf info
psql -U postgres -d bootcamp_flyway -f sql/04_flyway_check.sql

psql -U postgres -d bootcamp -v api_password="'pick-a-real-secret'" -f sql/05_security.sql
psql -U postgres -d bootcamp -f sql/05b_hardening.sql
psql -U postgres -d bootcamp -f sql/06_verify_security.sql
```

**Why Step 4 uses a second database:** Steps 1-3 already created `audit_log` and
`categories` in `bootcamp`. Flyway refuses to run V2/V3 against a schema that already
contains those objects. Running the migrations on a clean `bootcamp_flyway` database
proves the three files rebuild the same schema from nothing, which is the point of
versioned migrations. (If you would rather migrate `bootcamp` itself, drop the Step 1 and
Step 3 objects first, or use `flyway baseline`.)

## What you should see

**Step 2: audit trail** (names depend on your seed data)

| tbl | op | was | now |
|---|---|---|---|
| students | DELETE | Chidi Okafor | *(null)* |
| students | UPDATE | Kofi Mensah | Kofi M. |

INSERT rows appear only for students inserted *after* the trigger exists.

**Step 3: tree**

```
Electronics
  Computers
  Phones
    Laptops
```
With the lab's `ORDER BY depth, name` the rows come out level by level
(Electronics, Computers, Phones, Laptops), so Laptops is *not* printed under Computers.
The bonus query orders by `path`, which prints each child directly under its parent:

```
Electronics
  Computers
    Laptops
  Phones
```

**Step 4: `flyway info`** lists V1, V2, V3 with state `Success`; `flyway_schema_history`
holds three rows with `success = t`.

**Step 5/6:** `app_read` can SELECT but INSERT fails with `permission denied for table students`;
`api` can INSERT/UPDATE but `DROP TABLE` / `CREATE TABLE` fail; after 05b, `DELETE FROM audit_log` fails for `api`.

## Design notes and gotchas

* **Audit trigger:** `AFTER ... FOR EACH ROW` so rows are only logged once the change succeeded.
  `to_jsonb(OLD)` is NULL on INSERT and `to_jsonb(NEW)` is NULL on DELETE (PostgreSQL 11+;
  older versions raise an error). `changed_by` uses `current_user`, so changes made through
  `api` are attributed to `api`.
* **Failure mode:** if the audit insert fails, the original statement fails too. That is
  usually what you want for an audit trail.
* **`DELETE ... id = 3`** fails if another table has a foreign key to that student. Delete or
  reassign the child rows first, or choose another id.
* **`ORDER BY at DESC`** can tie for rows in the same transaction (`now()` is transaction
  start time), so I added `id DESC` as a tie-breaker.
* **Recursive CTE safety:** a cycle in `parent_id` would loop forever. Production versions
  track visited ids in an array or cap `depth`.
* **Never edit an applied migration.** Flyway checksums each file; changes go in `V4__...`.
* **Least privilege gaps fixed in `05b`:** `ALL TABLES` misses future tables, `SERIAL`
  inserts need sequence `USAGE`, and `app_write` could rewrite `audit_log` (tamper-proofing it
  is the whole point of auditing). `PUBLIC` also gets `CONNECT` and `CREATE` on `public`
  by default in older setups.
* **Secrets:** the lab's `'strong-secret'` is a placeholder; the password is passed in as a
  variable so nothing sensitive is committed.
