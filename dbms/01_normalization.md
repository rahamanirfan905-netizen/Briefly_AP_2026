# Database Normalization Report – Briefly Application

**Project:** Briefly – News Aggregation and Reading Application  
**Database:** PostgreSQL  
**ORM:** Prisma  
**Document:** CP1 – Database Normalization  
**Normalization Levels:** 1NF, 2NF and 3NF

---

## 1. Introduction

Database normalization is the process of organizing data into structured tables to reduce data redundancy, prevent insertion, deletion and update anomalies, and maintain data consistency.

The Briefly application uses PostgreSQL as its database and Prisma as its ORM. The database manages users, news articles, categories, publishers, news sources, bookmarks, reading history, user preferences and application errors.

The database schema is designed using relational tables with primary keys, foreign keys, unique constraints and indexes.

This document evaluates the database structure of Briefly according to First Normal Form (1NF), Second Normal Form (2NF) and Third Normal Form (3NF).

## 2. Database Tables

The Briefly application contains the following database models:

| Table | Purpose |
|---|---|
| User | Stores user account information and authentication details |
| Category | Stores news categories and their classification information |
| Publisher | Stores publisher details and credibility information |
| NewsSource | Stores news API and RSS source information |
| NewsArticle | Stores aggregated news articles and their metadata |
| Bookmark | Stores articles bookmarked by users |
| UserPreference | Stores individual user preferences |
| ReadingHistory | Stores users' reading activity |
| AppError | Stores application error information |
| RefreshState | Stores the status of the latest news refresh |

The database also uses two enumerated types:

- Role: USER, ADMIN
- Region: INDIA, WORLD

## 3. First Normal Form (1NF)

### Definition

A table satisfies First Normal Form when:

1. Every column contains atomic values.
2. Each record can be uniquely identified.
3. There are no repeating groups or nested records in individual columns.

### Application in Briefly

The database uses unique identifiers as primary keys to identify individual records.

Examples:

**User Table**

| id | email | name | role |
|---|---|---|---|
| U001 | user1@example.com | Rahul | USER |
| U002 | user2@example.com | Aman | ADMIN |

Each row represents one user, and each column stores a defined attribute.

**NewsArticle Table**

Each article has a unique ID and URL. Information such as headline, summary, publication date and publisher reference is stored in separate columns.

**Bookmark Table**

Each bookmark represents an association between one user and one news article.

### Important observation about array fields

The existing Prisma schema contains three PostgreSQL array fields:

- `Category.keywords` – stores multiple keywords.
- `UserPreference.categories` – stores multiple preferred category slugs.
- `NewsArticle.titleTokens` – stores multiple title tokens.

These arrays are supported by PostgreSQL, but they are not strictly atomic under the classical relational definition of 1NF.

For a fully normalized relational design, these attributes can be represented using separate tables:

**CategoryKeyword**

| id | categoryId | keyword |
|---|---|---|
| 1 | C001 | politics |
| 2 | C001 | government |

**UserPreferredCategory**

| userId | categoryId |
|---|---|
| U001 | C001 |
| U001 | C002 |

**ArticleTitleToken**

| articleId | token |
|---|---|
| A001 | technology |
| A001 | news |

Each row then contains one individual keyword, category preference or title token.

This would provide strict atomicity while preserving the existing relationships.

**1NF conclusion:** The schema uses atomic scalar attributes and unique identifiers throughout its relational tables. However, the three PostgreSQL array fields are exceptions to strict 1NF and can be normalized using separate child tables as described above.

## 4. Second Normal Form (2NF)

### Definition

A table satisfies Second Normal Form when:

1. It already satisfies First Normal Form.
2. Every non-key attribute is fully dependent on the entire candidate key.
3. There are no partial functional dependencies.

Partial dependency occurs when a non-key attribute depends on only part of a composite candidate key.

### Application in Briefly

Most tables in the Briefly database use a single-column primary key.

Examples include:

- User(id)
- Category(id)
- Publisher(id)
- NewsArticle(id)
- NewsSource(id)
- UserPreference(id)

Since these tables use single-column primary keys, partial dependency on a subset of the primary key is not possible.

### Bookmark Table

The Bookmark table connects users with news articles.

Its important attributes are:

- id
- userId
- articleId
- createdAt

The combination of `userId` and `articleId` is unique.

The following functional dependency exists:

(userId, articleId) → createdAt

This means that the creation timestamp belongs to the complete user-article relationship.

A user can bookmark multiple articles, and an article can be bookmarked by multiple users. The unique constraint prevents the same user from bookmarking the same article more than once.

### ReadingHistory Table

The ReadingHistory table records which articles users have read.

Its attributes are:

- id
- userId
- articleId
- readAt

The combination of `userId` and `articleId` is unique.

Functional dependency:

(userId, articleId) → readAt

The reading timestamp depends on the complete user-article combination.

### 2NF conclusion

The database uses single-column primary keys for its main entities and composite unique constraints for the Bookmark and ReadingHistory relationships.

The relationship-specific attributes depend on their complete candidate keys. Therefore, there are no identified partial dependencies in the existing scalar relational attributes.

Strict 2NF compliance of the entire schema is conditional on resolving the array-field issue identified under 1NF.

## 5. Third Normal Form (3NF)

### Definition

A table satisfies Third Normal Form when:

1. It already satisfies Second Normal Form.
2. It contains no transitive dependency of non-key attributes on a candidate key.
3. Non-key attributes depend on the key, the whole key and nothing but the key.

A transitive dependency occurs when one non-key attribute determines another non-key attribute.

### Application in Briefly

The Briefly database separates information into independent tables to avoid unnecessary duplication.

**1. User and UserPreference**

User account information is stored in the User table, whereas personalized preferences are stored separately in UserPreference.

The UserPreference table references User through `userId`, which is unique.

This avoids storing preference information repeatedly inside the User table.

**2. NewsArticle and Category**

Category information is stored in the Category table.

The NewsArticle table references the category through `categoryId`.

Category names and slugs are therefore not repeatedly stored in every article record.

**3. NewsArticle and Publisher**

Publisher information is maintained separately in the Publisher table.

The NewsArticle table stores `publisherId` as a foreign key.

Publisher name, domain and credibility are maintained in one location.

This avoids duplicating publisher details across multiple news articles.

**4. NewsArticle and NewsSource**

NewsSource stores information about individual news providers, such as their source key, name, type and synchronization status.

NewsArticle references the appropriate source using `sourceId`.

This keeps source-specific information separate from article-specific information.

**5. Bookmark and ReadingHistory**

Both tables maintain user-article relationships through foreign keys.

They also use unique constraints to prevent duplicate user-article associations.

This avoids unnecessary duplication of user and article information.

### 3NF conclusion

The database separates users, categories, publishers, sources and articles into independent tables.

Foreign keys maintain relationships between these entities, while unique constraints prevent duplicate records.

No unintended transitive dependencies have been identified in the scalar attributes of the existing schema.

As with 2NF, full strict compliance requires resolving the PostgreSQL array fields first.

## 6. Primary Keys and Foreign Keys

The database uses primary keys and foreign keys to maintain referential integrity.

| Table | Primary Key | Foreign Keys |
|---|---|---|
| User | id | None |
| Category | id | None |
| Publisher | id | None |
| NewsSource | id | None |
| NewsArticle | id | categoryId, publisherId, sourceId |
| Bookmark | id | userId, articleId |
| UserPreference | id | userId |
| ReadingHistory | id | userId, articleId |
| AppError | id | None |
| RefreshState | id | None |

The database also applies unique constraints to important attributes:

- User.email
- Category.slug
- Publisher.name
- Publisher.domain
- NewsSource.key
- NewsArticle.url
- Bookmark(userId, articleId)
- UserPreference.userId
- ReadingHistory(userId, articleId)

These constraints help maintain data integrity and prevent duplicate records.

## 7. Referential Integrity

Foreign key relationships ensure that related records reference existing records.

Examples:

- A bookmark must reference an existing user and news article.
- A reading history record must reference an existing user and news article.
- A news article must reference an existing category, publisher and news source.
- A user preference must reference an existing user.

The database also uses cascading deletion for Bookmark, ReadingHistory and UserPreference when their associated user or article is deleted, according to the configured Prisma relations.

## 8. Benefits of Normalization in Briefly

The database structure provides several benefits:

1. **Reduced Data Redundancy:** Publisher, category and source information is maintained separately instead of being repeated in every article.

2. **Improved Data Consistency:** Updates to publisher and category information can be made in one location.

3. **Referential Integrity:** Foreign keys ensure that related records reference valid database entries.

4. **Reduced Update Anomalies:** Separating related entities reduces the possibility of inconsistent information.

5. **Better Maintainability:** Independent tables make the database easier to understand, manage and extend.

6. **Efficient Relationships:** Bookmark and ReadingHistory tables manage many-to-many user-article relationships.

## 9. Conclusion

The Briefly application uses a relational database structure designed around separate entities and their relationships.

The database separates user information, news articles, categories, publishers, news sources, bookmarks, reading history and preferences into individual tables.

Primary keys, foreign keys, unique constraints and indexes help maintain database integrity and support efficient data retrieval.

The existing scalar relational attributes have been designed to avoid partial and transitive dependencies. However, three PostgreSQL array fields require separate child tables if strict classical 1NF, 2NF and 3NF compliance is required.

Overall, the schema provides a structured foundation for the Briefly news aggregation and reading application, with a clear path toward a fully normalized relational design.