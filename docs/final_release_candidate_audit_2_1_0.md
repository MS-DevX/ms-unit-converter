# MS Unit Converter — Final Release Candidate Audit — v2.1.0

**Date:** 2026-06-22  
**Version:** `2.1.0+3`  
**Branch:** `main` (`c51cc0d`)  
**Auditor:** Automated release audit

---

## 1. Identity

| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| applicationId | `com.msdevx.unitconverter` | `com.msdevx.unitconverter` | ✓ |
| namespace | `com.msdevx.unitconverter` | `com.msdevx.unitconverter` | ✓ |
| appName (AndroidManifest) | `MS Unit Converter` | `MS Unit Converter` | ✓ |
| appName (AppConstants) | `MS Unit Converter` | `MS Unit Converter` | ✓ |
| versionName | `2.1.0` | `2.1.0` | ✓ |
| versionCode | `3` | `+3` (pubspec.yaml) | ✓ |

**Identity: PASS**

---

## 2. Security

| Check | Status |
|-------|--------|
| No signing passwords in docs | ✓ (placeholders only in RELEASE_GUIDE.md) |
| key.properties gitignored | ✓ (confirmed via `git check-ignore`) |
| .jks / .keystore gitignored | ✓ (confirmed via `git check-ignore`) |
| No .env committed | ✓ (no `.env` file exists) |
| No API keys in source | ✓ (Frankfurter requires no key; ad unit IDs are public) |
| Secret scan (api_key, secret, password) | ✓ (no matches in tracked source) |

**Security: PASS**

---

## 3. Android / Play Store Compliance

| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| targetSdk | >= 35 | 35 | ✓ |
| minSdk | >= 21 | 21 (flutter default) | ✓ |
| INTERNET permission | declared and justified | Declared — for AdMob + currency API | ✓ |
| Location permission | declared and justified | ACCESS_FINE_LOCATION + ACCESS_COARSE — compass true north only | ✓ |
| Background location | not declared | Not declared | ✓ |
| cleartext traffic | disabled | `usesCleartextTraffic="false"` | ✓ |
| AdMob App ID | in manifest + constants | Both match | ✓ |
| IAP product ID | in constants | `com.msdevx.unitconverter.removeads` | ✓ |
| Privacy policy URL | valid | `https://msdevx.com/msunit-privacy` | ✓ |

**Android/Play: PASS**

---

## 4. Feature Verification

| Feature | Status |
|---------|--------|
| 20 unit categories (length..typography) | ✓ (confirmed in `units_data.dart` enum) |
| PKR exists and is pinned | ✓ (confirmed in `currencies_data.dart`) |
| Common currencies (USD, EUR, GBP, JPY, AED, SAR, INR) | ✓ (all pinned) |
| Currency search by code/name/symbol | ✓ (`currency_service.dart` + search UI) |
| Currency cache (SharedPreferences) | ✓ (`saveRates` + `loadCachedRates`) |
| Currency offline fallback | ✓ (hardcoded fallback rates for all 53) |
| Compass (magnetic) no location needed | ✓ (sensors_plus, no location required) |
| Compass no re-prompt after denial (same session) | ✓ (`enableTrueNorth` tracks `_lastPermissionResult`) |
| Compass true-north with location | ✓ (geolocator + magnetic declination) |
| Settings (theme, precision, IAP) | ✓ (all wired via `SettingsProvider`) |
| History (save, load, swipe-delete, clear) | ✓ (SharedPreferences + `HistoryService`) |
| Favorites (pin/unpin, persist, reorder) | ✓ (`FavoritesProvider` + `FavoritesService`) |
| Smart parser (paste `42km` → auto-detect) | ✓ (`SmartParseService`) |
| Bubble level (calibrate, gauge, pitch/roll) | ✓ (`BubbleLevelService` + `BubbleLevelWidget`) |

**Features: PASS**

---

## 5. Automated Test Results

| Test | Result |
|------|--------|
| `flutter pub get` | ✓ (0 errors, dependencies resolved) |
| `dart format --set-exit-if-changed .` | ✓ (0 files changed) |
| `flutter analyze` | ✓ (0 issues) |
| `flutter test` | ✓ (297/297 passed) |
| `python3 tools/conversion_validation/validate_units.py` | ✓ (49/49 passed) |
| `python3 tools/docs_export/build_release_pdf.py --help` | ✓ (tool runs) |
| `flutter build apk --debug --target-platform android-arm64` | ✓ (builds successfully) |

**Automated Tests: PASS**

---

## 6. Manual Testing Checklist

Use this checklist for internal testing on physical devices.

### First launch
- [ ] Splash screen shows for ~1500ms with app icon + loading indicator
- [ ] App Open Ad loads (check logcat: `Ad request successful`)
- [ ] After ad/splash, main screen appears with category grid
- [ ] No crashes on cold start

### No-internet unit conversions (airplane mode)
- [ ] All 20 categories convert correctly offline
- [ ] Result updates on every keystroke
- [ ] Swap button rotates and inverts units
- [ ] Copy/share buttons work

### No-internet currency tab
- [ ] Currency screen shows "Rates by Frankfurter" with offline indicator
- [ ] Cached rates (if previously fetched) are displayed
- [ ] Fallback rates used if no cache exists
- [ ] Error state shown gracefully (no crash, no blank screen)

### Online currency refresh
- [ ] Pull-to-refresh fetches fresh rates
- [ ] Pinned quick pairs (USD→PKR etc.) update
- [ ] Search bar filters currencies by code/name/symbol
- [ ] Share button on result rows works

### PKR conversions
- [ ] PKR appears first in the pinned list
- [ ] PKR→USD, USD→PKR, AED→PKR, SAR→PKR, GBP→PKR, EUR→PKR all convert
- [ ] Fallback rate for PKR (278.4) used when offline

### Compass — opens without location prompt
- [ ] Open compass tab → no location dialog appears
- [ ] Magnetic heading updates in real time
- [ ] 8 direction chips are tappable

### Compass — location denied
- [ ] Tap "True North" toggle → location dialog appears
- [ ] Tap "Deny" → True North stays off, no crash
- [ ] Compass continues showing magnetic north
- [ ] No error/warning displayed to user

### Compass — second GPS tap after denial (same session)
- [ ] Tap "True North" again → **No location dialog re-appears**
- [ ] Status shows appropriate message (not "Requesting...")
- [ ] All other compass controls still work

### Compass — permission granted
- [ ] Tap "True North" → location dialog → "Allow"
- [ ] GPS coordinates appear on screen
- [ ] Heading shifts from magnetic to true north
- [ ] Coordinates update when moving

### Settings — theme change
- [ ] Toggle theme: System → Light → Dark → System
- [ ] All screens reflect the change
- [ ] Preference persists across app restart

### History
- [ ] Perform a few conversions → switch to History tab
- [ ] Entries appear newest-first
- [ ] Swipe to delete individual entry
- [ ] "Clear All" removes all entries
- [ ] History persists across app restart

### App background/foreground
- [ ] Press home → reopen app → no crash
- [ ] App returns to previous screen
- [ ] State is preserved (input values, results)
- [ ] Ad cooldown respected (4h)

### Tablet layout
- [ ] App runs on tablet without layout overflow
- [ ] Category grid adapts to wider screen
- [ ] Text is readable at all sizes

### Dark mode
- [ ] Set system to dark mode → app follows
- [ ] All screens have dark backgrounds, light text
- [ ] Contrast is sufficient on all screens
- [ ] No unreadable text on dark surfaces

### Light mode
- [ ] Set system to light mode or toggle to Light
- [ ] All screens have light backgrounds, dark text
- [ ] No washed-out elements

---

## 7. Final Recommendation

### Ready for internal testing

All audit checks pass:

| Category | Result |
|----------|--------|
| Identity | ✓ PASS |
| Security | ✓ PASS |
| Android/Play compliance | ✓ PASS |
| Feature completeness | ✓ PASS |
| Automated tests | ✓ 7/7 pass |
| Manual checklist | ⏳ Requires device testing |

**Pre-existing non-blocking notes:**
- Kotlin Gradle Plugin warning from `package_info_plus`, `sensors_plus`, `share_plus` — documented in RELEASE_GUIDE.md, cosmetic, no functional impact.

**Next step:** Complete the manual testing checklist above on 1-2 physical Android devices (Android 14+ recommended). If all checks pass, promote to staged rollout (5-10%).
