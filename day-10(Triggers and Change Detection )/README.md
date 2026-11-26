# Day 10 – Triggers and Change Detection: Complete Deliverables

This package covers all three assignment sets from the supplied Day 10 brief.

## Contents
Each set folder contains:
- `triggers.sql` – table/view setup and trigger definitions
- `test_evidence.sql` – runnable test cases and queries to inspect outcomes
- `watch_*.js` – MongoDB 8.0 change-stream watcher
- `notes.md` – pitfalls, limits, and design justification

## Before running
1. Run each set's `triggers.sql` in its own SQL Server database (or change the object names to avoid collisions).
2. Run the corresponding `test_evidence.sql`.
3. Run the MongoDB watcher in `mongosh` against a MongoDB deployment configured as a replica set.
4. The SQL scripts use illustrative table designs because the assignment brief does not specify schemas. Each triggers.sql starts with CREATE TABLE statements and uses unqualified table names (no dbo. prefix). SQL Server resolves these under your default schema. Adapt column names/types to your actual database if your trainer supplied a schema.
5. Run each SQL file from top to bottom. The scripts target SQL Server 2025-compatible T-SQL.

## Important transaction behaviour
SQL Server triggers execute inside the transaction of the statement that fired them. Therefore, an error raised with `THROW` rolls back the statement and trigger-side writes in that same transaction. The retail Set 1 instead-of trigger logs rejected rows and returns without applying the statement, so the rejection log can persist. Sets 2 and 3 demonstrate `THROW`-based rejection; their transactional audit rows are rolled back when the business operation is rejected.
