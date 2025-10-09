package com.example.newapplocker

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.content.SharedPreferences
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable
import android.graphics.Bitmap
import android.graphics.Canvas
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val PLATFORM_CHANNEL = "com.example.newapplocker/platform"
    private val EVENT_CHANNEL = "com.example.newapplocker/events"
    private val PERMISSIONS_CHANNEL = "com.example.newapplocker/permissions"
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponent: ComponentName
    private lateinit var sharedPreferences: SharedPreferences
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, DeviceAdminReceiver::class.java)
        sharedPreferences = getSharedPreferences("app_locker_prefs", Context.MODE_PRIVATE)

        // Setup platform methods channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLATFORM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    initializePlatformService(result)
                }
                "isAccessibilityServiceEnabled" -> {
                    result.success(hasAccessibilityPermission())
                }
                "requestAccessibilityPermission" -> {
                    requestAccessibilityPermission(result)
                }
                "isDeviceAdminEnabled" -> {
                    result.success(isDeviceAdminEnabled())
                }
                "requestDeviceAdminPermission" -> {
                    requestDeviceAdmin(result)
                }
                "setLockedApps" -> {
                    val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                    setLockedApps(packageNames, result)
                }
                "enableAccessibilityMonitoring" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    enableAccessibilityMonitoring(enabled, result)
                }
                "showUnlockScreen" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    showUnlockScreen(packageName, result)
                }
                "killApp" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    killApp(packageName, result)
                }
                "openAppSettings" -> {
                    openAppSettings(result)
                }
                "openAccessibilitySettings" -> {
                    requestAccessibilityPermission(result)
                }
                "hasSystemAlertWindowPermission" -> {
                    result.success(hasSystemAlertWindowPermission())
                }
                "requestSystemAlertWindowPermission" -> {
                    requestSystemAlertWindowPermission(result)
                }
                "getInstalledApps" -> {
                    getInstalledApps(result)
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    getAppIcon(packageName, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Setup permissions channel (existing)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestDeviceAdmin" -> {
                    requestDeviceAdmin(result)
                }
                "requestAccessibility" -> {
                    requestAccessibilityPermission(result)
                }
                "requestBatteryOptimization" -> {
                    requestBatteryOptimization(result)
                }
                "hasAccessibilityPermission" -> {
                    result.success(hasAccessibilityPermission())
                }
                "requestUsageStats" -> {
                    requestUsageStatsPermission(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestDeviceAdmin(result: MethodChannel.Result) {
        try {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
            intent.putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Enable device admin to lock apps effectively"
            )
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun requestAccessibilityPermission(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun requestBatteryOptimization(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun requestUsageStatsPermission(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                startActivity(intent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun hasAccessibilityPermission(): Boolean {
        return try {
            val accessibilityServiceName = "$packageName/${AccessibilityService::class.java.canonicalName}"
            val enabledServices = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            enabledServices?.contains(accessibilityServiceName) ?: false
        } catch (e: Exception) {
            false
        }
    }

    private fun initializePlatformService(result: MethodChannel.Result) {
        try {
            // Initialize any required services
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun isDeviceAdminEnabled(): Boolean {
        return devicePolicyManager.isAdminActive(adminComponent)
    }

    private fun setLockedApps(packageNames: List<String>, result: MethodChannel.Result) {
        try {
            val editor = sharedPreferences.edit()
            editor.putStringSet("locked_apps", packageNames.toSet())
            editor.apply()
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun enableAccessibilityMonitoring(enabled: Boolean, result: MethodChannel.Result) {
        try {
            val editor = sharedPreferences.edit()
            editor.putBoolean("accessibility_service_enabled", enabled)
            editor.apply()
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun showUnlockScreen(packageName: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(this, UnlockActivity::class.java)
            intent.putExtra("package_name", packageName)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun killApp(packageName: String, result: MethodChannel.Result) {
        try {
            if (isDeviceAdminEnabled()) {
                // With device admin, we can try to force close apps
                // This is limited and may not work on all devices/Android versions
                val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
                activityManager.killBackgroundProcesses(packageName)
            }
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun openAppSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun hasSystemAlertWindowPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestSystemAlertWindowPermission(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun getInstalledApps(result: MethodChannel.Result) {
        try {
            val packageManager = packageManager
            val packages = packageManager.getInstalledPackages(PackageManager.GET_META_DATA)
            val appsList = mutableListOf<Map<String, Any>>()

            for (packageInfo in packages) {
                try {
                    val applicationInfo = packageInfo.applicationInfo
                    if (applicationInfo.enabled && packageManager.getLaunchIntentForPackage(packageInfo.packageName) != null) {
                        val appName = applicationInfo.loadLabel(packageManager).toString()
                        val isSystemApp = (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0

                        val appMap = mapOf(
                            "packageName" to packageInfo.packageName,
                            "appName" to appName,
                            "isSystemApp" to isSystemApp
                        )
                        appsList.add(appMap)
                    }
                } catch (e: Exception) {
                    // Skip apps that can't be processed
                }
            }

            result.success(appsList)
        } catch (e: Exception) {
            result.error("GET_APPS_ERROR", "Failed to get installed apps", e.message)
        }
    }

    private fun getAppIcon(packageName: String, result: MethodChannel.Result) {
        try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            val drawable = applicationInfo.loadIcon(packageManager)

            // Convert drawable to byte array
            val bitmap = drawableToBitmap(drawable)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            val byteArray = stream.toByteArray()

            result.success(byteArray.toList())
        } catch (e: Exception) {
            result.success(null)
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth.coerceAtLeast(1),
            drawable.intrinsicHeight.coerceAtLeast(1),
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}