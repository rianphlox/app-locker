import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/app_lock_service.dart';
import '../services/platform_service.dart';
import '../models/app_info.dart';
import '../widgets/app_list_item.dart';

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
    try {
      final apps = await PlatformService.getInstalledApps();

      final systemApps = <AppInfo>[];
      final userApps = <AppInfo>[];

      for (final appMap in apps) {
        final packageName = appMap['packageName'] as String;
        final appName = appMap['appName'] as String;
        final isSystemApp = appMap['isSystemApp'] as bool;

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
          'App Locker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Settings functionality
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
                _buildAppList(_userApps, 'No user apps found'),
                _buildAppList(_systemApps, 'No system apps found'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadApps,
        backgroundColor: const Color(0xFF4DB6AC),
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}