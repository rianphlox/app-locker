# QVault - Advanced Android App Locker

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-API%2023+-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A powerful, cross-device compatible Android app locker with advanced security features**

[Features](#-features) • [Installation](#-installation) • [Device Compatibility](#-device-compatibility) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## 🚀 Features

### 🔐 **Core Security**
- **PIN Protection** - Secure 4-digit PIN authentication
- **Biometric Authentication** - Fingerprint & Face unlock support
- **App Locking** - Lock any installed application
- **Real-time Monitoring** - Instant app switch detection
- **Secure Storage** - Encrypted PIN storage with SHA-256

### 📱 **Universal Device Compatibility**
- **Multi-Manufacturer Support** - Works on 8+ major Android brands
- **Auto-Detection** - Automatically detects device manufacturer
- **Smart Permission Guidance** - Device-specific setup instructions
- **Graceful Fallbacks** - Works on unknown devices too

### 🛠️ **Advanced Features**
- **Background Monitoring** - Continuous app usage tracking
- **Native Integration** - Deep Android system integration
- **Permission Management** - Comprehensive permission handling
- **Auto-Start Configuration** - Device-specific background settings
- **Professional UI** - Modern, intuitive interface

---

## 📱 Device Compatibility

QVault automatically detects your device and provides manufacturer-specific guidance:

| **Manufacturer** | **Custom ROM** | **Auto-Start Method** | **Status** |
|------------------|----------------|----------------------|------------|
| **Vivo** | FunTouchOS | Background App Manager | ✅ Fully Supported |
| **Oppo** | ColorOS | Startup App Management | ✅ Fully Supported |
| **Realme** | Realme UI | Startup App Management | ✅ Fully Supported |
| **Xiaomi** | MIUI | Auto-start Manager | ✅ Fully Supported |
| **Redmi** | MIUI | Auto-start Manager | ✅ Fully Supported |
| **Samsung** | One UI | Battery Optimization | ✅ Fully Supported |
| **Infinix** | HiOS | Boot Start Activity | ✅ Fully Supported |
| **Tecno** | XOS | Boot Start Activity | ✅ Fully Supported |
| **Huawei** | EMUI | Startup Manager | ✅ Fully Supported |
| **Honor** | Magic UI | Startup Manager | ✅ Fully Supported |
| **OnePlus** | OxygenOS | Chain Launch Manager | ✅ Fully Supported |
| **Lenovo** | ZUI | Pure Background | ✅ Fully Supported |
| **Others** | Stock Android | Battery Optimization | ✅ Supported |

---

## 🔧 Installation

### **Prerequisites**
- Android 6.0+ (API Level 23+)
- Flutter 3.0+ (for development)
- Dart 3.0+

### **For Users**
1. Download the latest APK from [Releases](../../releases)
2. Enable "Install from Unknown Sources" in Android settings
3. Install the APK and follow the setup wizard

### **For Developers**

```bash
# Clone the repository
git clone https://github.com/yourusername/qvault-app-locker.git
cd qvault-app-locker

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release
```

---

## 📖 Usage

### **Initial Setup**

1. **Launch QVault** and create a secure PIN
2. **Grant Permissions** - Follow the guided permission setup
3. **Enable Auto-Start** - Tap device-specific auto-start button
4. **Configure Apps** - Select which apps to lock
5. **You're Protected!** - QVault monitors in the background

### **Required Permissions**

| **Permission** | **Purpose** | **Required** |
|----------------|-------------|--------------|
| **Usage Access** | Monitor app launches | ✅ Yes |
| **Display Over Apps** | Show unlock screen | ✅ Yes |
| **Accessibility Service** | Real-time app detection | ✅ Yes |
| **Battery Optimization** | Background operation | ⚠️ Recommended |
| **Auto-Start** | Survive device reboot | ⚠️ Device-specific |

### **Key Features Usage**

```dart
// Request all permissions at once
await PlatformService.requestAllPermissions();

// Open device-specific auto-start settings
await PlatformService.requestAutoStart();

// Show native feedback to user
await PlatformService.showToast("App locked successfully!");

// Get device information
String deviceInfo = await PlatformService.getDeviceInfo();
```

---

## 🏗️ Architecture

### **Project Structure**

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── app_info.dart        # App information model
├── screens/                  # UI screens
│   ├── splash_screen.dart   # Loading screen
│   ├── home_screen.dart     # Main app list
│   ├── permissions_screen.dart # Permission setup
│   ├── settings_screen.dart # App settings
│   └── pin_*.dart          # PIN management
├── services/                # Business logic
│   ├── app_lock_service.dart    # Core locking logic
│   ├── platform_service.dart   # Android integration
│   ├── permission_service.dart # Permission management
│   ├── app_monitor_service.dart # Background monitoring
│   └── unlock_event_service.dart # Unlock handling
└── widgets/                 # Reusable components
    └── app_list_item.dart   # App list items

android/
└── app/src/main/
    ├── kotlin/...MainActivity.kt # Flutter-Android bridge
    └── java/.../utils/      # Native Android utilities
        ├── AppUtils.java    # Device-specific methods
        ├── LockUtil.java    # Permission utilities
        ├── ToastUtil.java   # Native messaging
        ├── MainUtil.java    # Preferences management
        └── LogUtil.java     # Debug logging
```

### **Technology Stack**

- **Frontend**: Flutter 3.0+ with Material Design
- **Backend**: Native Android (Kotlin/Java) integration
- **Storage**: SharedPreferences + SQLite
- **Security**: SHA-256 encryption, Android Keystore
- **Monitoring**: AccessibilityService + UsageStatsManager
- **Authentication**: Local Authentication (PIN + Biometric)

---

## 🔒 Security Features

### **Data Protection**
- ✅ **Local Storage Only** - No cloud data transmission
- ✅ **Encrypted PIN Storage** - SHA-256 hashed with salt
- ✅ **Biometric Integration** - Android Keystore protected
- ✅ **Secure Communication** - Method channels for Flutter-Android

### **Privacy Compliance**
- ✅ **No Internet Permission** - App works completely offline
- ✅ **No Data Collection** - Zero telemetry or analytics
- ✅ **Local Processing** - All operations on-device
- ✅ **Transparent Code** - Open source for security audit

---

## 🛠️ Development

### **Build Configuration**

```yaml
# pubspec.yaml key dependencies
dependencies:
  flutter: sdk: flutter
  local_auth: ^2.1.8           # Biometric authentication
  shared_preferences: ^2.2.3   # Local storage
  permission_handler: ^11.3.1  # Permission management
  crypto: ^3.0.3              # Encryption utilities
  sqflite: ^2.3.3             # Local database
```

### **Android Configuration**

```kotlin
// Minimum SDK requirements
android {
    compileSdk = 36
    minSdk = 23
    targetSdk = 36
}
```

### **Key Method Channels**

| **Channel** | **Purpose** | **Methods** |
|-------------|-------------|-------------|
| `platform` | Core functionality | `requestAutoStart`, `showToast`, `getDeviceInfo` |
| `permissions` | Permission management | `requestUsageStats`, `hasAccessibilityPermission` |
| `events` | Real-time monitoring | App switch event stream |

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

### **Development Setup**

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Make** your changes and test thoroughly
5. **Commit** with descriptive messages: `git commit -m 'Add amazing feature'`
6. **Push** to your branch: `git push origin feature/amazing-feature`
7. **Submit** a Pull Request

### **Code Standards**

- ✅ Follow Dart/Flutter style guidelines
- ✅ Add comments for complex logic
- ✅ Write tests for new features
- ✅ Ensure cross-device compatibility
- ✅ Update documentation as needed

### **Testing Requirements**

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Build verification
flutter build apk --release
```

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 QVault App Locker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 📞 Support

### **Need Help?**

- 🐛 **Bug Reports**: [Create an Issue](../../issues/new?template=bug_report.md)
- 💡 **Feature Requests**: [Create an Issue](../../issues/new?template=feature_request.md)
- 📖 **Documentation**: Check the [Wiki](../../wiki)
- 💬 **Discussions**: [GitHub Discussions](../../discussions)

### **Device-Specific Issues**

If you're experiencing issues on a specific device:

1. **Check** the [Device Compatibility](#-device-compatibility) table
2. **Try** the auto-start configuration button in settings
3. **Report** your device model if it's not supported
4. **Include** device info from Settings → Device Information

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **Android Open Source Project** - For system APIs and documentation
- **Community Contributors** - For testing across different devices
- **Security Researchers** - For best practices and vulnerability reports

---

## 📊 Project Stats

![GitHub Stars](https://img.shields.io/github/stars/yourusername/qvault-app-locker?style=social)
![GitHub Forks](https://img.shields.io/github/forks/yourusername/qvault-app-locker?style=social)
![GitHub Issues](https://img.shields.io/github/issues/yourusername/qvault-app-locker)
![GitHub Pull Requests](https://img.shields.io/github/issues-pr/yourusername/qvault-app-locker)

---

<div align="center">

**Made with ❤️ using Flutter**

**Star ⭐ this repo if you found it helpful!**

[⬆ Back to Top](#qvault---advanced-android-app-locker)

</div>
