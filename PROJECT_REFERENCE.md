# MS Unit Converter — Project Reference

Complete file-by-file reference. Each entry lists the file path, its purpose, key classes/functions, dependencies, and important details for maintenance.

---

## Root Files

### `pubspec.yaml`
- **Purpose:** Project metadata, version, dependencies, launcher icons config
- **Version field:** `line 19` — `version: 2.0.0+2` (versionName + versionCode)
- **Key dependencies:** provider, shared_preferences, google_mobile_ads, in_app_purchase, sensors_plus, share_plus, package_info_plus, url_launcher, flutter_launcher_icons
- **Launcher icons config:** lines 58-70 — source image `assets/icon.png`
- **To bump version:** Edit line 19

### `analysis_options.yaml`
- **Purpose:** Dart analyzer rules — uses `package:flutter_lints/flutter.yaml`
- **Custom rules section:** empty by default, add lint overrides here

### `AGENTS.md`
- **Purpose:** OpenCode agent rules for AI-assisted development
- **Contains:** folder structure, design system, quality rules, monetization details

---

## `lib/` — Core Library

### `lib/main.dart`
- **Purpose:** App entry point. Initializes IAP, sets up Provider tree, renders `MaterialApp`
- **Key classes:** `MyApp` (StatefulWidget), `_MyAppState`
- **Provider lifecycle:** Instantiates `SettingsProvider`, `ConverterProvider`, `CurrencyProvider`, `HistoryProvider` in state and passes via `MultiProvider`
- **Theme wiring:** `Consumer<SettingsProvider>` wraps `MaterialApp` so theme changes rebuild the entire app
- **Splash → MainShell:** `home: const SplashScreen()` — splash handles ad init, then navigates to `MainShell`
- **IAP callback:** `IapService.instance.onPremiumUnlocked` triggers `settings.setPremium(true)`

---

## `lib/core/` — Theme & Constants

### `lib/core/colors.dart`
- **Purpose:** All color tokens as `static const` fields
- **Key tokens:** `primary` (0xFF2563EB), `lightBackground`/`darkBackground`, `lightSurface`/`darkSurface`, `lightTextPrimary`/`darkTextPrimary`, `success`/`error`/`warning`, `borderLight`/`borderDark`, `chipInactive`/`chipActive`, `currencyFrom`/`currencyTo`
- **No theme dependency** — colors are absolute, used directly in widgets

### `lib/core/theme.dart`
- **Purpose:** `AppTheme` class with `lightTheme` and `darkTheme` getters
- **Both themes:** Use `ColorScheme.fromSeed(seedColor: AppColors.primary)`, Material 3
- **Customizations:** AppBar, BottomNavigationBar, Card, InputDecoration, ElevatedButton, Divider
- **Scaffold background:** `lightBackground` / `darkBackground`

### `lib/core/constants.dart`
- **Purpose:** `AppConstants` — all app-wide strings, IDs, storage keys
- **AdMob:** `admobAppIdAndroid` (line 19), `appOpenAdUnitId` (line 23)
- **IAP:** `removeAdsProductId` (line 27), `removeAdsPrice` (line 31)
- **URLs:** `privacyPolicyUrl` (line 34), `playStoreUrl` (line 37), `shareMessage` (line 41)
- **Storage keys:** `historyStorageKey`, `premiumStorageKey`, `themeModeStorageKey`, `lastAdShownTimestampKey`
- **Limits:** `maxHistoryEntries` (20), `adCooldownHours` (4), `splashDurationMs` (1500)
- **To switch between test/production ad IDs:** Edit lines 19, 23 (also update AndroidManifest.xml:38)

---

## `lib/data/` — Static Data

### `lib/data/units_data.dart`
- **Purpose:** Defines `UnitCategory` enum with 15 values + `unitsData` map + preset conversions
- **Categories:** length, weight, temperature, area, volume, speed, data, time, angle, energy, power, pressure, force, frequency, fuelEconomy
- **Extension methods:** `displayName`, `description`, `unitSymbols`, `commonConversions`, `icon` (emoji)
- **Special case units:** Temperature (all 3), L/100km — marked `isSpecialCase: true`
- **Conversion model:** Each unit has `toBase` factor relative to category base unit
- **To add a category:** Add enum value, update all switch statements in extension, add units to `unitsData` map, add `_categoryGradients` in screens
- **To add a unit:** Add entry to the appropriate list in `unitsData` map

### `lib/data/currencies_data.dart`
- **Purpose:** `allCurrencies` list (30 entries) + `fallbackRatesToUsd` map + `currencyByCode()` helper
- **Each currency:** ISO code, name, symbol, flag emoji, decimalDigits
- **Fallback rates:** Rough market rates used on first launch or offline — update periodically
- **Helper:** `currencyByCode(String code)` → `CurrencyModel?`

---

## `lib/models/` — Data Classes

### `lib/models/unit_model.dart`
- **Fields:** `name` (String), `symbol` (String), `toBase` (double), `isSpecialCase` (bool, default false)
- **Features:** `copyWith()`, `==` operator (all fields), `hashCode`, `toString()`
- **Usage:** Immutable — use `copyWith()` to create modified copies

### `lib/models/currency_model.dart`
- **Fields:** `code` (String), `name` (String), `symbol` (String), `flag` (String), `decimalDigits` (int, default 2)
- **Identity:** `==` and `hashCode` based solely on `code`

### `lib/models/conversion_result.dart`
- **Fields:** `result` (double), `formattedResult` (String), `formula` (String), `isValid` (bool), `errorMessage` (String?)
- **Factories:** `ConversionResult.success()`, `ConversionResult.failure()`
- **Features:** `copyWith()`, `==` (all fields)

### `lib/models/history_entry.dart`
- **Fields:** `id` (String), `category` (String), `inputValue` (double), `fromUnit` (String), `toUnit` (String), `result` (double), `timestamp` (DateTime)
- **Serialization:** `toJson()` / `fromJson()` — stored as JSON strings in SharedPreferences
- **Features:** `copyWith()`, `==` (all fields)

---

## `lib/providers/` — State Management (Provider/ChangeNotifier)

### `lib/providers/converter_provider.dart`
- **Purpose:** Core conversion UI state — category, units, input, result
- **State:** `_selectedCategory` (default: length), `_fromUnit`, `_toUnit`, `_inputValue`, `_result`
- **Methods:** `setCategory()`, `setFromUnit()`, `setToUnit()`, `setInput()`, `swapUnits()`
- **Computed:** `isValidInput`, `formattedInput`, `currentUnits`
- **Internal:** `_initUnitsForCategory()` (selects first two units), `_recalculate()` (calls `ConversionService.convert`)
- **Dependencies:** `units_data.dart`, `conversion_service.dart`, `formatters.dart`
- **Category change:** Resets input, clears result, selects first two units of new category

### `lib/providers/currency_provider.dart`
- **Purpose:** Currency converter UI state — source currency, input, rates, all results
- **State:** `_fromCurrency` (default: USD), `_inputValue` (default: "1"), `_isLoading`, `_error`, `_lastUpdated`, `_rates`
- **Methods:** `setFromCurrency()`, `setInput()`, `refreshRates()`, `getAllResults()`
- **Ready state:** `isReady` getter — true when source and rates available (synchronous from constructor)
- **Constructor:** Populates fallback rates immediately so `isReady` is true before any async work
- **Internal:** `_init()` loads cached rates, then fetches fresh ones in background
- **Refresh:** Pull-to-refresh calls `refreshRates()` — fetches from Frankfurter.app, falls back to cache, then to hardcoded rates
- **Result rows:** `CurrencyResultRow` inner class — currency info + formatted conversion

### `lib/providers/history_provider.dart`
- **Purpose:** Manages in-memory history list + SharedPreferences persistence
- **State:** `entries` (List<HistoryEntry>), `isLoading`
- **Methods:** `loadHistory()`, `addEntry()`, `clearHistory()`, `removeEntry()`, `refresh()`
- **Cap:** Max 20 entries (`AppConstants.maxHistoryEntries`)
- **Error handling:** All storage errors caught — in-memory list updated optimistically
- **Refresh:** `refresh()` delegates to `loadHistory()`

### `lib/providers/settings_provider.dart`
- **Purpose:** Theme mode + premium status persistence
- **State:** `themeMode` (default: `ThemeMode.system`), `isPremium` (default: false), `isLoaded`
- **Methods:** `loadSettings()`, `toggleTheme()`, `setThemeMode()`, `setPremium()`
- **Theme cycle:** System → Light → Dark → System (set in `toggleTheme()`)
- **Persistence:** All settings saved to SharedPreferences on change
- **Error handling:** Storage failures caught — in-memory state kept unchanged

---

## `lib/services/` — Business Logic

### `lib/services/conversion_service.dart`
- **Purpose:** Pure stateless conversion engine. No UI, no storage, no network.
- **Static method:** `convert(double value, UnitModel from, UnitModel to, UnitCategory category)` → `ConversionResult`
- **Normal conversion:** `(value * from.toBase) / to.toBase`
- **Temperature:** Celsius → Fahrenheit → Kelvin (Celsius as intermediate)
- **Fuel economy:** km/L as intermediate, L/100km uses reciprocal
- **Formula builder:** `buildFormula()` — human-readable string with factor or simplified for special cases
- **Short circuits:** Same-unit → value unchanged; NaN/Infinity → failure

### `lib/services/currency_service.dart`
- **Purpose:** Fetch, cache, and apply exchange rates from Frankfurter.app
- **Static API:** `fetchRates()`, `saveRates()`, `loadCachedRates()`, `loadLastUpdated()`, `convert()`, `getFallbackRates()`
- **HTTP:** Uses `dart:io` `HttpClient` (no third-party HTTP package needed)
- **Endpoint:** `https://api.frankfurter.app/latest?from=USD`
- **Caching:** Rates stored as JSON string in SharedPreferences with ISO-8601 timestamp
- **Fallback:** `getFallbackRates()` returns hardcoded rates from `currencies_data.dart`

### `lib/services/history_service.dart`
- **Purpose:** SharedPreferences CRUD for conversion history
- **Storage format:** `StringList` of JSON-encoded `HistoryEntry` objects
- **Key:** `AppConstants.historyStorageKey`
- **Static methods:** `saveEntry()`, `getEntries()`, `clearAll()`
- **Error handling:** All methods catch errors silently — history is best-effort

### `lib/services/admob_service.dart`
- **Purpose:** App Open Ad singleton — load, show, cooldown management
- **Ad format:** `AppOpenAd` only (NOT banner, NOT interstitial, NOT rewarded)
- **Load strategy:** Preload during splash screen
- **Show rules:** Premium users skip; 4-hour cooldown; ad must be loaded; failure = silent skip
- **Key methods:** `loadAppOpenAd()`, `showAdIfEligible(bool isPremium)`, `dispose()`
- **State:** `isAdReady` getter, internal `_isLoading` flag, `_appOpenAd` reference
- **Cooldown:** Timestamp stored in SharedPreferences, checked via `_isCooldownElapsed()`

### `lib/services/iap_service.dart`
- **Purpose:** In-app purchase singleton — initialize, purchase, restore
- **Product ID:** `com.msdevx.unitconverter.removeads` (\$1.99)
- **Singleton access:** `IapService.instance`
- **Key methods:** `initialize()`, `purchase()`, `restore()`, `isPurchased()`, `dispose()`
- **Purchase stream:** Listens via `InAppPurchase.purchaseStream`, handles pending/purchased/restored/error states
- **Verification:** Simple product ID + status check in `_verifyPurchase()`
- **Callback:** `onPremiumUnlocked` — wired in `main.dart` to set `SettingsProvider.isPremium = true`
- **Platform safety:** Only initializes on Android/iOS (graceful degradation on desktop)

### `lib/services/compass_service.dart`
- **Purpose:** Real-time tilt-compensated heading from device sensors
- **Sensors:** Uses `sensors_plus` accelerometer + magnetometer at 100ms sampling
- **Algorithm:** Gravity vector from accelerometer → roll/pitch → project magnetic field onto horizontal plane → heading (0-360°)
- **Smoothing:** Low-pass filter on raw sensor values + weighted smoothing on heading (factor 0.25)
- **Streams:** `headingStream` (broadcast `Stream<double>`), `liveStatusStream`
- **Lifecycle:** `start()` / `stop()` / `dispose()`
- **Singleton:** `CompassService.instance`

---

## `lib/screens/` — UI Screens

### `lib/screens/splash_screen.dart`
- **Purpose:** 1500ms brand impression + parallel ad/service init
- **UI:** App icon (from assets), "MS Unit Converter" title, "by MS DevX" subtitle, loading spinner
- **Background:** `#080E14`
- **Flow:** Loads ad during splash → checks premium → shows ad or navigates directly to `MainShell`
- **Timing:** `_minimumTimeElapsed` flag + `_adReady` flag → `_onReady()` triggers navigation

### `lib/screens/main_shell.dart`
- **Purpose:** Bottom navigation shell — 5 tabs with reduced-sensitivity swipe
- **Tabs:** Home (0), Currency (1), Compass (2), History (3), Settings (4)
- **Swipe behavior:** `_ReducedSensitivityPhysics` extends `PageScrollPhysics`, `dragStartDistanceMotionThreshold = 28.0`
- **Page preservation:** `_KeepAlivePage` wraps each screen with `AutomaticKeepAliveClientMixin`
- **Back button:** Tab 0 → exit app; any other tab → return to tab 0
- **Navigation:** `PageView` + `BottomNavigationBar` with `_onTabTapped` animation

### `lib/screens/home_screen.dart`
- **Purpose:** Premium category grid with gradient animated cards + quick presets section
- **Grid:** 2 columns (4 on wide screens), `SliverGrid` with `TweenAnimationBuilder` (fade + slide up)
- **Cards:** Gradient background, icon, name, description, unit symbol tags
- **Interactions:** Tap → pushes `ConverterScreen` with category; Long-press → bottom sheet with presets
- **Quick presets:** 6 common conversions below the grid as gradient chips
- **Pull-to-refresh:** `RefreshIndicator` wrapping `CustomScrollView` — increments `_refreshKey` to re-stagger animations
- **Category colors:** 15 categories, each has a 2-color gradient defined in `_categoryGradients`

### `lib/screens/converter_screen.dart`
- **Purpose:** Full converter view — input, swap, all-unit results
- **Input modes:** As standalone tab (with CategoryChipBar) or pushed from home (with gradient header + back button)
- **Components:** `ConverterInputBar` (value + source unit), `ConverterConnectorBar` (gradient bar + swap), `ConversionResultsList` (all units with results)
- **Live conversion:** Updates on every keystroke — no Calculate button
- **Result tap:** Copies to clipboard + saves to history via `HistoryProvider.addEntry()`
- **Category gradients:** 15 category color schemes defined as `_categoryGradients`
- **Preset support:** Accepts `initialCategory`, `presetValue`, `presetFromUnitName`, `presetToUnitName` for deep linking from home

### `lib/screens/currency_screen.dart`
- **Purpose:** Live FX rates for all 30 currencies in a scrollable list
- **Layout:** `CustomScrollView` with `SliverFillRemaining` — pull-to-refresh enabled
- **Input:** 36pt text field with source dropdown on the right
- **Source dropdown:** Custom styled `DropdownButton` inside a bordered container
- **Quick switches:** Row of 10 common currency code chips (USD, EUR, GBP, JPY, CNY, INR, AUD, CAD, CHF, BRL)
- **Results:** `_CurrencyResultsList` — flag, code, name, converted value, symbol — tap to copy
- **Status bar:** Shows "Updated X ago" + base rate ("1 $ = X €") + loading/error state
- **Copy:** Tap any row → clipboard + snackbar
- **Default:** Input starts at "1", source defaults to USD

### `lib/screens/compass_screen.dart`
- **Purpose:** Compass with live sensor heading + manual angle override
- **Layout:** `CustomScrollView` + `SliverFillRemaining` with radial gradient background
- **Live mode:** Sensors active, arrow follows device, heading label green
- **Manual mode:** Tap rose / type angle / tap direction chip → pauses live, locks heading, blue arrow
- **Components:** `CompassRose` (CustomPaint), direction label (32pt), angle TextField, 8 direction chips (N/NE/E/SE/S/SW/W/NW)
- **Resume live:** "Live" button in AppBar (shown when in manual mode)
- **Pull-to-refresh:** Re-enables live sensor mode with a settle delay
- **Direction categories:** N (0°), NE (45°), E (90°), SE (135°), S (180°), SW (225°), W (270°), NW (315°)

### `lib/screens/history_screen.dart`
- **Purpose:** Shows last 20 conversions with clear and delete actions
- **States:** Loading spinner, empty state with pulsing icon, data list
- **List items:** `Dismissible` cards — swipe left to delete with confirmation
- **Long press:** Bottom sheet with "Delete this entry" option
- **AppBar action:** Delete icon (only visible when entries exist) — clears all with confirmation
- **Pull-to-refresh:** `RefreshIndicator` wrapping `ListView.builder` with `AlwaysScrollableScrollPhysics`
- **Empty state:** Pulsing history icon (2s animation), "No history yet" text
- **Animation:** Each card fades + slides up on load

### `lib/screens/settings_screen.dart`
- **Purpose:** All settings in card-based grouped sections
- **Sections:** Appearance (theme toggle), Premium (buy/restore), About (app version, package ID), Actions (rate, share, privacy)
- **Theme toggle:** Cycles System → Light → Dark, shown as pill chip with brightness icon
- **Premium state:** If purchased → green checkmark tile (disabled); if not → "Remove Ads — $1.99" tappable tile + Restore option
- **About:** Uses `PackageInfo.fromPlatform()` to show version + build number
- **Actions:** Rate (opens Play Store URL), Share (system share sheet), Privacy Policy (opens URL)
- **Components:** `_SectionHeader`, `_SettingsCard` (rounded card with border), `_SettingsTile` (icon + title + subtitle + trailing), `_Divider`, `_ThemeChip`

---

## `lib/widgets/` — Reusable UI Components

### `lib/widgets/category_chip_bar.dart`
- **Purpose:** Horizontal scrollable category selector — one animated chip per `UnitCategory`
- **Props:** `categories`, `selected`, `onSelected`
- **Chip animation:** `AnimatedContainer` (200ms) — background, border, shadow change on selection
- **Styling:** Primary color for selected, surface/inactive for unselected

### `lib/widgets/converter_input_bar.dart`
- **Purpose:** Value input field + source unit picker in a single row
- **Layout:** `TextField` (28pt, decimal keyboard, signed) + divider + unit button
- **Unit picker:** Tapping opens `UnitSearchDialog` — full-screen searchable list
- **Clear button:** Shows when input is non-empty

### `lib/widgets/converter_connector_bar.dart`
- **Purpose:** Gradient bar connecting input to results with swap button
- **Features:** Pulsing arrow icon (1500ms animation), "All conversions" label, swap button with 180° rotation animation
- **Swap animation:** `AnimationController` (250ms, easeInOutBack curve) — rotates 180° on tap
- **Gradient:** Inherits colors from the active category (passed from `ConverterScreen`)

### `lib/widgets/conversion_results_list.dart`
- **Purpose:** Simple wrapper that maps `(UnitModel, ConversionResult?)` tuples to `ConversionResultRow` widgets
- **Props:** `results`, `sourceUnit`, `isDark`, `onResultTapped`
- **Separator:** Thin divider between rows

### `lib/widgets/conversion_result_row.dart`
- **Purpose:** Single result row — value, share button, unit name
- **States:** Empty ("—"), invalid (error message in red), valid (formatted result)
- **Interactions:** Tap → copy value + snackbar; tap share icon → system share sheet
- **Animation:** `AnimatedSwitcher` (200ms fade) for value changes
- **Selected state:** Highlighted with primary color background (source unit row)

### `lib/widgets/compass_rose.dart`
- **Purpose:** Custom-painted compass rose (`CustomPainter`)
- **Features:** Outer/inner circles, 16 tick marks (cardinals thicker), N/E/S/W labels (w900, black, 0.85 alpha), highlight arc (green/blue, 22.5°), arrow with triangular head, center dot
- **Interaction:** Tap on rose → calculates bearing from tap position → calls `onBearingSelected`
- **Colors:** Live mode = green (#10B981); Manual mode = blue (#3B82F6)
- **Compass points:** `compassPoints` list — all 16 directions with bearings
- **Helper:** `nearestCompassPoint(double bearing)` → returns closest 16-point label

### `lib/widgets/swap_button.dart`
- **Purpose:** Standalone animated swap button (not used in current UI — `ConverterConnectorBar` uses its own swap)
- **Animation:** 180° rotation, `easeInOutBack` curve, 250ms
- **Styling:** Primary color circle with swap icon, double shadow

### `lib/widgets/unit_dropdown.dart`
- **Purpose:** Styled dropdown for selecting a unit (not used in current UI — replaced by search dialog)
- **Features:** Label, bordered container, `DropdownButton` with custom styling

### `lib/widgets/unit_search_dialog.dart`
- **Purpose:** Full-screen searchable unit picker
- **Features:** AppBar with close button + search TextField (autofocus), scrollable unit list with symbols
- **Filtering:** Matches against unit name and symbol (case-insensitive)
- **Selection:** Highlighted row with checkmark icon for currently selected unit

---

## `lib/utils/` — Helpers

### `lib/utils/formatters.dart`
- **Purpose:** Number formatting utilities (pure Dart, no Flutter dependency)
- **Key functions:**
  - `formatResult(double value)` — max 8 significant digits, no scientific notation for `0.000001`–`999999999`, strips trailing zeros, returns "Invalid" for NaN/Infinity
  - `formatInput(String raw)` — sanitizes user input: keeps digits, one decimal point, leading minus
  - `_expandScientific(String value)` — expands "1.23e+5" to "123000"
  - `_removeTrailingZeros(String value)` — removes trailing zeros after decimal

### `lib/utils/validators.dart`
- **Purpose:** Input validation helpers
- (Check the actual file for specific validator functions)

---

## `android/` — Platform Configuration

### `android/key.properties`
- **Purpose:** Keystore credentials for release signing (**gitignored**)
- **Content:** `storePassword`, `keyPassword`, `keyAlias`, `storeFile`
- **Current values:** `storePassword=<STORE_PASSWORD>`, `keyAlias=<KEY_ALIAS>`, `storeFile=<STORE_FILE>`
- **⚠️ On fresh clone:** Must restore this file from backup

### `android/app/upload-keystore.jks`
- **Purpose:** The actual release signing keystore (**gitignored**)
- **⚠️ Must back up** to cloud + external drive. Loss = cannot publish app updates.
- **Alias:** `<KEY_ALIAS>`
- **Password:** `<KEY_PASSWORD>`

### `android/upload_certificate.pem`
- **Purpose:** Public certificate for Play Console App Integrity
- **Must upload** to Play Console before uploading the first AAB
- Generated from keystore: `keytool -export -rfc -keystore android/app/upload-keystore.jks -alias upload -file android/upload_certificate.pem`

### `android/app/build.gradle.kts`
- **Purpose:** App-level Gradle — SDK versions, signing config, proguard
- **Namespace:** `com.msdevx.unitconverter`
- **Compile SDK:** `flutter.compileSdkVersion`
- **Build tools:** `36.1.0`
- **Java target:** 17
- **Signing:** Release config reads from `key.properties`
- **Proguard:** Minify + shrink resources enabled for release builds

### `android/build.gradle.kts`
- **Purpose:** Project-level Gradle — repository config, build output directory mapping

### `android/settings.gradle.kts`
- **Purpose:** Module settings

### `android/gradle.properties`
- **Purpose:** JVM args, AndroidX, R8 full mode
- **JVM:** `-Xmx8G -XX:MaxMetaspaceSize=4G`

### `android/app/src/main/AndroidManifest.xml`
- **Purpose:** App manifest — permissions, AdMob App ID, intent filters
- **INTERNET permission:** Required for AdMob and currency API
- **AdMob App ID:** Line 38 — must match `constants.dart:19`
- **Play Store query:** Required for `in_app_purchase`

---

## `assets/`

### `assets/icon.png`
- **Purpose:** Source image for app launcher icon (512×512 PNG)
- **Regenerate icons:** `dart run flutter_launcher_icons`
- **Generates:** Android mipmaps (hdpi–xxxhdpi), adaptive icon, iOS all sizes

---

## `test/` — Unit Tests

### `test/conversion_result_test.dart`
- Tests for `ConversionResult` model (success, failure, equality, serialization)

### `test/conversion_service_test.dart`
- Tests for `ConversionService` — linear, temperature, fuel economy conversions

### `test/formatters_test.dart`
- Tests for `Formatters` — formatResult, formatInput, edge cases

### `test/history_entry_test.dart`
- Tests for `HistoryEntry` model — toJson/fromJson, equality, copyWith

### `test/history_service_test.dart`
- Tests for `HistoryService` — save, read, clear, max entries

### `test/unit_model_test.dart`
- Tests for `UnitModel` — construction, equality, copyWith

### `test/units_data_test.dart`
- Tests for `unitsData` — every category has units, no nulls, symbols are non-empty

### `test/widget_test.dart`
- Smoke test — verifies app builds without errors

---

## Quick Reference — Version Update Checklist

```markdown
1. pubspec.yaml:19       → bump version + build number
2. constants.dart:13     → update appVersion string
3. Run: flutter clean && flutter pub get
4. Run: flutter analyze   (must be 0 issues)
5. Run: flutter test      (all pass)
6. Build: flutter build appbundle --release
7. Upload AAB to Play Console
```

## Quick Reference — Common Edits

| What you want to change | File(s) to edit |
|-------------------------|-----------------|
| Add a new conversion unit | `lib/data/units_data.dart` |
| Add a new currency | `lib/data/currencies_data.dart` + `fallbackRatesToUsd` |
| Change theme colors | `lib/core/colors.dart` + `lib/core/theme.dart` |
| Change theme default | `lib/providers/settings_provider.dart:21` |
| Change ad unit ID | `lib/core/constants.dart:23` + `AndroidManifest.xml:38` |
| Change IAP product ID | `lib/core/constants.dart:27` |
| Change privacy policy URL | `lib/core/constants.dart:34` |
| Change app icon | Replace `assets/icon.png` + `dart run flutter_launcher_icons` |
| Change swap sensitivity | `lib/screens/main_shell.dart:26` — `dragStartDistanceMotionThreshold` |
| Change max history count | `lib/core/constants.dart:58` |
| Change ad cooldown period | `lib/core/constants.dart:61` |
| Change splash duration | `lib/core/constants.dart:64` |
| Add a new screen/tab | Create screen file + add to `main_shell.dart` `_screens` + `_navItems` |
