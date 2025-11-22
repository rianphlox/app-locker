import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import 'splash_screen.dart';

class PermissionsCheckScreen extends StatefulWidget {
  const PermissionsCheckScreen({super.key});

  @override
  State<PermissionsCheckScreen> createState() => _PermissionsCheckScreenState();
}

class _PermissionsCheckScreenState extends State<PermissionsCheckScreen> {
  bool _hasAccessibility = false;
  bool _hasUsageStats = false;
  bool _hasOverlay = false;
  bool _hasAutoStart = false;
  bool _isBatteryOptimizationDisabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final accessibility = await PermissionService.hasAccessibilityPermission();
    final usageStats = await PermissionService.hasUsageStatsPermission();
    final overlay = await PermissionService.hasOverlayPermission();
    final autoStart = true; // Not implemented yet
    final battery = true; // Not implemented yet

    setState(() {
      _hasAccessibility = accessibility;
      _hasUsageStats = usageStats;
      _hasOverlay = overlay;
      _hasAutoStart = autoStart;
      _isBatteryOptimizationDisabled = battery;
    });

    if (_hasAccessibility && _hasUsageStats && _hasOverlay && _hasAutoStart && _isBatteryOptimizationDisabled) {
      _navigateToSplash();
    }
  }

  void _navigateToSplash() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Check'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPermissionTile('Accessibility Service', _hasAccessibility, () {
              PermissionService.requestAccessibilityPermission();
            }),
            _buildPermissionTile('Usage Stats', _hasUsageStats, () {
              PermissionService.requestUsageStatsPermission();
            }),
            _buildPermissionTile('Overlay Permission', _hasOverlay, () {
              PermissionService.requestOverlayPermission();
            }),
            _buildPermissionTile('Auto-start', _hasAutoStart, () {
              // Not implemented yet
            }),
            _buildPermissionTile('Disable Battery Optimization', _isBatteryOptimizationDisabled, () {
              PermissionService.requestIgnoreBatteryOptimization();
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPermissions,
              child: const Text('Re-check Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(String title, bool granted, VoidCallback onRequest) {
    return ListTile(
      title: Text(title),
      trailing: granted
          ? const Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
              onPressed: onRequest,
              child: const Text('Grant'),
            ),
    );
  }
}
