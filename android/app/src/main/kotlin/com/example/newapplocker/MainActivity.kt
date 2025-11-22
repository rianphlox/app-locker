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
import android.os.Bundle
import java.io.ByteArrayOutputStream

// Import our utility classes
import com.example.newapplocker.utils.ToastUtilManager
import com.example.newapplocker.utils.LockUtilManager
import com.example.newapplocker.utils.MainUtilManager
import com.example.newapplocker.utils.AppUtilsManager
import com.example.newapplocker.utils.LogUtilManager

class MainActivity: FlutterActivity() {
    private val PLATFORM_CHANNEL = "app_locker_channel"
    private val EVENT_CHANNEL = "app_locker_events"
    private val PERMISSIONS_CHANNEL = "app_locker_permissions"
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponent: ComponentName
    private lateinit var sharedPreferences: SharedPreferences
    private var eventSink: EventChannel.EventSink? = null
    private var pendingUnlockRequest: Pair<String, String>? = null // (action, packageName)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize utility classes
        MainUtilManager.getInstance().init(this)
        LogUtilManager.i("MainActivity", "App started - ${AppUtilsManager.getDeviceInfo()}")

        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        LogUtilManager.i("MainActivity", "🔐 STEP 4: handleIntent called")

        intent?.let {
            val action = it.getStringExtra("action")
            val packageName = it.getStringExtra("package_name")

            LogUtilManager.i("MainActivity", "🔐 STEP 5: Intent received - action: $action, package: $packageName")

            if ((action == "unlock_app" || action == "unlock_app_direct") && packageName != null) {
                LogUtilManager.i("MainActivity", "🔐 STEP 6: Valid unlock request received for: $packageName")

                if (action == "unlock_app_direct") {
                    LogUtilManager.i("MainActivity", "🔐 STEP 7: DIRECT unlock mode - should show only PIN screen")
                    // TODO: Hide normal app UI and show only PIN screen
                }

                if (eventSink != null) {
                    LogUtilManager.i("MainActivity", "🔐 STEP 8: EventSink ready, sending unlock event immediately")
                    // Flutter is ready, send immediately
                    eventSink?.success(mapOf(
                        "type" to "unlock_request",
                        "packageName" to packageName
                    ))
                    LogUtilManager.i("MainActivity", "🔐 STEP 9: Unlock event sent to Flutter")
                } else {
                    LogUtilManager.i("MainActivity", "🔐 STEP 8: EventSink not ready, storing pending request")
                    // Flutter not ready yet, store for later
                    pendingUnlockRequest = Pair(action, packageName)
                    LogUtilManager.i("MainActivity", "🔐 STEP 9: Stored pending unlock request for: $packageName")
                }
            } else {
                LogUtilManager.i("MainActivity", "🔐 STEP 6: Intent ignored - not an unlock request")
            }
        } ?: run {
            LogUtilManager.i("MainActivity", "🔐 STEP 5: No intent received")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, DeviceAdminReceiver::class.java)
        sharedPreferences = getSharedPreferences("app_locker_prefs", Context.MODE_PRIVATE)

        // Setup event channel for unlock requests
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                LogUtilManager.i("MainActivity", "🔐 STEP 10: Flutter EventChannel connected")
                eventSink = events

                // Process pending unlock request if any
                pendingUnlockRequest?.let { (action, packageName) ->
                    LogUtilManager.i("MainActivity", "🔐 STEP 11: Processing pending unlock request for: $packageName")
                    eventSink?.success(mapOf(
                        "type" to "unlock_request",
                        "packageName" to packageName
                    ))
                    LogUtilManager.i("MainActivity", "🔐 STEP 12: Pending unlock event sent to Flutter")
                    pendingUnlockRequest = null
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

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
                "requestAutoStart" -> {
                    requestAutoStart(result)
                }
                "requestAllPermissions" -> {
                    requestAllPermissions(result)
                }
                "showToast" -> {
                    val message = call.argument<String>("message") ?: ""
                    showToast(message, result)
                }
                "getDeviceInfo" -> {
                    result.success(AppUtilsManager.getDeviceInfo())
                }
                "getIntentData" -> {
                    val intent = activity.intent
                    val lockedPackage = intent.getStringExtra("package_name")
                    result.success(mapOf("package_name" to lockedPackage))
                }
                "temporarilyUnlockApp" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    temporarilyUnlockApp(packageName, result)
                }
                "reEnableAppInterception" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    reEnableAppInterception(packageName, result)
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    launchApp(packageName, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Setup permissions channel (updated)
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
                "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission(result)
                }
                "hasUsageStatsPermission" -> {
                    result.success(LockUtilManager.isUsageStatsPermissionGranted(this))
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
            LockUtilManager.requestUsageStatsPermission(this)
            result.success(true)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to request usage stats permission: ${e.message}")
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
            LogUtilManager.i("MainActivity", "Locked apps updated: ${packageNames.size} apps - ${packageNames}")

            // Update the locked apps in the AccessibilityService
            AccessibilityService.updateLockedApps(this, packageNames)

            result.success(true)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to set locked apps: ${e.message}")
            result.success(false)
        }
    }

    private fun enableAccessibilityMonitoring(enabled: Boolean, result: MethodChannel.Result) {
        try {
            val editor = sharedPreferences.edit()
            editor.putBoolean("accessibility_monitoring_enabled", enabled)
            editor.apply()
            LogUtilManager.i("MainActivity", "Accessibility monitoring set to: $enabled")
            result.success(true)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to set accessibility monitoring: ${e.message}")
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
            val appsList = mutableListOf<Map<String, Any>>()

            // Method 1: Try getting all packages with different flags for MIUI compatibility
            var packages = try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    packageManager.getInstalledPackages(PackageManager.PackageInfoFlags.of(PackageManager.GET_META_DATA.toLong()))
                } else {
                    @Suppress("DEPRECATION")
                    packageManager.getInstalledPackages(PackageManager.GET_META_DATA)
                }
            } catch (e: Exception) {
                // Fallback for MIUI devices
                try {
                    @Suppress("DEPRECATION")
                    packageManager.getInstalledPackages(0)
                } catch (e2: Exception) {
                    emptyList()
                }
            }

            // Method 2: If still empty, try getting applications directly
            if (packages.isEmpty()) {
                val applications = try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        packageManager.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(PackageManager.GET_META_DATA.toLong()))
                    } else {
                        @Suppress("DEPRECATION")
                        packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
                    }
                } catch (e: Exception) {
                    @Suppress("DEPRECATION")
                    packageManager.getInstalledApplications(0)
                }

                // Convert ApplicationInfo to PackageInfo-like structure
                for (appInfo in applications) {
                    try {
                        val packageInfo = packageManager.getPackageInfo(appInfo.packageName, 0)
                        packages = packages + packageInfo
                    } catch (e: Exception) {
                        // Skip if package info can't be retrieved
                    }
                }
            }

            // Process the packages
            for (packageInfo in packages) {
                try {
                    val applicationInfo = packageInfo.applicationInfo
                    if (applicationInfo != null && applicationInfo.enabled) {
                        val appName = try {
                            applicationInfo.loadLabel(packageManager).toString()
                        } catch (e: Exception) {
                            packageInfo.packageName // Fallback to package name
                        }

                        val isSystemApp = (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0

                        // Include app if it's either:
                        // 1. A user app with launch intent
                        // 2. A system app (regardless of launch intent for system apps tab)
                        val hasLaunchIntent = packageManager.getLaunchIntentForPackage(packageInfo.packageName) != null

                        if (hasLaunchIntent || isSystemApp) {
                            val appMap = mapOf(
                                "packageName" to packageInfo.packageName,
                                "appName" to appName,
                                "isSystemApp" to isSystemApp,
                                "hasLaunchIntent" to hasLaunchIntent
                            )
                            appsList.add(appMap)
                        }
                    }
                } catch (e: Exception) {
                    // Log the error but continue processing other apps
                    LogUtilManager.w("QVault", "Error processing app ${packageInfo.packageName}: ${e.message}")
                }
            }

            // Sort apps by name for better UX
            appsList.sortBy { (it["appName"] as String).lowercase() }

            LogUtilManager.i("QVault", "Found ${appsList.size} apps (${appsList.count { !(it["isSystemApp"] as Boolean) }} user apps, ${appsList.count { it["isSystemApp"] as Boolean }} system apps)")

            result.success(appsList)
        } catch (e: Exception) {
            LogUtilManager.e("QVault", "Error getting installed apps: ${e.message}")
            result.error("GET_APPS_ERROR", "Failed to get installed apps: ${e.message}", e.toString())
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

    // New utility methods

    private fun requestAutoStart(result: MethodChannel.Result) {
        try {
            val success = AppUtilsManager.autoStart(this)
            LogUtilManager.i("MainActivity", "Auto-start request: $success")
            result.success(success)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to request auto-start: ${e.message}")
            result.success(false)
        }
    }

    private fun requestAllPermissions(result: MethodChannel.Result) {
        try {
            // Request usage stats permission
            if (!LockUtilManager.isUsageStatsPermissionGranted(this)) {
                LockUtilManager.requestUsageStatsPermission(this)
            }

            // Request overlay permission
            if (!LockUtilManager.canDrawOverlays(this)) {
                LockUtilManager.requestOverlayPermission(this)
            }

            // Request auto-start permission
            AppUtilsManager.autoStart(this)

            // Request ignore battery optimization
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            }

            LogUtilManager.i("MainActivity", "All permissions requested")
            result.success(true)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to request all permissions: ${e.message}")
            result.success(false)
        }
    }

    private fun showToast(message: String, result: MethodChannel.Result) {
        try {
            ToastUtilManager.showToast(this, message)
            result.success(true)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to show toast: ${e.message}")
            result.success(false)
        }
    }

    private fun temporarilyUnlockApp(packageName: String, result: MethodChannel.Result) {
        try {
            val editor = sharedPreferences.edit()
            val temporarilyUnlockedApps = sharedPreferences.getStringSet("temporarily_unlocked_apps", setOf())?.toMutableSet() ?: mutableSetOf()
            temporarilyUnlockedApps.add(packageName)
            editor.putStringSet("temporarily_unlocked_apps", temporarilyUnlockedApps)
            editor.apply()
            LogUtilManager.i("MainActivity", "Temporarily unlocked app: $packageName")
            result.success(true)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to temporarily unlock app: ${e.message}")
            result.success(false)
        }
    }

    private fun reEnableAppInterception(packageName: String, result: MethodChannel.Result) {
        try {
            val editor = sharedPreferences.edit()
            val temporarilyUnlockedApps = sharedPreferences.getStringSet("temporarily_unlocked_apps", setOf())?.toMutableSet() ?: mutableSetOf()
            temporarilyUnlockedApps.remove(packageName)
            editor.putStringSet("temporarily_unlocked_apps", temporarilyUnlockedApps)
            editor.apply()
            LogUtilManager.i("MainActivity", "Re-enabled interception for app: $packageName")
            result.success(true)
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to re-enable interception: ${e.message}")
            result.success(false)
        }
    }

    private fun launchApp(packageName: String, result: MethodChannel.Result) {
        try {
            val packageManager = packageManager
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
                startActivity(launchIntent)
                LogUtilManager.i("MainActivity", "Successfully launched app: $packageName")
                result.success(true)
            } else {
                LogUtilManager.w("MainActivity", "No launch intent found for app: $packageName")
                result.success(false)
            }
        } catch (e: Exception) {
            LogUtilManager.e("MainActivity", "Failed to launch app: ${e.message}")
            result.success(false)
        }
    }

}