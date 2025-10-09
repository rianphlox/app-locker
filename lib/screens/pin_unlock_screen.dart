import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import '../services/app_lock_service.dart';

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
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    if (AppLockService.isBiometricEnabled()) {
      try {
        final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final bool isDeviceSupported = await _localAuth.isDeviceSupported();

        if (canCheckBiometrics && isDeviceSupported) {
          final bool didAuthenticate = await _localAuth.authenticate(
            localizedReason: 'Please verify your identity to unlock ${widget.lockedAppName}',
            options: const AuthenticationOptions(
              biometricOnly: false,
              stickyAuth: true,
            ),
          );

          if (didAuthenticate) {
            _unlockApp();
          }
        }
      } catch (e) {
        // Biometric authentication failed, continue with PIN
      }
    }
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

  void _unlockApp() {
    Navigator.of(context).pop(true);
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

  Widget _buildBiometricButton() {
    if (!AppLockService.isBiometricEnabled()) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: _checkBiometric,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.white54, width: 2),
          elevation: 0,
        ),
        child: const Icon(
          Icons.fingerprint,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
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
            child: Column(
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
                        _buildBiometricButton(),
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