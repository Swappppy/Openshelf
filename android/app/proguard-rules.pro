# Google ML Kit and CameraX - Prevent obfuscation of internal classes
# that cause NullPointerExceptions on physical devices.

-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }

# Prevent shrinking of CameraX and barcode/text internal logic
-keep class androidx.camera.** { *; }
-keep class com.google.android.odml.** { *; }

# ML Kit Text Recognition specific
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# General Flutter/Android release stability
-keep class io.flutter.plugins.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**