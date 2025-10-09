import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:usage_stats/usage_stats.dart';
import 'app_lock_service.dart';
import 'platform_service.dart';

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'app_locker_service',
        initialNotificationTitle: 'App Locker',
        initialNotificationContent: 'App Locker is running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          await _checkForegroundApp(service);
        }
      }
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    // iOS background handling
    return true;
  }

  static Future<void> _checkForegroundApp(ServiceInstance service) async {
    try {
      // Get usage stats for the last few seconds
      final endTime = DateTime.now();
      final startTime = endTime.subtract(const Duration(seconds: 5));

      final queryEvents = await UsageStats.queryEvents(
        startTime,
        endTime,
      );

      if (queryEvents.isNotEmpty) {
        // Get the most recent app event
        final lastEvent = queryEvents.last;
        final packageName = lastEvent.packageName;

        if (packageName != null && packageName.isNotEmpty) {
          // Check if this app is locked
          final isLocked = await AppLockService.isAppLocked(packageName);

          if (isLocked) {
            await PlatformService.showUnlockScreen(packageName);
          }
        }
      }
    } catch (e) {
      // Handle errors silently
    }
  }


  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}