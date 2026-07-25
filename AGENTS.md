# MS Unit Converter — OpenCode Agent Rules (AGENTS.md)
# Read this entire file before every task. No exceptions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECT IDENTITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App name     : Unit Converter
Developer    : MS DevX
Package      : com.msdevx.unitconverter
Platform     : Android (Play Store first, iOS later)
Flutter ver  : 3.x stable (SDK ^3.12.0)
Dart ver     : 3.x stable (null-safe)
State mgmt   : Provider (^6.1.0) — ChangeNotifier per feature
Min SDK      : 21 (Android 5.0)
Target SDK   : 37 (Android 17)
App version  : 2.2.0+6
Priority     : Quality over speed — clean code, great UX

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APP FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
53 conversion categories (UnitCategory enum):
  length, weight, temperature, area, volume, speed, data, time,
  angle, energy, power, pressure, force, frequency, fuelEconomy,
  cooking, shoeSize, clothingSize, numberBase, typography,
  voltage, current, resistance, capacitance, inductance,
  electricCharge, conductance, illuminance, luminousFlux,
  luminousIntensity, luminance, specificHeat, thermalConductivity,
  thermalResistance, heatFluxDensity, torque, momentum,
  angularVelocity, density, surfaceTension, kinematicViscosity,
  dynamicViscosity, acceleration, flowRate, massFlowRate,
  radioactivity, radiationDose, radiationExposure,
  astronomicalLength, pace, heartRate, bloodSugar, bloodPressure,
  bmi, percentageRatio, soundLevel, concentration,
  magneticField, magneticFlux, wavenumber

12 screens:
  1. SplashScreen              — 1500ms min, loads ad + checks Play Store update
  2. MainShell                 — nav host, PageView (compact) / NavigationRail (expanded)
  3. HomeScreen                — search, filters (browse/favorites/recent/popular), collections,
                                pinned, insights banner, did-you-know, category grid, recent
  4. ConverterScreen           — live conversion, swap, formula, copy, share
  5. CurrencyScreen            — live FX via Frankfurter.app, 170+ currencies, offline fallback
  6. CompassScreen             — magnetic + true north, bubble level, manual angle
  7. HistoryScreen             — last 50 entries, newest first, persisted in SharedPreferences
  8. SettingsScreen            — theme, decimal precision, cosmic mode, user profile, about
  9. CollectionScreen          — categories within a predefined collection
  10. CustomConverterScreen    — user-created linear-ratio converters (CRUD)
  11. HomeCustomizationScreen  — reorder/toggle home sections
  12. NotesScreen              — user-created conversion notes (CRUD)

Bottom nav (5 tabs):
  Index 0: Home      — Icons.home_outlined / Icons.home_rounded
  Index 1: Currency   — Icons.currency_exchange_outlined / Icons.currency_exchange_rounded
  Index 2: Compass    — Icons.explore_outlined / Icons.explore_rounded
  Index 3: History    — Icons.history_outlined / Icons.history_rounded
  Index 4: Settings   — Icons.settings_outlined / Icons.settings_rounded

Responsive layout:
  Compact (<600dp)  — PageView + StitchBottomNav (custom pill-animated bottom nav)
  Expanded (≥840dp) — NavigationRail + IndexedStack (side nav)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FOLDER STRUCTURE (enforce this exactly)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lib/
  main.dart
  core/
    colors.dart              ← AppColors (50+ Material 3 dark/light color tokens)
    constants.dart           ← AppConstants (ad IDs, URLs, storage keys, limits)
    theme.dart               ← AppTheme (dark/light ThemeData builder, custom text theme)
    ui_constants.dart        ← CosmicUIConstants (glassmorphic cosmic dark theme tokens)
  data/
    collections_data.dart    ← 9 predefined Collection objects
    converter_config.dart    ← ConverterConfig registry (icon, gradient, group per category)
    currencies_data.dart     ← 170+ ISO-4217 currencies, flags, symbols, fallback rates
    did_you_know.dart        ← 60 DidYouKnowFact educational facts
    units_data.dart          ← UnitCategory enum, all unit definitions, conversion factors
  models/
    conversion_note.dart     ← ConversionNote (id, title, body, timestamps)
    conversion_result.dart   ← ConversionResult (result, formattedResult, formula, isValid, errorMessage)
    currency_model.dart      ← CurrencyModel (code, name, symbol, flag, decimalDigits, isPinned)
    custom_converter.dart    ← CustomConverter + CustomUnit (id, name, emoji, units with toBase)
    history_entry.dart       ← HistoryEntry (id, category, value, units, symbols, result, timestamp)
    unit_model.dart          ← UnitModel (name, symbol, toBase, isSpecialCase, group)
  providers/
    collections_provider.dart    ← pinned collection IDs
    converter_provider.dart      ← category, fromUnit, toUnit, inputValue, result, swap
    currency_provider.dart       ← from/to currency, value, result, FX rates, fetch
    custom_converter_provider.dart ← CRUD for user custom converters
    favorites_provider.dart      ← favorite category IDs
    history_provider.dart        ← history list, add, clear
    home_layout_provider.dart    ← home section ordering, visibility
    notes_provider.dart          ← CRUD for conversion notes
    pinned_provider.dart         ← pinned category IDs
    settings_provider.dart       ← theme mode, decimal precision, cosmic mode, user name/avatar
    usage_provider.dart          ← category usage counts, frequently used
  screens/
    collection_screen.dart
    compass_screen.dart
    converter_screen.dart
    currency_screen.dart
    custom_converter_screen.dart
    history_screen.dart
    home_customization_screen.dart
    home_screen.dart
    main_shell.dart
    notes_screen.dart
    settings_screen.dart
    splash_screen.dart
  services/
    admob_service.dart           ← AppOpenAd load/show, cooldown, session cap
    bubble_level_service.dart   ← accelerometer pitch/roll streaming
    collections_service.dart    ← persist pinned collection IDs
    compass_service.dart        ← magnetic + true north heading, GPS declination
    conversion_service.dart     ← pure-logic conversion engine (53 categories)
    currency_service.dart       ← Frankfurter API fetch/cache, SharedPreferences
    custom_converter_service.dart ← CRUD for custom converters
    favorites_service.dart      ← persist favorite categories
    history_service.dart        ← persist last 50 conversion entries
    home_layout_service.dart    ← persist home section config
    in_app_update_service.dart  ← Google Play in-app update flow
    insights_service.dart       ← total conversions, favorite category, most used unit
    installation_source_service.dart ← detect Play Store vs sideload
    navigation_service.dart     ← AppNavigator/TabNotifier for programmatic tab switching
    notes_service.dart          ← CRUD for conversion notes
    pinned_service.dart         ← persist pinned categories
    refresh_service.dart        ← global pull-to-refresh orchestrator
    shortcuts_service.dart      ← dynamic app launcher shortcuts
    smart_parse_service.dart    ← offline NL parser ("10 km to miles", "5'9 to cm")
    unit_info_service.dart      ← load unit info from JSON asset
    usage_service.dart          ← persist category usage counts
  utils/
    formatters.dart             ← Formatters (formatResult, formatInput, cleanFloatingPoint)
    responsive_helper.dart      ← ScreenSizeClass (compact/medium/expanded), grid column count
    search_helper.dart          ← fuzzy category/unit search with alias expansion
  widgets/
    animated_icon_wrapper.dart
    bubble_level_widget.dart
    category_chip_bar.dart
    compass_rose.dart
    conversion_bar.dart
    conversion_result_row.dart
    conversion_results_list.dart
    converter_connector_bar.dart
    converter_input_bar.dart
    cosmic_background.dart
    decimal_precision_bar.dart
    did_you_know_card.dart
    empty_state_widget.dart
    glassmorphic_tile.dart
    insights_banner.dart
    performance_monitor.dart
    stitch_bottom_nav.dart      ← custom bottom nav bar (pill animation, haptic feedback)
    stitch_card.dart
    stitch_search_bar.dart
    swap_button.dart
    unit_dropdown.dart
    unit_info_sheet.dart
    unit_search_dialog.dart
    user_avatar.dart
    welcome_name_dialog.dart

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DESIGN SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIMARY TOKENS (dark theme):
  primary          #4F8CFF    onPrimary       #002D6C
  primaryContainer #1A2438    onPrimaryContainer #00275F
  primaryDark      #004398

SECONDARY TOKENS (dark theme):
  secondary        #BCC6E1    onSecondary       #263045
  secondaryContainer #3F495F  onSecondaryContainer #AEB8D2

TERTIARY TOKENS (dark theme):
  tertiary         #FFB77B    onTertiary        #4D2700
  tertiaryContainer #D87802   onTertiaryContainer #432100

BACKGROUND / SURFACE (dark theme):
  background       #0B1220    surface           #141D2E
  surfaceContainerLowest #0B0E15
  surfaceContainerLow    #191B22
  surfaceContainer       #1D1F27
  surfaceContainerHigh   #272A31
  surfaceContainerHighest #32353C
  surfaceVariant  #32353C    card #1A2438

TEXT (dark theme):
  onSurface / textPrimary      #E1E2EC
  onSurfaceVariant / textSecondary #C2C6D6
  outline / textMuted          #8C909F
  outlineVariant / divider     #424753

ERROR / STATUS:
  error            #FFB4AB    errorContainer #93000A
  onError          #690005    onErrorContainer #FFDAD6
  danger           #FFB4AB (= error)
  success          #22C55E
  warning          #FFB77B (= tertiary)

CATEGORY ACCENT ICONS:
  lengthIcon   #4F8CFF    weightIcon   #FFB77B    tempIcon     #FFB4AB
  areaIcon     #A855F7    volumeIcon   #F97316    speedIcon    #06B6D4
  dataIcon     #EC4899    timeIcon     #6366F1    angleIcon    #14B8A6
  energyIcon   #F59E0B    powerIcon    #8B5CF6    pressureIcon #0EA5E9

LIGHT THEME:
  primary          #2563EB    scaffoldBackground #F8FAFC
  surface          #FFFFFF    background        #F8FAFC
  lightTextPrimary #0F172A    lightTextSecondary #475569
  borderLight      #E2E8F0    borderDark        #424753
  secondary        #475569    tertiary          #D97706

BORDER RADIUS:
  Cards             16  (theme) / 18 (cosmic glassmorphic)
  Buttons/Inputs    16
  Chips             20 (quick filters) / 24 (bottom nav pill)
  Bottom nav height 72

TYPOGRAPHY (system font, Inter family in text theme):
  displayLarge   36px w700 letterSpacing -0.72
  headlineMedium 28px w600 letterSpacing -0.3
  titleMedium    22px w500   titleLarge 22px w600
  bodyLarge      16px w400   labelMedium 15px w500
  bodySmall      13px w400   labelSmall  11px w500
  Input hint     16px        Input user  32px

COSMIC THEME (glassmorphic dark variant):
  blur: 10.0, border: 1.2
  cosmicCardSurface: #141D2E, cosmicBorder: #394457
  primaryGlow: #4F8CFF, secondaryGlow: #FFB77B
  tertiaryGlow: #6366F1, accentGlow: #22C55E

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
QUALITY RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Live conversion: result updates on every keystroke — no Calculate button
- Temperature: special-case formulas, never multiplier
- Result format: max 8 significant digits, no scientific notation for
  values between 0.000001 and 999999999
- Empty input → result shows "—"
- Invalid input → result shows "Invalid"
- Keyboard: dismisses on tap outside input field
- Swap button: rotates 180° with 200ms animation on tap
- Category change: resets both dropdowns to index 0 of new category
- History: last 50 entries, newest first, persisted in SharedPreferences
- Dark mode: follows system by default, overridable in Settings
- Offline: zero internet required except AdMob + currency rates
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 37 (Android 17)
- App size target: under 15MB
- Never use print() — use debugPrint() only
- Use const constructors wherever possible
- Every class and public function needs a doc comment (///)
- Null-safe Dart 3 only — no placeholders, no TODO comments

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PUBSPEC DEPENDENCIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
flutter (sdk)
cupertino_icons: ^1.0.8
provider: ^6.1.0
shared_preferences: ^2.2.0
google_mobile_ads: ^9.0.0
share_plus: ^13.2.1
package_info_plus: ^10.2.1
url_launcher: ^6.2.0
sensors_plus: ^7.1.0
flutter_compass: ^0.8.0
geolocator: ^14.0.3
geomag: ^0.3.0
in_app_update: ^5.0.0
image_picker: ^1.1.2
dynamic_color: ^1.7.0
quick_actions: ^1.0.0

Dev deps:
flutter_lints: ^6.0.0
flutter_launcher_icons: ^0.14.4

Assets:
  assets/data/unit_information.json
  assets/icon.png
  assets/adaptive_icon_foreground.png

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MONETIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MODEL: Free with App Open Ad per session.

AD TYPE: AppOpenAd (google_mobile_ads: ^9.0.0)
  NOT interstitial. NOT banner. NOT rewarded.
  ONLY AppOpenAd — cooldown + session cap.

Real Admob App ID   : ca-app-pub-8684958562988579~9464291585
Real App Open Ad ID : ca-app-pub-8684958562988579/4208361403

WHEN TO SHOW:
  ✓ Cold start (app launched fresh)
  ✓ Warm start after 5+ minutes in background
  ✗ Never if ad failed to load (skip silently)
  ✗ Max 3 shows per session

LOADING STRATEGY:
  - Load AppOpenAd during splash screen (parallel to service init)
  - Splash screen duration: 1500ms minimum
  - 2s delay on cold start before showing ad
  - If ad ready within 1500ms → show after splash
  - If ad not ready → skip, go straight to app
  - Never delay user more than 1500ms total for any reason

COOLDOWN:
  - Minimum 5 minutes between ad shows
  - Store lastAdShownTimestamp in SharedPreferences
  - On each cold start: check timestamp before showing
  - Session cap: 3 ad shows maximum

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
  ✗ No ad_banner_widget.dart exists
  The only ad-related code is in AdmobService (AppOpenAd).

ADMOB SERVICE FILE: lib/services/admob_service.dart
  Responsibilities:
  - Initialize MobileAds SDK (done at splash)
  - Load AppOpenAd
  - Show AppOpenAd (if loaded + cooldown passed + session cap)
  - Track lastAdShownTimestamp + show count
  - Expose: isAdReady (bool), showAdIfEligible()

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONVERSION ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
File: lib/services/conversion_service.dart
  - Stateless — all methods are static
  - Handles: normal (factor-based), temperature, fuel economy,
    cooking (group-guarded), shoe size, clothing size, number base,
    typography, pace, blood sugar, BMI, percentage ratio, density,
    flow rate, radiation, and more
  - Each category's units have a toBase factor in units_data.dart
  - Special-case categories use custom formulas (temperature, BMI, etc.)

SMART PARSER: lib/services/smart_parse_service.dart
  - Offline NL parser for natural queries
  - Supports: "10 km to miles", "100 usd to pkr", "5 feet 9 inches to cm"
  - Parses compound units (feet+inches), currency codes, category names

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
KEY SERVICES SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CompassService        — magnetic heading via sensors_plus, true north via geolocator + geomag
BubbleLevelService    — accelerometer pitch/roll streaming via sensors_plus
CurrencyService       — Frankfurter API v2 fetcher + SharedPreferences cache
InAppUpdateService    — Google Play in-app update (flexible/IMMEDIATE)
HomeLayoutService     — persist home section ordering (7 section types)
NavigationService     — AppNavigator InheritedNotifier for programmatic tab switching
InsightsService       — total conversions, favorite category, most used unit, last used
SmartParseService     — offline NL conversion query parser
ShortcutsService      — dynamic app launcher shortcuts (7 shortcuts)

HOME LAYOUT SECTIONS (7):
  insights, collections, pinned, frequently_used, categories, did_you_know, recent

PREDEFINED COLLECTIONS (9):
  Everyday, Student, Developer, Engineering, Cooking, Travel, Fitness, Science, Electrical

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPENCODE TASK RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Read AGENTS.md before every task
2. Follow the folder structure exactly — never create files outside it
3. Complete Dart code — no placeholders, no TODO comments
4. Null-safe Dart 3 only
5. Every class and public function needs a doc comment (///)
6. Never use print() — use debugPrint() only
7. Use const constructors wherever possible
8. Use AppColors tokens from core/colors.dart — never hardcode hex values
9. Use AppTheme from core/theme.dart — never build ThemeData inline
10. After each task output:

✓ COMPLETE: [task name]
📁 Files created/edited: [list]
🧪 Test: [how to verify this works]
⚠️  Notes: [anything to watch or "none"]
