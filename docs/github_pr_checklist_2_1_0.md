# GitHub Pull Request Checklist — v2.1.0

---

## 1\. Branch information

- **Source:** `upgrade/security-currency-ui-v2-1`
- **Target:** `main`
- **PR title:** `Upgrade MS Unit Converter: security, PKR currency, UI, tests, CI`

---

## 2\. Required local checks

Run each command from the repository root.

- [ ] `flutter pub get` — resolves without errors.
- [ ] `dart format --set-exit-if-changed .` — no formatting changes needed.
- [ ] `flutter analyze` — zero errors, zero warnings (info-level only).
- [ ] `flutter test` — all unit/widget tests pass.
- [ ] `python tools/conversion_validation/validate_units.py` — all conversion factors validated.
- [ ] `python tools/docs_export/build_release_pdf.py --help` — if PDF tooling is present, the help text is displayed; otherwise skip.
- [ ] `flutter build apk --debug` — debug APK builds successfully.

---

## 3\. Security checks

- [ ] **No `key.properties`** — not staged, not committed, not in `.gitignore`-dirty state.
- [ ] **No `.jks` / `.keystore`** — no keystore files in the repository.
- [ ] **No `.env`** — no environment files with secrets committed.
- [ ] **No signing passwords in docs** — no keystore passwords, alias, or key passwords appear in any Markdown file.
- [ ] **gitleaks or fallback scan completed** — `gitleaks detect --source . -v` (or `git secrets --scan`, etc.) passes cleanly.

---

## 4\. Feature checks

- [ ] **PKR added** — Pakistani Rupee (PKR) is available in the currency list and converts correctly.
- [ ] **Currency search works** — typing in the currency search/filter field filters the list in real time.
- [ ] **Cached currency fallback works** — with network off, currency screen loads last-known rates and shows a "cached data" indicator.
- [ ] **Home search works** — the home screen search bar filters categories or units.
- [ ] **Formula explanations work** — tapping the info/help icon on a conversion shows the formula.
- [ ] **Decimal precision setting works** — changing the decimal precision in Settings updates result formatting throughout the app.
- [ ] **Compass fallback works** — when GPS/location is denied, the compass screen shows manual angle entry instead of crashing.
- [ ] **GPS denial current-session rule works** — denying location mid-session (after previously granting) does not cause a double-prompt or crash; the compass degrades gracefully.
- [ ] **UI reviewed** — all screens match the design system in `AGENTS.md` (colours, border radii, font sizes, spacing).

---

## 5\. Release checks

- [ ] **`applicationId` unchanged** — still `com.msdevx.unitconverter`.
- [ ] **`versionName` / `versionCode` increased** — higher than the current production release.
- [ ] **`targetSdk` Play Store compliant** — meets Play Console's current target SDK requirement.
- [ ] **Privacy / Data Safety docs updated** — `docs/privacy_data_safety_notes.md` reflects any new data collection or removal.
- [ ] **Release notes created** — `docs/release_notes_2_1_0.md` exists and is accurate.

---

## 6\. GitHub steps

- [ ] **Push branch** — `git push origin upgrade/security-currency-ui-v2-1`.
- [ ] **Open pull request** — created on GitHub with title and body as specified.
- [ ] **Review changed files** — inspect the diff for unintended changes, debug code, or leftover TODOs.
- [ ] **Ensure CI passes** — GitHub Actions (or other CI) shows green on all jobs.
- [ ] **Merge only after approval** — at least one reviewer has approved; no self-merge without review.

---

## PR checklist (paste into the PR description body)

```
- [X] flutter analyze passes
- [X] flutter test passes
- [X] Python validation passes
- [X] Debug APK builds
- [X] No secrets committed
- [X] PKR currency works
- [X] Offline conversions work
- [X] Currency cache works
- [X] Compass opens without automatic location prompt
- [X] Compass does not ask location twice after Not Allow in same session
- [X] Settings work
- [X] Version bumped
- [X] Release checklist updated
```
