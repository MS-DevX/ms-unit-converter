# MS Unit Converter

An Android unit converter by **MS DevX** — clean, fast, offline-capable.

**Package:** `com.msdevx.unitconverter`
**Platform:** Android (Play Store). iOS scaffolding exists but not yet shipped.

---

## Features

### 20 unit categories

Length, Weight, Temperature, Area, Volume, Speed, Data, Time, Angle, Energy,
Power, Pressure, Force, Frequency, Fuel Economy, Cooking, Shoe Size,
Clothing Size, Number Base, Typography.

Real-time conversion — result updates on every keystroke. No Calculate button.
Max 8 significant digits, no scientific notation for everyday values.

### Currency converter

Live exchange rates via [Frankfurter.app](https://api.frankfurter.dev) — free,
no API key required. 53 currencies supported. Pinned quick pairs for PKR, USD,
EUR, GBP, JPY, AED, SAR, INR. Search by code, name, or symbol.

**Cached/offline behaviour:** Rates are cached to SharedPreferences on each
successful fetch. On subsequent launches the app reads the cached rates
immediately and refreshes in the background. When offline, the app falls back
to hardcoded approximate rates for all 53 currencies. A "Rates by Frankfurter"
label is shown below the status row.

### Compass with true north

Tilt-compensated magnetic compass using accelerometer + magnetometer.
Optional GPS coordinates and true north via location permission.

**GPS denial behaviour (current session):** If the user denies the location
permission, the app does **not** re-prompt again in the same session.
The magnetic compass continues to work normally. All other app features remain
fully accessible.

### Bubble level

A built-in bubble level using the device accelerometer. Shows pitch and roll
angles with a live bubble gauge. Includes a calibrate/reset feature and
auto-centre assist.

### Smart paste parser

When pasting text containing a number followed by a unit abbreviation
(e.g. `42km` or `100°F`), the app auto-detects the category, fills the
input value, and selects the source unit — no manual scrolling needed.

### History

Last 20 conversions, persisted across sessions. Newest first.
Swipe to delete individual entries or clear all.

### Favorites

Mark any conversion category as a favourite. Favourites appear at the top of
the home screen grid for quick access.

### Settings

- Theme toggle: System (default) / Light / Dark
- Decimal precision: Auto / 2 / 4 / 6 / 8 decimals
- Remove ads via \$1.99 one-time in-app purchase
- Restore previous purchases
- Privacy policy link
- Clear history and clear favourites

### Monetisation

Free with a single App Open Ad on cold start (4-hour cooldown).
\$1.99 one-time in-app purchase removes ads permanently.
No banners, no interstitials, no rewarded ads.

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter (stable 3.x) |
| Language | Dart 3 (null-safe) |
| State management | Provider |
| Ads | Google Mobile Ads (App Open Ad only) |
| IAP | `in_app_purchase` (Play Billing) |
| Storage | `SharedPreferences` |
| HTTP | `dart:http` (via CurrencyService) |
| Sensors | `sensors_plus` |
| Min SDK | 21 (Android 5.0) |
| Currency API | Frankfurter.dev (free, no key) |
| Validation tooling | Python (`tools/conversion_validation/validate_units.py`) |
| Docs tooling | Python (`tools/docs_export/build_release_pdf.py`) |
| CI | GitHub Actions (planned) |

---

## How to run

```bash
flutter pub get
flutter run
```

---

## How to test

```bash
flutter analyze
flutter test
python tools/conversion_validation/validate_units.py
```

---

## How to build — debug

```bash
flutter build apk --debug --target-platform android-arm64
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

---

## How to build — release (local)

1. Ensure `android/key.properties` exists with placeholder values:

```
storePassword=<store-password>
keyPassword=<key-password>
keyAlias=<key-alias>
storeFile=upload-keystore.jks
```

2. Place the release keystore at `android/app/upload-keystore.jks`.
3. Run:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

> The keystore and key.properties are gitignored. Restore from a secure backup
> on a fresh clone.

---

## Security notes

- All conversions happen on-device. No data is transmitted to any server.
- Currency rates are fetched from a free public API (Frankfurter). No API key,
  no authentication, no user-identifying headers.
- Location data (compass true north / GPS) stays on the device. It is never sent
  to any server.
- The only network requests are:
  - App Open Ad (Google Mobile Ads SDK)
  - Currency rate fetch (Frankfurter API)
  - In-app purchase verification (Google Play Billing)
- Premium status and all preferences are stored locally in SharedPreferences.
- No analytics, no crash reporting, no telemetry SDK is included.

---

## Contribution / agent notes

This project uses [OpenCode](https://opencode.ai) for AI-assisted development.
See `AGENTS.md` for the full agent ruleset.

Key conventions:
- Null-safe Dart 3 with `const` constructors where possible.
- `///` doc comments on every public class and function.
- Uses `debugPrint()` — never `print()`.
- State management via `Provider` + `ChangeNotifier`.
- All changes must pass `flutter analyze` (zero issues) and `flutter test`.

---

## License

Proprietary — MS DevX.
