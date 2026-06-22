# MS Unit Converter — Privacy & Data Safety Notes

Use this document when filling in the Google Play Console **Data Safety** form and
when reviewing the app's privacy posture.

---

## 1. No Account / No Signup

The app does **not**:

- Require account creation
- Require login
- Offer a sign-in option of any kind
- Collect email addresses, names, or any personal identifiers

---

## 2. Local-Only Storage (SharedPreferences)

All user data is stored **only on-device** via `SharedPreferences`.
Nothing is transmitted to a server. No analytics, no crash reporting.

| Data | Key (`AppConstants.*`) | Purpose |
|------|------------------------|---------|
| Conversion history | `historyStorageKey` | Last 20 conversions (max), persisted across sessions |
| Theme preference | `themeModeStorageKey` | System / Light / Dark mode |
| Favorite categories | `favoritesStorageKey` | Set of pinned category indices |
| Decimal precision | `decimalPrecisionKey` | Auto / 2 / 4 / 6 / 8 fixed decimals |
| Premium (ads removed) | `premiumStorageKey` | `true` after successful IAP |
| Ad cooldown timestamp | `lastAdShownTimestamp` | Unix ms of last App Open Ad show |
| Currency cache | N/A (uses `historyStorageKey`-style list) | Cached FX rates + ISO-8601 timestamp |

**Play Store Data Safety:** All of the above are *App functionality* data that is
*not shared with third parties* and *not collected* by the developer.

---

## 3. Currency Exchange Rates API

- **Provider:** Frankfurter.app (`https://api.frankfurter.dev`)
- **Purpose:** Fetch live USD-base exchange rates for 53 currencies
- **Sent:** `GET /v2/rates?base=USD` — no API key, no authentication, no headers beyond defaults
- **Received:** Exchange rate JSON (public data)
- **Caching:** Rates + timestamp saved to SharedPreferences on each successful fetch
- **Offline:** App uses cached rates or hardcoded fallback rates when offline
- **Data Safety:** This is an *optional, user-initiated* network request. The developer
  does not collect or log the request.

---

## 4. Compass & Location

- **Magnetic compass** works without any location permission. Uses accelerometer +
  magnetometer (`sensors_plus`) entirely on-device.
- **Location permission** (`ACCESS_FINE_LOCATION`) is only requested when the user
  explicitly taps the **"True North"** toggle in the compass screen.
- **Purpose:** Used solely to calculate magnetic declination (true north) and to
  display GPS coordinates on screen.
- **No transmission:** Location data is never sent off-device. There is no server
  endpoint to receive it.
- **Denial behavior:** If the user denies the permission, the app does **not** re-prompt
  in the same session. The compass continues to show magnetic north and all other
  app features work normally.
- **Play Store Data Safety:** Location is *not collected* (it stays on-device).
  Mark as *App functionality* / *not shared* if desired, or mark as *No location collected*.

---

## 5. Ads & In-App Purchases

### Ads
- **Network:** Google Mobile Ads SDK (`google_mobile_ads`)
- **Format:** Single App Open Ad — shown once per cold start if 4+ hours since last show
- **No banners, no interstitials, no rewarded ads**
- **Trigger:** Cold start (app launched fresh) or warm start after 4+ hours in background
- **Premium users:** Ad is completely skipped when `isPremium` is `true`
- **Cooldown:** 4-hour minimum between ad shows, persisted in SharedPreferences
- **Failure handling:** If ad fails to load, app proceeds silently without ad
- **AdMob App ID:** `ca-app-pub-8684958562988579~9464291585`
- **Test ad unit:** `ca-app-pub-3940256099942544/9257395921`

The Google Mobile Ads SDK may collect device advertising IDs for ad personalisation.
Refer to Google's own Data Safety disclosures for the SDK.

### In-App Purchases
- **Product:** Remove Ads (`com.msdevx.unitconverter.removeads`) — \$1.99 one-time
- **Billing:** Google Play Billing via `in_app_purchase` package
- **Effect:** Sets `isPremium = true` in SharedPreferences; hides App Open Ad permanently
- **Restore:** Restored purchases trigger the same `isPremium = true` flow
- **Data Safety:** Purchase details are handled entirely by Google Play. The app only
  stores a local boolean flag (`is_premium` in SharedPreferences).

---

## 6. Permissions

| Permission | Reason | Required? |
|------------|--------|-----------|
| `INTERNET` | AdMob ads, currency rate fetches | Yes (core functionality) |
| `ACCESS_FINE_LOCATION` | True north / GPS coordinates in compass screen | No (user-prompted, magnetic compass works without it) |
| `ACCESS_COARSE_LOCATION` | Same as fine location | No (falls back to fine) |

No other platform permissions are declared or requested.

---

## 7. Play Store Checklist

### Data Safety Form

| Question | Answer |
|----------|--------|
| Does your app collect or share any personal data? | No |
| Does your app collect any user data? | No user-provided data is collected or transmitted |
| Device or other IDs? | Google Mobile Ads SDK may collect advertising ID |
| Financial info? | No (IAP handled entirely by Google Play) |
| Location? | Location stays on-device; only used for compass GPS display |
| App activity? | No |
| Web browsing? | No |
| Health / fitness? | No |
| Messages? | No |
| Photos / videos? | No |
| Audio? | No |

Fill in the Data Safety form to match the notes in sections 1-6 above.

### Privacy Policy URL

`https://msdevx.com/msunit-privacy`

Set in `lib/core/constants.dart:34` — `AppConstants.privacyPolicyUrl`.

The hosted page should cover:
- What data is stored locally (section 2)
- Third-party SDKs: Google Mobile Ads, Google Play Billing (section 5)
- That no data is transmitted to MS DevX servers
- External API usage: Frankfurter.app (section 3) — public exchange rate data
- Location data stays on-device (section 4)

**Do not embed secrets or API keys in the privacy policy.** There are none.

### Content Rating

Complete the Google Play Content Rating questionnaire. The app:
- Contains no user-generated content
- Contains no sexual content, violence, or hate speech
- Shows app open ads (Google-adserver controlled, typical rating: Everyone)
- No in-app gambling or purchases of chance

### App Access

- **Login required:** No
- **Account required:** No
- **How to access:** Open the app. All features are immediately available.
  Compass true north requires optional location permission grant.
