# Query Execution Timings

## Overview

This document records the execution times of all nine SQL queries tested for the Briefly AP database project.

Execution plans were generated using PostgreSQL EXPLAIN ANALYZE with BUFFERS.

## Read Queries

| Query ID | Query Name | Execution Time |
|---|---|---:|
| R1 | Read Feed | 0.244 ms |
| R2 | Category Feed | 0.197 ms |
| R3 | Saved Articles | 0.209 ms |
| R4 | Reading History | 0.122 ms |
| R5 | User Preferences | 0.097 ms |

## Write Queries

| Query ID | Query Name | Execution Time |
|---|---|---:|
| W1 | Insert Bookmark | 2.268 ms |
| W2 | Delete Bookmark | 0.224 ms |
| W3 | Upsert Reading History | 2.949 ms |
| W4 | Update User Preferences | 0.235 ms |

## Benchmark Methodology

- PostgreSQL EXPLAIN (ANALYZE, BUFFERS) was used.
- Read queries were measured using their corresponding SELECT statements.
- Write queries were executed inside transactions followed by ROLLBACK.
- All timings are recorded in milliseconds (ms).
- Execution times may vary depending on database state, system load, and cache conditions.

## Execution Plan Files

All nine execution plans are stored in:

`dbms/plans/`
