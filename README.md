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

For production builds, you'll need to configure signing in `android/app/build.gradle.kts`. Currently, the release build uses debug signing for testing purposes.
