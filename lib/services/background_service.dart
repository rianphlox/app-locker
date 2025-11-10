import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';

@pragma('vm:entry-point')
class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'app_locker_service',
        initialNotificationTitle: 'App Locker Active',
        initialNotificationContent: 'Background monitoring enabled',
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

    // Simple background service that just maintains a persistent notification
    // The actual monitoring is handled by the main app isolate
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "App Locker Active",
        content: "Background monitoring enabled",
      );
    }

    // Keep service alive with periodic health check
    Timer? healthTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // Simple heartbeat to keep service alive
          service.setForegroundNotificationInfo(
            title: "App Locker Active",
            content: "Background monitoring enabled - ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          );
        }
      }
    });

    service.on('stopService').listen((event) {
      healthTimer.cancel();
      service.stopSelf();
    });

    // Listen for commands from main isolate
    service.on('updateStatus').listen((event) {
      if (service is AndroidServiceInstance) {
        final data = event;
        if (data is Map<String, dynamic>) {
          service.setForegroundNotificationInfo(
            title: data['title'] ?? "App Locker Active",
            content: data['content'] ?? "Background monitoring enabled",
          );
        }
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    // iOS background handling
    return true;
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

  static Future<void> updateNotification({
    String title = "App Locker Active",
    String? content,
  }) async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('updateStatus', {
        'title': title,
        'content': content ?? "Background monitoring enabled",
      });
    }
  }
}