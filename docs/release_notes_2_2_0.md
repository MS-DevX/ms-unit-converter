# Release Notes — Version 2.2.0+6

**Release Date:** July 25, 2026  
**Developer:** MS DevX (`com.msdevx.unitconverter`)  
**Platform:** Android (Google Play Store)  

---

## 🚀 Overview of Updates in v2.2.0+6

Version 2.2.0+6 elevates **Unit Converter** into a complete, professional offline productivity toolkit. This release completes all feature expansions, UI/UX refinements, accessibility enhancements, performance optimizations, and production hardening.

---

## Key Features & Refinements

### 1. Expanded Unit & Currency Engine
- **53 Conversion Categories**: Length, Weight, Temperature, Area, Volume, Speed, Data, Time, Angle, Energy, Power, Pressure, Force, Frequency, Fuel Economy, Cooking, Shoe Size, Clothing Size, Number Base, Typography, Voltage, Current, Resistance, Capacitance, Inductance, Electric Charge, Conductance, Illuminance, Luminous Flux, Luminous Intensity, Luminance, Specific Heat, Thermal Conductivity, Thermal Resistance, Heat Flux Density, Torque, Momentum, Angular Velocity, Density, Surface Tension, Kinematic Viscosity, Dynamic Viscosity, Acceleration, Flow Rate, Mass Flow Rate, Radioactivity, Radiation Dose, Radiation Exposure, Astronomical Length, Pace, Heart Rate, Blood Sugar, Blood Pressure, BMI, Percentage Ratio, Sound Level, Concentration, Magnetic Field, Magnetic Flux, Wavenumber.
- **170+ ISO-4217 Currencies**: Supported with full country mapping, symbols, flags, decimal precision, and Frankfurter.app API integration.
- **Offline Currency Fallback**: Automatic fallback to bundled offline rates when network is unavailable, displaying relative timestamps (*"Last updated: 2 hours ago"*, *"Using bundled exchange rates"*).

### 2. Curated Collections & Custom Converters
- **9 Curated Collections**: Student, Developer, Engineering, Cooking, Travel, Fitness, Science, Electrical, Everyday.
- **Linear Ratio Custom Converters**: User-created ratio groups (e.g., *1 Box = 24 Bottles*).
- **Conversion Notes**: Full offline CRUD for saved notes and calculation reminders.

### 3. Global Pull-to-Refresh (`RefreshService`)
- Centralized Material 3 `RefreshIndicator` gesture across Home, History, Currency, Collections, Custom Converters, and Notes.
- Refreshes local database, provider states, calculation insights, search indices, and attempts background exchange rate updates concurrently without blocking the UI.
- Minimum 800ms animation duration for a smooth experience.

### 4. UI Polish & Material 3 Alignment
- **Floating Rounded Search Bar**: Enforced 24dp horizontal margins, 16dp corner radius, and floating card appearance across all search inputs.
- **Flat M3 Filter Chips**: Removed shadows and dividers behind filter chip rows on Home, History, and Favorites screens.
- **Theme System**: Seamless dark (`#0B1220` background, `#141D2E` surface) and light theme rendering with optional Cosmic Glassmorphic dark mode.

### 5. Quality Assurance & Performance
- **Static Analysis**: `flutter analyze` passed with 0 errors, 0 warnings, and 0 lints.
- **Test Suite**: `flutter test` passed 290/290 unit and widget tests.
- **Release Package**: Verified compilation of `app-release.apk` (57.7 MB).

---

## 🛠️ Summary of Changed Files Today
- `pubspec.yaml`
- `README.md`
- `PROJECT_REFERENCE.md`
- `AGENTS.md`
- `lib/services/refresh_service.dart`
- `lib/providers/currency_provider.dart`
- `lib/screens/currency_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/history_screen.dart`
- `lib/screens/collection_screen.dart`
- `lib/screens/custom_converter_screen.dart`
- `lib/screens/notes_screen.dart`
- `lib/widgets/stitch_search_bar.dart`
- `lib/widgets/category_chip_bar.dart`
- `lib/widgets/did_you_know_card.dart`
- `lib/widgets/insights_banner.dart`
- `lib/widgets/unit_search_dialog.dart`
- `docs/release_notes_2_2_0.md`
