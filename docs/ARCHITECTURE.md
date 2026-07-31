# MS Unit Converter — Core Architecture Specification (v2.3.0)

This document defines the official software architecture of **MS Unit Converter**. All future feature development must strictly conform to these architectural standards.

---

## 1. High-Level Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    Flutter UI Components                    │
│      (Screens, Widgets, Dialogs, Custom Nav, Shell)         │
└──────────────────────────────┬──────────────────────────────┘
                               │ Reads state / Triggers actions
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       Provider Layer                        │
│   (ConverterProvider, CurrencyProvider, SettingsProvider)   │
└──────────────────────────────┬──────────────────────────────┘
                               │ Requests data via singletons
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Repository Layer                       │
│    (7 Singleton Repositories with In-Memory Caching)        │
└──────────────────────────────┬──────────────────────────────┘
                               │ Queries database instance
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       DatabaseService                       │
│      (SQLite Lifecycle, Asset Copying, Version Control)     │
└──────────────────────────────┬──────────────────────────────┘
                               │ Opens & manages connection
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   SQLite Database File                      │
│             (assets/database/unit_converter.db)             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Layer Responsibilities & Strict Boundaries

### A. Flutter UI Layer (`lib/screens/`, `lib/widgets/`)
* **Responsibility**: Render visual interfaces, handle user input, present animations, and listen to providers via `Consumer` or `Provider.of`.
* **Strict Rule**: UI widgets must **NEVER** query SQLite or access `DatabaseService` directly. All data access must pass through Providers or Repositories.

### B. Provider Layer (`lib/providers/`)
* **Responsibility**: Manage presentation state, coordinate UI events, handle loading states, and call repositories for backend data.
* **Strict Rule**: Providers must **NEVER** execute SQL statements or import `sqflite`. All data fetching must delegate to Repositories.

### C. Repository Layer (`lib/repositories/`)
* **Responsibility**: Act as the single source of truth for reference data queries, manage in-memory query caches, transform raw database rows into domain objects (`UnitModel`, `CategoryRow`, etc.), and encapsulate backend queries.
* **Strict Rule**: Repositories are the **ONLY** layer permitted to query SQLite.

### D. Database Service (`lib/database/database_service.dart`)
* **Responsibility**: Manage the SQLite database connection lifecycle, copy pre-populated binary assets from `rootBundle` to the app documents directory on first launch, execute schema migrations via `MigrationService`, and check content version consistency.
* **Strict Rule**: `DatabaseService` must **NEVER** contain business logic, unit conversion math, or UI state.

---

## 3. Runtime Data Flow

```text
SQLite Database (assets/database/unit_converter.db)
      ↓
Repository (e.g. UnitRepository queries units table & populates _categoryCache)
      ↓
Provider (e.g. ConverterProvider requests units for selected category)
      ↓
Widget (e.g. ConverterScreen renders unit dropdowns and updates UI)
```

---

## 4. Repository Pattern & Cache Behavior

Each repository is a thread-safe singleton managing specific data domains:

1. **Singleton Pattern**: Access via `RepositoryName.instance`.
2. **In-Memory Caching**:
   - First call queries SQLite and stores domain models in memory.
   - Subsequent calls return from memory instantaneously (0 ms database latency).
3. **Read-Only Reference Data**: Reference data (units, categories, currencies, facts) is immutable during runtime.
4. **Cache Invalidation**: Calling `clearCache()` purges the memory cache (used during developer reseeding or dynamic content updates).

---

## 5. Conversion Engine Architecture

* **Service**: `ConversionService` ([`lib/services/conversion_service.dart`](file:///home/marth/Desktop/unit-converter/lib/services/conversion_service.dart))
* **Characteristics**:
  * **100% Pure Stateless Dart Service**.
  * Contains only static mathematical calculation methods.
  * **Zero SQL imports** (`sqflite`, `database_service`).
  * **Zero Repository imports**.
  * **Zero Provider imports**.

```text
UnitModel (from UnitRepository)
      ↓
ConversionService.convert(value, fromUnit, toUnit, category)
      ↓
ConversionResult (result, formattedResult, formula, isValid)
```

---

## 6. Search Architecture

```text
Search UI (stitch_search_bar.dart / HomeScreen)
      ↓
SearchHelper (lib/utils/search_helper.dart)
      ↓
SearchRepository (lib/repositories/search_repository.dart)
      ↓
SqliteSearchBackend (queries search_aliases, categories, units tables)
      ↓
SQLite Database (unit_converter.db)
```

* **Rule**: Search must query SQLite indexed tables (`search_aliases`, `categories`, `units`) during runtime. Searching JSON assets or Dart files during normal app execution is strictly prohibited.
