# GS PRO Mobile

Flutter mobile application for GS PRO Purchase Requisition and Purchase Order approval system.

## Getting Started

This project uses environment-based configuration. You can build for different environments using `--dart-define=ENV=<environment>`.

## Building the App

### Development
```bash
flutter run --dart-define=ENV=dev
```

### Staging
```bash
# Build APK
flutter build apk --release --dart-define=ENV=staging

# Build App Bundle (for Play Store)
flutter build appbundle --release --dart-define=ENV=staging
```

### Production
**Important:** Before building for production, make sure to set the production API URL in `lib/config.dart`.

```bash
# Build APK
flutter build apk --release --dart-define=ENV=production

# Build App Bundle (for Play Store)
flutter build appbundle --release --dart-define=ENV=production

# Build split APKs by ABI (smaller file size)
flutter build apk --split-per-abi --release --dart-define=ENV=production
```

### Run Direct to Device in Release Mode (Signed with Keystore)
Karena `android/key.properties` sudah ada, perintah `flutter run --release` akan otomatis meng-compile APK dengan signature release keystore dan langsung menginstalnya ke HP/device yang terhubung:

```bash
# Production Release
fvm flutter run --release --dart-define=ENV=production

# Staging Release
fvm flutter run --release --dart-define=ENV=staging

# Jika ada beberapa device, tentukan target device:
fvm flutter run --release -d <device_id> --dart-define=ENV=production
```

> **Catatan:** Jika sebelumnya di HP sudah terpasang versi **debug**, pastikan untuk **uninstall aplikasi lama terlebih dahulu** dari HP karena Android menolak update jika signature berbeda (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`).


The output files will be located at:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

## Environment Configuration

The app supports three environments:
- **dev**: Development environment (default)
- **staging**: Staging environment
- **production**: Production environment

Each environment uses a different API base URL configured in `lib/config.dart`.

## Signing

For production builds and release preparation, refer to the detailed [Android Signing & Play Store Guide](docs/ANDROID_SIGNING_GUIDE.md).
Release signing is configured in `android/app/build.gradle.kts` and uses `android/key.properties` when present.

