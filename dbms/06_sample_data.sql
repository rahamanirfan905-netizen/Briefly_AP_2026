
-- Sample data for Briefly query benchmarking

INSERT INTO "User" (id, email, name, "passwordHash")
VALUES
('u1', 'irfan@test.com', 'Irfan', 'test_hash');

INSERT INTO "Category" (id, slug, name, keywords)
VALUES
('c1', 'technology', 'Technology', ARRAY['AI', 'Tech']),
('c2', 'sports', 'Sports', ARRAY['Football', 'Cricket']);

INSERT INTO "Publisher" (id, name, domain)
VALUES
('p1', 'Test Publisher', 'test.com');

INSERT INTO "NewsSource" (id, key, name, type)
VALUES
('s1', 'test-source', 'Test Source', 'RSS');

INSERT INTO "NewsArticle" (
    id, headline, summary, url, "publishedAt",
    region, "clusterId", "titleTokens",
    "categoryId", "publisherId", "sourceId"
)
VALUES
(
    'a1', 'AI Developments',
    'Latest developments in AI.',
    'https://test.com/article1',
    CURRENT_TIMESTAMP,
    'INDIA', 'cluster1',
    ARRAY['AI', 'Developments'],
    'c1', 'p1', 's1'
),
(
    'a2', 'Football Updates',
    'Latest football news.',
    'https://test.com/article2',
    CURRENT_TIMESTAMP - INTERVAL '1 day',
    'INDIA', 'cluster2',
    ARRAY['Football', 'Updates'],
    'c2', 'p1', 's1'
);

INSERT INTO "UserPreference" (
    id, "userId", categories, region
)
VALUES (
    'pref1', 'u1', ARRAY['technology'], 'INDIA'
);

INSERT INTO "Bookmark" (id, "userId", "articleId")
VALUES ('b1', 'u1', 'a1');

INSERT INTO "ReadingHistory" (
    id, "userId", "articleId"
)
VALUES ('h1', 'u1', 'a1');
