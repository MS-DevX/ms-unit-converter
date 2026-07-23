# MS Unit Converter — Build Output — v2.1.0

## Build command

```
flutter build appbundle --release
```

## Output

| Field | Value |
|-------|-------|
| AAB path | `build/app/outputs/bundle/release/app-release.aab` |
| Size | 58.2 MB |
| versionName | `2.1.0` |
| versionCode | `3` |
| targetSdk | 35 |
| minSdk | 21 |
| Build date | 2026-06-22 |
| Build time | 13:27 UTC |

## Pre-build verification

| Check | Result |
|-------|--------|
| `flutter clean` | ✓ |
| `flutter pub get` | ✓ |
| `dart format --set-exit-if-changed .` | ✓ (0 changes) |
| `flutter analyze` | ✓ (0 issues) |
| `flutter test` | ✓ (297/297) |
| `python3 tools/conversion_validation/validate_units.py` | ✓ (49/49) |
| `python3 tools/docs_export/build_release_pdf.py --help` | ✓ (tool available) |

## Notes

- The AAB is signed with the release keystore via `android/key.properties`.
- Kotlin Gradle Plugin warnings from `package_info_plus`, `sensors_plus`, `share_plus` are pre-existing and non-blocking.
- Font tree-shaking reduced MaterialIcons from 1.6 MB to 10.7 KB (99.3% reduction).
- Universal APK (debug) was ~53 MB; the AAB at 56 MB delivers split APKs (~22 MB per device) via Play Store.
