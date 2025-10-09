import 'dart:typed_data';

class AppInfo {
  final String packageName;
  final String appName;
  final Uint8List? icon;
  final bool isSystemApp;
  bool isLocked;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.icon,
    required this.isSystemApp,
    required this.isLocked,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'isSystemApp': isSystemApp ? 1 : 0,
      'isLocked': isLocked ? 1 : 0,
    };
  }

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? '',
      icon: map['icon'] != null ? Uint8List.fromList(List<int>.from(map['icon'])) : null,
      isSystemApp: map['isSystemApp'] ?? false,
      isLocked: map['isLocked'] ?? false,
    );
  }

  AppInfo copyWith({
    String? packageName,
    String? appName,
    Uint8List? icon,
    bool? isSystemApp,
    bool? isLocked,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      icon: icon ?? this.icon,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  String toString() {
    return 'AppInfo(packageName: $packageName, appName: $appName, isSystemApp: $isSystemApp, isLocked: $isLocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppInfo && other.packageName == packageName;
  }

  @override
  int get hashCode {
    return packageName.hashCode;
  }
}