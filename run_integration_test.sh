#!/bin/bash

# Check devices
DEVICES=$(adb devices | grep -v "List of devices attached" | grep -v "^$" | grep "device$")
if [ -z "$DEVICES" ]; then
    echo "Error: No Android devices found"
    exit 1
fi

DEVICE_ID=$(echo "$DEVICES" | head -n1 | cut -f1)
echo "Using device: $DEVICE_ID"

# Build APK if not exists
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "Building app..."
    flutter build apk --debug || exit 1
fi

# Install app
echo "Installing app..."
adb -s "$DEVICE_ID" install -r "$APK_PATH" || exit 1

# Grant permission
echo "Granting camera permission..."
adb -s "$DEVICE_ID" shell pm grant com.example.securecapture android.permission.CAMERA || exit 1

# Run tests
echo "Running integration tests..."
flutter test integration_test/main_test.dart -d "$DEVICE_ID" 