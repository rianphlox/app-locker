package com.example.newapplocker.utils

import android.util.Log

object LogUtilManager {
    private const val TAG = "AppLocker"

    fun i(className: String, message: String) {
        Log.i(TAG, "$className: $message")
    }

    fun e(className: String, message: String) {
        Log.e(TAG, "$className: $message")
    }
     fun w(className: String, message: String) {
        Log.w(TAG, "$className: $message")
    }
}
