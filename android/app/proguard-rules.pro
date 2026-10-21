# Prevent shrinking of CameraX (needed for OCR)
-keep class androidx.camera.** { *; }

# Flutter plugin channel APIs
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class dev.flutter.plugins.** { *; }

# Keep attributes required for reflection, generic signatures, and Kotlin coroutines
-keepattributes Signature,InnerClasses,EnclosingMethod,Annotation,*Annotation*,Exceptions

# Kotlin runtime, inline classes (kotlin.Result de Pigeon), coroutines
-keep class kotlin.** { *; }
-keep interface kotlin.** { *; }

# barcode_scan2
-keep class de.mintware.barcode_scan.** { *; }
