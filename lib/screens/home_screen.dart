import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/app_lock_service.dart';
import '../services/platform_service.dart';
import '../models/app_info.dart';
import '../widgets/app_list_item.dart';
import 'settings_screen.dart';
import '../services/log_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppInfo> _systemApps = [];
  List<AppInfo> _userApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadApps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apps = await PlatformService.getInstalledApps();
      LogService.logger.i('Loaded ${apps.length} apps from platform service');

      final systemApps = <AppInfo>[];
      final userApps = <AppInfo>[];

      for (final appMap in apps) {
        try {
          final packageName = appMap['packageName'] as String? ?? 'unknown';
          final appName = appMap['appName'] as String? ?? 'Unknown App';
          final isSystemApp = appMap['isSystemApp'] as bool? ?? false;

          if (packageName == 'unknown') {
            LogService.logger.w('Skipping app with unknown package name');
            continue;
          }

          // Get app icon
          final iconData = await PlatformService.getAppIcon(packageName);
          Uint8List? icon;
          if (iconData != null) {
            icon = Uint8List.fromList(iconData);
          }

          final appInfo = AppInfo(
            packageName: packageName,
            appName: appName,
            icon: icon,
            isSystemApp: isSystemApp,
            isLocked: await AppLockService.isAppLocked(packageName),
          );

          if (isSystemApp) {
            systemApps.add(appInfo);
          } else {
            userApps.add(appInfo);
          }
        } catch (e) {
          LogService.logger.e('Error processing app: $e');
          continue;
        }
      }

      // Sort apps alphabetically
      systemApps.sort((a, b) => a.appName.compareTo(b.appName));
      userApps.sort((a, b) => a.appName.compareTo(b.appName));

      setState(() {
        _systemApps = systemApps;
        _userApps = userApps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading apps: $e')),
        );
      }
    }
  }

  Future<void> _toggleAppLock(AppInfo app) async {
    try {
      if (app.isLocked) {
        await AppLockService.unlockApp(app.packageName);
      } else {
        await AppLockService.lockApp(app.packageName);
      }

      // Update native service with locked apps
      await _updateNativeLockedApps();

      setState(() {
        app.isLocked = !app.isLocked;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling app lock: $e')),
        );
      }
    }
  }

  Future<void> _updateNativeLockedApps() async {
    try {
      final lockedApps = await AppLockService.getLockedApps();
      await PlatformService.setLockedApps(lockedApps);
      await PlatformService.enableAccessibilityMonitoring(lockedApps.isNotEmpty);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _showDiagnosticDialog() async {
    try {
      // Gather diagnostic information
      final lockedApps = await AppLockService.getLockedApps();
      final isAccessibilityEnabled = await PlatformService.isAccessibilityServiceEnabled();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Diagnostic Information',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDiagnosticRow(
                'Accessibility Service',
                isAccessibilityEnabled ? 'ENABLED ✓' : 'DISABLED ✗',
                isAccessibilityEnabled ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              _buildDiagnosticRow(
                'Locked Apps Count',
                '${lockedApps.length}',
                lockedApps.isNotEmpty ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 8),
              if (lockedApps.isNotEmpty) ...[
                const Text(
                  'Locked Apps:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                ...lockedApps.map((app) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '• $app',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                )),
                const SizedBox(height: 12),
              ],
              if (!isAccessibilityEnabled)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha((255 * 0.1).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚠️ Accessibility service is disabled!\nGo to Settings → Accessibility → QVault and turn it ON.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
          actions: [
            if (!isAccessibilityEnabled)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  PlatformService.requestAccessibilityPermission();
                },
                child: const Text(
                  'Open Settings',
                  style: TextStyle(color: Color(0xFF4DB6AC)),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting diagnostic info: $e')),
        );
      }
    }
  }

  Widget _buildDiagnosticRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAppList(List<AppInfo> apps, String emptyMessage) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (apps.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApps,
      child: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return AppListItem(
            app: app,
            onToggle: () => _toggleAppLock(app),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.security,
            color: Color(0xFF4DB6AC),
            size: 28,
          ),
        ),
        title: const Text(
          'QVault',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadApps,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4DB6AC),
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                    color: Color(0xFF4DB6AC),
                  ),
            tooltip: 'Refresh Apps',
          ),
          IconButton(
            onPressed: _showDiagnosticDialog,
            icon: const Icon(
              Icons.info_outline,
              color: Color(0xFF4DB6AC),
            ),
            tooltip: 'Diagnostic Info',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4DB6AC),
          labelColor: const Color(0xFF4DB6AC),
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Local (${_userApps.length})'),
            Tab(text: 'System (${_systemApps.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Local Apps / System Apps summary card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tabController.index == 0 ? 'Local Apps' : 'System Apps',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_tabController.index == 0 ? _userApps.length : _systemApps.length} apps total • ${_tabController.index == 0 ? _userApps.where((app) => app.isLocked).length : _systemApps.where((app) => app.isLocked).length} locked',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'All Unlocked',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Unlocked Apps section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_open,
                  color: Color(0xFF4DB6AC),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Unlocked Apps (${_tabController.index == 0 ? _userApps.where((app) => !app.isLocked).length : _systemApps.where((app) => !app.isLocked).length})',
                  style: const TextStyle(
                    color: Color(0xFF4DB6AC),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // App list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppList(_userApps, 'No user apps found.\nTry tapping the refresh button.'),
                _buildAppList(_systemApps, 'No system apps found.\nTry tapping the refresh button.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
