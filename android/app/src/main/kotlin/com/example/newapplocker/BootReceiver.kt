package com.example.newapplocker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AppLockerBootReceiver"
        private const val ENGINE_ID = "app_locker_boot_engine"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d(TAG, "Received intent: $action")

        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {
                Log.d(TAG, "System event detected, starting app locker services")

                try {
                    // Start the main application
                    val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                    if (launchIntent != null) {
                        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
                        context.startActivity(launchIntent)
                        Log.d(TAG, "Main app started successfully")
                    }

                    // Also start a background Flutter engine to ensure background service runs
                    val flutterEngine = FlutterEngine(context)
                    flutterEngine.dartExecutor.executeDartEntrypoint(
                        DartExecutor.DartEntrypoint.createDefault()
                    )
                    FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)

                    Log.d(TAG, "Background services initialized")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to start services", e)
                }
            }
        }
    }
}