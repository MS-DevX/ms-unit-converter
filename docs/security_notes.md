# Security Notes — MS Unit Converter

## Secrets Cleaned (2026-06-21)

| File | What was redacted | Replacement |
|---|---|---|
| `RELEASE_GUIDE.md` | `storePassword`, `keyPassword` plaintext values | `<STORE_PASSWORD>`, `<KEY_PASSWORD>` |
| `PROJECT_REFERENCE.md` | `storePassword`, `keyPassword` values; `keyAlias` | `<STORE_PASSWORD>`, `<KEY_PASSWORD>`, `<KEY_ALIAS>` |
| `docs/baseline_upgrade_audit.md` | Audit table and summary referencing plaintext passwords | Redacted descriptions without actual values |

After cleanup, `grep -rn MSDevX@2024 .` returns no results.

## Files That Must NEVER Be Committed

```
android/key.properties
**/key.properties
**/*.jks
**/*.keystore
.env
.env.*
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
local.properties
```

These are now blocked by `.gitignore`. If any exist in a clone, do not `git add -f` them.

## Local Signing Setup (after cloning)

Create `android/key.properties` (not tracked in git):

```properties
storePassword=<STORE_PASSWORD>
keyPassword=<KEY_PASSWORD>
keyAlias=<KEY_ALIAS>
storeFile=<STORE_FILE>
```

## Credential Rotation

The original signing passwords were committed in git history (commits before `57312d9`). **It is strongly recommended to rotate the signing credentials** — generate a new keystore, update the app signing in Play Console, and replace the values in the local `key.properties`.

## AdMob & IAP — Not Secrets

The following are **public-facing identifiers**, not private secrets:

| Value | Found in |
|---|---|
| AdMob App ID: `ca-app-pub-8684958562988579~6766583891` | `lib/core/constants.dart` |
| AdMob Ad Unit ID: `ca-app-pub-8684958562988579/2956999697` | `lib/core/constants.dart`, `AGENTS.md` |
| IAP Product ID: `com.msdevx.unitconverter.removeads` | `lib/core/constants.dart` |

These are open identifiers required at runtime by Google Play services and the Play Store. They do not need to be redacted.

## Secret Scanning

`gitleaks` is not installed in this environment. Use it locally:

```bash
brew install gitleaks   # macOS
sudo apt install gitleaks  # Linux (if available)
gitleaks detect --source . --verbose
```

To add Dependabot secret scanning to this repo, create `.github/dependabot.yml` and enable the "Secret scanning" toggle in the repo Settings > Security.

## Summary

- **Passwords redacted from docs**: ✅
- **.gitignore hardened**: ✅
- **Secrets in git history**: ⚠️ rotation recommended
- **CI/CD secret scanning**: ❌ not configured (no `.github/` directory yet)
