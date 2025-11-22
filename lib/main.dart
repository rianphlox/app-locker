import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/app_lock_service.dart';
import 'services/permission_service.dart';
import 'services/platform_service.dart';
import 'services/unlock_event_service.dart';
import 'services/app_monitor_service.dart';
import 'services/log_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await LogService.init();
  await AppLockService.init();
  await PermissionService.init();
  await PlatformService.init();
  await AppMonitorService.initialize();

  // Initialize background service (disabled temporarily due to Android 14 issues)
  // await BackgroundService.initializeService();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UnlockEventService.init();
      _startMonitoring();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    UnlockEventService.dispose();
    AppMonitorService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        LogService.logger.i('QVault: App resumed - checking if unlock needed');
        _handleAppResume();
        break;
      case AppLifecycleState.paused:
        LogService.logger.i('QVault: App paused/minimized');
        _handleAppPause();
        break;
      case AppLifecycleState.detached:
        LogService.logger.i('QVault: App detached');
        _updateBackgroundNotification();
        break;
      default:
        break;
    }
  }

  Future<void> _handleAppResume() async {
    try {
      // Simulate a small delay to let the system register the app switch
      await Future.delayed(const Duration(milliseconds: 100));
      await _startMonitoring();
    } catch (e) {
      LogService.logger.e('Failed to handle app resume: $e');
    }
  }

  Future<void> _handleAppPause() async {
    try {
      // Mark QVault as minimized for self-protection
      LogService.logger.i('QVault paused - will require unlock on return');
      _updateBackgroundNotification();
    } catch (e) {
      LogService.logger.e('Failed to handle app pause: $e');
    }
  }

  Future<void> _startMonitoring() async {
    try {
      await AppMonitorService.startMonitoring();
      _startBackgroundServiceIfNeeded();
    } catch (e) {
      LogService.logger.e('Failed to start monitoring: $e');
    }
  }

  Future<void> _startBackgroundServiceIfNeeded() async {
    try {
      // Background service disabled due to Android 14 compatibility issues
      // Core monitoring still works via accessibility service
      LogService.logger.i('Background monitoring active via accessibility service');
    } catch (e) {
      LogService.logger.e('Background service error (non-critical): $e');
      // Continue without background service if it fails
    }
  }

  Future<void> _updateBackgroundNotification() async {
    try {
      // Background notification disabled temporarily
      LogService.logger.i('Monitoring active - background notification disabled');
    } catch (e) {
      LogService.logger.e('Failed to update notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QVault',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
    );
  }
}
