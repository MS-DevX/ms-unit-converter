# Dependency Upgrade Report

**Date:** 2026-06-21
**Flutter:** 3.44.1 / Dart 3.12.1

---

## Summary

| Upgraded | Not upgraded | Total reviewed |
|---------:|------------:|---------------:|
| 1 direct | 11 direct | 12 |
| 14 transitive | — | — |

---

## Upgraded Packages

### Direct Dependencies

| Package | From | To | Reason |
|---------|------|----|--------|
| `in_app_purchase` | 3.2.3 | 3.3.0 | Minor bump within `^3.1.0` constraint. Updates `in_app_purchase_android` to `^0.5.0`. No API changes. Safe. |

### Transitive Dependencies (automatic via `flutter pub upgrade`)

| Package | From | To | Notes |
|---------|------|----|-------|
| `code_assets` | 1.2.0 | 1.2.1 | Patch |
| `geolocator_apple` | 2.3.13 | 2.3.14 | Patch |
| `geolocator_platform_interface` | 4.2.6 | 4.2.8 | Patch |
| `hooks` | 2.0.0 | 2.0.2 | Patch |
| `in_app_purchase_android` | 0.4.0+11 | 0.5.1 | Minor, required by `in_app_purchase` 3.3.0 |
| `in_app_purchase_platform_interface` | 1.4.0 | 1.4.1 | Patch |
| `in_app_purchase_storekit` | 0.4.9 | 0.4.10 | Patch |
| `path_provider` | 2.1.5 | 2.1.6 | Patch |
| `path_provider_platform_interface` | 2.1.2 | 2.1.3 | Patch |
| `shared_preferences_android` | 2.4.23 | 2.4.26 | Patch |
| `url_launcher_android` | 6.3.30 | 6.3.32 | Patch |
| `webview_flutter` | 4.13.1 | 4.14.0 | Minor |
| `webview_flutter_android` | 4.12.0 | 4.13.0 | Minor |
| `webview_flutter_wkwebview` | 3.25.1 | 3.26.0 | Minor |

---

## Packages NOT Upgraded

### `provider` — current: 6.1.x
- Already at latest within constraint `^6.1.0`
- **No upgrade needed**

### `shared_preferences` — current: 2.x
- Already at latest within constraint `^2.2.0`
- Transitive `shared_preferences_android` upgraded to 2.4.26
- **No upgrade needed**

### `google_mobile_ads` — current: 5.3.1, latest: 9.0.0
- 4 major versions ahead (5→9)
- Major API breaking changes: new ad loading API, Ad Manager changes, initialization changes
- The `AppOpenAd` class API used by this project may differ significantly
- **Delayed** — requires dedicated migration effort and thorough testing

### `share_plus` — current: 7.2.2, latest: 13.1.0
- 6 major versions ahead (7→13)
- Multiple breaking changes: return types, error handling, platform interface
- **Delayed** — apply when `share_plus` is actively needed for iOS work

### `package_info_plus` — current: 6.0.0, latest: 10.1.0
- 4 major versions ahead (6→10)
- Platform interface changes, breaking API changes
- **Delayed** — only used for about screen; low impact

### `url_launcher` — current: 6.2.x
- Already at latest within constraint `^6.2.0`
- Transitive `url_launcher_android` upgraded to 6.3.32
- **No upgrade needed**

### `sensors_plus` — current: 6.1.2, latest: 7.0.0
- 1 major version ahead (6→7)
- The compass service relies on `sensors_plus` for accelerometer + magnetometer
- 7.0.0 changelog not locally cached; risks breaking sensor event handling
- **Delayed** — low priority; current version works

### `geolocator` — current: 12.0.0, latest: 14.0.3
- 2 major versions ahead (12→14)
- API changes in location permission handling and stream APIs
- The compass service uses `Geolocator.requestPermission()` and `getPositionStream()`
- **Delayed** — requires testing on real iOS/Android hardware

### `geomag` — current: 0.3.0
- Already at latest within constraint `^0.3.0`
- **No upgrade needed**

### `flutter_lints` — current: 6.0.x
- Already at latest within constraint `^6.0.0`
- **No upgrade needed**

### `flutter_launcher_icons` — current: 0.14.4
- Already at latest within constraint `^0.14.4`
- **No upgrade needed**

---

## Breaking Changes Handled
None. All upgrades were within compatible version ranges.

## Verification
- `flutter pub get` ✅
- `dart format .` ✅ (0 files changed)
- `flutter analyze` ✅ (0 issues)
- `flutter test` ✅ (74 pass, 3 pre-existing failures unrelated to upgrade)

## Remaining Risks
| Risk | Detail |
|------|--------|
| `google_mobile_ads` 5.3.1 | Latest is 9.0.0 — delaying means missing bug fixes and new features |
| `share_plus` 7.2.2 | >6 major versions behind — migrate when iOS support is added |
| `package_info_plus` 6.0.0 | >4 major versions behind — low priority |
| `sensors_plus` 6.1.2 | Only 1 version behind — safe to delay |
| `geolocator` 12.0.0 | 2 versions behind — test before upgrading |
| Plugin KGP warnings | Multiple plugins still apply Kotlin Gradle Plugin; Flutter's Built-in Kotlin migration not yet available for all |
