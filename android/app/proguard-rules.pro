# Flutter engine classes — required for JNI / reflection in release builds.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# AdMob requires these rules to keep SDK classes in release builds.
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Keep Google Mobile Ads annotations.
-dontwarn com.google.android.gms.ads.**

# Play Core — used by Flutter's deferred component manager at runtime.
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# AndroidX WorkManager & Room Database keep rules for R8 / minification
-keep class androidx.work.** { *; }
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase
-dontwarn androidx.work.**
-dontwarn androidx.room.**
