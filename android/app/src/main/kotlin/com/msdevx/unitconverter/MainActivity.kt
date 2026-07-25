package com.msdevx.unitconverter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.msdevx.unitconverter/installer_source"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInstallerPackageName") {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        try {
                            @Suppress("DEPRECATION")
                            val installer = packageManager.getInstallerPackageName(packageName)
                            result.success(installer)
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "packageName is required", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
