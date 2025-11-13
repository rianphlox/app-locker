package com.example.newapplocker

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log

class UnlockActivity : Activity() {

    companion object {
        private const val TAG = "UnlockActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val packageName = intent.getStringExtra("package_name")
        Log.d(TAG, "Unlock activity started for package: $packageName")

        // Launch the Flutter app's unlock screen directly
        val unlockIntent = Intent(this, MainActivity::class.java)
        unlockIntent.putExtra("action", "unlock_app")
        unlockIntent.putExtra("package_name", packageName)
        unlockIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        unlockIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        unlockIntent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION) // Skip animation for faster launch
        startActivity(unlockIntent)

        finish()
    }
}