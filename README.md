# Launcher

A minimal black and white app launcher for Android.

## Features

- **Clean Interface**: Minimalist black and white design
- **Quick Actions**: Fast access to phone, messages, and camera
- **App Drawer**: Swipe up to access all installed apps
- **Customizable Widgets**: Clock, date, and battery widgets for the home screen
- **Hidden Apps**: Hide system apps and unwanted apps from the drawer
- **Gesture Controls**: 
  - Swipe up to open app drawer
  - Swipe down to open notification panel
  - Long press to open settings
  - Swipe down on app drawer (when at top) to close

## Getting Started

### Prerequisites

- Flutter SDK (3.11.0 or later)
- Android SDK
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/blackandwhiteapps/launcher.git
cd launcher
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Android signing (for release builds):
   - Generate a keystore:
   ```bash
   cd android
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   - Create `android/key.properties`:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

4. Run the app:
```bash
flutter run
```

### Building for Release

Build an app bundle:
```bash
flutter build appbundle
```

The output will be at: `build/app/outputs/bundle/release/app-release.aab`

## Usage

### Setting as Default Launcher

1. Open Settings (long press on home screen)
2. Navigate to "Launcher Settings"
3. Tap "Set as Default Launcher"
4. Select this app in the system launcher picker

### Hiding Apps

1. Open Settings (long press on home screen)
2. Navigate to "App Management" → "Hidden Apps"
3. Tap any app to hide/show it

### Customizing Home Screen

1. Open Settings (long press on home screen)
2. Configure widgets for Top, Center, and Bottom positions
3. Available widgets: Clock, Date, Battery, or None

## Contributing

We welcome contributions! Here's how you can help:

### Reporting Issues

If you find a bug or have a feature request, please open an issue on GitHub with:
- A clear description of the problem or feature
- Steps to reproduce (for bugs)
- Your device/Android version
- Any relevant screenshots

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Ensure your code follows the existing style
5. Test your changes thoroughly
6. Commit your changes (`git commit -m 'Add some amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- Follow Dart/Flutter style guidelines
- Keep functions small and focused
- Add comments for complex logic
- Write clear commit messages

### Development Setup

1. Fork and clone the repository
2. Create a branch for your changes
3. Make your changes
4. Test on a physical device when possible
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Black and White Apps (blackandwhiteapps.org)

## Acknowledgments

- Built with Flutter
- Uses [installed_apps](https://pub.dev/packages/installed_apps) for app management
