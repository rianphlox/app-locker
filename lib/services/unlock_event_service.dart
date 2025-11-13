import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../screens/unlock_screen.dart';
import '../services/platform_service.dart';
import '../main.dart';

class UnlockEventService {
  static const EventChannel _eventChannel = EventChannel('com.example.newapplocker/events');
  static StreamSubscription<dynamic>? _eventSubscription;

  static void init() {
    _startListening();
  }

  static void _startListening() {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map<dynamic, dynamic>) {
          final eventType = event['type'] as String?;
          final packageName = event['packageName'] as String?;

          if (eventType == 'unlock_request' && packageName != null) {
            _showUnlockScreen(packageName);
          }
        }
      },
      onError: (dynamic error) {
        debugPrint('UnlockEventService error: $error');
      },
    );
  }

  static void _showUnlockScreen(String packageName) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    try {
      // Get app name for display
      final apps = await PlatformService.getInstalledApps();
      final app = apps.firstWhere(
        (app) => app['packageName'] == packageName,
        orElse: () => {'appName': 'Unknown App'},
      );

      final appName = app['appName'] as String;

      // Show unlock screen
      if (!context.mounted) return;
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => UnlockScreen(
            packageName: packageName,
            appName: appName,
          ),
          fullscreenDialog: true,
        ),
      );

      // If unlock was successful (result == true), allow the app to continue
      // If cancelled or failed (result == false or null), do nothing (app remains blocked)
      if (result == true) {
        // App was successfully unlocked, temporarily disable interception
        debugPrint('App $packageName unlocked successfully');
        await PlatformService.temporarilyUnlockApp(packageName);

        // Launch the app that was originally trying to open
        await _launchApp(packageName);
      } else {
        // App unlock was cancelled or failed
        debugPrint('App $packageName unlock cancelled or failed');
      }
    } catch (e) {
      debugPrint('Error showing unlock screen: $e');
    }
  }

  static Future<void> _launchApp(String packageName) async {
    try {
      // Use Android intent to launch the app
      await PlatformService.launchApp(packageName);
      debugPrint('Launched app: $packageName');
    } catch (e) {
      debugPrint('Error launching app $packageName: $e');
    }
  }

  static void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}