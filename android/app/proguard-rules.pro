# Dio
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions
-dontwarn okhttp3.**
-dontwarn okio.**

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.embedding.**

# Suppress deprecated API warnings
-keepattributes *Annotation*
-dontwarn java.lang.Deprecated
-dontwarn io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
