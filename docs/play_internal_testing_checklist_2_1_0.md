# Play Store Internal Testing Checklist — v2.1.0

> Use this checklist before promoting an AAB to **Internal Testing** and again before promoting to **Staged Production Rollout**.

---

## ☐ 1\. Upload AAB to Internal Testing

- [ ] Build a release AAB from the `release/2.1.0` branch.
- [ ] Upload to Play Console > Internal Testing track.
- [ ] No Play Console policy warnings (review each warning if any appear).
- [ ] Release notes entered (see `docs/release_notes_2_1_0.md`).

---

## ☐ 2\. Confirm versionCode is higher than production

- [ ] Read `versionCode` from `android/app/build.gradle` (or `pubspec.yaml` if using Flutter version plugin).
- [ ] Compare against the **latest production** versionCode in Play Console.
- [ ] versionCode is strictly greater — no gaps, no downgrades.

---

## ☐ 3\. Confirm package name matches existing app

- [ ] Package name in `android/app/build.gradle` = `com.msdevx.unitconverter`.
- [ ] Package name matches the existing listing on Play Console.

---

## ☐ 4\. Confirm Play Console accepts target SDK

- [ ] `targetSdkVersion` meets Play Console's current minimum requirement (usually latest 2 versions back).
- [ ] `compileSdkVersion` supports `targetSdkVersion`.
- [ ] No Play Console warning about soon-mandatory target SDK level.

---

## ☐ 5\. Confirm Data Safety form matches actual app behaviour

- [ ] Data Safety section in Play Console has been reviewed and updated for this release.
- [ ] No data type declared that the app does not **actually** collect (over-declaration is a compliance risk).
- [ ] All data types the app collects are declared (see `docs/privacy_data_safety_notes.md` for audited list).
- [ ] Data handling policies (encryption, sharing, deletion) are truthfully described.

---

## ☐ 6\. Confirm Privacy Policy URL works

- [ ] Privacy Policy link in Play Console listing is live and returns HTTP 200.
- [ ] Policy text covers the current app version's behaviour.
- [ ] Policy URL is reachable from the app itself (settings or first-launch flow).

---

## ☐ 7\. Confirm permissions declaration is correct

- [ ] Permissions listed in `AndroidManifest.xml` match what the app actually uses.
- [ ] No unused permissions declared.
- [ ] Dangerous permissions (if any) are accompanied by a rationale in the app.
- [ ] Play Console permissions declaration matches `AndroidManifest.xml`.

---

## ☐ 8\. Confirm ads/IAP declarations are correct

- [ ] Open the Play Console > App content > Ads.
- [ ] If ads are **kept**:
  - [ ] "Contains ads" = **Yes**.
  - [ ] Ad type(s) listed match actual implementation (AppOpenAd only — see AGENTS.md monitization section).
- [ ] If ads are **removed** (isPremium / no ad SDK linked):
  - [ ] "Contains ads" = **No**.
  - [ ] Verify no ad SDK calls remain in the release AAB (obfuscation may hide remnants).
- [ ] Open the Play Console > App content > In-app products.
- [ ] If IAP is kept:
  - [ ] IAP product `com.msdevx.unitconverter.removeads` is active and priced at $1.99.
  - [ ] "Contains in-app purchases" = **Yes**.
- [ ] If IAP is removed:
  - [ ] "Contains in-app purchases" = **No**.
  - [ ] `in_app_purchase` dependency removed from `pubspec.yaml`.

---

## ☐ 9\. Add tester accounts

- [ ] Add at least 2–3 tester Google accounts in Play Console > Internal Testing > Testers.
- [ ] Testers have accepted the invite link.
- [ ] Testers are not Developer account owners (test from a non-privileged account).

---

## ☐ 10\. Install from Play internal testing link

- [ ] Open the internal testing opt-in URL on a test device.
- [ ] App installs and opens without errors.
- [ ] Splash screen shows for ~1500 ms then transitions to main UI.
- [ ] Bottom navigation (5 tabs) renders correctly.
- [ ] Smoke-test all 8 conversion categories — type a value, confirm live result updates.
- [ ] Smoke-test Currency screen — rates load (or fallback gracefully offline).
- [ ] Smoke-test Compass screen — heading updates (or manual angle entry works).
- [ ] Smoke-test History — a conversion appears after performing one.
- [ ] Smoke-test Settings — theme toggle, about section renders.

---

## ☐ 11\. Test update over current Play Store version

- [ ] Install the **current production** version from Play Store (or sideload equivalent).
- [ ] Open the production app, perform a conversion to seed a history entry.
- [ ] Install the internal testing AAB on top (simulates an update).
- [ ] App opens without database/data migration errors.
- [ ] Old history entries survive the update.
- [ ] Settings (theme choice, premium status) survive the update.

---

## ☐ 12\. Test fresh install

- [ ] Uninstall any existing version from the test device.
- [ ] Install via internal testing link.
- [ ] First-launch flow (splash → main UI) completes without crashes.
- [ ] Default state is sensible (Length category, first unit selected, empty input → `—`).

---

## ☐ 13\. Test GPS denial current-session rule from Play-installed build

> This simulates a user who denies Location/GPS **after** granting it earlier in the same session (the "current-session rule").

- [ ] Install the build from the Play internal testing link (not via `flutter run` / sideload).
- [ ] Launch app, grant fine location when prompted on Compass screen.
- [ ] Compass screen shows a live heading.
- [ ] Switch away from Compass, then switch back.
- [ ] Deny location via quick settings or system permission dialog (remove the grant mid-session).
- [ ] Compass screen degrades gracefully — shows manual angle input, no crash, no frozen heading.
- [ ] Re-grant location — heading resumes updating.
- [ ] Test with location **never** granted — no crash, manual angle entry works.

---

## ☐ 14\. Review Play pre-launch report

- [ ] After upload, wait for Play Console to generate the **Pre-launch report** (usually 30–90 min).
- [ ] Open the report and check:
  - [ ] No crashes on any tested device/OS combination.
  - [ ] No ANRs (Application Not Responding).
  - [ ] No accessibility failures (missing content descriptions, small touch targets).
  - [ ] Screenshots look correct — no layout clipping, no overflow errors.
  - [ ] All tested locales render UI text without truncation.

---

## ☐ 15\. Fix crashes / ANRs / accessibility issues

- [ ] If any crash, ANR, or accessibility issue is found:
  - [ ] Reproduce locally (use the same device/OS as the report).
  - [ ] Fix the root cause.
  - [ ] Upload a new AAB to the same Internal Testing track.
  - [ ] Re-run steps 10–14 on the fixed build.
- [ ] Only proceed when **zero** pre-launch issues remain.

---

## ☐ 16\. Only then move to staged production rollout

- [ ] All preceding checklist items are **checked**.
- [ ] Team lead or reviewer has signed off.
- [ ] Promote to **Production** track with staged rollout (start at 1–5%).
- [ ] Monitor crash-free rate, ANR rate, and user reviews for 24–48 h before expanding.
