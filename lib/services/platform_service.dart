import 'dart:async';
import 'package:flutter/services.dart';
import 'log_service.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('app_locker_channel');
  static const EventChannel _eventChannel = EventChannel('app_locker_events');

  static Stream<Map<String, dynamic>>? _appSwitchStream;

  // Initialize platform service
  static Future<void> init() async {
    try {
      await _channel.invokeMethod('init');
    } catch (e) {
      LogService.logger.e('Error initializing platform service: $e');
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
      LogService.logger.e('Error requesting accessibility permission: $e');
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
      LogService.logger.e('Error requesting device admin permission: $e');
    }
  }

  // Set locked apps in native service
  static Future<void> setLockedApps(List<String> packageNames) async {
    try {
      LogService.logger.i('Setting locked apps on native side: $packageNames');
      await _channel.invokeMethod('setLockedApps', {
        'packageNames': packageNames,
      });
      LogService.logger.i('Successfully set locked apps on native side');
    } catch (e) {
      LogService.logger.e('Error setting locked apps: $e');
    }
  }

  // Enable accessibility monitoring
  static Future<void> enableAccessibilityMonitoring(bool enabled) async {
    try {
      LogService.logger.i('Setting accessibility monitoring to: $enabled');
      await _channel.invokeMethod('enableAccessibilityMonitoring', {
        'enabled': enabled,
      });
      LogService.logger.i('Successfully set accessibility monitoring to: $enabled');
    } catch (e) {
      LogService.logger.e('Error enabling accessibility monitoring: $e');
    }
  }

  // Show unlock screen overlay
  static Future<void> showUnlockScreen(String packageName) async {
    try {
      await _channel.invokeMethod('showUnlockScreen', {
        'packageName': packageName,
      });
    } catch (e) {
      LogService.logger.e('Error showing unlock screen: $e');
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
      LogService.logger.e('Error killing app: $e');
    }
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (e) {
      LogService.logger.e('Error opening app settings: $e');
    }
  }

  // Open accessibility settings
  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      LogService.logger.e('Error opening accessibility settings: $e');
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
      LogService.logger.e('Error requesting system alert window permission: $e');
    }
  }

  // Get installed apps
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      LogService.logger.d('Raw result type: ${result.runtimeType}');
      LogService.logger.d('Raw result: $result');

      if (result is List) {
        return result.map((item) {
          if (item is Map) {
            // Convert Map<Object?, Object?> to Map<String, dynamic>
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }

      LogService.logger.w('Unexpected result type: ${result.runtimeType}');
      return [];
    } catch (e) {
      LogService.logger.e('Error getting installed apps: $e');
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
      LogService.logger.e('Error getting app icon: $e');
      return null;
    }
  }

  // Request auto-start permission for device-specific manufacturers
  static Future<bool> requestAutoStart() async {
    try {
      final result = await _channel.invokeMethod('requestAutoStart');
      return result ?? false;
    } catch (e) {
      LogService.logger.e('Error requesting auto-start: $e');
      return false;
    }
  }

  // Request all necessary permissions for AppLocker
  static Future<bool> requestAllPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestAllPermissions');
      return result ?? false;
    } catch (e) {
      LogService.logger.e('Error requesting all permissions: $e');
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
      LogService.logger.e('Error showing toast: $e');
    }
  }

  // Get device information
  static Future<String> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return result ?? 'Unknown device';
    } catch (e) {
      LogService.logger.e('Error getting device info: $e');
      return 'Error getting device info';
    }
  }

  static Future<Map<dynamic, dynamic>> getIntentData() async {
    try {
      final result = await _channel.invokeMethod('getIntentData');
      return result as Map<dynamic, dynamic>;
    } catch (e) {
      LogService.logger.e('Error getting intent data: $e');
      return <dynamic, dynamic>{};
    }
  }

  // Temporarily unlock an app (bypass interception after successful PIN)
  static Future<void> temporarilyUnlockApp(String packageName) async {
    try {
      LogService.logger.i('Temporarily unlocking app: $packageName');
      await _channel.invokeMethod('temporarilyUnlockApp', {
        'packageName': packageName,
      });
      LogService.logger.i('Successfully temporarily unlocked app: $packageName');
    } catch (e) {
      LogService.logger.e('Error temporarily unlocking app: $e');
    }
  }

  // Re-enable interception for an app (after app closes permanently)
  static Future<void> reEnableAppInterception(String packageName) async {
    try {
      LogService.logger.i('Re-enabling interception for app: $packageName');
      await _channel.invokeMethod('reEnableAppInterception', {
        'packageName': packageName,
      });
      LogService.logger.i('Successfully re-enabled interception for app: $packageName');
    } catch (e) {
      LogService.logger.e('Error re-enabling app interception: $e');
    }
  }

  // Launch an app by package name
  static Future<void> launchApp(String packageName) async {
    try {
      LogService.logger.i('Launching app: $packageName');
      await _channel.invokeMethod('launchApp', {
        'packageName': packageName,
      });
      LogService.logger.i('Successfully launched app: $packageName');
    } catch (e) {
      LogService.logger.e('Error launching app: $e');
    }
  }
}
