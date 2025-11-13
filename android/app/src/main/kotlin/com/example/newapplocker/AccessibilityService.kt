package com.example.newapplocker

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class AccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "AppLockerAccessibility"
        private var instance: AccessibilityService? = null
        private var lastActivePackage: String? = null

        fun getInstance(): AccessibilityService? = instance

        fun isServiceRunning(): Boolean = instance != null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "Accessibility Service Created")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility Service Connected")

        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS

        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            val className = event.className?.toString()

            if (packageName != null && className != null) {
                Log.d(TAG, "App switched to: $packageName")

                // Check if monitoring is enabled
                val sharedPrefs = getSharedPreferences("app_locker_prefs", MODE_PRIVATE)
                val isMonitoringEnabled = sharedPrefs.getBoolean("accessibility_monitoring_enabled", false)
                val lockedApps = sharedPrefs.getStringSet("locked_apps", setOf()) ?: setOf()
                val temporarilyUnlockedApps = sharedPrefs.getStringSet("temporarily_unlocked_apps", setOf()) ?: setOf()

                Log.d(TAG, "Monitoring enabled: $isMonitoringEnabled")
                Log.d(TAG, "Locked apps: ${lockedApps.joinToString(", ")}")
                Log.d(TAG, "Temporarily unlocked apps: ${temporarilyUnlockedApps.joinToString(", ")}")

                // Check if we're switching away from a temporarily unlocked app
                if (lastActivePackage != null && lastActivePackage != packageName) {
                    if (temporarilyUnlockedApps.contains(lastActivePackage)) {
                        // App was switched away - re-enable interception after delay
                        // This is simpler and more reliable than checking running processes
                        reEnableInterceptionForApp(lastActivePackage!!)
                        Log.d(TAG, "App $lastActivePackage switched away - re-enabled interception")
                    }
                }

                lastActivePackage = packageName

                if (isMonitoringEnabled) {
                    // Check if this app is locked
                    if (lockedApps.contains(packageName) && !isSystemPackage(packageName)) {
                        // Check if app is temporarily unlocked
                        if (temporarilyUnlockedApps.contains(packageName)) {
                            Log.d(TAG, "App $packageName is temporarily unlocked - allowing access")
                        } else {
                            Log.d(TAG, "LOCKED APP DETECTED - SHOWING UNLOCK SCREEN: $packageName")
                            showUnlockScreen(packageName)
                        }
                    } else {
                        Log.d(TAG, "App $packageName is not locked or is system package")
                    }
                } else {
                    Log.d(TAG, "Accessibility monitoring is disabled")
                }

                // Send broadcast to notify Flutter app about app switch
                val intent = Intent("com.example.newapplocker.APP_SWITCHED")
                intent.putExtra("packageName", packageName)
                intent.putExtra("className", className)
                sendBroadcast(intent)
            }
        }
    }

    private fun isSystemPackage(packageName: String): Boolean {
        // Skip our own app
        if (packageName == this.packageName) return true

        // Skip system UI and launcher apps
        val systemPackages = setOf(
            "com.android.systemui",
            "com.android.launcher",
            "com.google.android.launcher",
            "com.miui.home",
            "com.huawei.android.launcher",
            "com.oneplus.launcher"
        )
        return systemPackages.any { packageName.contains(it) } ||
               packageName.contains("launcher") ||
               packageName.startsWith("com.android.") ||
               packageName.startsWith("com.google.android.") ||
               packageName == "android"
    }

    private fun showUnlockScreen(packageName: String) {
        try {
            val intent = Intent(this, UnlockActivity::class.java)
            intent.putExtra("package_name", packageName)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start unlock activity: ${e.message}")
        }
    }

    private fun reEnableInterceptionForApp(packageName: String) {
        try {
            val sharedPrefs = getSharedPreferences("app_locker_prefs", MODE_PRIVATE)
            val editor = sharedPrefs.edit()
            val temporarilyUnlockedApps = sharedPrefs.getStringSet("temporarily_unlocked_apps", setOf())?.toMutableSet() ?: mutableSetOf()
            temporarilyUnlockedApps.remove(packageName)
            editor.putStringSet("temporarily_unlocked_apps", temporarilyUnlockedApps)
            editor.apply()
            Log.d(TAG, "Re-enabled interception for app: $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to re-enable interception for app: ${e.message}")
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility Service Interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "Accessibility Service Destroyed")
    }
}