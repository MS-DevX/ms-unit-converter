/// SQLite schema creation and version migration service.
///
/// All schema changes are implemented as numbered migration steps.
/// Rules:
/// - Migrations are **additive only** — never DROP, TRUNCATE, or ALTER existing
///   columns in a way that destroys data.
/// - User-generated data tables (`favorites`, `history`, `notes`, etc.) are
///   never created here — they remain in SharedPreferences for this release.
///
/// ## Version History
/// | Schema Version | Changes |
/// |---|---|
/// | 1 | Initial schema: categories, units, unit_information, search_aliases, |
/// |   | collections, collection_items, currencies, educational_facts, tags, |
/// |   | content_tags, related_content, schema_version, content_version |
library;

import 'package:sqflite/sqflite.dart';

/// Service that holds all schema migration steps.
class MigrationService {
  MigrationService._();

  /// Current schema version. Increment when adding or modifying tables.
  static const int currentSchemaVersion = 1;

  /// Creates the full schema from scratch (called via sqflite's [onCreate]).
  static Future<void> createSchema(Database db) async {
    await db.transaction((txn) async {
      await _runMigration1(txn);
    });
  }

  /// Runs incremental migrations from [oldVersion] to [newVersion].
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await db.transaction((txn) async {
      for (var v = oldVersion + 1; v <= newVersion; v++) {
        switch (v) {
          case 1:
            await _runMigration1(txn);
          default:
            break;
        }
      }
    });
  }

  // ─── Migration Steps ───────────────────────────────────────────────────────

  /// Schema v1 — Initial: all reference tables.
  static Future<void> _runMigration1(Transaction txn) async {
    // ── Version tables ──────────────────────────────────────────────
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS schema_version (
        version     INTEGER PRIMARY KEY,
        applied_at  TEXT    NOT NULL,
        description TEXT    NOT NULL
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS content_version (
        id           INTEGER PRIMARY KEY CHECK (id = 1),
        version      TEXT    NOT NULL,
        generated_at TEXT    NOT NULL,
        source_hash  TEXT    NOT NULL
      )
    ''');

    // ── Core reference tables ───────────────────────────────────────
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id             TEXT    PRIMARY KEY,
        display_name   TEXT    NOT NULL,
        description    TEXT    NOT NULL,
        group_name     TEXT    NOT NULL,
        emoji          TEXT    NOT NULL DEFAULT '',
        display_order  INTEGER NOT NULL DEFAULT 0,
        is_featured    INTEGER NOT NULL DEFAULT 0,
        is_hidden      INTEGER NOT NULL DEFAULT 0,
        search_weight  INTEGER NOT NULL DEFAULT 100
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS units (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id     TEXT    NOT NULL REFERENCES categories(id),
        name            TEXT    NOT NULL,
        symbol          TEXT    NOT NULL,
        to_base         REAL    NOT NULL,
        is_special_case INTEGER NOT NULL DEFAULT 0,
        group_name      TEXT,
        display_order   INTEGER NOT NULL DEFAULT 0,
        is_featured     INTEGER NOT NULL DEFAULT 0,
        is_hidden       INTEGER NOT NULL DEFAULT 0,
        search_weight   INTEGER NOT NULL DEFAULT 100
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS unit_information (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        unit_id    INTEGER NOT NULL UNIQUE REFERENCES units(id),
        symbol     TEXT    NOT NULL,
        definition TEXT    NOT NULL,
        history    TEXT    NOT NULL,
        used_for   TEXT    NOT NULL,
        examples   TEXT    NOT NULL
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS search_aliases (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword     TEXT    NOT NULL,
        canonical   TEXT    NOT NULL,
        unit_id     INTEGER REFERENCES units(id),
        category_id TEXT    REFERENCES categories(id),
        priority    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS collections (
        id            TEXT    PRIMARY KEY,
        name          TEXT    NOT NULL,
        emoji         TEXT    NOT NULL,
        description   TEXT    NOT NULL,
        display_order INTEGER NOT NULL DEFAULT 0,
        is_featured   INTEGER NOT NULL DEFAULT 0,
        is_hidden     INTEGER NOT NULL DEFAULT 0,
        search_weight INTEGER NOT NULL DEFAULT 100
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS collection_items (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        collection_id TEXT    NOT NULL REFERENCES collections(id),
        category_id   TEXT    NOT NULL REFERENCES categories(id),
        display_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS currencies (
        iso_code              TEXT    PRIMARY KEY,
        name                  TEXT    NOT NULL,
        symbol                TEXT    NOT NULL,
        flag                  TEXT    NOT NULL,
        country               TEXT    NOT NULL,
        decimal_digits        INTEGER NOT NULL DEFAULT 2,
        fallback_rate_to_usd  REAL    NOT NULL,
        is_pinned             INTEGER NOT NULL DEFAULT 0,
        pin_order             INTEGER,
        display_order         INTEGER NOT NULL DEFAULT 0,
        is_featured           INTEGER NOT NULL DEFAULT 0,
        search_weight         INTEGER NOT NULL DEFAULT 100
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS educational_facts (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        emoji         TEXT    NOT NULL,
        fact          TEXT    NOT NULL,
        category_id   TEXT    REFERENCES categories(id),
        display_order INTEGER NOT NULL DEFAULT 0,
        is_featured   INTEGER NOT NULL DEFAULT 0,
        is_hidden     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Cross-cutting metadata tables ───────────────────────────────
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS content_tags (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        tag_id      INTEGER NOT NULL REFERENCES tags(id),
        source_type TEXT    NOT NULL,
        source_id   TEXT    NOT NULL
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS related_content (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        source_type       TEXT    NOT NULL,
        source_id         TEXT    NOT NULL,
        target_type       TEXT    NOT NULL,
        target_id         TEXT    NOT NULL,
        relationship_type TEXT    NOT NULL,
        display_order     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Performance indexes ─────────────────────────────────────────
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_units_category    ON units(category_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_units_name        ON units(name)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_units_symbol      ON units(symbol)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_unit_info_unit    ON unit_information(unit_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_aliases_keyword   ON search_aliases(keyword)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_aliases_canonical ON search_aliases(canonical)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_aliases_unit      ON search_aliases(unit_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_coll_items        ON collection_items(collection_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_currencies_code   ON currencies(iso_code)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_currencies_country ON currencies(country)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_facts_category    ON educational_facts(category_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_content_tags_src  ON content_tags(source_type, source_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_related_src       ON related_content(source_type, source_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_related_tgt       ON related_content(target_type, target_id)');
  }
}
