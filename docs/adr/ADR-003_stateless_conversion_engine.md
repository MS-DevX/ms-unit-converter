# ADR-003: Pure Stateless Conversion Engine Architecture

* **Status**: Accepted
* **Date**: 2026-07-30
* **Target Version**: v2.3.0

## Context

Unit conversion mathematics must be fast, perfectly accurate, deterministic, and isolated from database operations or UI state changes.

## Decision

We maintained `ConversionService` ([`lib/services/conversion_service.dart`](file:///home/marth/Desktop/unit-converter/lib/services/conversion_service.dart)) as a **100% pure, stateless Dart class** with static calculation methods only.

## Rationale

1. **Zero Database Overhead**: Math operations execute purely in memory without waiting for disk or database I/O.
2. **Determinism & Testability**: Every conversion function produces identical outputs for identical inputs, enabling exhaustive unit testing (over 300 unit tests).
3. **Clean Architecture**: `ConversionService` has zero dependencies on `sqflite`, repositories, or Flutter UI providers.
