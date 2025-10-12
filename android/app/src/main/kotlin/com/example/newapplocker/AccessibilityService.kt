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

                Log.d(TAG, "Monitoring enabled: $isMonitoringEnabled")
                Log.d(TAG, "Locked apps: ${lockedApps.joinToString(", ")}")

                if (isMonitoringEnabled) {
                    // Check if this app is locked
                    if (lockedApps.contains(packageName) && !isSystemPackage(packageName)) {
                        Log.d(TAG, "LOCKED APP DETECTED - SHOWING UNLOCK SCREEN: $packageName")
                        showUnlockScreen(packageName)
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

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility Service Interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "Accessibility Service Destroyed")
    }
}