import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/app_lock_service.dart';
import 'services/permission_service.dart';
import 'services/platform_service.dart';
import 'services/unlock_event_service.dart';
import 'services/app_monitor_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AppLockService.init();
  await PermissionService.init();
  await PlatformService.init();
  await AppMonitorService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UnlockEventService.init();
    });
  }

  @override
  void dispose() {
    UnlockEventService.dispose();
    AppMonitorService.dispose();
    super.dispose();
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