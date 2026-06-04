import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Service managing in-app purchases (IAP) for the Unit Converter app.
///
/// Implemented as a singleton via [instance]. This service allows purchasing
/// and restoring the premium status (removing ads) using [in_app_purchase]
/// and persists the status locally using [SharedPreferences].
class IapService {
  IapService._();

  /// Shared singleton instance of [IapService].
  static final IapService instance = IapService._();

  InAppPurchase? _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Cache of the purchase-ready state.
  bool _isAvailable = false;

  /// Callback triggered when premium status is successfully verified and unlocked.
  void Function()? onPremiumUnlocked;

  /// Whether in-app purchases are available on this device/platform.
  bool get isAvailable => _isAvailable;

  /// Initializes the in-app purchase service by listening to the purchase stream.
  ///
  /// This listener handles all purchase states (pending, purchased, restored, error).
  /// When a purchase is successfully made or restored, it is verified and stored
  /// in local storage using [SharedPreferences].
  ///
  /// On platforms where in-app purchases are not supported (e.g. Windows desktop),
  /// this method degrades gracefully without crashing.
  Future<void> initialize() async {
    if (_subscription != null) return;
    try {
      _iap = InAppPurchase.instance;
      _isAvailable = await _iap!.isAvailable();
      if (_isAvailable) {
        _subscription = _iap!.purchaseStream.listen(
          _handlePurchaseUpdates,
          onError: (Object error) {
            // Safe degradation without crashing or logging to console
          },
        );
      }
    } catch (_) {
      // Plugin not available on this platform.
      _subscription?.cancel();
      _subscription = null;
      _iap = null;
      _isAvailable = false;
    }
  }

  /// Initiates the purchase flow for the "Remove Ads" product.
  ///
  /// Queries the product using [AppConstants.removeAdsProductId] and initiates
  /// a non-consumable purchase flow. Handles billing errors and empty product
  /// listings gracefully.
  Future<void> purchase() async {
    final iap = _iap;
    if (iap == null) return;
    try {
      final bool isAvailable = await iap.isAvailable();
      if (!isAvailable) return;

      final ProductDetailsResponse response = await iap.queryProductDetails({
        AppConstants.removeAdsProductId,
      });

      if (response.notFoundIDs.contains(AppConstants.removeAdsProductId) ||
          response.productDetails.isEmpty) {
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      await iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {
      // Degrade gracefully on billing errors
    }
  }

  /// Restores previous in-app purchases.
  ///
  /// Triggers store purchase restoration, which posts restored transactions
  /// to the purchase stream listened to in [initialize].
  Future<void> restore() async {
    final iap = _iap;
    if (iap == null) return;
    try {
      final bool isAvailable = await iap.isAvailable();
      if (!isAvailable) return;
      await iap.restorePurchases();
    } catch (_) {
      // Degrade gracefully on billing or store errors
    }
  }

  /// Checks if the premium status (remove ads) has been purchased.
  ///
  /// Reads the premium flag from [SharedPreferences] and returns `false`
  /// if it is missing or an error occurs.
  Future<bool> isPurchased() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.premiumStorageKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Cancels the purchase stream subscription to prevent memory leaks.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Internal handler for the purchase stream updates.
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    final iap = _iap;
    if (iap == null) return;
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Purchase is pending, do not unlock yet
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error safely without crashing
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = _verifyPurchase(purchaseDetails);
          if (valid) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppConstants.premiumStorageKey, true);
            onPremiumUnlocked?.call();
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Basic success check for verifying the purchase details.
  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    return purchaseDetails.productID == AppConstants.removeAdsProductId &&
        (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored);
  }
}
