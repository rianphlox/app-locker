package com.example.newapplocker.utils;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

public class AppUtils {

    /**
     * Hide or show status bar for fullscreen mode
     */
    public static void hideStatusBar(Window window, boolean enable) {
        if (enable) {
            window.getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            );
        } else {
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
        }
    }

    /**
     * Main method to handle auto-start for different manufacturers
     */
    public static boolean autoStart(Context context) {
        String manufacturer = Build.MANUFACTURER.toLowerCase();

        try {
            switch (manufacturer) {
                case "vivo":
                    return autoStartVivo(context);
                case "oppo":
                case "realme":
                    return autoStartOppo(context);
                case "xiaomi":
                case "redmi":
                    return autoStartMi(context);
                case "samsung":
                    return autoStartSamsung(context);
                case "infinix":
                case "tecno":
                    return autoStartInfinix(context);
                case "huawei":
                case "honor":
                    return autoStartHuawei(context);
                case "oneplus":
                    return autoStartOnePlus(context);
                case "lenovo":
                    return autoStartLenovo(context);
                default:
                    // Fallback to general battery optimization settings
                    return requestIgnoreBatteryOptimization(context);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return requestIgnoreBatteryOptimization(context);
        }
    }

    /**
     * Vivo devices auto-start settings
     */
    private static boolean autoStartVivo(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (Exception e) {
            try {
                Intent intent = new Intent();
                intent.setComponent(new ComponentName("com.iqoo.secure",
                    "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            } catch (Exception e2) {
                try {
                    Intent intent = new Intent();
                    intent.setComponent(new ComponentName("com.vivo.permissionmanager",
                        "com.vivo.permissionmanager.activity.PurviewTabActivity"));
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);
                    return true;
                } catch (Exception e3) {
                    return requestIgnoreBatteryOptimization(context);
                }
            }
        }
    }

    /**
     * Oppo/Realme devices auto-start settings
     */
    private static boolean autoStartOppo(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.coloros.safecenter",
                "com.coloros.safecenter.permission.startup.FakeActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (Exception e) {
            try {
                Intent intent = new Intent();
                intent.setComponent(new ComponentName("com.coloros.safecenter",
                    "com.coloros.safecenter.startupapp.StartupAppListActivity"));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            } catch (Exception e2) {
                try {
                    Intent intent = new Intent();
                    intent.setComponent(new ComponentName("com.oppo.safe",
                        "com.oppo.safe.permission.startup.StartupAppListActivity"));
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);
                    return true;
                } catch (Exception e3) {
                    return requestIgnoreBatteryOptimization(context);
                }
            }
        }
    }

    /**
     * Xiaomi/Redmi devices auto-start settings
     */
    private static boolean autoStartMi(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.miui.securitycenter",
                "com.miui.permcenter.autostart.AutoStartManagementActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            // Also try to open general permissions
            allPermMi(context);
            return true;
        } catch (Exception e) {
            try {
                Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
                intent.setClassName("com.miui.securitycenter",
                    "com.miui.permcenter.permissions.PermissionsEditorActivity");
                intent.putExtra("extra_pkgname", context.getPackageName());
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            } catch (Exception e2) {
                return requestIgnoreBatteryOptimization(context);
            }
        }
    }

    /**
     * Samsung devices battery optimization
     */
    private static boolean autoStartSamsung(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.samsung.android.lool",
                "com.samsung.android.sm.ui.battery.BatteryActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (Exception e) {
            try {
                Intent intent = new Intent();
                intent.setComponent(new ComponentName("com.samsung.android.sm_cn",
                    "com.samsung.android.sm.ui.ram.RamActivity"));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            } catch (Exception e2) {
                return requestIgnoreBatteryOptimization(context);
            }
        }
    }

    /**
     * Infinix/Tecno devices auto-start settings
     */
    private static boolean autoStartInfinix(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.transsion.phonemanager",
                "com.transsion.phonemanager.module.appmanager.bootstart.view.BootStartActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (Exception e) {
            try {
                Intent intent = new Intent();
                intent.setComponent(new ComponentName("com.itel.autobootmanager",
                    "com.itel.autobootmanager.AutoBootActivity"));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            } catch (Exception e2) {
                return requestIgnoreBatteryOptimization(context);
            }
        }
    }

    /**
     * Huawei/Honor devices auto-start settings
     */
    private static boolean autoStartHuawei(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.huawei.systemmanager",
                "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (Exception e) {
            try {
                Intent intent = new Intent();
                intent.setComponent(new ComponentName("com.huawei.systemmanager",
                    "com.huawei.systemmanager.optimize.process.ProtectActivity"));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            } catch (Exception e2) {
                return requestIgnoreBatteryOptimization(context);
            }
        }
    }

    /**
     * OnePlus devices auto-start settings
     */
    private static boolean autoStartOnePlus(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.oneplus.security",
                "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (Exception e) {
            return requestIgnoreBatteryOptimization(context);
        }
    }

    /**
     * Lenovo devices auto-start settings
     */
    private static boolean autoStartLenovo(Context context) {
        try {
            Intent intent = new Intent();
            intent.setComponent(new ComponentName("com.lenovo.security",
                "com.lenovo.security.purebackground.PureBackgroundActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (Exception e) {
            return requestIgnoreBatteryOptimization(context);
        }
    }

    /**
     * Additional Xiaomi permissions management
     */
    private static void allPermMi(Context context) {
        try {
            Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
            intent.setClassName("com.miui.securitycenter",
                "com.miui.permcenter.permissions.PermissionsEditorActivity");
            intent.putExtra("extra_pkgname", context.getPackageName());
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Request to ignore battery optimization (fallback method)
     */
    private static boolean requestIgnoreBatteryOptimization(Context context) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Intent intent = new Intent();
                String packageName = context.getPackageName();

                intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
                intent.setData(Uri.parse("package:" + packageName));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            }
        } catch (Exception e) {
            try {
                Intent intent = new Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
                return true;
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
        return false;
    }

    /**
     * Get device manufacturer info
     */
    public static String getDeviceInfo() {
        return "Manufacturer: " + Build.MANUFACTURER +
               ", Model: " + Build.MODEL +
               ", Brand: " + Build.BRAND +
               ", SDK: " + Build.VERSION.SDK_INT;
    }
}