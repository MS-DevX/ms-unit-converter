# MS Unit Converter

An Android unit converter app by **MS DevX** — clean, fast, offline-capable.

**Package:** `com.msdevx.unitconverter`
**Platform:** Android (Play Store), iOS scaffolding exists but not yet shipped.

---

## Features

### 15 conversion categories

Length, Weight, Temperature, Area, Volume, Speed, Data, Time, Angle, Energy,
Power, Pressure, Force, Frequency, Fuel Economy, Cooking, Number Base, Typography,
Clothing Size, Shoe Size.

### Real-time conversion

Result updates on every keystroke — no Calculate button. Max 8 significant digits.

### Currency converter

Live exchange rates via [Frankfurter.app](https://api.frankfurter.dev) (free, no API key).
53 currencies with search, pinned quick pairs, and offline fallback rates.

### Compass

Tilt-compensated magnetic compass using device sensors. Optional GPS coordinates
and true north via location permission (user-prompted, denied gracefully).

### History

Last 20 conversions, persisted across sessions. Swipe to delete individual entries
or clear all.

### Dark mode

System default, overridable to Light or Dark in Settings.

### Monetization

Free with a single App Open Ad on cold start (4-hour cooldown). \$1.99 one-time
in-app purchase removes ads permanently.

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter (stable 3.x) |
| Language | Dart 3 (null-safe) |
| State management | Provider |
| Ads | Google Mobile Ads (App Open Ad only) |
| IAP | in_app_purchase (Play Billing) |
| Storage | SharedPreferences |
| HTTP | dart:http (via CurrencyService) |
| Sensors | sensors_plus |
| Min SDK | 21 (Android 5.0) |

---

## Project Structure

```
lib/
  main.dart                  # Entry point, provider tree, IAP init
  core/                      # Theme, colors, constants
  data/                      # Unit & currency definitions
  models/                    # UnitModel, CurrencyModel, ConversionResult, HistoryEntry
  providers/                 # ChangeNotifier providers (converter, currency, history, settings)
  services/                  # Conversion, currency, history, AdMob, IAP, compass
  screens/                   # Splash, MainShell, Home, Converter, Currency, Compass, History, Settings
  widgets/                   # Reusable UI components
  utils/                     # Formatters, validators
test/                        # 297+ unit tests
```

---

## Quick Start

```bash
flutter pub get
flutter run
```

---

## Testing

```bash
flutter test
```

---

## License

Proprietary — MS DevX.
