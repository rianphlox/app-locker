package com.example.newapplocker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AppLockerBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            Log.d(TAG, "Boot completed, starting services")

            // Start accessibility service if needed
            // This would typically be handled by the Flutter app when it starts

            Log.d(TAG, "Services started after boot")
        }
    }
}