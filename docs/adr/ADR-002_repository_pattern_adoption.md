# ADR-002: Adoption of Repository Pattern with In-Memory Caching

* **Status**: Accepted
* **Date**: 2026-07-30
* **Target Version**: v2.3.0

## Context

Directly embedding SQL queries inside Flutter UI widgets or state providers leads to code duplication, high query latency, tight coupling, and difficult testing.

## Decision

We adopted the **Repository Pattern** with singleton instances (`UnitRepository`, `CategoryRepository`, `CurrencyRepository`, `CollectionRepository`, `SearchRepository`, `UnitInformationRepository`, `EducationalFactsRepository`).

## Rationale

1. **Decoupling**: UI and Providers interact only with repository interfaces (`List<UnitModel>`, `List<CategoryRow>`), remaining completely ignorant of SQLite or SQL syntax.
2. **In-Memory Caching**: Repositories cache query results in RAM on first load. Subsequent calls return cached objects in 0 ms, providing instant UI response.
3. **Future Migration Isolation**: Allows migrating user data (history, notes, favorites) to SQLite in future releases without modifying public provider or widget APIs.
4. **Backend Swapability**: Backend search implementation can be swapped (e.g. `SqliteSearchBackend` to `Fts5SearchBackend`) inside `SearchRepository` with zero ripple effect on UI components.
