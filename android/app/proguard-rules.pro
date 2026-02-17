# Add project specific ProGuard rules here.

# ==========================================
# CRITICAL: Keep ALL Flutter/Dart classes
# R8/ProGuard cannot properly obfuscate Dart code
# ==========================================
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-keep class com.google.** { *; }
-dontwarn io.flutter.**
-dontwarn androidx.**

# ==========================================
# Hive ProGuard Rules - CRITICAL for release builds
# Keep all Hive-related classes to prevent crashes
# ==========================================
-keep class hive.** { *; }
-keep class hive_flutter.** { *; }
-keep class * extends hive.** { *; }
-keep class * extends hive_flutter.** { *; }

# Keep all Hive annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# Keep Hive TypeAdapters - CRITICAL
-keep class * extends hive.TypeAdapter { *; }
-keep class * implements hive.TypeAdapter { *; }

# Keep ALL generated files (*.g.dart compiled to Java bytecode)
# This prevents R8 from stripping Hive adapters
-keep class **$** { *; }
-keepclassmembers class * {
    *;
}

# Keep all model classes with HiveType annotation
-keep @hive.HiveType class * { *; }

# Prevent obfuscation of any fields
-keepclassmembers class * {
    @hive.HiveField <fields>;
    <fields>;
}

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Image Picker - CRITICAL for image functionality
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class * extends android.provider.MediaStore$Images { *; }
-dontwarn android.provider.MediaStore$Images

# File access for images
-keep class java.io.File { *; }
-keep class java.nio.file.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Google Fonts
-keep class com.google.fonts.** { *; }

# Google Play Core (Required for Flutter)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
