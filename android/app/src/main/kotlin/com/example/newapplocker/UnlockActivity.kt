package com.example.newapplocker

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.content.pm.PackageManager
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable

class UnlockActivity : Activity() {

    companion object {
        private const val TAG = "UnlockActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val packageName = intent.getStringExtra("package_name")
        Log.d(TAG, "🔐 STEP 1: UnlockActivity started for package: $packageName")

        if (packageName == null) {
            Log.e(TAG, "🔐 ERROR: No package name provided")
            finish()
            return
        }

        // Get app information for display
        val appName = getAppName(packageName)
        val appIcon = getAppIcon(packageName)

        Log.d(TAG, "🔐 STEP 2: App info - name: $appName")

        // Set content to a simple PIN screen layout
        setContentView(R.layout.activity_unlock)

        // Launch native PIN screen directly (no Flutter involvement)
        Log.d(TAG, "🔐 STEP 3: Launching NATIVE PIN screen")

        val unlockIntent = Intent(this, PinUnlockActivity::class.java)
        unlockIntent.putExtra("package_name", packageName)
        unlockIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        unlockIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        unlockIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        unlockIntent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)

        Log.d(TAG, "🔐 STEP 4: Starting NATIVE PinUnlockActivity")
        startActivity(unlockIntent)

        Log.d(TAG, "🔐 STEP 5: UnlockActivity finishing")
        finish()
    }

    private fun getAppName(packageName: String): String {
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (e: Exception) {
            "Unknown App"
        }
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            val drawable = packageManager.getApplicationIcon(applicationInfo)
            val bitmap = drawableToBitmap(drawable)

            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
            byteArrayOutputStream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            return drawable.bitmap
        }

        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )

        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}