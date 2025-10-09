import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/app_lock_service.dart';
import 'services/permission_service.dart';
import 'services/platform_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AppLockService.init();
  await PermissionService.init();
  await PlatformService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Locker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}