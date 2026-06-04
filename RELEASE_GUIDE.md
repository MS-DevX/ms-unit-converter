# MS Unit Converter — Release Guide

## Project Structure

```
unit_converter/
├── lib/
│   ├── main.dart                  # App entry, Provider wiring, theme setup
│   ├── core/
│   │   ├── theme.dart             # AppTheme — light + dark ThemeData
│   │   ├── constants.dart         # App-wide config (ad IDs, IAP IDs, strings)
│   │   └── colors.dart            # AppColors — all color tokens
│   ├── data/
│   │   └── units_data.dart        # Unit definitions + conversion factors (8 categories)
│   ├── models/
│   │   ├── unit_model.dart        # UnitModel class
│   │   ├── conversion_result.dart # ConversionResult class
│   │   └── history_entry.dart     # HistoryEntry class
│   ├── providers/
│   │   ├── converter_provider.dart # Conversion state (category, units, value, result)
│   │   ├── history_provider.dart   # History state (load, save, clear)
│   │   └── settings_provider.dart  # Theme mode, isPremium flag
│   ├── services/
│   │   ├── conversion_service.dart # Pure conversion logic (no UI)
│   │   ├── history_service.dart    # SharedPreferences read/write
│   │   ├── admob_service.dart      # AppOpenAd load/show logic
│   │   └── iap_service.dart        # In-app purchase (remove ads)
│   ├── screens/
│   │   ├── splash_screen.dart      # Splash (1500ms) + ad init
│   │   ├── converter_screen.dart   # Main screen — bottom nav item 1
│   │   ├── history_screen.dart     # History — bottom nav item 2
│   │   └── settings_screen.dart    # Settings — bottom nav item 3
│   ├── widgets/
│   │   ├── category_chip_bar.dart  # Horizontal scrollable category selector
│   │   ├── unit_dropdown.dart      # Styled unit dropdown
│   │   ├── swap_button.dart        # Animated rotate swap button
│   │   ├── result_display.dart     # Result + formula + copy button
│   │   ├── history_tile.dart       # Single history list item
│   │   └── empty_state_widget.dart # Reusable empty state (icon + message)
│   └── utils/
│       ├── formatters.dart         # Number formatting helpers
│       └── validators.dart         # Input validation helpers
├── android/
│   ├── app/
│   │   ├── build.gradle.kts        # App-level build config, signing, proguard
│   │   ├── proguard-rules.pro      # ProGuard rules
│   │   ├── upload-keystore.jks     # 🔑 RELEASE SIGNING KEYSTORE
│   │   └── src/
│   │       └── main/
│   │           └── AndroidManifest.xml  # AdMob App ID, permissions
│   ├── build.gradle.kts            # Project-level Gradle config
│   ├── gradle/
│   │   └── wrapper/                # Gradle wrapper (use for builds)
│   ├── gradle.properties           # Gradle JVM settings
│   ├── key.properties              # 🔑 Keystore alias + passwords (gitignored)
│   ├── settings.gradle.kts         # Module settings
│   ├── local.properties            # Local Android SDK path (gitignored)
│   ├── gradlew                     # Gradle wrapper script (Linux/macOS)
│   └── gradlew.bat                 # Gradle wrapper script (Windows)
├── ios/                            # iOS platform code (for future Play Store)
├── assets/
│   └── icon.png                    # App launcher icon
├── test/                           # Unit tests
├── pubspec.yaml                    # ★ VERSION + dependencies
├── RELEASE_GUIDE.md                # This file
└── AGENTS.md                       # OpenCode agent rules
```

---

## Key Files Map

### 🔢 Version
| File | Line | What to change |
|------|------|----------------|
| `pubspec.yaml` | 19 | `version: x.y.z+b` — bump `x.y.z` (versionName) and/or `b` (versionCode) |

**Android mapping:** `versionName` = `x.y.z`, `versionCode` = `b` (integer, must increment)

### 🔑 Release Signing
| File | Purpose | In git? |
|------|---------|---------|
| `android/app/upload-keystore.jks` | The actual keystore binary | ❌ (`**/*.jks` in `.gitignore`) |
| `android/key.properties` | Keystore alias, passwords, storeFile path | ❌ (`key.properties` in `.gitignore`) |
| `android/app/build.gradle.kts:36-41` | Reads `key.properties` to configure `signingConfigs.release` | ✅ |

### 📦 Monetization IDs
| ID | Value | Defined in | Used in |
|----|-------|------------|---------|
| AdMob App ID | `ca-app-pub-8684958562988579~6766583891` | `lib/core/constants.dart:19` + `AndroidManifest.xml:35` | AdMob SDK init |
| App Open Ad Unit ID | `ca-app-pub-8684958562988579/2956999697` | `lib/core/constants.dart:23` | `lib/services/admob_service.dart:52` |
| IAP Remove Ads ID | `com.msdevx.unitconverter.removeads` | `lib/core/constants.dart:27` | `lib/services/iap_service.dart:74,77,153` |
| IAP Display Price | `$1.99` | `lib/core/constants.dart:30` | `lib/screens/settings_screen.dart:115` |

**To switch between test and production:** Update the values in `lib/core/constants.dart` and `AndroidManifest.xml`.  
Google test ad unit: `ca-app-pub-3940256099942544/9257395921`

### 🎨 Theme & Colors
| File | What it controls |
|------|------------------|
| `lib/core/colors.dart` | All color tokens (primary, surfaces, text, success/warning/danger) |
| `lib/core/theme.dart` | `ThemeData` for light + dark mode, applies colors from `colors.dart` |

---

## Build Commands

### Debug APK (quick test on device)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (sideload testing)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Release AAB (Play Store submission)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Clean build (start fresh)
```bash
flutter clean && flutter pub get
```

### Override version from CLI (optional)
```bash
flutter build appbundle --release --build-name=1.1.0 --build-number=2
```

---

## Release Checklist

### Before Every Release
1. — [ ] Bump version in `pubspec.yaml:19` (e.g. `1.0.0+1` → `1.1.0+2`)
2. — [ ] Run tests: `flutter test`
3. — [ ] Clean build: `flutter clean && flutter pub get`
4. — [ ] Build release AAB: `flutter build appbundle --release`
5. — [ ] Verify the output at `build/app/outputs/bundle/release/app-release.aab`

### First-Time Setup (one-time)
- [ ] Generate upload keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- [ ] Place keystore in `android/app/upload-keystore.jks`
- [ ] Create `android/key.properties` with:
  ```
  storePassword=<your-password>
  keyPassword=<your-password>
  keyAlias=upload
  storeFile=upload-keystore.jks
  ```
- [ ] Create Google Play Console listing
- [ ] Create IAP product `com.msdevx.unitconverter.removeads` in Play Console ($1.99, managed product)

### First Upload to Play Store
1. Go to [Google Play Console](https://play.google.com/console/)
2. Create a new app with package name `com.msdevx.unitconverter`
3. Go to **Release > Production > Create new release**
4. Upload `build/app/outputs/bundle/release/app-release.aab`
5. Fill in release notes
6. Roll out

### Subsequent Updates
1. Bump version in `pubspec.yaml`
2. Build AAB
3. Upload to existing release on Play Console

---

## Troubleshooting

### Build fails: "Keystore was tampered with, or password was incorrect"
→ Check `android/key.properties` passwords match the keystore.

### Build fails: "Could not find storeFile"
→ Verify `storeFile` path in `key.properties`. For `upload-keystore.jks` in `android/app/`, the relative path from `android/` is `app/upload-keystore.jks`.

### "Daemon compilation failed" / Kotlin cache errors
→ Run `flutter clean && flutter pub get` and rebuild. These are stale cache issues.

### Ad not showing
→ Ensure you're using a real device (not emulator for production ads).  
→ Check ad unit ID in `lib/core/constants.dart:23`.  
→ Verify AdMob App ID in `AndroidManifest.xml:35`.

### IAP not working
→ Product must be published in Play Console first.  
→ Test with a Play Console tester account (License Testing).  
→ Check product ID matches `lib/core/constants.dart:27`.
