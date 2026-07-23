# MS Unit Converter — Release Notes — v2.1.0

## New & Improved

### PKR / Pakistani Rupee support
- PKR is now a pinned currency (appears first in the currency list).
- Quick pairs: USD→PKR, PKR→USD, AED→PKR, SAR→PKR, GBP→PKR, EUR→PKR.
- Fallback rate for PKR is maintained and verified.

### More currencies
- Currency data now fetched dynamically from the Frankfurter v2 API.
- 53 currencies supported with search by code, name, or symbol.

### Improved currency cache / offline behaviour
- Exchange rates are cached to SharedPreferences on each successful fetch.
- Cached rates load immediately on next launch; background refresh updates them.
- Hardcoded fallback rates available for all 53 currencies when offline.
- Graceful degradation: stale cache shown when network unavailable.

### Compass improvements
- Fixed black screen on devices with reduced transparency / accessibility settings.
- Improved true-north fallback when GPS/location is unavailable.
- Bubble level layout fixed — gauge fills available space without overflow.
- Compass rose re-centred; direction labels and status text readability improved.

### Location denial behaviour (current session)
- If the user denies location permission for true north, the app does **not**
  re-prompt in the same session.
- Magnetic compass continues to work without location.
- Permission is auto-requested on screen entry for a smoother experience.

### Security & documentation
- Privacy policy URL updated: `msdevx.com/msunit-privacy`.
- `docs/privacy_data_safety_notes.md` added — Play Store Data Safety form reference.
- RELEASE_GUIDE.md updated with version bump, staged rollout, and rollback plan.
- README.md rewritten with complete feature list and security notes.
- AGENTS.md updated with project conventions.

### UI / search / features
- Converter input bar border styling fixed (no oval fill when focused).
- History auto-saves with 800ms debounce; deduplication built in.
- Smart paste parser improvements for unit detection.
- Favourite categories persisted and displayed at top of home screen.
- Conversion result formatting respects decimal precision setting.

### Bug fixes & test improvements
- Fixed pre-existing crash when `setCategory` was called during widget build.
- All 297 tests pass; 17 test files covering services, models, providers, widgets.
- Added test coverage for `SettingsProvider` (premium flag, theme, cooldown constants).
- Added tests for `IapService.isPurchased()`.
- Python validation tooling (`validate_units.py`) updated.
