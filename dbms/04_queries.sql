-- Briefly CP3 query catalogue, based on dbms/03_schema.sql.
-- Parameters use psql variables (for example: -v user_id='u1').
-- These represent schema-supported application operations; app source is unavailable here.

-- R1 READ: visible regional feed with category and publisher labels.
SELECT a.id, a.headline, a.summary, a."publishedAt", a.score,
       c.name AS category_name, p.name AS publisher_name
FROM "NewsArticle" a
JOIN "Category" c ON c.id = a."categoryId"
JOIN "Publisher" p ON p.id = a."publisherId"
WHERE a.region = 'INDIA' AND NOT a.hidden AND a."isClusterPrimary"
ORDER BY a.score DESC, a.id
LIMIT 30;

-- R2 READ: filtered category feed, including the source name.
SELECT a.id, a.headline, a."publishedAt", c.slug, s.name AS source_name
FROM "NewsArticle" a
JOIN "Category" c ON c.id = a."categoryId"
JOIN "NewsSource" s ON s.id = a."sourceId"
WHERE c.slug = :'category_slug' AND c.active AND NOT a.hidden
ORDER BY a."publishedAt" DESC, a.id
LIMIT 30;

-- R3 READ: a user's saved articles in bookmark order.
SELECT b.id AS bookmark_id, b."createdAt", a.id AS article_id,
       a.headline, p.name AS publisher_name
FROM "Bookmark" b
JOIN "NewsArticle" a ON a.id = b."articleId"
JOIN "Publisher" p ON p.id = a."publisherId"
WHERE b."userId" = :'user_id'
ORDER BY b."createdAt" DESC, b.id;

-- R4 READ: recent reading history with article category.
SELECT h."readAt", a.id, a.headline, c.name AS category_name
FROM "ReadingHistory" h
JOIN "NewsArticle" a ON a.id = h."articleId"
JOIN "Category" c ON c.id = a."categoryId"
WHERE h."userId" = :'user_id'
ORDER BY h."readAt" DESC, h.id
LIMIT 50;

-- R5 READ: account preferences and their user identity.
SELECT u.id, u.email, pref.categories, pref.region
FROM "User" u
LEFT JOIN "UserPreference" pref ON pref."userId" = u.id
WHERE u.id = :'user_id';

-- W1 WRITE: save an existing article for an existing user.
INSERT INTO "Bookmark" (id, "userId", "articleId")
VALUES (:'bookmark_id', :'user_id', :'article_id')
ON CONFLICT ("userId", "articleId") DO NOTHING;

-- W2 WRITE: remove a user's bookmark by its relationship, scoped to that user.
DELETE FROM "Bookmark"
WHERE "userId" = :'user_id' AND "articleId" = :'article_id';

-- W3 WRITE: record first read, or update the latest read time.
INSERT INTO "ReadingHistory" (id, "userId", "articleId", "readAt")
VALUES (:'history_id', :'user_id', :'article_id', CURRENT_TIMESTAMP)
ON CONFLICT ("userId", "articleId")
DO UPDATE SET "readAt" = EXCLUDED."readAt";

-- W4 WRITE: update an existing user's regional and category preferences.
UPDATE "UserPreference"
SET region = :'region', categories = ARRAY[:'category_slug']::text[]
WHERE "userId" = :'user_id';
