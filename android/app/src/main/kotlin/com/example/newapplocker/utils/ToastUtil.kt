package com.example.newapplocker.utils

import android.content.Context
import android.widget.Toast

object ToastUtilManager {
    fun showToast(context: Context, message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }
}
