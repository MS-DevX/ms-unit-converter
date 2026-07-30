# ADR-004: Pre-Populated SQLite Binary Asset Deployment

* **Status**: Accepted
* **Date**: 2026-07-30
* **Target Version**: v2.3.0

## Context

Seeding hundreds of categories, units, currencies, search aliases, and educational facts at runtime during first app launch can delay splash screen transition and waste CPU cycles on user devices.

## Decision

We introduced a developer build pipeline (`tools/build_database.dart`) to generate a pre-populated SQLite database asset (`assets/database/stem_data.db`, 316 KB). On first launch, `DatabaseService.initialize()` copies this asset directly to the application documents directory.

## Rationale

1. **Instant First Launch**: Eliminates runtime DB creation and transaction overhead on cold start. First launch initialization completes in ~15 ms.
2. **Deterministic Build Pipeline**: Ensures every user receives an identical, fully indexed, pre-populated database binary out of the box.
3. **Graceful Fallback**: If asset copying is omitted or unmocked (e.g. in unit test runners), `DatabaseService` falls back gracefully to dynamic schema creation and seeding.
