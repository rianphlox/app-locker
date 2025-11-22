package com.example.newapplocker.utils

import android.content.Context
import android.annotation.SuppressLint

@SuppressLint("StaticFieldLeak")
object MainUtilManager {

    private var context: Context? = null

    fun init(context: Context) {
        this.context = context.applicationContext
    }

    fun getInstance(): MainUtilManager {
        return this
    }
}

