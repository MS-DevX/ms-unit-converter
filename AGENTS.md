# MS Unit Converter — OpenCode Agent Rules (AGENTS.md)
# Read this entire file before every task. No exceptions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECT IDENTITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App name     : Unit Converter
Developer    : MS DevX
Package      : com.msdevx.unitconverter (Android), com.msdevx.unitconverter (iOS)
Platform     : Android (Play Store first, iOS later)
Flutter ver  : Latest stable (3.x)
Dart ver     : Latest stable (null-safe, 3.x)
State mgmt   : Provider (simple, beginner-friendly, well supported)
Priority     : Quality over speed — clean code, great UX

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APP FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
8 conversion categories:
  1. Length    — km, m, cm, mm, mile, yard, foot, inch, nautical mile
  2. Weight    — kg, g, mg, tonne, lb, oz, stone
  3. Temp      — Celsius, Fahrenheit, Kelvin (special formula, no multiplier)
  4. Area      — km², m², cm², mm², hectare, acre, ft², in², yd²
  5. Volume    — litre, ml, m³, gallon(US), gallon(UK), cup, fl oz, pint, quart
  6. Speed     — km/h, m/s, mph, knot, ft/s
  7. Data      — bit, byte, KB, MB, GB, TB, PB
  8. Time      — ms, second, minute, hour, day, week, month, year

5 screens:
  1. HomeScreen        (bottom nav item 0 — category grid + quick presets)
  2. CurrencyScreen    (bottom nav item 1 — live FX rates via Frankfurter.app)
  3. CompassScreen     (bottom nav item 2 — live heading via sensors + manual angle)
  4. HistoryScreen     (bottom nav item 3 — last 20 conversions)
  5. SettingsScreen    (bottom nav item 4 — theme, premium, about)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FOLDER STRUCTURE (enforce this exactly)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lib/
  main.dart                        ← app entry, providers, theme setup
  /core
    theme.dart                     ← AppTheme (light + dark ThemeData)
    constants.dart                 ← app-wide constants, strings, ad unit IDs
    colors.dart                    ← AppColors class with all color tokens
  /data
    units_data.dart                ← all unit definitions and conversion factors
    currencies_data.dart           ← supported currency list + fallback rates
  /models
    unit_model.dart                ← UnitModel class
    currency_model.dart            ← CurrencyModel class
    conversion_result.dart         ← ConversionResult class
    history_entry.dart             ← HistoryEntry class
  /providers
    converter_provider.dart        ← conversion state (selected category, units, value, result)
    currency_provider.dart         ← currency state (from, to, value, result, rates, fetch)
    history_provider.dart          ← history state (load, save, clear)
    settings_provider.dart         ← theme mode, isPremium state
  /services
    conversion_service.dart        ← pure conversion logic (no UI)
    currency_service.dart          ← fetch FX rates, cache, convert
    history_service.dart           ← SharedPreferences read/write
    admob_service.dart             ← banner + interstitial ad management
    iap_service.dart               ← in-app purchase (remove ads)
  /screens
    converter_screen.dart
    currency_screen.dart
    history_screen.dart
    settings_screen.dart
  /widgets
    category_chip_bar.dart         ← horizontal scrollable category selector
    unit_dropdown.dart             ← styled dropdown for unit selection
    swap_button.dart               ← animated rotate swap button
    result_display.dart            ← result + formula + copy button
    history_tile.dart              ← single history list item
    empty_state_widget.dart        ← reusable empty state (icon + message)
  /utils
    formatters.dart                ← number formatting helpers
    validators.dart                ← input validation helpers

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DESIGN SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Primary accent   : #3B82F6  (MS DevX blue)
Accent hover     : #60A5FA
Background dark  : #0D1117
Surface dark     : #161B22
Surface elevated : #1C2433
Border dark      : #30363D
Text primary dk  : #E6EDF3
Text secondary dk: #8B949E
Text muted dk    : #484F58
Background light : #FFFFFF
Surface light    : #F6F8FA
Border light     : #D0D7DE
Text primary lt  : #1F2328
Text secondary lt: #656D76
Success          : #10B981
Warning          : #F59E0B
Danger           : #EF4444

Border radius: 12 (cards), 8 (buttons/inputs/chips)
Font: system default (clean, no custom font needed)
Input font size: 32 (large, thumb-friendly)
Result font size: 32
Bottom navbar: 5 items (Home / Currency / Compass / History / Settings)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
QUALITY RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Live conversion: result updates on every keystroke — no Calculate button
- Temperature: special-case formulas, never multiplier
- Result format: max 8 significant digits, no scientific notation for
  values between 0.000001 and 999999999
- Empty input → result shows "—"
- Invalid input → result shows "Invalid"
- Keyboard: dismisses on tap outside input field
- Swap button: rotates 180° with 200ms animation on tap
- Category change: resets both dropdowns to index 0 of new category
- History: last 20 entries, newest first, persisted in SharedPreferences
- Dark mode: follows system by default, overridable in Settings
- Offline: zero internet required except AdMob
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- App size target: under 15MB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PUBSPEC DEPENDENCIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
provider: ^6.1.0
shared_preferences: ^2.2.0
google_mobile_ads: ^5.0.0
in_app_purchase: ^3.1.0
share_plus: ^7.0.0
package_info_plus: ^6.0.0
url_launcher: ^6.2.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MONETIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MODEL: Free with single App Open Ad + $1.99 remove ads IAP

AD TYPE: AppOpenAd (google_mobile_ads)
  NOT interstitial. NOT banner. NOT rewarded.
  ONLY AppOpenAd — one per app session.

Test App Open Ad ID : ca-app-pub-3940256099942544/9257395921
Real App Open Ad ID : ca-app-pub-3940256099942544/9257395921

WHEN TO SHOW:
  ✓ Cold start (app launched fresh)
  ✓ Warm start after 4+ hours in background
  ✗ Never on resume after < 4 hours background
  ✗ Never if isPremium = true
  ✗ Never if ad failed to load (skip silently)

LOADING STRATEGY:
  - Load AppOpenAd during splash screen (parallel to service init)
  - Splash screen duration: 1500ms minimum
  - If ad ready within 1500ms → show after splash
  - If ad not ready → skip, go straight to app
  - Never delay user more than 1500ms total for any reason

COOLDOWN:
  - Minimum 4 hours between ad shows
  - Store lastAdShownTimestamp in SharedPreferences
  - On each cold start: check timestamp before showing

IAP — REMOVE ADS:
  Product ID : com.msdevx.unitconverter.removeads
  Price      : $1.99 one-time purchase
  On purchase: isPremium = true → save to SharedPreferences
  On restore : check past purchases → restore isPremium
  Always restore on app start (handles reinstalls/device changes)

isPremium BEHAVIOUR:
  true  → skip all ad logic, app launches instantly after splash
  false → follow ad flow above

SPLASH SCREEN:
  Duration   : 1500ms
  Content    : App icon (swap_horiz, large, centered) + "MS Unit Converter" +
               "by MS DevX" (small, bottom) + loading indicator (subtle)
  Background : #080E14
  Purpose    : Brand impression + hides ad/service initialization
  File       : lib/screens/splash_screen.dart

NO OTHER ADS:
  ✗ No AdBannerWidget anywhere in the app
  ✗ No interstitial on tab switch
  ✗ No ad_banner_widget.dart needed
  Remove any banner ad widget from all screens.
  The only ad-related widget is the App Open Ad fullscreen format.

ADMOB SERVICE FILE: lib/services/admob_service.dart
  Responsibilities:
  - Initialize MobileAds SDK (done at splash)
  - Load AppOpenAd
  - Show AppOpenAd (if loaded + cooldown passed + not premium)
  - Track lastAdShownTimestamp
  - Expose: isAdReady (bool), showAdIfEligible(bool isPremium)

IAP SERVICE FILE: lib/services/iap_service.dart
  Responsibilities:
  - Initialize in_app_purchase stream
  - loadProducts(): fetch product details from Play Store
  - purchase(): initiate $1.99 purchase
  - restore(): restore past purchases
  - isPurchased(): check SharedPreferences
  - verifyAndSave(): on successful purchase, save isPremium=true

SETTINGS SCREEN IAP BUTTON:
  if !isPremium:
    ListTile "Remove Ads — $1.99"
    subtitle: "One-time purchase. No ads forever."
  if isPremium:
    ListTile with check icon
    "✓ Premium — Ad Free"
    subtitle: "Thank you for your support!"
    (disabled, not tappable)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPENCODE TASK RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Read AGENTS.md before every task
2. Follow the folder structure exactly — never create files outside it
3. Complete Dart code — no placeholders, no TODO comments
4. Null-safe Dart 3 only
5. Every class and public function needs a doc comment (///)
6. Never use print() — use debugPrint() only
7. Use const constructors wherever possible
8. After each task output:

✓ COMPLETE: [task name]
📁 Files created/edited: [list]
🧪 Test: [how to verify this works]
⚠️  Notes: [anything to watch or "none"]