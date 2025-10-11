import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('com.example.newapplocker/platform');
  static const EventChannel _eventChannel = EventChannel('com.example.newapplocker/events');

  static Stream<Map<String, dynamic>>? _appSwitchStream;

  // Initialize platform service
  static Future<void> init() async {
    try {
      await _channel.invokeMethod('init');
    } catch (e) {
      debugPrint('Error initializing platform service: $e');
    }
  }

  // Check if accessibility service is enabled
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final result = await _channel.invokeMethod('isAccessibilityServiceEnabled');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Request accessibility service permission
  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      debugPrint('Error requesting accessibility permission: $e');
    }
  }

  // Check if device admin is enabled
  static Future<bool> isDeviceAdminEnabled() async {
    try {
      final result = await _channel.invokeMethod('isDeviceAdminEnabled');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Request device admin permission
  static Future<void> requestDeviceAdminPermission() async {
    try {
      await _channel.invokeMethod('requestDeviceAdminPermission');
    } catch (e) {
      debugPrint('Error requesting device admin permission: $e');
    }
  }

  // Set locked apps in native service
  static Future<void> setLockedApps(List<String> packageNames) async {
    try {
      await _channel.invokeMethod('setLockedApps', {
        'packageNames': packageNames,
      });
    } catch (e) {
      debugPrint('Error setting locked apps: $e');
    }
  }

  // Enable accessibility monitoring
  static Future<void> enableAccessibilityMonitoring(bool enabled) async {
    try {
      await _channel.invokeMethod('enableAccessibilityMonitoring', {
        'enabled': enabled,
      });
    } catch (e) {
      debugPrint('Error enabling accessibility monitoring: $e');
    }
  }

  // Show unlock screen overlay
  static Future<void> showUnlockScreen(String packageName) async {
    try {
      await _channel.invokeMethod('showUnlockScreen', {
        'packageName': packageName,
      });
    } catch (e) {
      debugPrint('Error showing unlock screen: $e');
    }
  }

  // Get app switch events stream
  static Stream<Map<String, dynamic>> getAppSwitchEvents() {
    _appSwitchStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
    return _appSwitchStream!;
  }

  // Kill app (requires device admin)
  static Future<void> killApp(String packageName) async {
    try {
      await _channel.invokeMethod('killApp', {
        'packageName': packageName,
      });
    } catch (e) {
      debugPrint('Error killing app: $e');
    }
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  // Open accessibility settings
  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Error opening accessibility settings: $e');
    }
  }

  // Check if system alert window permission is granted
  static Future<bool> hasSystemAlertWindowPermission() async {
    try {
      final result = await _channel.invokeMethod('hasSystemAlertWindowPermission');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Request system alert window permission
  static Future<void> requestSystemAlertWindowPermission() async {
    try {
      await _channel.invokeMethod('requestSystemAlertWindowPermission');
    } catch (e) {
      debugPrint('Error requesting system alert window permission: $e');
    }
  }

  // Get installed apps
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('Error getting installed apps: $e');
      return [];
    }
  }

  // Get app icon
  static Future<List<int>?> getAppIcon(String packageName) async {
    try {
      final result = await _channel.invokeMethod('getAppIcon', {
        'packageName': packageName,
      });
      return result != null ? List<int>.from(result) : null;
    } catch (e) {
      debugPrint('Error getting app icon: $e');
      return null;
    }
  }

  // Request auto-start permission for device-specific manufacturers
  static Future<bool> requestAutoStart() async {
    try {
      final result = await _channel.invokeMethod('requestAutoStart');
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting auto-start: $e');
      return false;
    }
  }

  // Request all necessary permissions for AppLocker
  static Future<bool> requestAllPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestAllPermissions');
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting all permissions: $e');
      return false;
    }
  }

  // Show native toast message
  static Future<void> showToast(String message) async {
    try {
      await _channel.invokeMethod('showToast', {
        'message': message,
      });
    } catch (e) {
      debugPrint('Error showing toast: $e');
    }
  }

  // Get device information
  static Future<String> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return result ?? 'Unknown device';
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return 'Error getting device info';
    }
  }
}