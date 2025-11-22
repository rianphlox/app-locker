package com.example.newapplocker.utils

import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.os.Build

object AppUtilsManager {

    fun getDeviceInfo(): String {
        return "OS: ${Build.VERSION.RELEASE}, Model: ${Build.MODEL}, Product: ${Build.PRODUCT}"
    }

    fun autoStart(context: Context): Boolean {
        try {
            val intent = Intent()
            val manufacturer = Build.MANUFACTURER.lowercase()

            when {
                manufacturer == "xiaomi" -> {
                    intent.component = ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                }
                manufacturer == "oppo" -> {
                    intent.component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                    )
                }
                manufacturer == "vivo" -> {
                    intent.component = ComponentName(
                        "com.vivo.permissionmanager",
                        "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
                    )
                }
                manufacturer == "huawei" -> {
                    intent.component = ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.optimize.process.ProtectActivity"
                    )
                }
            }

            if (context.packageManager.resolveActivity(intent, 0) != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                return true
            }
        } catch (e: Exception) {
            // LogUtil.e("AppUtils", "Failed to open auto-start settings: ${e.message}")
        }
        return false
    }
}
