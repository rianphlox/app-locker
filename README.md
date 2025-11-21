
# QVault - Advanced Android App Locker

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)
![Android](https://img.shields.io/badge/Android-API%2023+-3DDC84?style=for-the-badge\&logo=android\&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A lightweight, privacy-first Android app locker built with Flutter and native Android integration.**

</div>

---

## 🚀 Features

### 🔐 Security & Protection

* Lock any installed app with **PIN or biometrics**
* **Real-time app monitoring** via AccessibilityService
* **Local-only storage** with SHA-256 encryption
* **Offline operation** — no data collection, no internet required

### ⚙️ System Integration

* Works across multiple Android manufacturers
* Smart **auto-start** and **background permission** detection
* Deep **native integration** (Java/Kotlin) for reliability

### 🧠 User Experience

* Simple, elegant, Material-based design
* Adaptive permission guidance
* Runs quietly in the background

---

## 🧩 Project Structure

```
lib/
├── main.dart
├── screens/             # UI screens
├── services/            # Core business logic
├── models/              # Data models
└── widgets/             # Shared UI components

android/
└── java/com/templatemela/applocker/utils/
    ├── AppUtils.java      # Device-specific settings
    ├── LockUtil.java      # Permission helpers
    ├── ToastUtil.java     # Native messages
    ├── MainUtil.java      # Local data management
    └── LogUtil.java       # Debug logging
```

---

## 🛠️ Getting Started

### Requirements

* Android 6.0 (API 23) or higher
* Flutter 3.0+ and Dart 3.0+

### Run Locally

```bash
# Clone the repository
git clone https://github.com/rianphlox/app-locker.git
cd app-locker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Release

```bash
flutter build apk --release
```

---

## 🔒 Privacy & Security

* ✅ 100% offline — no internet permission
* ✅ Local-only encrypted storage (SHA-256)
* ✅ Optional biometric unlock
* ✅ Transparent, open-source code

---

## 🤝 Contributing

Want to help improve QVault?

1. Fork this repo
2. Create a branch (`feature/new-idea`)
3. Commit and push your changes
4. Open a pull request

Run tests before submitting:

```bash
flutter analyze
flutter test
```

---

## 📄 License

**MIT License**
Copyright © 2025
Free to use, modify, and distribute with attribution.

---

<div align="center">

**Made using Flutter**
⭐ Star this project to support development!

</div>

---
