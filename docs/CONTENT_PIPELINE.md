# MS Unit Converter — Content & Build Pipeline Documentation

This document describes the developer tooling, validation workflows, and database generation pipeline for **MS Unit Converter**.

---

## 1. Developer Build & Import Pipeline

```text
Source Data Files
  ├── lib/data/units_data.dart
  ├── lib/data/currencies_data.dart
  ├── lib/data/collections_data.dart
  ├── lib/data/did_you_know.dart
  ├── lib/data/converter_config.dart
  └── assets/data/unit_information.json
        ↓
tools/lint_content.dart
  (Performs 20 static analysis checks: JSON syntax, missing files, pubspec dependencies)
        ↓
tools/validate_content.dart
  (Validates structural integrity of reference data and infrastructure components)
        ↓
tools/build_database.dart
  (Generates SQLite database using sqflite_common_ffi & DatabaseService.seedDatabase)
        ↓
assets/database/unit_converter.db
  (Pre-populated 316 KB binary asset registered in pubspec.yaml)
        ↓
DatabaseService.initialize()
  (Copies pre-populated asset DB to application documents directory on first launch)
```

---

## 2. Developer Tooling Reference

| Tool Path | Purpose | Inputs | Outputs / Artifacts |
|---|---|---|---|
| [`tools/lint_content.dart`](file:///home/marth/Desktop/unit-converter/tools/lint_content.dart) | Content & JSON linter | Data files, JSON assets, `pubspec.yaml` | 20-check validation status (exit 0 on success, exit 1 on error) |
| [`tools/validate_content.dart`](file:///home/marth/Desktop/unit-converter/tools/validate_content.dart) | Structural integrity validator | Project infrastructure paths | Infrastructure verification status |
| [`tools/build_database.dart`](file:///home/marth/Desktop/unit-converter/tools/build_database.dart) | Database pre-population builder | Reference datasets + `unit_information.json` | [`assets/database/unit_converter.db`](file:///home/marth/Desktop/unit-converter/assets/database/unit_converter.db) (316 KB) |
| [`tools/check_database.dart`](file:///home/marth/Desktop/unit-converter/tools/check_database.dart) | Database integrity checker | Path to SQLite DB file | `PRAGMA integrity_check;` and `PRAGMA foreign_key_check;` report |
| [`tools/inspect_database.dart`](file:///home/marth/Desktop/unit-converter/tools/inspect_database.dart) | Database row count inspector | Path to SQLite DB file | Table row counts and file size diagnostics |
| [`tools/verify_database.dart`](file:///home/marth/Desktop/unit-converter/tools/verify_database.dart) | CI database binary verification stub | Committed DB vs Generated DB | SHA-256 binary hash comparison for CI |

---

## 3. Running Content & Build Verification

To execute full content validation and database generation, run:

```bash
# 1. Run static content linter
dart run tools/lint_content.dart

# 2. Run structural validator
dart run tools/validate_content.dart

# 3. Generate pre-populated database asset
flutter test test/build_database_runner_test.dart

# 4. Verify database health & integrity
dart run tools/check_database.dart assets/database/unit_converter.db
```
