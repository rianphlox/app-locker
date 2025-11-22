import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/platform_service.dart';
import '../services/log_service.dart';

class PinUnlockScreen extends StatefulWidget {
  final String lockedAppName;
  final String lockedPackage;

  const PinUnlockScreen({
    super.key,
    required this.lockedAppName,
    required this.lockedPackage,
  });

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  String _pin = '';
  final int _pinLength = 4;
  bool _isWrongPin = false;
  String? lockedPackage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    LogService.logger.i('🔐 STEP 24: PinUnlockScreen initState called');
    LogService.logger.i('🔐 STEP 25: Locked app name from constructor: ${widget.lockedAppName}');
    LogService.logger.i('🔐 STEP 26: Locked package from constructor: ${widget.lockedPackage}');
    _getLockedPackage();
  }

  Future<void> _getLockedPackage() async {
    LogService.logger.i('🔐 STEP 27: Getting locked package from intent');
    final intent = await PlatformService.getIntentData();
    LogService.logger.i('🔐 STEP 28: Intent data received: $intent');
    setState(() {
      lockedPackage = intent['package_name'] as String?;
      _isLoading = false;
    });
    LogService.logger.i('🔐 STEP 29: Locked package set to: $lockedPackage, loading complete');
  }

  void _onNumberTap(String number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
        _isWrongPin = false;
      });

      if (_pin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onDeleteTap() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isWrongPin = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('app_pin');

    if (storedPin != null) {
      final bytes = utf8.encode(_pin);
      final hashedPin = sha256.convert(bytes).toString();

      if (hashedPin == storedPin) {
        _unlockApp();
      } else {
        setState(() {
          _pin = '';
          _isWrongPin = true;
        });

        // Show wrong pin feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wrong PIN. Try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _unlockApp() async {
    if (lockedPackage == null) {
      Navigator.pop(context); // safety
      return;
    }

    try {
      LogService.logger.i("PIN correct! Launching app: $lockedPackage");

      // Launch the real app that user wanted to open
      await PlatformService.launchApp(lockedPackage!);

      LogService.logger.i("App launch triggered for $lockedPackage, closing lock screen");

      // Immediately close lock screen - the real app will come to front
      SystemNavigator.pop(); // Kills the lock activity completely
    } catch (e) {
      LogService.logger.e("Error launching $lockedPackage: $e");
      // Stay on PIN screen if launch failed
    }
  }

  Widget _buildPinDot(int index) {
    Color dotColor = Colors.white;
    if (_isWrongPin) {
      dotColor = Colors.red;
    }

    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index < _pin.length ? dotColor : Colors.transparent,
        border: Border.all(color: dotColor, width: 2),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () => _onNumberTap(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.white54, width: 2),
          elevation: 0,
        ),
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: _onDeleteTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.white54, width: 2),
          elevation: 0,
        ),
        child: const Icon(
          Icons.backspace_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
            ),
          ),
          child: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      size: 40,
                      color: Color(0xFF4DB6AC),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  widget.lockedAppName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter PIN to unlock',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pinLength,
                        (index) => _buildPinDot(index),
                  ),
                ),
                const SizedBox(height: 80),
                // Number pad
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNumberButton('1'),
                        _buildNumberButton('2'),
                        _buildNumberButton('3'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNumberButton('4'),
                        _buildNumberButton('5'),
                        _buildNumberButton('6'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNumberButton('7'),
                        _buildNumberButton('8'),
                        _buildNumberButton('9'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 96),
                        _buildNumberButton('0'),
                        _buildDeleteButton(),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
