package org.ftena.openshelf

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.system.exitProcess

class MainActivity : FlutterActivity() {
    private val ICON_CHANNEL = "org.ftena.openshelf/icon"
    private val SYSTEM_CHANNEL = "org.ftena.openshelf/system"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ICON_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setAlternateIcon") {
                val iconName = call.argument<String?>("iconName")
                changeAppIcon(iconName, true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAllFilesSettings" -> {
                    openAllFilesSettings()
                    result.success(null)
                }
                "restartApp" -> {
                    val iconName = call.argument<String?>("iconName")
                    Log.i("Openshelf", "Native restartApp called")
                    restartApp(iconName)
                    result.success(null)
                }
                "closeApp" -> {
                    Log.i("Openshelf", "Native closeApp called")
                    closeApp()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openAllFilesSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent(android.provider.Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            } catch (e: Exception) {
                val intent = Intent(android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                startActivity(intent)
            }
        }
    }

    private fun restartApp(iconName: String?) {
        try {
            val pm = packageManager
            val intent = pm.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                val mainIntent = Intent.makeRestartActivityTask(intent.component)
                startActivity(mainIntent)
                exitProcess(0)
            } else {
                exitProcess(0)
            }
        } catch (e: Exception) {
            Log.e("Openshelf", "Error during restartApp: ${e.message}")
            exitProcess(1)
        }
    }

    private fun closeApp() {
        finishAffinity()
        exitProcess(0)
    }

    private fun changeAppIcon(iconName: String?, dontKill: Boolean) {
        val pm = packageManager
        val pkg = packageName
        val flags = if (dontKill) PackageManager.DONT_KILL_APP else 0

        val variants = listOf(
            "color0", "color1", "color2", "color3", "color4", "color5",
            "color6", "color7", "color8", "color9", "color10", "color11",
            "color12", "color13", "color14", "color15", "color16", "color17",
            "color18", "color19", "color20", "color21", "color22", "color23"
        )

        for (v in variants) {
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.$v"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                flags
            )
        }

        if (iconName == null || iconName == "default") {
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.MainActivity"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                flags
            )
        } else {
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.MainActivity"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                flags
            )
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.$iconName"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                flags
            )
        }
    }
}
