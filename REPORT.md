# Lab Report: Audit Logging, Category Trees, and Safe Migrations

Name: Esther Elimlim
Database: `bootcamp` (PostgreSQL ___ )  Flyway version: ___

> Fill in after running `./run_lab.sh`. Raw output is saved in `outputs/`.
> Add screenshots to `screenshots/` using the names below.

## Step 1: Audit log
- [ ] `screenshots/01_trigger_created.png` (`pg_trigger` row for `trg_audit`)
- Observation: ______

## Step 2: Audit trail
- [ ] `screenshots/02_audit_trail.png`
- Rows produced: ______
- Why does `new_row` show NULL for the DELETE? ______

## Step 3: Category tree
- [ ] `screenshots/03_tree.png`
- Why does `ORDER BY depth, name` not print Laptops under Computers? ______

## Step 4: Flyway
- [ ] `screenshots/04_flyway_info.png`
- Why must an applied migration never be edited? ______

## Step 5: Security
- [ ] `screenshots/05_permission_denied.png` (from `06_verify_security.sql`)
- Which operations were denied for `app_read`? ______  for `api`? ______
- What gaps did `05b_hardening.sql` close and why? ______

## Reflection
One thing that surprised me / one thing I'd improve: ______
