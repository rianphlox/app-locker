import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('first_time') ?? true;
    final String? pin = prefs.getString('app_pin');

    if (!mounted) return;

    if (isFirstTime || pin == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.security,
                size: 60,
                color: Color(0xFF4DB6AC),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'App Locker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Protect your privacy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}