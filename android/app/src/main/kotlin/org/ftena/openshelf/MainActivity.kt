package org.ftena.openshelf

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "org.ftena.openshelf/icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setAlternateIcon") {
                val iconName = call.argument<String?>("iconName")
                changeAppIcon(iconName)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun changeAppIcon(iconName: String?) {
        val pm = packageManager
        val pkg = packageName

        // List of all variants (must match AndroidManifest activity-alias names)
        val variants = listOf(
            "color0", "color1", "color2", "color3", "color4", "color5",
            "color6", "color7", "color8", "color9", "color10", "color11",
            "color12", "color13", "color14", "color15", "color16", "color17",
            "color18", "color19", "color20", "color21", "color22", "color23"
        )

        // Disable all variants first
        for (v in variants) {
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.$v"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }

        if (iconName == null) {
            // Restore default
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.MainActivity"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        } else {
            // Disable default and enable specific variant
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.MainActivity"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.$iconName"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}
