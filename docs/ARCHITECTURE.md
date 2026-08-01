# System Architecture — MS Unit Converter

## Overview
MS Unit Converter is a offline-first Android application built with Flutter & Dart. It relies on a pre-populated SQLite asset database (`assets/database/unit_converter.db`) as its single runtime source of truth for reference data.

---

## Architectural Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│   (Screens, NavigationShell, Glassmorphic Widgets, UI)  │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    Provider / State Layer               │
│   (ChangeNotifier per feature: ConverterProvider, etc.) │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    Repository Layer                     │
│   (BaseRepository<T, ID> implementations with caching)  │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    Database Layer                       │
│   (DatabaseService, sqflite, SQLite Asset Binary)       │
└─────────────────────────────────────────────────────────┘
```

---

## Core Principles
1. **Offline First**: Zero internet connection required for core conversions, compass, level, notes, and facts.
2. **Single Source of Truth**: All reference data (categories, units, facts, search aliases, collections) is loaded from SQLite.
3. **Repository Pattern**: Providers and widgets NEVER query SQL directly. All queries pass through `BaseRepository<T, ID>` implementations with in-memory caching.
4. **Pure Logic Conversion Engine**: `ConversionService` is stateless and operates solely on `UnitModel` instances. No SQL code enters the math engine.
5. **Zero Technical Debt**: Code passes `flutter analyze` with 0 warnings/errors and maintains 100% test coverage for core repositories.
