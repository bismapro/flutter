# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter Local Notifications - LENGKAP
-keep class com.dexterous.** { *; }
-keep interface com.dexterous.** { *; }
-keep enum com.dexterous.** { *; }
-dontwarn com.dexterous.**

# AndroidX Core
-keep class androidx.core.app.** { *; }
-keep interface androidx.core.app.** { *; }
-dontwarn androidx.core.**

# Notification Compat
-keep class * extends androidx.core.app.NotificationCompat$Style { *; }
-keep class androidx.core.app.NotificationCompat$* { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }

# Keep generic signatures
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Gson (used by notification plugin)
-keepattributes Signature
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Timezone
-keep class org.threeten.bp.** { *; }
-keep class com.jakewharton.threetenabp.** { *; }
-dontwarn org.threeten.bp.**
-dontwarn com.jakewharton.threetenabp.**

# SharedPreferences
-keep class androidx.preference.** { *; }