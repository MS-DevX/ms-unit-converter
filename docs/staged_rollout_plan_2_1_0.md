# Staged Rollout Plan — v2.1.0

---

## 1\. Internal testing

- [ ] Upload AAB to Play Console > Internal Testing.
- [ ] Run through `docs/play_internal_testing_checklist_2_1_0.md`.
- [ ] All 16 checklist items pass.
- [ ] Team lead signs off.

---

## 2\. Fix blockers

- [ ] Any crash, ANR, or accessibility issue from pre-launch report is fixed and re-tested.
- [ ] Any tester-reported regression is resolved.
- [ ] All internal testing issues show **fixed** status before moving to production.

---

## 3\. Production staged rollout

### 3.1 Start small

- [ ] Promote the same AAB (or a rebuilt one with blocker fixes) to **Production** track.
- [ ] Set initial rollout percentage to **1 %** of existing userbase.
- [ ] Target only **non-rooted, current-OS** devices initially to minimise environmental variance.

### 3.2 Monitor crash rate

- [ ] Check Play Console > Android vitals > Crashes and ANRs **daily**.
- [ ] Alert threshold: crash rate > **0.5 %** of active users on v2.1.0.
- [ ] Do not increase rollout while crash rate exceeds threshold.

### 3.3 Monitor ANR rate

- [ ] Track ANR rate alongside crash rate.
- [ ] Alert threshold: ANR rate > **0.3 %** of active users on v2.1.0.

### 3.4 Monitor reviews

- [ ] Read Play Store reviews and ratings **daily** during staged rollout.
- [ ] Look for keywords: "crash", "close", "freeze", "not working", "permission", "compass", "currency".
- [ ] Categorise each negative review: crash / ANR / UI / currency / compass / permission / other.

### 3.5 Monitor currency complaints

- [ ] Track any user reports of stale FX rates, missing currencies, or conversion errors.
- [ ] If PKR is reported missing — **immediate stop**; do not increase rollout.
- [ ] If Frankfurter.app API is reported down — consider a hotfix with hardcoded fallback.

### 3.6 Monitor compass / location complaints

- [ ] Track reports of compass not working, wrong heading, or repeated permission prompts.
- [ ] If users report being asked location twice after tapping "Not Allow" in the same session — **immediate stop**; the current-session rule fix is broken.

### 3.7 Monitor GPS permission complaints

- [ ] Watch for 1-star reviews about aggressive location prompts.
- [ ] Verify that the compass only requests location when the user taps "Start Compass" (or similar explicit action), not on screen load.

---

## 4\. Increase rollout gradually only if stable

Flow:

```
1 %   → hold 24 h → all clear? → 5 %
5 %   → hold 24 h → all clear? → 20 %
20 %  → hold 48 h → all clear? → 50 %
50 %  → hold 48 h → all clear? → 100 %
```

- Use **business hours** for increases so the team can respond same-day.
- No increases over weekends unless on-call coverage is confirmed.
- If any threshold is breached at a given percentage:
  - **Pause** the rollout immediately.
  - Investigate and decide: hotfix (2.1.1) or rollback to 2.0.x.

---

## 5\. Rollback plan

### 5.1 Pause rollout

- One-click: Play Console > Production > Pause rollout.
- Existing users keep the version they have; no new users receive v2.1.0.

### 5.2 Fix the issue

- Reproduce and fix locally.
- Run full test suite + pre-launch report.
- Decide whether the fix goes into a new release (2.1.1) or the same AAB can be re-promoted.

### 5.3 Release 2\.1\.1+4 if needed

- If the issue is in the binary (not a configuration/server-side change):
  - Increase `versionCode` to `4` (or next available).
  - Increase `versionName` to `2.1.1`.
  - Follow the same checklist from Internal Testing onward.
  - Do **not** skip straight to production — re-run internal testing.

---

## 6\. Hotfix rules

Hotfix = any release made after v2.1.0 enters production but before the full 100 % rollout completes, intended to address a discovered issue.

- [ ] **Do not change package name** — `applicationId` remains `com.msdevx.unitconverter`. Changing it creates a new listing and loses existing installs.
- [ ] **Do not change signing identity** — use the same upload key and keystore as v2.1.0. A different signature causes Play Console to reject the upload.
- [ ] **Keep `versionCode` increasing** — never reuse or go backwards. If v2.1.0 has `versionCode = 3`, the hotfix must be `≥ 4`.
- [ ] **Keep privacy / data safety aligned** — if the hotfix changes no data collection, the existing Data Safety form remains valid. If it removes or adds collection, update the form before uploading.

---

## 7\. Success criteria

The rollout is considered **successful** when v2.1.0 reaches 100 % and the following are true:

- [ ] **No major crash spike** — crash rate ≤ 0.2 % at 100 % rollout.
- [ ] **No user reports of repeated location prompts after denial** — compass "Not Allow" → manual angle entry works every time; user is never re-prompted in the same session.
- [ ] **PKR conversions work** — Pakistani Rupee appears in the currency list and converts correctly.
- [ ] **No major currency outage complaints** — no flood of 1-star reviews about FX rates being stale / missing.
- [ ] **No premium / ad regression** (if monetisation is kept) — users who purchased "Remove Ads" still see no ads; non-paying users see the App Open Ad at most once per session.
