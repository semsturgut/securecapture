# SecureCapture

A secure image capture and storage application built with Flutter that provides encrypted image storage with biometric authentication.

## Features

- 📱 **Secure Image Capture**: Take photos with camera integration
- 🔐 **End-to-End Encryption**: All images are encrypted before storage
- 🔒 **Biometric Authentication**: Face ID, Touch ID, and Fingerprint authentication
- 🖼️ **Encrypted Gallery**: View and manage encrypted images
- 📦 **Local Storage**: Secure local database with SQLite
- 🌐 **Cross-Platform**: Android, iOS, Windows, Linux, and Web support

## Technical Requirements

### Flutter & Dart
- **Flutter**: 3.32.5 or higher
- **Dart**: 3.8.1 or higher
- **Channel**: Stable

### Android Requirements
- **Minimum SDK**: 25 (Android 7.1)
- **Target SDK**: 35 (Android 15)
- **Compile SDK**: 35
- **NDK Version**: 27.0.12077973
- **Gradle**: 8.12
- **Java**: 11 (sourceCompatibility & targetCompatibility)
- **Kotlin**: JVM Target 11

### iOS Requirements
- **iOS Version**: 15.0+ (recommended)
- **Xcode**: Latest version
- **CocoaPods**: Latest version

### Project Setup

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run on Android/IOS**
   ```bash
   flutter run
   ```

5. **Running Tests**
   ```bash
   flutter test
   ```

## Security Features

- **AES Encryption**: All images encrypted before storage
- **Biometric Authentication**: Face ID, Touch ID, Fingerprint support
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **Local Database**: SQLite with encrypted image metadata
- **Permission Handling**: Proper runtime permission management