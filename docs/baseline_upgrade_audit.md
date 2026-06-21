# Baseline Upgrade Audit — MS Unit Converter v2.0.0+2

> Generated: 2026-06-21
> Branch: `upgrade/security-currency-ui-v2-1`
> Tag: `before-security-currency-ui-upgrade`

---

## 1. App Identity

| Field | Value |
|---|---|
| App name | MS Unit Converter |
| Android applicationId / package | `com.msdevx.unitconverter` |
| Current versionName | `2.0.0` (pubspec.yaml:19) |
| Current versionCode | `2` (pubspec.yaml:19) |
| Android minSdk | `flutter.minSdkVersion` → 21 (Android 5.0) |
| Android compileSdk | `flutter.compileSdkVersion` (resolved by Flutter Gradle plugin) |
| Android targetSdk | `flutter.targetSdkVersion` (resolved by Flutter Gradle plugin) |
| Build tools version | `36.1.0` (android/app/build.gradle.kts:19) |
| Namespace | `com.msdevx.unitconverter` (android/app/build.gradle.kts:17) |
| Flutter SDK constraint | `^3.12.0` (pubspec.yaml:21) |

### Signing setup

Release signing is configured in `android/app/build.gradle.kts:36-41`:
- Reads `keyAlias`, `keyPassword`, `storeFile`, `storePassword` from `android/key.properties`
- `signingConfigs.release` is applied to `buildTypes.release`
- Release build requires `android/key.properties` + keystore file at the path defined in properties
- Debug builds work without `key.properties`
- ProGuard/R8 enabled for release: `isMinifyEnabled = true`, `isShrinkResources = true`

**⚠️ CRITICAL — Signing passwords exposed in documentation:**
- `RELEASE_GUIDE.md:125-126`: contained `storePassword` and `keyPassword` with a shared plaintext credential
- `PROJECT_REFERENCE.md:354,361` (approximate): duplicated the same plaintext passwords
- Both files have now been redacted to use `<STORE_PASSWORD>` and `<KEY_PASSWORD>` placeholders
- These values were committed to git history; rotation of credentials is recommended

---

## 2. Current Architecture

```
lib/
├── main.dart                          # Entry point — Provider tree, IAP init, SplashScreen
├── core/
│   ├── theme.dart                     # AppTheme — light + dark ThemeData (Material 3)
│   ├── constants.dart                 # AppConstants — ad IDs, IAP ID, URLs, storage keys
│   └── colors.dart                    # AppColors — all color tokens as static const
├── data/
│   ├── units_data.dart                # UnitCategory enum (20 categories) + unitsData map
│   └── currencies_data.dart           # allCurrencies list (30 currencies) + fallbackRatesToUsd
├── models/
│   ├── unit_model.dart                # UnitModel — name, symbol, toBase, isSpecialCase, group
│   ├── currency_model.dart            # CurrencyModel — code, name, symbol, flag, decimalDigits
│   ├── conversion_result.dart         # ConversionResult — success/failure, formatted, formula
│   └── history_entry.dart             # HistoryEntry — id, category, units, value, result, timestamp
├── providers/
│   ├── converter_provider.dart        # ConverterProvider — category, units, input, result state
│   ├── currency_provider.dart         # CurrencyProvider — source currency, rates, all-results list
│   ├── history_provider.dart          # HistoryProvider — load, add, remove, clear history
│   └── settings_provider.dart         # SettingsProvider — themeMode, isPremium
├── services/
│   ├── conversion_service.dart        # Pure conversion logic (linear + all special cases)
│   ├── currency_service.dart          # Frankfurter.app fetch, cache, fallback, convert
│   ├── history_service.dart           # SharedPreferences CRUD for history entries
│   ├── admob_service.dart             # AppOpenAd singleton — load, show, cooldown, dispose
│   ├── iap_service.dart               # In-app purchase — init, purchase, restore, verify
│   └── compass_service.dart           # Sensor fusion — accelerometer + magnetometer + GPS
├── screens/
│   ├── splash_screen.dart             # 1500ms splash — brand + ad init + premium check
│   ├── main_shell.dart                # Bottom nav (5 tabs) + PageView with reduced-sensitivity swipe
│   ├── home_screen.dart               # Category grid with gradient cards + quick presets
│   ├── converter_screen.dart          # Full converter — input bar, swap, all-unit results list
│   ├── currency_screen.dart           # Live FX rates — source dropdown, all-currency results
│   ├── compass_screen.dart            # Live magnetic heading + GPS coordinates + compass rose
│   ├── history_screen.dart            # Last 20 conversions — swipe/delete, clear all
│   └── settings_screen.dart           # Theme toggle, premium IAP, about, rate/share/privacy
├── widgets/
│   ├── category_chip_bar.dart         # Horizontal scrollable category selector chips
│   ├── converter_input_bar.dart       # Value input + source unit picker
│   ├── converter_connector_bar.dart   # Gradient bar with swap button + pulsing arrow
│   ├── conversion_results_list.dart   # Wrapper that maps results to ConversionResultRows
│   ├── conversion_result_row.dart     # Single result row — copy, share, animated value
│   ├── compass_rose.dart              # Custom-painted rose — needle, 16 ticks, N/E/S/W labels
│   ├── swap_button.dart               # Animated rotate swap button (180°, easeInOutBack)
│   ├── unit_dropdown.dart             # Styled dropdown for unit selection
│   ├── unit_search_dialog.dart        # Full-screen searchable unit picker
│   ├── tactile_input_bar.dart         # Tactile keypad input bar
│   ├── tactile_keypad.dart            # Numpad for tactile input
│   └── converter_connector_bar.dart   # Visual connector between from/to
└── utils/
    └── formatters.dart                # formatResult (8 sig digits), formatInput (sanitize)
```

---

## 3. Existing Screens / Tabs

### Home Screen (`lib/screens/home_screen.dart`)
- Bottom nav index 0
- Category grid with gradient cards (2-column layout)
- Quick preset conversions below grid (3 per category)
- Scrollable, dark/light theme support
- Working as designed

### Currency Screen (`lib/screens/currency_screen.dart`)
- Bottom nav index 1
- Large text input (default "1"), source currency dropdown
- Quick-source chips: USD, EUR, GBP, JPY, CNY, INR, AUD, CAD, CHF, BRL
- Scrollable list showing all 30 currencies with converted values
- Copy-to-clipboard on tap, floating snackbar
- Pull-to-refresh, refresh button in AppBar
- Status indicator: "Updated Xm ago", source rate line
- Working, but 30-entry list is unscrollable without search/filter

### Compass Screen (`lib/screens/compass_screen.dart`)
- Bottom nav index 2
- Full-screen black background
- Direction label (N/NE/E/SE/S/SW/W/NW), large compass rose
- GPS coordinates in DMS format (latitude + longitude)
- Pull-to-refresh recalibrates
- **CRITICAL ISSUE:** Location permission requested on screen open (via `CompassService.start()`)
- **CRITICAL ISSUE:** No "Not Allow" denial flag — permission re-requested every session
- **CRITICAL ISSUE:** Pull-to-refresh re-requests permission after denial

### History Screen (`lib/screens/history_screen.dart`)
- Bottom nav index 3
- Last 20 conversions, newest first
- Swipe to delete, clear all button
- Stored in SharedPreferences as JSON string list
- Working as designed

### Settings Screen (`lib/screens/settings_screen.dart`)
- Bottom nav index 4
- Theme toggle (system → light → dark → system)
- Premium/remove-ads ListTile (purchase or "Thank you" state)
- About section with version, rate, share, privacy link
- Working as designed

---

## 4. Unit Converter

### All 20 categories confirmed in `lib/data/units_data.dart`

| # | Category | Enum value | Special? | Risk |
|---|---|---|---|---|
| 1 | Length | `UnitCategory.length` | No | Low |
| 2 | Weight | `UnitCategory.weight` | No | Low |
| 3 | Temperature | `UnitCategory.temperature` | Yes | Medium — special formula via Celsius intermediate |
| 4 | Area | `UnitCategory.area` | No | Low |
| 5 | Volume | `UnitCategory.volume` | No | Low |
| 6 | Speed | `UnitCategory.speed` | No | Low |
| 7 | Data | `UnitCategory.data` | No | Low |
| 8 | Time | `UnitCategory.time` | No | Low |
| 9 | Angle | `UnitCategory.angle` | No | Low |
| 10 | Energy | `UnitCategory.energy` | No | Low |
| 11 | Power | `UnitCategory.power` | No | Low |
| 12 | Pressure | `UnitCategory.pressure` | No | Low |
| 13 | Force | `UnitCategory.force` | No | Low |
| 14 | Frequency | `UnitCategory.frequency` | No | Low |
| 15 | Fuel Economy | `UnitCategory.fuelEconomy` | Yes | Medium — L/100km reciprocal formula, div-by-zero risk |
| 16 | Cooking | `UnitCategory.cooking` | Yes | Low — volume/weight group separation prevents cross-conversion |
| 17 | Shoe Size | `UnitCategory.shoeSize` | Yes | Medium — lookup tables via CM, 0.5 rounding assumed for all |
| 18 | Clothing Size | `UnitCategory.clothingSize` | Yes | **High — hardcoded men's sizing only, no women's toggle** |
| 19 | Number Base | `UnitCategory.numberBase` | Yes | Medium — radix-based string conversion (no arithmetic operations) |
| 20 | Typography | `UnitCategory.typography` | Yes | Medium — hardcoded 16px base font size for em/rem/percent |

### Where formulas are stored
- `lib/services/conversion_service.dart` — all special-case conversion methods
- `lib/data/units_data.dart` — `toBase` factors for linear conversions
- `lib/providers/converter_provider.dart:158-197` — Number Base conversion logic (**should be in ConversionService**)

### Formula risk areas
1. **Number Base in Provider (HIGH):** `_convertNumberBase()` logic at `ConverterProvider:158` belongs in `ConversionService`. Mixes UI state with conversion logic.
2. **Clothing Size (HIGH):** `_convertClothingSize()` at `ConversionService:233` passes hardcoded `isMen = true` — no support for women's sizing via the public API.
3. **Typography (MEDIUM):** `_convertTypography()` at `ConversionService:277` hardcodes `16.0` as default `baseFontSize`. Provider stores a configurable `_baseFontSize` but service doesn't accept it as parameter.
4. **Fuel Economy (MEDIUM):** `L/100km` uses reciprocal `100 / value` — zero input returns `double.nan` (handled correctly in service tests, but no UI test).
5. **Shoe Size (LOW-MEDIUM):** 0.5 rounding `(result * 2).roundToDouble() / 2` assumes all shoe sizes are half-increment — some markets use whole sizes only.

### UI-based conversion logic that should move into services
- `ConverterProvider._convertNumberBase()` (lines 158-181) — uses radix parsing, returns `ConversionResult` — pure conversion logic with zero UI dependency. Should live in `ConversionService` or a dedicated `NumberBaseService`.
- `ConverterProvider._radixForUnit()` (lines 184-197) — maps unit name to radix int — belongs in data layer or conversion service.

---

## 5. Currency Tab

| Aspect | Status |
|---|---|
| API endpoint | `https://api.frankfurter.app/latest?from=USD` |
| API key required | **No** — free, no-key API |
| Current currencies | **30** (defined in `lib/data/currencies_data.dart`) |
| PKR (Pakistani Rupee) | **❌ Does NOT exist** |
| Gulf/South Asian currencies | **❌ Missing** — AED, SAR, QAR, OMR, BHD, KWD, PKR, LKR, NPR, BDT, VND, EGP, IRR, IQD |
| Cache behavior | SharedPreferences — JSON map of code→rate string; checked for completeness against allCurrencies |
| Timeout behavior | **❌ NO TIMEOUT** — `dart:io` `HttpClient` used without timeout parameter; could hang indefinitely |
| Offline behavior | Falls back to cached rates → hardcoded fallback rates from `fallbackRatesToUsd` (approximate) |
| Error behavior | Shows inline warning text (orange) below status bar; cached or fallback rates used silently |
| UI source chips | 10 hardcoded quick chips (USD, EUR, GBP, JPY, CNY, INR, AUD, CAD, CHF, BRL) |
| UI currency list | All 30 currencies in a scrollable `ListView.separated` — **NO search, NO filter** |
| UI empty state | "Loading rates..." or "Enter an amount to convert" — basic, no guidance |

### Rate conversion formula (CurrencyService:94)
```dart
amount * targetRate / sourceRate
```
Both rates relative to USD. Correct, confirmed.

### Cache completeness check (CurrencyProvider:94-95)
```dart
allCurrencies.every((c) => cached.containsKey(c.code))
```
Coverage check is correct — avoids partial cache.

### Fallback rates
Hardcoded `fallbackRatesToUsd` map (currencies_data.dart:44-75). 30 entries. Rates are approximate/outdated.

---

## 6. Compass Tab

| Aspect | Status |
|---|---|
| Sensors used | Accelerometer + Magnetometer via `sensors_plus` |
| Location usage | GPS for true north correction via WMM declination (GeoMag) |
| Android permissions | `ACCESS_FINE_LOCATION` declared in `AndroidManifest.xml:5` |
| iOS permissions | **❌ No `NSLocationWhenInUseUsageDescription`** in `ios/Runner/Info.plist` — geolocator will crash |
| Fallback behavior | **❌ None** — no unsupported-sensor fallback, no magnetic-only fallback if GPS denied |
| Listener disposal | `stop()` cancels all subs + timers ✅; `dispose()` closes stream controllers ✅ |
| Location requested on screen open? | **YES — CRITICAL BUG** — `CompassService.start()` → `_startLocationUpdates()` → `Geolocator.requestPermission()` immediately |
| Location re-requested after denial? | **YES — CRITICAL BUG** — No `_locationDeniedThisSession` flag; pull-to-refresh re-requests |
| Privacy concerns | **HIGH** — User opens compass and gets a location dialog without context or opt-in |
| Calibration help | **❌ None** — no figure-8 prompt, no sensor health indicator |

### Bug analysis
1. `CompassScreen.initState()` → `_startServices()` → `CompassService.instance.start()` → `_startLocationUpdates()` line 86-87 calls `Geolocator.requestPermission()` unconditionally
2. On denial, `_startLocationUpdates()` returns early but no session flag is set
3. Pull-to-refresh: `_onRefresh()` (compass_screen.dart:95-99) calls `compass.stop()` then `_startServices()` — this re-enters the same flow and re-requests permission
4. No magnetic-only fallback: compass requires GPS for true north correction; if GPS is denied, declination is zero and heading is magnetic (confusing to users)

---

## 7. Security

| Finding | Location | Severity | Detail |
|---|---|---|---|
| Signing passwords in git-tracked docs | `RELEASE_GUIDE.md:125-126` | **CRITICAL** | `storePassword`, `keyPassword` with shared plaintext credential (now redacted) |
| Signing passwords in git-tracked docs | `PROJECT_REFERENCE.md:354,361` | **CRITICAL** | Duplicates same passwords |
| No .gitignore for key material | `.gitignore` | **HIGH** | Missing `**/*.jks`, `**/*.keystore`, `key.properties`, `.env` — these are NOT gitignored |
| Real AdMob app ID in code | `lib/core/constants.dart:19-20` | MEDIUM | `ca-app-pub-8684958562988579~6766583891` — production ID in source |
| Real AdMob ad unit ID in code | `lib/core/constants.dart:23-24` | MEDIUM | `ca-app-pub-8684958562988579/2956999697` — production ID in source |
| Real AdMob ID in manifest | `AndroidManifest.xml:40` | MEDIUM | Same app ID repeated |
| Real IAP product ID in code | `lib/core/constants.dart:27-28` | LOW | `com.msdevx.unitconverter.removeads` — required by Play Store |
| Real IAP product ID in docs | `RELEASE_GUIDE.md:138` | LOW | Documented but necessary for release process |
| Real Privacy Policy URL | `lib/core/constants.dart:34` | LOW | `https://msdevx.com/privacy` — public URL |
| SharedPreferences keys | `lib/core/constants.dart:46-55` | LOW | `history_entries`, `is_premium`, `theme_mode`, `last_ad_shown_timestamp` |
| Android INTERNET permission | `AndroidManifest.xml:3` | NONE | Required for AdMob + currency API — expected |
| Android FINE_LOCATION permission | `AndroidManifest.xml:5` | MEDIUM | Required for compass GPS but requested immediately on screen open |
| Cleartext / network security | `AndroidManifest.xml` | LOW | No `android:usesCleartextTraffic` flag — HTTPS used by Frankfurter but no explicit restriction |
| ProGuard / R8 | `gradle.properties:3` | OK | `android.enableR8.fullMode=true` — R8 full mode enabled |
| ProGuard rules | `android/app/proguard-rules.pro` | OK | Covers Flutter engine, AdMob, billing, Play Core |

---

## 8. Tests

### Existing test files (8 files)

| File | Tests | Status |
|---|---|---|
| `test/conversion_result_test.dart` | 6 | ✅ Covers success, failure, equality, copyWith, toString |
| `test/conversion_service_test.dart` | 20 | ✅ Length, weight, temperature, data, fuel economy, error handling |
| `test/formatters_test.dart` | 12 | ✅ formatResult (sig digits, sci notation), formatInput (sanitize) |
| `test/history_entry_test.dart` | 7 | ✅ toJson, fromJson, equality, copyWith, toString |
| `test/history_service_test.dart` | 9 | ✅ CRUD, ordering, max history, clear, corrupted data |
| `test/unit_model_test.dart` | 6 | ✅ Equality, copyWith, isSpecialCase default |
| `test/units_data_test.dart` | 10 | **❌ STALE — expects 15 categories** (line 6), missing categories 9-20 |
| `test/widget_test.dart` | 1 | ✅ Smoke test — mounts ConverterScreen without crash |

### Stale tests
- **`test/units_data_test.dart:6`** — `expect(unitsData.length, 15)` should be `expect(unitsData.length, 20)`
- Same file line 53-69 — unit count checks only cover categories 1-15 (Length through Fuel Economy). Missing checks for Cooking, Shoe Size, Clothing Size, Number Base, Typography.

### Missing tests
- **Cooking conversions** — volume-to-volume, weight-to-weight, cross-group error
- **Shoe Size** — EU→US, EU→CM, rounding behavior, all pairs
- **Clothing Size** — US→EU, US→UK, men's default (no women's)
- **Number Base** — decimal→binary, hex→decimal, binary→hex, invalid input
- **Typography** — px→pt, em→px, percent→px, DPI variation
- **Angle** — deg→rad, rad→grad, arcmin/arcsec
- **Energy, Power, Pressure, Force, Frequency, Time** — one basic test each
- **CurrencyService** — fetchRates (mock HTTP), saveRates, loadCachedRates, convert, getFallbackRates, timeout behavior, cache completeness
- **CompassService helpers** — `_directionFromHeading()`, `_toDMS()`, permission-state mapping
- **ConverterProvider** — Number Base conversion (currently has no tests anywhere)
- **CurrencyProvider** — getAllResults, setFromCurrency, input handling

### Tests likely to fail
- `test/units_data_test.dart` — **WILL FAIL** due to stale `expect(unitsData.length, 15)` assertion
- All other tests expected to pass

---

## 9. GitHub Readiness

| Area | Status |
|---|---|
| README.md | **❌ Default Flutter template** — still says "A new Flutter project." Needs real project description |
| AGENTS.md | **✅ Updated** with merged rules (448 lines, covers 20 categories, security, compass, etc.) |
| GitHub Actions | **❌ NOT configured** — no `.github/workflows/` directory |
| Dependabot | **❌ NOT configured** — no `.github/dependabot.yml` |
| Secret scanning | **❌ NOT configured** — no Gitleaks or similar in CI; secrets already exposed in docs |
| Release checklist | **⚠️ EXISTS but needs cleanup** — `RELEASE_GUIDE.md` has a checklist but contains exposed signing passwords |
| .gitignore | **⚠️ Needs hardening** — missing `**/*.jks`, `**/*.keystore`, `key.properties`, `.env` |
| CI/CD | No automated build, test, or analysis pipeline |

---

## 10. Recommended Implementation Order

This order prioritises security, build safety, and privacy fixes before feature work.

| Priority | Step | Justification |
|---|---|---|
| 1 | **Security cleanup** | Redact signing passwords from docs, harden .gitignore, run Gitleaks scan |
| 2 | **Build safety** | Ensure debug builds work without key.properties, release builds fail clearly without signing |
| 3 | **GPS/location denial bug** | Fix compass requesting permission on open; add `_locationDeniedThisSession` flag |
| 4 | **Test suite repair** | Fix stale `units_data_test.dart` (expect 20, not 15); add missing category tests |
| 5 | **Currency expansion** | Add PKR + Gulf/South Asian currencies; add search; add timeout to HTTP client |
| 6 | **Compass privacy/fallback** | Add unsupported-sensor fallback, calibration help, magnetic-only mode if GPS denied |
| 7 | **Python validation tooling** | Offline conversion validation script with sample cases |
| 8 | **PDF docs tooling** | Generate release checklist, privacy notes, final audit from Markdown |
| 9 | **UI polish** | Empty states, error states, accessibility, overflow fixes |
| 10 | **New features** | Home search, formula card, decimal precision, favorites after all critical fixes |
| 11 | **Release candidate** | Final audit, AAB build, staged rollout plan |

---

## Summary Table

| Area | Current status | Risk level | Recommended action | Files involved |
|---|---|---|---|---|
| **Signing secrets** | Plaintext passwords in `RELEASE_GUIDE.md` + `PROJECT_REFERENCE.md` | 🔴 CRITICAL | Replace with `<STORE_PASSWORD>` / `<KEY_PASSWORD>` placeholders ✅ DONE | `RELEASE_GUIDE.md`, `PROJECT_REFERENCE.md` |
| **.gitignore** | Missing `**/*.jks`, `*.keystore`, `key.properties`, `.env` | 🔴 HIGH | Add missing patterns | `.gitignore` |
| **Compass — location request** | `Geolocator.requestPermission()` called on screen open with no user opt-in | 🔴 HIGH | Gate behind explicit "Enable GPS" button; add session denial flag | `lib/services/compass_service.dart`, `lib/screens/compass_screen.dart` |
| **Compass — denial re-request** | No `_locationDeniedThisSession` flag; pull-to-refresh re-requests | 🔴 HIGH | Add session flag, check before requesting | `lib/services/compass_service.dart` |
| **iOS location description** | No `NSLocationWhenInUseUsageDescription` in `Info.plist` | 🔴 HIGH | Add usage description string | `ios/Runner/Info.plist` |
| **Stale test** | `units_data_test.dart` expects 15 categories (actual: 20) | 🔴 HIGH | Update to `expect(unitsData.length, 20)`; add checks for categories 16-20 | `test/units_data_test.dart` |
| **Currency — PKR missing** | PKR not in `allCurrencies` or `fallbackRatesToUsd` | 🟡 MEDIUM | Add PKR and Gulf/South Asian currencies | `lib/data/currencies_data.dart` |
| **Currency — no HTTP timeout** | `HttpClient` without timeout could hang indefinitely | 🟡 MEDIUM | Add `Duration(seconds: 10)` timeout to HTTP requests | `lib/services/currency_service.dart` |
| **Currency — no search** | 30 currencies in scrollable list with no search/filter | 🟡 MEDIUM | Add search bar or filter chips | `lib/screens/currency_screen.dart` |
| **Number Base in Provider** | `_convertNumberBase()` lives in `ConverterProvider`, not `ConversionService` | 🟡 MEDIUM | Move pure conversion logic to `ConversionService` | `lib/providers/converter_provider.dart`, `lib/services/conversion_service.dart` |
| **Clothing Size — men only** | `_convertClothingSize()` hardcodes `isMen = true` | 🟡 MEDIUM | Accept sizing toggle parameter from provider | `lib/services/conversion_service.dart` |
| **README.md** | Default Flutter template — no project info | 🟡 MEDIUM | Write real project README | `README.md` |
| **GitHub Actions** | No CI/CD pipeline configured | 🟡 MEDIUM | Add workflow: `flutter analyze`, `flutter test`, `dart format` | `.github/workflows/` |
| **Dependabot** | No automated dependency updates | 🟢 LOW | Add `dependabot.yml` for pub.dev | `.github/dependabot.yml` |
| **AdMob IDs in source** | Production `ca-app-pub-8684958562988579` IDs in constants + manifest | 🟢 LOW | Use test IDs for development; swap before release (document process) | `lib/core/constants.dart`, `AndroidManifest.xml` |
| **Missing test coverage** | No tests for Cooking, Shoe Size, Clothing, Number Base, Typography, CurrencyService, Compass | 🟡 MEDIUM | Add focused test suites for each untested category and service | `test/` (new files) |
| **Compass — no fallback** | No magnetic-only mode if GPS denied; no calibration help | 🟢 LOW | Add unsupported-sensor fallback, calibration guidance | `lib/services/compass_service.dart`, `lib/screens/compass_screen.dart` |

---

*End of baseline audit. All findings documented without modifying production code.*
