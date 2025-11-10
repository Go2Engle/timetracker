# Android ProGuard Rules for TimeTracker

# Keep Flutter's main entry point
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter embedding classes
-keep class io.flutter.embedding.** { *; }

# Keep Play Core library (for deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep plugin classes
-keep class androidx.lifecycle.** { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Keep database classes (SQLite)
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Gson rules (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
