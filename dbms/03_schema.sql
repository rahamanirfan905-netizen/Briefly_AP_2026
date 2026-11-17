
-- ============================================
-- BRIEFLY APPLICATION
-- PostgreSQL Database Schema
-- Converted from Prisma Schema
-- ============================================

-- 1. ENUM TYPES

CREATE TYPE "Role" AS ENUM (
    'USER',
    'ADMIN'
);

CREATE TYPE "Region" AS ENUM (
    'INDIA',
    'WORLD'
);


-- 2. USER TABLE

CREATE TABLE "User" (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    name TEXT,
    "passwordHash" TEXT NOT NULL,
    role "Role" NOT NULL DEFAULT 'USER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 3. CATEGORY TABLE

CREATE TABLE "Category" (
    id TEXT PRIMARY KEY,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    keywords TEXT[] NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE
);


-- 4. PUBLISHER TABLE

CREATE TABLE "Publisher" (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    domain TEXT UNIQUE,
    credibility DOUBLE PRECISION NOT NULL DEFAULT 0.6,
    active BOOLEAN NOT NULL DEFAULT TRUE
);


-- 5. NEWS SOURCE TABLE

CREATE TABLE "NewsSource" (
    id TEXT PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    "lastSuccessAt" TIMESTAMP(3),
    "lastErrorAt" TIMESTAMP(3),
    "lastError" TEXT,
    "lastCount" INTEGER NOT NULL DEFAULT 0
);


-- 6. NEWS ARTICLE TABLE

CREATE TABLE "NewsArticle" (
    id TEXT PRIMARY KEY,
    headline TEXT NOT NULL,
    description TEXT,
    summary TEXT NOT NULL,
    "summaryBy" TEXT NOT NULL DEFAULT 'extractive',
    "imageUrl" TEXT,
    url TEXT NOT NULL UNIQUE,
    author TEXT,
    "publishedAt" TIMESTAMP(3) NOT NULL,
    "fetchedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    region "Region" NOT NULL,
    country TEXT,
    score DOUBLE PRECISION NOT NULL DEFAULT 0,
    "isBreaking" BOOLEAN NOT NULL DEFAULT FALSE,
    "isTrending" BOOLEAN NOT NULL DEFAULT FALSE,
    hidden BOOLEAN NOT NULL DEFAULT FALSE,
    "readMinutes" INTEGER NOT NULL DEFAULT 1,

    "clusterId" TEXT NOT NULL,
    "isClusterPrimary" BOOLEAN NOT NULL DEFAULT TRUE,
    "clusterSize" INTEGER NOT NULL DEFAULT 1,
    "titleTokens" TEXT[] NOT NULL,

    "categoryId" TEXT NOT NULL,
    "publisherId" TEXT NOT NULL,
    "sourceId" TEXT NOT NULL,

    CONSTRAINT "NewsArticle_categoryId_fkey"
        FOREIGN KEY ("categoryId")
        REFERENCES "Category"(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT "NewsArticle_publisherId_fkey"
        FOREIGN KEY ("publisherId")
        REFERENCES "Publisher"(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT "NewsArticle_sourceId_fkey"
        FOREIGN KEY ("sourceId")
        REFERENCES "NewsSource"(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- 7. BOOKMARK TABLE

CREATE TABLE "Bookmark" (
    id TEXT PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "articleId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Bookmark_userId_fkey"
        FOREIGN KEY ("userId")
        REFERENCES "User"(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT "Bookmark_articleId_fkey"
        FOREIGN KEY ("articleId")
        REFERENCES "NewsArticle"(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT "Bookmark_userId_articleId_key"
        UNIQUE ("userId", "articleId")
);


-- 8. USER PREFERENCE TABLE

CREATE TABLE "UserPreference" (
    id TEXT PRIMARY KEY,
    "userId" TEXT NOT NULL UNIQUE,
    categories TEXT[] NOT NULL,
    region TEXT NOT NULL DEFAULT 'BOTH',

    CONSTRAINT "UserPreference_userId_fkey"
        FOREIGN KEY ("userId")
        REFERENCES "User"(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- 9. READING HISTORY TABLE

CREATE TABLE "ReadingHistory" (
    id TEXT PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "articleId" TEXT NOT NULL,
    "readAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ReadingHistory_userId_fkey"
        FOREIGN KEY ("userId")
        REFERENCES "User"(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT "ReadingHistory_articleId_fkey"
        FOREIGN KEY ("articleId")
        REFERENCES "NewsArticle"(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT "ReadingHistory_userId_articleId_key"
        UNIQUE ("userId", "articleId")
);


-- 10. APP ERROR TABLE

CREATE TABLE "AppError" (
    id TEXT PRIMARY KEY,
    scope TEXT NOT NULL,
    message TEXT NOT NULL,
    stack TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 11. REFRESH STATE TABLE

CREATE TABLE "RefreshState" (
    id TEXT PRIMARY KEY DEFAULT 'singleton',
    "lastSuccessAt" TIMESTAMP(3),
    "lastAttemptAt" TIMESTAMP(3),
    running BOOLEAN NOT NULL DEFAULT FALSE
);


-- ============================================
-- 12. INDEXES
-- ============================================

-- NewsArticle indexes

CREATE INDEX "NewsArticle_region_hidden_isClusterPrimary_score_idx"
ON "NewsArticle" (
    region,
    hidden,
    "isClusterPrimary",
    score DESC
);

CREATE INDEX "NewsArticle_categoryId_hidden_isClusterPrimary_score_idx"
ON "NewsArticle" (
    "categoryId",
    hidden,
    "isClusterPrimary",
    score DESC
);

CREATE INDEX "NewsArticle_publishedAt_idx"
ON "NewsArticle" ("publishedAt" DESC);

CREATE INDEX "NewsArticle_clusterId_idx"
ON "NewsArticle" ("clusterId");

CREATE INDEX "NewsArticle_publisherId_idx"
ON "NewsArticle" ("publisherId");

CREATE INDEX "NewsArticle_headline_idx"
ON "NewsArticle" (headline);


-- Bookmark index

CREATE INDEX "Bookmark_userId_createdAt_idx"
ON "Bookmark" ("userId", "createdAt" DESC);


-- ReadingHistory index

CREATE INDEX "ReadingHistory_userId_readAt_idx"
ON "ReadingHistory" ("userId", "readAt" DESC);


-- AppError index

CREATE INDEX "AppError_createdAt_idx"
ON "AppError" ("createdAt" DESC);

