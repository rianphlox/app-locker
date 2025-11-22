import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PermissionService {
  static const platform = MethodChannel('app_locker_permissions');

  static Future<void> init() async {
    // Initialize permission checks
  }

  static Future<bool> requestUsageStatsPermission() async {
    try {
      if (Platform.isAndroid) {
        final result = await platform.invokeMethod('requestUsageStatsPermission');
        return result ?? false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestOverlayPermission() async {
    try {
      final status = await Permission.systemAlertWindow.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestDeviceAdminPermission() async {
    try {
      // This would typically require native Android code
      final result = await platform.invokeMethod('requestDeviceAdmin');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestAccessibilityPermission() async {
    try {
      final result = await platform.invokeMethod('requestAccessibility');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestIgnoreBatteryOptimization() async {
    try {
      final result = await platform.invokeMethod('requestBatteryOptimization');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasUsageStatsPermission() async {
    try {
      final result = await platform.invokeMethod('hasUsageStatsPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasOverlayPermission() async {
    final status = await Permission.systemAlertWindow.status;
    return status == PermissionStatus.granted;
  }

  static Future<bool> hasAccessibilityPermission() async {
    try {
      final result = await platform.invokeMethod('hasAccessibilityPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasAllRequiredPermissions() async {
    final usage = await hasUsageStatsPermission();
    final overlay = await hasOverlayPermission();
    final accessibility = await hasAccessibilityPermission();

    return usage && overlay && accessibility;
  }

  static Future<void> requestAllPermissions() async {
    await requestUsageStatsPermission();
    await requestOverlayPermission();
    await requestAccessibilityPermission();
    await requestIgnoreBatteryOptimization();
  }
}