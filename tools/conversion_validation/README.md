# Conversion Validation Tooling

## Purpose

This Python tooling validates the conversion formulas used by the MS Unit Converter Flutter app. It mirrors the conversion logic from `lib/services/conversion_service.dart` so that correctness can be verified independently, without launching the app or running Flutter tests.

It is **not** part of the app itself — it is a developer-side validation harness. The real app remains Flutter/Dart.

## How to Run

```bash
# From the project root:
python3 tools/conversion_validation/validate_units.py
```

Exit code **0** = all cases pass.  
Exit code **>0** = one or more cases failed (details printed).

You can also point to a custom JSON file:

```bash
python3 tools/conversion_validation/validate_units.py my_cases.json
```

## How It Works

1. `sample_cases.json` defines known input/output pairs for all 20 categories.
2. `validate_units.py` implements the same conversion formulas as the Dart `ConversionService` (linear multiplier, temperature, fuel economy, cooking groups, shoe size, clothing size, number base, typography).
3. Each case is checked against its expected value within the specified tolerance.
4. A summary is printed to stdout; exit code signals pass/fail.

## How to Add New Cases

Add an entry to the `"cases"` array in `sample_cases.json`:

```json
{
  "category": "length",
  "fromUnit": "Meter",
  "toUnit": "Foot",
  "input": 1,
  "expected": 3.28084,
  "tolerance": 1e-4,
  "description": "1 m ≈ 3.28084 ft"
}
```

For expected-failure cases (e.g., cooking cross-group), set `"shouldFail": true` and omit the expected value:

```json
{
  "category": "cooking",
  "fromUnit": "Cup (US)",
  "toUnit": "Gram",
  "input": 1,
  "expected": null,
  "shouldFail": true,
  "description": "Cross-group volume→weight should fail"
}
```

Unit names must match those in `lib/data/units_data.dart` exactly.

## Why Python?

- **Zero dependencies** — Python stdlib only (`json`, `math`, `sys`, `os`).
- **Fast** — no app build, no emulator, no compile step.
- **Portable** — works on any machine with Python 3.8+.
- **Independent** — validates without touching the Flutter project's build system.

## File Layout

```
tools/conversion_validation/
├── README.md
├── sample_cases.json          # Known expected values for all categories
└── validate_units.py          # Validation script (stdlib only)
```

## Updating the Unit Database

If `lib/data/units_data.dart` is modified (new units, changed toBase values), update the `_UNITS` dictionary at the top of `validate_units.py` to match, and add corresponding sample cases.
