# Prevent shrinking of CameraX (needed for OCR)
-keep class androidx.camera.** { *; }

# General Flutter stability & Plugin Channel APIs
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

-keep class io.flutter.plugins.** { *; }
-keepclassmembers class io.flutter.plugins.** {
    <fields>;
    <methods>;
}

-keep class dev.flutter.plugins.** { *; }
-keepclassmembers class dev.flutter.plugins.** {
    <fields>;
    <methods>;
}

# Keep attributes required for reflection, generic signatures, and Kotlin coroutines
-keepattributes Signature,InnerClasses,EnclosingMethod,Annotation,*Annotation*,Exceptions

# Preserve Kotlin Coroutines continuation classes and interfaces
-keep class kotlin.coroutines.** { *; }
-keep interface kotlin.coroutines.** { *; }

# Prevent shrinking of barcode_scan2 internal classes if needed
-keep class de.mintware.barcode_scan.** { *; }




