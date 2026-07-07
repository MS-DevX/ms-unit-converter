import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class InAppUpdateService {
  InAppUpdateService._();

  static final InAppUpdateService instance = InAppUpdateService._();

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info;
    } catch (e) {
      debugPrint('[InAppUpdate] Check failed: $e');
      return null;
    }
  }

  Future<AppUpdateResult> startFlexibleUpdate() {
    return InAppUpdate.startFlexibleUpdate();
  }

  Stream<InstallStatus> get installUpdateListener =>
      InAppUpdate.installUpdateListener;

  Future<void> completeFlexibleUpdate() {
    return InAppUpdate.completeFlexibleUpdate();
  }
}
