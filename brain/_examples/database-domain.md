# Database Domain Rules

<!-- Template — fill with your project's actual DB conventions -->

## Database Engine

- **Engine**: {{DB_ENGINE}} (PostgreSQL / MySQL / SQLite / MongoDB / etc.)
- **Version**: {{DB_VERSION}}
- **ORM / Query builder**: {{ORM}}
- **Migration tool**: {{MIGRATION_TOOL}}

## Schema Conventions

- **Naming**: {{NAMING_CONVENTION}} (snake_case / camelCase)
- **Primary keys**: {{PK_STRATEGY}} (serial / uuid / ulid)
- **Timestamps**: `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` on every table
- **Soft delete**: `{{SOFT_DELETE_STRATEGY}}` (deleted_at column / status field / hard delete)

## Migration Rules

- **NEVER** drop a column in the same migration that removes it from the code — two-phase (code first, column later)
- **NEVER** rename a column in a single migration — add new column, migrate data, drop old column
- **Always** add an index when adding a foreign key
- **Always** test migrations on a production-size dataset before merging

## Query Conventions

- Use parameterized queries — NEVER string interpolation
- Read replicas (if applicable): `{{READ_REPLICA_STRATEGY}}`
- Transaction isolation: `{{TX_ISOLATION_LEVEL}}`

## Common Pitfalls

<!-- Example: "Table X has a partial index — WHERE clause must match exactly or the index is skipped" -->
<!-- Example: "Column Y is stored as TEXT even though it's an enum — validate at application layer" -->
