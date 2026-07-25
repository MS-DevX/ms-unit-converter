# Unit Converter

An Android offline productivity toolkit by **MS DevX** — fast, clean, and fully offline-capable.

**Package:** `com.msdevx.unitconverter`  
**Version:** `2.2.0+6`  
**Platform:** Android (Play Store first).  

---

## Features

### 53 Unit Categories & 300+ Units

Length, Weight, Temperature, Area, Volume, Speed, Data, Time, Angle, Energy, Power, Pressure, Force, Frequency, Fuel Economy, Cooking, Shoe Size, Clothing Size, Number Base, Typography, Voltage, Current, Resistance, Capacitance, Inductance, Electric Charge, Conductance, Illuminance, Luminous Flux, Luminous Intensity, Luminance, Specific Heat, Thermal Conductivity, Thermal Resistance, Heat Flux Density, Torque, Momentum, Angular Velocity, Density, Surface Tension, Kinematic Viscosity, Dynamic Viscosity, Acceleration, Flow Rate, Mass Flow Rate, Radioactivity, Radiation Dose, Radiation Exposure, Astronomical Length, Pace, Heart Rate, Blood Sugar, Blood Pressure, BMI, Percentage Ratio, Sound Level, Concentration, Magnetic Field, Magnetic Flux, Wavenumber.

- Real-time conversion — result updates on every keystroke. No Calculate button.
- Max 8 significant digits, no scientific notation for everyday values.
- Pure logic conversion engine supporting linear ratio factors, special-case formulas, and compound units.

### 170+ Currency Converter

- Live exchange rates via [Frankfurter.app](https://api.frankfurter.dev) — free, no API key required.
- **170+ ISO-4217 currencies** supported with flags, symbols, names, and country mappings.
- **Cached/offline behavior:** Exchange rates cached to `SharedPreferences` on each successful fetch. Shows relative timestamp (*"Just now"*, *"2 hours ago"*, *"Yesterday"*) and falls back seamlessly to bundled offline exchange rates when network is unavailable (*"Using bundled exchange rates"*).

### Curated Collections (9 Predefined)

Quick access to themed converter groups:
- 📚 Student
- 👨‍💻 Developer
- 👷 Engineering
- 🍳 Cooking
- ✈️ Travel
- 🏋️ Fitness
- 🧪 Science
- ⚡ Electrical
- 🛠️ Everyday

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

### Dynamic & Static App Shortcuts

Dynamic launcher shortcuts updating automatically based on user's recent converter usage via `quick_actions`.

### History & Favorites

- Remembers last 50 conversion entries, newest first, persisted locally.
- Pin or favorite any of the 53 conversion categories for instant home access.

### Settings & Themes

- System / Dark / Light theme options with optional Cosmic Glassmorphic mode.
- User profile name customization.
- Configurable decimal precision (Auto, 2, 4, 6, 8 decimals).
- Play Store in-app update check integration.

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter (3.x stable, SDK ^3.12.0) |
| Language | Dart 3 (null-safe) |
| State Management | Provider (^6.1.0) |
| Architecture | Feature-First / Clean Provider Architecture |
| Monetization | App Open Ad (cold start / warm start cooldown cap) |
| Storage | `SharedPreferences` |
| HTTP | `dart:http` (CurrencyService via Frankfurter.app) |
| Sensors | `sensors_plus`, `flutter_compass`, `geolocator`, `geomag` |
| Min SDK | 21 (Android 5.0) |
| Target SDK | 37 (Android 17) |

---

## How to Run & Test

```bash
# Install dependencies
flutter pub get

# Static code analysis
flutter analyze

# Run full unit and widget test suite
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
