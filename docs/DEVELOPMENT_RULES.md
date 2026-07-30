# MS Unit Converter — Development Rules & Guardrails

This document establishes the mandatory architectural rules for all contributors and future feature additions to **MS Unit Converter**.

---

## 1. Mandatory Architectural Rules

### ❌ Rule 1: Widgets Must Never Access SQLite
* **Constraint**: UI Widgets (`lib/screens/`, `lib/widgets/`) must **NEVER** execute SQL queries, import `sqflite`, or call `DatabaseService` directly.
* **Allowed Pattern**: Widgets must consume state through Providers (`ConverterProvider`, `CurrencyProvider`, etc.) or read from Repository singletons.

### ❌ Rule 2: Providers Must Never Execute SQL
* **Constraint**: Providers (`lib/providers/`) must **NEVER** write raw SQL queries or import `sqflite`.
* **Allowed Pattern**: Providers must delegate all data fetching and persistence tasks to Repositories.

### ❌ Rule 3: Only Repositories May Access DatabaseService
* **Constraint**: `DatabaseService.instance.database` is strictly reserved for the Repository layer (`lib/repositories/`).
* **Allowed Pattern**: Repositories query SQLite tables, transform database rows into typed domain models, and maintain in-memory caches.

### ❌ Rule 4: DatabaseService Is a Lifecycle Manager Only
* **Constraint**: `DatabaseService` ([`lib/database/database_service.dart`](file:///home/marth/Desktop/unit-converter/lib/database/database_service.dart)) is responsible strictly for:
  - Copying pre-populated asset databases on first launch
  - Opening database connections
  - Managing schema migrations and versioning
* **Forbidden**: Never implement unit conversions, business rules, or UI state management inside `DatabaseService`.

### ❌ Rule 5: ConversionEngine Must Remain Pure Dart
* **Constraint**: `ConversionService` ([`lib/services/conversion_service.dart`](file:///home/marth/Desktop/unit-converter/lib/services/conversion_service.dart)) must remain a:
  - 100% pure Dart stateless service
  - Deterministic mathematical calculation engine
* **Forbidden**: `ConversionService` must **NEVER** import SQLite, repositories, or providers.

### ❌ Rule 6: Search Must Always Query SQLite
* **Constraint**: All search operations must execute against indexed SQLite tables (`search_aliases`, `categories`, `units`) via `SearchRepository`.
* **Forbidden**: Search functions must never read JSON assets or hardcoded Dart maps during normal application runtime.

### ❌ Rule 7: Reference Content Management
* **Constraint**: Reference content belongs in structured files (`content/*.json` in Phase 2+ or seeded via `lib/data/` in Phase 1).
* **Forbidden**: Never hardcode large datasets inside Flutter UI widgets or inline provider methods.

---

## 2. Layer Integration Summary Matrix

| Architectural Layer | Permitted Operations | Prohibited Operations |
|---|---|---|
| **UI Widgets** | Render UI, listen to Providers, dispatch UI events | Direct SQL queries, DB connection calls |
| **Providers** | Manage state, notify listeners, invoke Repositories | Writing SQL, importing `sqflite` |
| **Repositories** | Execute SQL, transform rows to models, cache data | Managing UI state, UI navigation |
| **DatabaseService** | Open DB, asset copy, schema migrations, versioning | Business logic, math conversion, UI state |
| **ConversionEngine**| Pure math calculations, formula handling | Importing DB, repos, or providers |
