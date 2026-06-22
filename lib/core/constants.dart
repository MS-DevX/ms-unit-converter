/// Application-wide constant values for MS Unit Converter.
///
/// All fields are [static] and [const] for compile-time safety
/// and zero runtime overhead. This class is not meant to be
/// instantiated; use [AppConstants] directly.
class AppConstants {
  AppConstants._();

  /// Human-readable name of the application.
  static const String appName = 'MS Unit Converter';

  /// Current version of the application following semver.
  static const String appVersion = '2.0.0';

  /// Unique package identifier for the Android platform.
  static const String packageId = 'com.msdevx.unitconverter';

  /// AdMob application ID for Android.
  static const String admobAppIdAndroid =
      'ca-app-pub-8684958562988579~6766583891';

  /// AdMob App Open ad unit ID.
  static const String appOpenAdUnitId =
      'ca-app-pub-8684958562988579/2956999697';

  /// In-app purchase product ID for removing ads.
  static const String removeAdsProductId = 'com.msdevx.unitconverter.removeads';

  /// Price of the remove-ads IAP.
  static const String removeAdsPrice = r'$1.99';

  /// URL to the privacy policy hosted by MS DevX.
  static const String privacyPolicyUrl = 'https://msdevx.com/msunit-privacy';

  /// URL to the app listing on Google Play Store.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.msdevx.unitconverter';

  /// Default message used when sharing the app via the system share sheet.
  static const String shareMessage =
      'Try MS Unit Converter by MS DevX:\n'
      'https://play.google.com/store/apps/details?id=com.msdevx.unitconverter';

  /// SharedPreferences key for storing conversion history.
  static const String historyStorageKey = 'history_entries';

  /// SharedPreferences key for storing premium (ads removed) status.
  static const String premiumStorageKey = 'is_premium';

  /// SharedPreferences key for storing the selected theme mode.
  static const String themeModeStorageKey = 'theme_mode';

  /// SharedPreferences key for the last AppOpenAd show timestamp.
  static const String lastAdShownTimestampKey = 'last_ad_shown_timestamp';

  /// SharedPreferences key for storing the decimal precision setting.
  static const String decimalPrecisionKey = 'decimal_precision';

  /// SharedPreferences key for storing favorite category indices.
  static const String favoritesStorageKey = 'favorite_categories';

  /// Maximum number of history entries persisted locally.
  static const int maxHistoryEntries = 20;

  /// Minimum hours between AppOpenAd shows.
  static const int adCooldownHours = 4;

  /// Minimum duration (ms) the splash screen is visible.
  static const int splashDurationMs = 1500;
}
