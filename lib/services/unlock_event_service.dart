import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../screens/pin_unlock_screen.dart';
import '../services/platform_service.dart';
import '../main.dart';
import 'log_service.dart';

class UnlockEventService {
  static const EventChannel _eventChannel = EventChannel('app_locker_events');
  static StreamSubscription<dynamic>? _eventSubscription;

  static void init() {
    _startListening();
  }

  static void _startListening() {
    LogService.logger.i('🔐 STEP 13: UnlockEventService starting to listen for events');
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        LogService.logger.i('🔐 STEP 14: UnlockEventService received event: $event');
        if (event is Map<dynamic, dynamic>) {
          final eventType = event['type'] as String?;
          final packageName = event['packageName'] as String?;

          LogService.logger.i('🔐 STEP 15: Event details - type: $eventType, package: $packageName');

          if (eventType == 'unlock_request' && packageName != null) {
            LogService.logger.i('🔐 STEP 16: Valid unlock request, showing PIN screen for $packageName');
            _showUnlockScreen(packageName);
          } else {
            LogService.logger.w('🔐 STEP 16: Invalid event - ignoring');
          }
        } else {
          LogService.logger.w('🔐 STEP 15: Event is not a map - ignoring');
        }
      },
      onError: (dynamic error) {
        LogService.logger.e('🔐 ERROR: UnlockEventService error: $error');
      },
    );
  }

  static void _showUnlockScreen(String packageName) async {
    LogService.logger.i('🔐 STEP 17: _showUnlockScreen called for $packageName');

    final context = navigatorKey.currentContext;
    if (context == null) {
      LogService.logger.e('🔐 ERROR: Navigator context is null');
      return;
    }

    try {
      LogService.logger.i('🔐 STEP 18: Getting app info for display');
      // Get app name for display
      final apps = await PlatformService.getInstalledApps();
      final app = apps.firstWhere(
        (app) => app['packageName'] == packageName,
        orElse: () => {'appName': 'Unknown App'},
      );

      final appName = app['appName'] as String;
      LogService.logger.i('🔐 STEP 19: App name resolved: $appName');

      // Show unlock screen
      if (!context.mounted) {
        LogService.logger.e('🔐 ERROR: Context not mounted');
        return;
      }

      LogService.logger.i('🔐 STEP 20: About to show PIN unlock screen');
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => PinUnlockScreen(
            lockedPackage: packageName,
            lockedAppName: appName,
          ),
          fullscreenDialog: true,
        ),
      );

      LogService.logger.i('🔐 STEP 21: PIN unlock screen returned result: $result');

      // If unlock was successful (result == true), allow the app to continue
      // If cancelled or failed (result == false or null), do nothing (app remains blocked)
      if (result == true) {
        LogService.logger.i('🔐 STEP 22: PIN CORRECT! App $packageName unlocked successfully');
        await PlatformService.temporarilyUnlockApp(packageName);

        // Launch the app that was originally trying to open
        LogService.logger.i('🔐 STEP 23: Now launching the target app $packageName');
        await _launchApp(packageName);
      } else {
        LogService.logger.i('🔐 STEP 22: PIN WRONG/CANCELLED! App $packageName unlock cancelled or failed');
      }
    } catch (e) {
      LogService.logger.e('🔐 ERROR: Error showing unlock screen: $e');
    }
  }

  static Future<void> _launchApp(String packageName) async {
    try {
      // Use Android intent to launch the app
      await PlatformService.launchApp(packageName);
      LogService.logger.i('Launched app: $packageName');
    } catch (e) {
      LogService.logger.e('Error launching app $packageName: $e');
    }
  }

  static void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
