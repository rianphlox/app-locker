# Changelog

All notable changes to QVault App Locker will be documented in this file.

## [1.1.0] - 2025-11-22

### 🎯 Major Fix: PIN Interception Loop Resolved

**The Problem**: After entering the correct PIN, apps would launch successfully but then immediately get intercepted again by the AccessibilityService, causing the PIN screen to appear in an infinite loop.

**The Solution**: Implemented a temporary unlock mechanism where successfully unlocked apps are added to a "temporarily unlocked" list, allowing access until the user switches away.

### ✨ Added
- **Native Android PIN Screen**: Complete rewrite with native Kotlin implementation
  - No more Flutter app flash - users see only the PIN screen
  - Proper SHA-256 PIN verification integrated with Flutter SharedPreferences
  - Clean, Material Design interface matching system aesthetics

- **Temporary Unlock Mechanism**:
  - Apps stay unlocked after correct PIN entry until user switches away
  - Automatic re-protection when switching to different apps
  - Prevents PIN screen loops while maintaining security

- **Comprehensive Logging System**:
  - Added 🔐 markers for easy debugging of unlock flow
  - Full traceability of PIN verification process
  - Real-time monitoring of AccessibilityService behavior

### 🗑️ Removed
- **Biometric Authentication**: Removed entirely for simplified, more reliable experience
  - Deleted `local_auth` dependency from pubspec.yaml
  - Removed biometric permissions from AndroidManifest.xml
  - Stripped biometric UI from settings screen
  - Removed biometric-related methods from services

### 🔧 Technical Improvements
- **SharedPreferences Integration**: Fixed native Android code to properly access Flutter SharedPreferences
- **AccessibilityService Enhancement**: Better app switching detection and handling
- **Build Optimization**: Removed unnecessary dependencies, reduced app size
- **Error Handling**: Improved error reporting in native PIN verification

### 🐛 Bug Fixes
- Fixed PIN interception loop causing infinite unlock prompts
- Fixed SharedPreferences key mismatch between Flutter and native Android
- Fixed resource linking errors in native PIN activity
- Fixed Kotlin compilation issues with type inference

### 📱 User Experience
- PIN verification now works seamlessly without repeated prompts
- Apps launch directly after successful PIN entry
- No more unexpected QVault app appearances
- Clean, consistent native Android UI

### 🔧 Architecture Changes
- **PinUnlockActivity.kt**: New native PIN screen with proper unlock flow
- **AccessibilityService.kt**: Enhanced with temporary unlock tracking
- **MainActivity.kt**: Streamlined Flutter bridge
- Project structure updated to reflect Kotlin-based implementation

### 🚀 Performance
- Faster app launches due to native implementation
- Reduced memory footprint without biometric libraries
- More reliable accessibility service monitoring

---

## [1.0.0] - 2025-11-21

### 🚀 Initial Release
- Basic app locking functionality with Flutter UI
- AccessibilityService implementation for app monitoring
- PIN and biometric authentication support
- SQLite database for locked apps storage
- Material Design interface

---

## How to Update

1. **From Git**: `git pull origin main`
2. **Dependencies**: `flutter pub get`
3. **Build**: `flutter build apk`
4. **Install**: `adb install build/app/outputs/flutter-apk/app-release.apk`

---

## Technical Notes

### SharedPreferences Keys
- Flutter uses: `flutter.app_pin` in `FlutterSharedPreferences`
- Native Android accesses the same key for PIN verification

### Accessibility Service Configuration
- Monitors `TYPE_WINDOW_STATE_CHANGED` events
- Maintains temporary unlock list in `app_locker_prefs`
- Automatically re-enables protection when switching away from unlocked apps

### Build Requirements
- Flutter 3.0+
- Android API 23+
- Kotlin support enabled