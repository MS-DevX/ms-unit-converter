# CI & Security Report

## Workflow Files Created

| File | Purpose |
|------|---------|
| `.github/workflows/flutter_ci.yml` | Flutter validation + Gitleaks secret scanning |
| `.github/dependabot.yml` | Automated dependency update checks |

## What Runs in CI

### Flutter CI (`flutter` job)

Triggered on: pull requests, pushes to `main`, pushes to `upgrade/security-currency-ui-v2-1`.

| Step | What it does |
|------|-------------|
| `actions/checkout@v4` | Check out repository |
| `subosito/flutter-action@v2` | Install Flutter stable with cache |
| `flutter pub get` | Resolve Dart dependencies |
| `dart format --set-exit-if-changed .` | Fail if any file isn't formatted |
| `flutter analyze` | Run Dart static analysis (0 warnings policy) |
| `flutter test` | Run all unit + widget tests (113 currently) |
| `validate_units.py` | Validate 49 conversion formulas independently |
| `build_release_pdf.py --help` | Verify PDF tooling is functional (non-fatal) |
| `flutter build apk --debug` | Verify debug APK compiles successfully |

### Secret Scanning (`security` job)

| Step | What it does |
|------|-------------|
| `actions/checkout@v4` with full depth | Full git history for Gitleaks |
| `gitleaks/gitleaks-action@v3` | Scan for credentials; redact findings; fail on match |

Gitleaks runs with `redact: true` so matched secrets are replaced with
`REDACTED` in the CI logs. The raw secret never appears in output.

### Dependabot

- Checks **pub** (Dart/Flutter) packages weekly on Mondays.
- Checks **GitHub Actions** weekly on Mondays.
- Minor/patch updates are grouped into single PRs to reduce noise.

## What Is Intentionally Not Included

| Feature | Why Omitted |
|---------|-------------|
| **Release signing** | Signing keys (`key.properties`, `.jks`) are in `.gitignore` and never uploaded. Release builds require local developer setup. |
| **Play Store upload** | Deployment is a manual process per the release guide. CI does not have access to service accounts or Google Play Console. |
| **Code signing** | No Android JKS, no iOS provisioning profiles, no Fastlane match. |
| **Dangerous Gitleaks mode** | Gitleaks runs in redact mode; raw findings are not uploaded as artifacts. |
| **Scheduled cron (Flutter CI)** | Only runs on push/PR to avoid unnecessary compute; Dependabot covers dependency checks. |
| **Major version grouping** | Only minor + patch updates are grouped; major updates create individual PRs for focused review. |
| **Paid GitHub features** | All workflows use free-tier GitHub-hosted runners and open-source actions. |

## How to Add Release Signing Later Safely

When you are ready to sign release APKs in CI:

1. **Store secrets in GitHub Actions secrets:**
   - `STORE_PASSWORD` — keystore password
   - `KEY_PASSWORD` — key password
   - `KEY_ALIAS` — key alias
   - `SIGNING_KEY_BASE64` — base64-encoded `.jks` file

2. **Add a new workflow or job step:**
   ```yaml
   - name: Decode signing key
     run: echo "${{ secrets.SIGNING_KEY_BASE64 }}" | base64 -d > android/app/upload-key.jks

   - name: Build release APK
     run: flutter build apk --release
     env:
       STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
       KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
       KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
   ```

3. **Never** log secrets in CI output. GitHub Actions automatically
   masks secret values in logs.

4. **Keep `android/key.properties` in `.gitignore`** — it is for local
   development only.

5. **Add Play Store upload** via `r0adkll/upload-google-play@v1`
   with a service account JSON stored as a secret.

The current CI is intentionally limited to **debug builds only** to
avoid the risk of accidentally signing with development keys.
