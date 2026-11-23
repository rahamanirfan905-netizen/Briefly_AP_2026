# Query Execution Timings

## Scope and method

Measured on 23 November 2026 with PostgreSQL 16.15 using `EXPLAIN (ANALYZE, BUFFERS)`.
The schema came from `dbms/03_schema.sql` and the checked-in fixture from
`dbms/06_sample_data.sql`: one user, two articles, one bookmark, one reading-history
row, and one preference. These are small synthetic-fixture results, **not production
performance results**. Reads used identical parameter values on all runs. Each write
used `BEGIN; EXPLAIN ...; ROLLBACK;`, so the database started every measured write run
in the same state.

| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |
|---|---|---|---:|---:|---:|---:|---|
| R1 | READ | Visible India feed | 0.044 | 0.040 | 0.034 | 0.039 | Sequential scans + nested loops |
| R2 | READ | Technology category feed | 0.033 | 0.035 | 0.033 | 0.034 | Sequential scans + nested loops |
| R3 | READ | User bookmarks | 0.040 | 0.037 | 0.035 | 0.037 | Sequential scans + nested loops |
| R4 | READ | User reading history | 0.034 | 0.033 | 0.034 | 0.034 | Sequential scans + nested loops |
| R5 | READ | User preferences | 0.023 | 0.027 | 0.027 | 0.026 | Sequential scans + nested loop |
| W1 | WRITE | Insert bookmark | 0.469 | 0.436 | 0.440 | 0.448 | Insert; rolled back |
| W2 | WRITE | Delete bookmark | 0.203 | 0.049 | 0.048 | 0.100 | Sequential scan; rolled back |
| W3 | WRITE | Upsert reading history | 0.103 | 0.090 | 0.092 | 0.095 | Insert conflict update; rolled back |
| W4 | WRITE | Update user preferences | 0.056 | 0.055 | 0.059 | 0.057 | Sequential scan; rolled back |

Each average is `(Run 1 + Run 2 + Run 3) / 3`, rounded to three decimal places.
`dbms/plans/CP4_three_run_evidence.md` records the instantiated SQL, each run's
observed plan operators, buffer use, planning time, and execution time.
