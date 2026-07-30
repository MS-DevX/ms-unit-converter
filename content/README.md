# Phase 2 JSON Content Format

This directory will contain the JSON source of truth for all static reference data
when the migration from Dart data files is complete.

## Current Status: Phase 1

The database is seeded at runtime from Dart data files:

```
lib/data/units_data.dart        → units + categories
lib/data/currencies_data.dart   → currencies
lib/data/collections_data.dart  → collections
lib/data/did_you_know.dart      → educational facts
lib/data/converter_config.dart  → UI config (icon/gradient per category)
assets/data/unit_information.json → unit educational info
```

## Phase 2 JSON Files (planned)

When Phase 2 is implemented, these JSON files will replace the Dart data files:

```
content/
├── categories.json           ← category metadata + display config
├── units.json               ← all units organized by category
├── currencies.json          ← 170+ ISO currencies with fallback rates
├── collections.json         ← 9 predefined collections
├── educational_facts.json   ← "Did You Know" facts
├── search_aliases.json      ← keyword → canonical name mappings
├── unit_information.json    ← unit educational info (replaces assets/data/)
└── README.md                ← this file
```

---

## Phase 2 JSON Schema Reference

### categories.json

```json
{
  "length": {
    "display_name": "Length",
    "description": "Measure of distance between two points.",
    "group": "Everyday",
    "emoji": "📏",
    "icon_codepoint": 57368,
    "icon_font_family": "MaterialIcons",
    "gradient_start": "4281544702",
    "gradient_end": "4280085666",
    "display_order": 0,
    "is_featured": true,
    "search_weight": 150
  }
}
```

### units.json

```json
{
  "length": [
    {
      "name": "Meter",
      "symbol": "m",
      "to_base": 1.0,
      "is_special_case": false,
      "display_order": 0
    },
    {
      "name": "Kilometer",
      "symbol": "km",
      "to_base": 1000.0,
      "is_special_case": false,
      "display_order": 1
    }
  ]
}
```

### currencies.json

```json
[
  {
    "iso_code": "USD",
    "name": "US Dollar",
    "symbol": "$",
    "flag": "🇺🇸",
    "country": "United States",
    "decimal_digits": 2,
    "fallback_rate_to_usd": 1.0,
    "is_pinned": true,
    "pin_order": 0
  }
]
```

### collections.json

```json
[
  {
    "id": "everyday",
    "name": "Everyday",
    "emoji": "🏠",
    "description": "Most commonly used converters for daily life.",
    "display_order": 0,
    "categories": ["length", "weight", "temperature", "volume", "area", "speed"]
  }
]
```

### educational_facts.json

```json
[
  {
    "emoji": "📏",
    "fact": "The meter was originally defined as one ten-millionth of the distance from the equator to the North Pole.",
    "category_id": "length",
    "display_order": 0
  }
]
```

### search_aliases.json

```json
[
  { "keyword": "metre",   "canonical": "Meter",     "priority": 10 },
  { "keyword": "meters",  "canonical": "Meter",     "priority": 10 },
  { "keyword": "km",      "canonical": "Kilometer", "priority": 20 },
  { "keyword": "lbs",     "canonical": "Pound",     "priority": 20 }
]
```

### unit_information.json (replaces assets/data/unit_information.json)

```json
{
  "meter": {
    "symbol": "m",
    "definition": "The SI base unit of length...",
    "history": "Originally defined in 1799...",
    "used_for": "Engineering, physics, everyday measurement",
    "examples": ["A door is about 2 meters tall", "A football field is about 100 meters"]
  }
}
```

---

## How to Add New Content (Phase 2)

### Adding a new unit to an existing category

1. Open `content/units.json`
2. Find the category key (e.g. `"length"`)
3. Add a new entry:
   ```json
   {
     "name": "Parsec",
     "symbol": "pc",
     "to_base": 3.085677581e16,
     "is_special_case": false,
     "display_order": 20
   }
   ```
4. Run `dart run tools/validate_content.dart`
5. Run `dart run tools/build_database.dart`
6. Commit both the JSON change and the regenerated `.db` file

### Adding a new category

1. Add the category name to `lib/data/units_data.dart` (enum `UnitCategory`)
2. Add category metadata to `content/categories.json`
3. Add units to `content/units.json`
4. Add UI config to `lib/data/converter_config.dart` (icon/gradient)
5. Add the category to [ConversionService] if it requires special formulas
6. Validate, build, commit

### Adding new educational facts

1. Open `content/educational_facts.json`
2. Add entries (no rebuild required if category_id is null or references an existing category)
3. Run `dart run tools/build_database.dart`

### Adding a new currency

1. Open `content/currencies.json`
2. Add an entry with a valid ISO 4217 code
3. Run `dart run tools/validate_content.dart` (validates ISO code format)
4. Run `dart run tools/build_database.dart`

---

## Validation Rules

All content runs through these checks before the database is generated:

| Rule | Description |
|---|---|
| Unique IDs | No duplicate category IDs, unit names per category, currency ISO codes |
| Required fields | No empty name, symbol, display_name, iso_code, etc. |
| Numeric validity | `to_base` is finite, non-zero, non-NaN |
| ISO codes | Currency codes are exactly 3 uppercase ASCII letters |
| Foreign keys | Collection items reference existing categories |
| Completeness | All 53 UnitCategory enum values have ≥ 2 units |
| Circular refs | No circular relationships in related_content |

---

## Troubleshooting

### "Database not ready" error on app start
- Ensure `DatabaseService.instance.initialize()` is called before `runApp()` in `main.dart`

### Units not showing after content update
- Increment `_contentVersion` in `lib/database/database_service.dart`
- The app will auto-reseed on next launch

### Search not finding results
- Check `search_aliases.json` / `_searchAliasMap` in `DatabaseService`
- Clear app data to force a reseed

### Build tool fails validation
- Read the error output — each rule violation includes the file and entry key
- Fix the content file and re-run
