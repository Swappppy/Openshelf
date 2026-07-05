# Prevent shrinking of CameraX (needed for OCR)
-keep class androidx.camera.** { *; }

# General Flutter stability
-keep class io.flutter.plugins.** { *; }

# Prevent shrinking of barcode_scan2 internal classes if needed
-keep class de.mintware.barcode_scan.** { *; }
