import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_service.dart';
import 'app_lock_service.dart';

class AppMonitorService {
  static StreamSubscription<Map<String, dynamic>>? _appSwitchSubscription;
  static bool _isMonitoring = false;
  static final List<String> _lockedApps = [];

  /// Initialize the app monitoring service
  static Future<void> initialize() async {
    debugPrint('AppMonitorService: Initializing...');

    try {
      await PlatformService.init();
      await _loadLockedApps();
      debugPrint('AppMonitorService: Initialization complete');
    } catch (e) {
      debugPrint('AppMonitorService: Initialization failed: $e');
    }
  }

  /// Start monitoring app switches
  static Future<void> startMonitoring() async {
    if (_isMonitoring) {
      debugPrint('AppMonitorService: Already monitoring');
      return;
    }

    try {
      debugPrint('AppMonitorService: Starting monitoring...');

      // Enable accessibility monitoring on Android
      await PlatformService.enableAccessibilityMonitoring(true);

      // Subscribe to app switch events
      _appSwitchSubscription = PlatformService.getAppSwitchEvents().listen(
        _handleAppSwitch,
        onError: (error) {
          debugPrint('AppMonitorService: Stream error: $error');
        },
      );

      _isMonitoring = true;
      debugPrint('AppMonitorService: Monitoring started');
    } catch (e) {
      debugPrint('AppMonitorService: Failed to start monitoring: $e');
    }
  }

  /// Stop monitoring app switches
  static Future<void> stopMonitoring() async {
    if (!_isMonitoring) {
      debugPrint('AppMonitorService: Not currently monitoring');
      return;
    }

    try {
      debugPrint('AppMonitorService: Stopping monitoring...');

      await _appSwitchSubscription?.cancel();
      _appSwitchSubscription = null;

      // Disable accessibility monitoring on Android
      await PlatformService.enableAccessibilityMonitoring(false);

      _isMonitoring = false;
      debugPrint('AppMonitorService: Monitoring stopped');
    } catch (e) {
      debugPrint('AppMonitorService: Failed to stop monitoring: $e');
    }
  }

  /// Handle app switch events
  static void _handleAppSwitch(Map<String, dynamic> event) {
    try {
      final packageName = event['packageName'] as String?;
      final eventType = event['type'] as String?;

      if (packageName == null || eventType == null) {
        return;
      }

      debugPrint('AppMonitorService: App switch detected - $packageName ($eventType)');

      // Only handle locked apps (not QVault itself)
      if (_lockedApps.contains(packageName)) {
        debugPrint('AppMonitorService: Locked app detected: $packageName');
        // Show unlock screen immediately when locked app is accessed
        _handleLockedAppAccess(packageName);
      }
    } catch (e) {
      debugPrint('AppMonitorService: Error handling app switch: $e');
    }
  }

  /// Handle access to a locked app
  static void _handleLockedAppAccess(String packageName) {
    try {
      debugPrint('AppMonitorService: Blocking access to $packageName');

      // Show unlock screen
      PlatformService.showUnlockScreen(packageName);

      // Optionally, kill the app (requires device admin)
      // PlatformService.killApp(packageName);

    } catch (e) {
      debugPrint('AppMonitorService: Error blocking app access: $e');
    }
  }

  /// Load locked apps from storage
  static Future<void> _loadLockedApps() async {
    try {
      _lockedApps.clear();
      _lockedApps.addAll(await AppLockService.getLockedApps());
      debugPrint('AppMonitorService: Loaded ${_lockedApps.length} locked apps');
    } catch (e) {
      debugPrint('AppMonitorService: Failed to load locked apps: $e');
    }
  }

  /// Update the list of locked apps
  static Future<void> updateLockedApps(List<String> lockedApps) async {
    try {
      _lockedApps.clear();
      _lockedApps.addAll(lockedApps);

      // Update platform service with new locked apps
      await PlatformService.setLockedApps(lockedApps);

      debugPrint('AppMonitorService: Updated locked apps: ${_lockedApps.length}');
    } catch (e) {
      debugPrint('AppMonitorService: Failed to update locked apps: $e');
    }
  }

  /// Check if monitoring is active
  static bool get isMonitoring => _isMonitoring;

  /// Get the list of currently locked apps
  static List<String> get lockedApps => List.unmodifiable(_lockedApps);

  /// Dispose of the service
  static Future<void> dispose() async {
    await stopMonitoring();
    debugPrint('AppMonitorService: Disposed');
  }

  /// Get monitoring status for UI
  static Map<String, dynamic> getStatus() {
    return {
      'isMonitoring': _isMonitoring,
      'lockedAppsCount': _lockedApps.length,
      'hasSubscription': _appSwitchSubscription != null,
    };
  }

  /// Restart monitoring (useful after permission changes)
  static Future<void> restartMonitoring() async {
    debugPrint('AppMonitorService: Restarting monitoring...');

    await stopMonitoring();
    await Future.delayed(const Duration(milliseconds: 500));
    await startMonitoring();

    debugPrint('AppMonitorService: Monitoring restarted');
  }

  /// Check if all required permissions are granted
  static Future<bool> hasRequiredPermissions() async {
    try {
      // You can add specific permission checks here
      // For now, we'll assume permissions are needed for monitoring
      return _isMonitoring;
    } catch (e) {
      debugPrint('AppMonitorService: Error checking permissions: $e');
      return false;
    }
  }
}