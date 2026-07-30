# Database Migrations Architecture

This directory holds future incremental schema migration steps for MS Unit Converter.

## Schema Version Rules

1. **Additive Only**: Migrations must NEVER `DROP TABLE`, `TRUNCATE`, or `ALTER TABLE ... DROP COLUMN` on user or reference tables.
2. **Version Tracking**: `MigrationService.currentSchemaVersion` controls the schema version target.
3. **Sequential Execution**: `MigrationService.upgrade(db, oldVersion, newVersion)` executes migrations step-by-step from `oldVersion + 1` to `newVersion`.
4. **Content Versioning**: Database content updates (data only, no schema change) are tracked separately via `_contentVersion` in `DatabaseService`.

## Adding a New Schema Migration (e.g., v2)

1. Create `lib/database/migrations/migration_v2.dart`.
2. Define a class or static method `Future<void> runMigration2(Transaction txn)`.
3. Increment `MigrationService.currentSchemaVersion` to `2`.
4. Add `case 2: await runMigration2(txn);` to `MigrationService.upgrade()`.
5. Update `schema_version` description table row in `DatabaseService._writeVersions()`.

## Directory Structure

```
lib/database/migrations/
├── README.md               ← Architecture & guidelines (this file)
└── migration_v2_stub.dart  ← Stub template for Schema Version 2
```
