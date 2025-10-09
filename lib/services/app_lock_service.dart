import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppLockService {
  static late Database _database;
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initDatabase();
  }

  static Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_locker.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locked_apps(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            package_name TEXT UNIQUE,
            app_name TEXT,
            is_system_app INTEGER,
            locked_at INTEGER
          )
        ''');
      },
    );
  }

  static Future<bool> isAppLocked(String packageName) async {
    final result = await _database.query(
      'locked_apps',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
    return result.isNotEmpty;
  }

  static Future<void> lockApp(String packageName) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.insert(
      'locked_apps',
      {
        'package_name': packageName,
        'locked_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> unlockApp(String packageName) async {
    await _database.delete(
      'locked_apps',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  static Future<List<String>> getLockedApps() async {
    final result = await _database.query('locked_apps');
    return result.map((row) => row['package_name'] as String).toList();
  }

  static Future<void> unlockAllApps() async {
    await _database.delete('locked_apps');
  }

  // Background service methods
  static Future<void> startLockService() async {
    await _prefs.setBool('lock_service_enabled', true);
  }

  static Future<void> stopLockService() async {
    await _prefs.setBool('lock_service_enabled', false);
  }

  static bool isLockServiceEnabled() {
    return _prefs.getBool('lock_service_enabled') ?? false;
  }

  // PIN verification
  static String? getStoredPin() {
    return _prefs.getString('app_pin');
  }

  static Future<void> setPin(String hashedPin) async {
    await _prefs.setString('app_pin', hashedPin);
  }

  static Future<void> removePin() async {
    await _prefs.remove('app_pin');
  }

  // Settings
  static bool isBiometricEnabled() {
    return _prefs.getBool('biometric_enabled') ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool('biometric_enabled', enabled);
  }

  static bool isAutoLockEnabled() {
    return _prefs.getBool('auto_lock_enabled') ?? false;
  }

  static Future<void> setAutoLockEnabled(bool enabled) async {
    await _prefs.setBool('auto_lock_enabled', enabled);
  }

  static int getAutoLockDelay() {
    return _prefs.getInt('auto_lock_delay') ?? 0; // in minutes
  }

  static Future<void> setAutoLockDelay(int minutes) async {
    await _prefs.setInt('auto_lock_delay', minutes);
  }
}