# Content Pipeline & Build Tooling — MS Unit Converter

## Overview
Content management and database generation are completely automated via developer CLI tooling located in the `tools/` directory.

---

## Tooling Workflows

### 1. Build Database (`tools/build_database.dart`)
Rebuilds the pre-populated SQLite asset database `assets/database/unit_converter.db`:
- Validates content referential integrity (`tools/validate_content.dart`).
- Seeds all 11 tables with pure Dart reference data.
- Runs `PRAGMA foreign_key_check` and `PRAGMA quick_check`.
- Runs `VACUUM` and `PRAGMA optimize`.
- Generates `assets/database/build_report.md`.

Usage:
```bash
flutter test test/build_database_runner_test.dart
```

---

### 2. Database Health Audit (`tools/database_health.dart`)
Audits database health and checks for foreign key violations, orphan records, duplicate keys, and missing fields.

Usage:
```bash
flutter test test/database_health_runner_test.dart
```

---

### 3. Alias Generator (`lib/utils/alias_generator.dart`)
Algorithmic search alias generator for unit plurals, US/UK spellings, and symbol variations.
