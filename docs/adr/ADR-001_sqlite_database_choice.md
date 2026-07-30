# ADR-001: Selection of SQLite as Primary Offline Reference Database

* **Status**: Accepted
* **Date**: 2026-07-30
* **Target Version**: v2.3.0

## Context

MS Unit Converter requires a high-performance, 100% offline database engine to support 60 conversion categories, 480+ units, search aliases, 150+ currencies, educational content, and upcoming features (Formula Library, Scientific Constants, Measurement Guides).

## Decision

We chose **SQLite** (via `sqflite` plugin) as the primary storage engine for reference data.

## Rationale

1. **Zero Network Dependency**: 100% offline, privacy-first, zero analytics, zero cloud database requirements.
2. **Indexed Search**: Supports B-tree indexing on `name`, `symbol`, `category_id`, and `keyword` for instant search.
3. **Structured Schema & Versioning**: Robust support for schema versioning (`PRAGMA user_version` / `schema_version` table) and FK relational constraints.
4. **Scale & Performance**: Efficiently handles thousands of units and educational content rows without loading everything into Flutter RAM.
5. **FTS5 & Upgradability**: Allows transparent backend upgrades to FTS5 full-text search in future releases.
