import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';

class UnlockScreen extends StatefulWidget {
  final String packageName;
  final String appName;

  const UnlockScreen({
    super.key,
    required this.packageName,
    required this.appName,
  });

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  String _enteredPin = '';
  final int _pinLength = 4;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();
  }

  Future<void> _checkBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (isBiometricEnabled) {
      try {
        final isAvailable = await _localAuth.canCheckBiometrics;
        if (isAvailable) {
          final isAuthenticated = await _localAuth.authenticate(
            localizedReason: 'Unlock ${widget.appName}',
            options: const AuthenticationOptions(
              biometricOnly: false,
              stickyAuth: true,
            ),
          );

          if (isAuthenticated) {
            _unlockApp();
          }
        }
      } catch (e) {
        // Biometric authentication failed, fall back to PIN
      }
    }
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin += number;
      });

      if (_enteredPin.length == _pinLength) {
        _validatePin();
      }
    }
  }

  void _onDeleteTap() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _validatePin() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('app_pin');

    if (storedPin != null) {
      final bytes = utf8.encode(_enteredPin);
      final hashedEnteredPin = sha256.convert(bytes).toString();

      if (hashedEnteredPin == storedPin) {
        _unlockApp();
      } else {
        _showWrongPinError();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _unlockApp() {
    Navigator.pop(context, true);
  }

  void _showWrongPinError() {
    setState(() {
      _enteredPin = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wrong PIN. Try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildPinDot(int index) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index < _enteredPin.length ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _onNumberTap(number),
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
        onPressed: _isLoading ? null : _onDeleteTap,
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
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _checkBiometricAuth,
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
    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.black87,
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
                  child: const Icon(
                    Icons.lock,
                    size: 40,
                    color: Color(0xFF4DB6AC),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  widget.appName,
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
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
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
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}