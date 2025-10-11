import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../services/platform_service.dart';
import 'home_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _usageStatsGranted = false;
  bool _overlayGranted = false;
  bool _accessibilityGranted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    final usageStats = await PermissionService.hasUsageStatsPermission();
    final overlay = await PermissionService.hasOverlayPermission();
    final accessibility = await PermissionService.hasAccessibilityPermission();

    setState(() {
      _usageStatsGranted = usageStats;
      _overlayGranted = overlay;
      _accessibilityGranted = accessibility;
      _isLoading = false;
    });
  }

  Future<void> _requestUsageStats() async {
    setState(() {
      _isLoading = true;
    });

    await PermissionService.requestUsageStatsPermission();

    // Check again after some delay
    await Future.delayed(const Duration(seconds: 1));
    await _checkPermissions();
  }

  Future<void> _requestOverlay() async {
    setState(() {
      _isLoading = true;
    });

    await PermissionService.requestOverlayPermission();

    await Future.delayed(const Duration(seconds: 1));
    await _checkPermissions();
  }

  Future<void> _requestAccessibility() async {
    setState(() {
      _isLoading = true;
    });

    await PermissionService.requestAccessibilityPermission();

    await Future.delayed(const Duration(seconds: 1));
    await _checkPermissions();
  }

  Future<void> _requestBatteryOptimization() async {
    await PermissionService.requestIgnoreBatteryOptimization();
  }

  Future<void> _requestAutoStart() async {
    try {
      await PlatformService.showToast('Opening device-specific auto-start settings...');
      await PlatformService.requestAutoStart();
    } catch (e) {
      // Handle error silently
    }
  }

  void _continueToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted ? const Color(0xFF4DB6AC) : Colors.grey.withValues(alpha: 0.3),
          width: isGranted ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isGranted
                ? const Color(0xFF4DB6AC).withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isGranted ? Icons.check_circle : icon,
            color: isGranted ? const Color(0xFF4DB6AC) : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing: isGranted
            ? const Icon(
                Icons.check_circle,
                color: Color(0xFF4DB6AC),
                size: 24,
              )
            : ElevatedButton(
                onPressed: _isLoading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB6AC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Enable',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _usageStatsGranted && _overlayGranted && _accessibilityGranted;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Required Permissions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Grant these permissions to enable app locking functionality',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      _buildPermissionCard(
                        title: 'Usage Access',
                        description: 'Monitor which apps are opened',
                        isGranted: _usageStatsGranted,
                        onTap: _requestUsageStats,
                        icon: Icons.analytics,
                      ),
                      _buildPermissionCard(
                        title: 'Display Over Apps',
                        description: 'Show lock screen over other apps',
                        isGranted: _overlayGranted,
                        onTap: _requestOverlay,
                        icon: Icons.layers,
                      ),
                      _buildPermissionCard(
                        title: 'Accessibility Service',
                        description: 'Monitor app switches in real-time',
                        isGranted: _accessibilityGranted,
                        onTap: _requestAccessibility,
                        icon: Icons.accessibility,
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: _requestBatteryOptimization,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.battery_charging_full,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Disable Battery Optimization',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: _requestAutoStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DB6AC),
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Enable Auto-Start (Device Specific)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: allGranted ? _continueToHome : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allGranted
                      ? const Color(0xFF4DB6AC)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  allGranted ? 'Continue' : 'Grant All Permissions First',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}