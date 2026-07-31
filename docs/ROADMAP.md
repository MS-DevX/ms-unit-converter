# MS Unit Converter — Database & Content Roadmap

This document outlines the phased evolution of data storage and content architecture for **MS Unit Converter**.

---

## Phase 1 — SQLite Infrastructure & Runtime Migration (v2.3.0) — **COMPLETE ✅**

* **Architecture Modernization**: Created SQLite database infrastructure (`DatabaseService`, `MigrationService`, Schema v1 with 20 tables and 16 indexes).
* **Repository Layer**: Implemented 7 singletons with in-memory caching (`UnitRepository`, `CategoryRepository`, `CurrencyRepository`, `CollectionRepository`, `SearchRepository`, `UnitInformationRepository`, `EducationalFactsRepository`).
* **Pre-Populated Binary Database Asset**: Built `tools/build_database.dart` developer pipeline to generate [`assets/database/unit_converter.db`](file:///home/marth/Desktop/unit-converter/assets/database/unit_converter.db) (316 KB). Registered in `pubspec.yaml`.
* **First-Launch Asset Copy**: `DatabaseService.initialize()` copies the pre-populated asset database to the application documents directory on first launch.
* **Developer & Quality Tooling**: Created static content linter (`lint_content.dart`), database checker (`check_database.dart`), inspector (`inspect_database.dart`), and health diagnostic service (`DatabaseHealthService`).
* **Test Suite**: 311 unit and widget tests passing (100% pass rate). Zero static analysis issues.

---

## Phase 2 — Canonical External Content Source (Planned Next Phase)

### Objectives
Transition from seeding SQLite via Dart datasets to using structured JSON content files inside `content/` as the single canonical source of truth.

### Planned Files in `content/`
```text
content/
├── categories.json           ← Category metadata & display config
├── units.json                ← All 480+ units organized by category
├── currencies.json           ← 170+ ISO currencies with fallback rates
├── collections.json          ← Predefined collections & item mappings
├── educational_facts.json    ← "Did You Know" educational facts
├── search_aliases.json       ← Search keyword alias mappings
└── unit_information.json     ← 100% full coverage educational info for all units
```

### Post-Phase 2 Role of Dart Files
After Phase 2 migration, Dart dataset files (`lib/data/units_data.dart`, `currencies_data.dart`, `collections_data.dart`) will **no longer contain hardcoded data maps**.

They will be stripped to contain **ONLY**:
- `enum UnitCategory` (53 type-safe enum values)
- App constants & storage keys
- Compile-time identifiers

All reference data populating SQLite will be built directly from `content/*.json` via `tools/build_database.dart`.

---

## Phase 3 — Educational Content & Scaffolding Population (Future)

Populate the pre-created empty scaffolding tables:
- **Formula Library**: `formulas`, `formula_categories`
- **Scientific Constants**: `scientific_constants`
- **Student Toolkit & Guides**: `subjects`, `grades`, `measurement_guides`
- **Engineering Reference**: `engineering_reference`, `tags`, `content_tags`, `related_content`

---

## Phase 4 — User Data Migration to SQLite (Future)

Migrate user-generated data (favorites, history, notes, custom converters, home layout) from `SharedPreferences` to dedicated user tables in SQLite (`user_favorites`, `user_history`, `user_notes`, `user_custom_converters`).

* **Design Guardrail**: Repositories are designed so that migrating user data to SQLite will alter internal repository storage implementation **without breaking public provider or UI APIs**.
