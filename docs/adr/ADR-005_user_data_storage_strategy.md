# ADR-005: Retention of User Data in SharedPreferences for Release v2.3.0

* **Status**: Accepted
* **Date**: 2026-07-30
* **Target Version**: v2.3.0

## Context

Task 17 focuses on architecture modernization and static reference data migration to SQLite without altering existing user experience or risking user data loss across version upgrades.

## Decision

User-generated data (favorites, conversion history, notes, custom converters, pinned categories, settings, home layout) remains in **SharedPreferences** for release v2.3.0. Migration of user tables to SQLite is scheduled for a dedicated future release.

## Rationale

1. **Zero User Data Loss Risk**: Existing user history and custom converters are preserved across the v2.3.0 update without complex migration scripts.
2. **API Abstraction**: Repository layer and service interfaces (`FavoritesService`, `HistoryService`, `NotesService`) isolate storage mechanisms. Future migration to SQLite user tables will update storage internals without breaking UI or Provider contracts.
3. **Phase-by-Phase Execution**: Isolates static reference data migration (Phase 1) from user data migration (Phase 4).
