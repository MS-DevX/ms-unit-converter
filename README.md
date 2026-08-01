# Unit Converter

An Android offline productivity toolkit by **MS DevX** — fast, clean, and fully offline-capable.

**Package:** `com.msdevx.unitconverter`  
**Version:** `2.3.0+7`  
**Platform:** Android (Play Store first).  

---

## Features

### 60 Unit Categories & 480 Conversion Units (100% Educational Coverage)

Length, Weight, Temperature, Area, Volume, Speed, Data, Time, Angle, Energy, Power, Pressure, Force, Frequency, Fuel Economy, Cooking, Shoe Size, Clothing Size, Number Base, Typography, Voltage, Current, Resistance, Capacitance, Inductance, Electric Charge, Conductance, Illuminance, Luminous Flux, Luminous Intensity, Luminance, Specific Heat, Thermal Conductivity, Thermal Resistance, Heat Flux Density, Torque, Momentum, Angular Velocity, Density, Surface Tension, Kinematic Viscosity, Dynamic Viscosity, Acceleration, Flow Rate, Mass Flow Rate, Radioactivity, Radiation Dose, Radiation Exposure, Astronomical Length, Pace, Heart Rate, Blood Sugar, Blood Pressure, BMI, Percentage Ratio, Sound Level, Concentration, Magnetic Field, Magnetic Flux, Wavenumber.

- Real-time conversion — result updates on every keystroke. No Calculate button.
- Max 8 significant digits, no scientific notation for everyday values.
- Pure logic conversion engine supporting linear ratio factors, special-case formulas, and compound units.
- **100% Unit Information Coverage**: All 480 units include definition, symbol, history, common uses, typical ranges, and mistakes.

### 742 Educational Facts & 242 Knowledge Graph Edges

- **742 Educational Facts**: Rotating fact cards across physics, engineering, astronomy, acoustics, medical vitals, and chemistry.
- **242 Entity Edges**: Knowledge graph connecting categories, units, and real-world facts for smart contextual recommendations.

### 779 Search Aliases

- High-density search engine with **779 search aliases** supporting plurals, US/UK spellings, SI symbols, abbreviations, and common typos.

### 32 Curated Collections (207 Items)

Quick access to themed converter groups:
- Everyday, Student, Developer, Engineering, Cooking, Travel, Fitness, Science, Electrical, Construction, Aviation, Chemistry, Maritime, HVAC, Baking, Meteorology, Athletics, Mechanics, Electronics, Typography & Design, Optics & Photonics, Nutrition, Quantum, and more.

### 170+ Currency Converter

- Live exchange rates via [Frankfurter.app](https://api.frankfurter.dev) — free, no API key required.
- **170+ ISO-4217 currencies** supported with flags, symbols, names, and country mappings.
- **Cached/offline behavior:** Exchange rates cached to `SharedPreferences` on each successful fetch. Shows relative timestamp (*"Just now"*, *"2 hours ago"*, *"Yesterday"*) and falls back seamlessly to bundled offline exchange rates when network is unavailable.

### Custom Converters

User-created ratio-based custom converter groups (e.g., *1 Box = 24 Bottles*, *1 Carton = 12 Packs*). Supports full local CRUD.

### Conversion Notes

Create, edit, search, and manage personal notes and formula reminders stored locally on device.

### Global Pull-to-Refresh (Material 3)

Hard swipe-down gesture across Home, History, Currency, Collections, Custom Converters, and Notes to reload local data, recalculate insights, rebuild search indices, and attempt silent currency exchange rate background updates.

### Compass & Bubble Level

- Tilt-compensated magnetic compass using device magnetometer + accelerometer.
- GPS declination lookup for True North alignment.
- Live pitch/roll gauge bubble level with tap-to-calibrate feature.

### Smart Natural Language Parser

Parses natural language conversion queries offline (e.g., `"10 km to miles"`, `"100 usd to pkr"`, `"5 feet 9 inches to cm"`).

---

## Tech Stack & Architecture

| Layer | Choice |
|-------|--------|
| Framework | Flutter (3.x stable, SDK ^3.12.0) |
| Language | Dart 3 (null-safe) |
| Architecture | Pre-Populated SQLite Database + Repository Pattern |
| Database Engine | `sqflite` (Schema v1, Content v2.3.5) |
| State Management | Provider (^6.1.0) |
| Monetization | App Open Ad (cold start / warm start cooldown cap) |
| Storage | `SharedPreferences` & Pre-Populated SQLite (`assets/database/unit_converter.db`) |
| HTTP | `dart:http` (CurrencyService via Frankfurter.app) |
| Sensors | `sensors_plus`, `flutter_compass`, `geolocator`, `geomag` |
| Min SDK | 21 (Android 5.0) |
| Target SDK | 37 (Android 17) |

---

## Developer CLI & Diagnostic Tools

The codebase includes standalone CLI diagnostic tools in `tools/`:

```bash
# 1. Database Health Auditor (Foreign Keys, PRAGMAs, Row Counts)
dart run tools/database_health.dart

# 2. Content Quality Auditor (Coverage, Alias Density, Graph Score)
dart run tools/content_quality.dart

# 3. Developer Performance Benchmark (Cold-Load Latency & Query Speeds)
dart run tools/performance_audit.dart
```

---

## How to Run & Test

```bash
# Install dependencies
flutter pub get

# Static code analysis
flutter analyze

# Run full unit and widget test suite (339 tests)
flutter test

# Run app
flutter run
```

---

## How to Build Release APK & Bundle

```bash
# Build release APK
flutter build apk --release

# Build Play Store App Bundle (.aab)
flutter build appbundle --release
```

---

## License

Proprietary — **MS DevX**. All rights reserved.
