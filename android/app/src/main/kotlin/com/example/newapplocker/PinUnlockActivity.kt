package com.example.newapplocker

import android.app.Activity
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import java.security.MessageDigest

class PinUnlockActivity : Activity() {

    companion object {
        private const val TAG = "PinUnlockActivity"
    }

    private lateinit var pinDots: Array<View>
    private lateinit var appNameTextView: TextView
    private lateinit var errorMessage: TextView
    private lateinit var sharedPreferences: SharedPreferences

    private var enteredPin = ""
    private val pinLength = 4
    private var lockedPackage: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_pin_unlock)

        lockedPackage = intent.getStringExtra("package_name")
        Log.d(TAG, "🔐 NATIVE PIN: Started for package: $lockedPackage")

        if (lockedPackage == null) {
            Log.e(TAG, "🔐 NATIVE PIN ERROR: No package name provided")
            finish()
            return
        }

        initViews()
        setupNumberPad()
        updateAppInfo()
    }

    private fun initViews() {
        pinDots = arrayOf(
            findViewById<View>(R.id.pin_dot_1),
            findViewById<View>(R.id.pin_dot_2),
            findViewById<View>(R.id.pin_dot_3),
            findViewById<View>(R.id.pin_dot_4)
        )
        appNameTextView = findViewById<TextView>(R.id.app_name)
        errorMessage = findViewById<TextView>(R.id.error_message)
        sharedPreferences = getSharedPreferences("app_locker_prefs", MODE_PRIVATE)
    }

    private fun setupNumberPad() {
        val numberButtons = arrayOf(
            findViewById<Button>(R.id.btn_0),
            findViewById<Button>(R.id.btn_1),
            findViewById<Button>(R.id.btn_2),
            findViewById<Button>(R.id.btn_3),
            findViewById<Button>(R.id.btn_4),
            findViewById<Button>(R.id.btn_5),
            findViewById<Button>(R.id.btn_6),
            findViewById<Button>(R.id.btn_7),
            findViewById<Button>(R.id.btn_8),
            findViewById<Button>(R.id.btn_9)
        )

        // Set click listeners for number buttons
        numberButtons.forEachIndexed { index, button ->
            button.setOnClickListener {
                onNumberClick(index.toString())
            }
        }

        // Delete button
        findViewById<Button>(R.id.btn_delete).setOnClickListener {
            onDeleteClick()
        }
    }

    private fun updateAppInfo() {
        try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(lockedPackage!!, 0)
            val appName = packageManager.getApplicationLabel(applicationInfo).toString()
            appNameTextView.text = appName

            Log.d(TAG, "🔐 NATIVE PIN: App name set to: $appName")
        } catch (e: Exception) {
            appNameTextView.text = "Unknown App"
            Log.e(TAG, "🔐 NATIVE PIN ERROR: Failed to get app name: ${e.message}")
        }
    }

    private fun onNumberClick(number: String) {
        if (enteredPin.length < pinLength) {
            enteredPin += number
            updatePinDots()
            hideError()

            Log.d(TAG, "🔐 NATIVE PIN: Pin length now: ${enteredPin.length}")

            if (enteredPin.length == pinLength) {
                verifyPin()
            }
        }
    }

    private fun onDeleteClick() {
        if (enteredPin.isNotEmpty()) {
            enteredPin = enteredPin.substring(0, enteredPin.length - 1)
            updatePinDots()
            hideError()

            Log.d(TAG, "🔐 NATIVE PIN: Pin deleted, length now: ${enteredPin.length}")
        }
    }

    private fun updatePinDots() {
        pinDots.forEachIndexed { index, dot ->
            dot.isSelected = index < enteredPin.length
        }
    }

    private fun verifyPin() {
        Log.d(TAG, "🔐 NATIVE PIN: Verifying PIN...")

        val storedPin = sharedPreferences.getString("app_pin", null)
        if (storedPin == null) {
            Log.e(TAG, "🔐 NATIVE PIN ERROR: No stored PIN found")
            showError("No PIN set")
            return
        }

        val hashedPin = hashPin(enteredPin)

        if (hashedPin == storedPin) {
            Log.d(TAG, "🔐 NATIVE PIN: PIN CORRECT! Unlocking app $lockedPackage")
            unlockApp()
        } else {
            Log.d(TAG, "🔐 NATIVE PIN: PIN WRONG! Showing error")
            showError("Wrong PIN. Try again.")
            clearPin()
            showErrorDots()
        }
    }

    private fun unlockApp() {
        try {
            Log.d(TAG, "🔐 NATIVE PIN: Launching app $lockedPackage")

            val packageManager = packageManager
            val launchIntent = packageManager.getLaunchIntentForPackage(lockedPackage!!)

            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
                startActivity(launchIntent)

                Log.d(TAG, "🔐 NATIVE PIN: Successfully launched $lockedPackage")
                finish()
            } else {
                Log.e(TAG, "🔐 NATIVE PIN ERROR: No launch intent for $lockedPackage")
                showError("Cannot launch app")
            }
        } catch (e: Exception) {
            Log.e(TAG, "🔐 NATIVE PIN ERROR: Failed to launch app: ${e.message}")
            showError("Failed to unlock")
        }
    }

    private fun clearPin() {
        enteredPin = ""
        updatePinDots()
    }

    private fun showError(message: String) {
        errorMessage.text = message
        errorMessage.visibility = View.VISIBLE
    }

    private fun hideError() {
        errorMessage.visibility = View.GONE
    }

    private fun showErrorDots() {
        pinDots.forEach { dot ->
            dot.isPressed = true
        }

        // Reset dots after 1 second
        pinDots[0].postDelayed({
            pinDots.forEach { dot ->
                dot.isPressed = false
            }
        }, 1000)
    }

    private fun hashPin(pin: String): String {
        val bytes = pin.toByteArray()
        val md = MessageDigest.getInstance("SHA-256")
        val digest = md.digest(bytes)
        return digest.fold("") { str, it -> str + "%02x".format(it) }
    }

    override fun onBackPressed() {
        // Prevent back button - force user to enter PIN
        Log.d(TAG, "🔐 NATIVE PIN: Back button pressed - ignoring")
    }
}