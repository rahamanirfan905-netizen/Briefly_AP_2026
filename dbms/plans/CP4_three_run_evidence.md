# CP4 three-run plan evidence

All commands used `EXPLAIN (ANALYZE, BUFFERS, COSTS false, TIMING false)` on PostgreSQL
16.15 with the small synthetic fixture in `../06_sample_data.sql`. Write entries ran in
`BEGIN; ...; ROLLBACK;`. The terse operator text below is the captured plan structure;
the existing query-specific `.txt` files retain the prior full-format plans.

| ID | Instantiated SQL | Run 1 | Run 2 | Run 3 |
|---|---|---|---|---|
| R1 | India visible feed (`region='INDIA'`, limit 30) | `Limit -> Sort -> Nested Loop`; Seq Scan Publisher, NewsArticle, Category; hit=9; planning 1.603 ms; execution **0.044 ms** | same operators; hit=9; planning 0.600 ms; execution **0.040 ms** | same operators; hit=9; planning 0.528 ms; execution **0.034 ms** |
| R2 | Technology feed (`slug='technology'`, limit 30) | `Limit -> Sort -> Nested Loop`; Seq Scan Category, NewsArticle, NewsSource; hit=9; planning 0.456 ms; execution **0.033 ms** | same operators; hit=9; planning 0.470 ms; execution **0.035 ms** | same operators; hit=9; planning 0.443 ms; execution **0.033 ms** |
| R3 | Bookmarks for `userId='u1'` | `Sort -> Nested Loop -> Nested Loop`; Seq Scan Bookmark, NewsArticle, Publisher; hit=9; planning 1.257 ms; execution **0.040 ms** | same operators; hit=9; planning 0.473 ms; execution **0.037 ms** | same operators; hit=9; planning 0.481 ms; execution **0.035 ms** |
| R4 | Reading history for `userId='u1'` | `Limit -> Sort -> Nested Loop -> Nested Loop`; Seq Scan ReadingHistory, NewsArticle, Category; hit=9; planning 0.674 ms; execution **0.034 ms** | same operators; hit=9; planning 0.488 ms; execution **0.033 ms** | same operators; hit=9; planning 0.488 ms; execution **0.034 ms** |
| R5 | Preferences for `id='u1'` | `Nested Loop Left Join`; Seq Scan User and UserPreference; hit=2; planning 0.285 ms; execution **0.023 ms** | same operators; hit=2; planning 0.303 ms; execution **0.027 ms** | same operators; hit=2; planning 0.271 ms; execution **0.027 ms** |
| W1 | `INSERT Bookmark('benchmark_b1','u1','a2') ON CONFLICT DO NOTHING` | Insert; arbiter `Bookmark_userId_articleId_key`; inserted=1; hit=19; planning 0.065 ms; execution **0.469 ms** | same operator; hit=19; planning 0.061 ms; execution **0.436 ms** | same operator; hit=19; planning 0.062 ms; execution **0.440 ms** |
| W2 | `DELETE Bookmark WHERE userId='u1' AND articleId='a1'` | Delete -> Seq Scan Bookmark; rows=1; hit=2; planning 0.167 ms; execution **0.203 ms** | same operator; hit=2; planning 0.164 ms; execution **0.049 ms** | same operator; hit=2; planning 0.170 ms; execution **0.048 ms** |
| W3 | `INSERT ReadingHistory ... ON CONFLICT(userId,articleId) DO UPDATE` | Insert conflict update; arbiter `ReadingHistory_userId_articleId_key`; conflicts=1; hit=28; planning 0.056 ms; execution **0.103 ms** | same operator; hit=28; planning 0.053 ms; execution **0.090 ms** | same operator; hit=28; planning 0.056 ms; execution **0.092 ms** |
| W4 | `UPDATE UserPreference SET region='INDIA', categories=ARRAY['technology'] WHERE userId='u1'` | Update -> Seq Scan UserPreference; rows=1; hit=7; planning 0.152 ms; execution **0.056 ms** | same operator; hit=7; planning 0.138 ms; execution **0.055 ms** | same operator; hit=7; planning 0.146 ms; execution **0.059 ms** |

The exact column selections and joins are the corresponding `R1`–`W4` statements in
`../04_queries.sql`; only psql variables were instantiated for this run.
