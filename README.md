# Bible Path for macOS

A native macOS version of the Bible Path app, built with Flutter. This version includes **all Pro features unlocked** with **no license validation, no subscription checks, and no purchase requirements**.

## Features

✅ **Full Bible Reading** - Multiple translations (ASV, KJV, WEB)  
✅ **Bible AI Chat** - Unlimited questions, no daily limits  
✅ **Daily Plans** - Verse, devotional, prayer, connection steps  
✅ **Prayer Wall** - Share and amen prayers with the community  
✅ **Study Plans** - Reading, listening, study plans, and challenges  
✅ **Streak Tracking** - Daily streak with achievements  
✅ **Widgets Support** - Daily verse widgets (macOS menu bar)  
✅ **Audio Playback** - Listen to Bible content  
✅ **Dark/Light Mode** - System-following or manual  
✅ **Multi-language** - EN, ES, PT, FR, DE, IT, RU  
✅ **Offline Ready** - Local storage with Hive  
✅ **Native macOS UI** - Custom title bar, window controls, sidebar  

## What's Removed (vs Android Version)

- ❌ **Google Play License Verification (LVL)** - No license checks
- ❌ **Google Play Billing** - No in-app purchases
- ❌ **RevenueCat** - No subscription management
- ❌ **Firebase Auth/Analytics/Crashlytics** - No tracking
- ❌ **Adjust SDK** - No attribution tracking
- ❌ **Facebook SDK** - No social tracking
- ❌ **Daily message limits** - Unlimited AI chat
- ❌ **Paywalls** - All features unlocked
- ❌ **Free trial logic** - No trial expiration

## Requirements

- **macOS 11.0 (Big Sur)** or later
- **Flutter 3.19+** (3.22+ recommended)
- **Dart 3.3+**
- **Xcode 15+** (for building)

## Quick Start

### 1. Install Flutter (if not already installed)

```bash
# Using Homebrew (recommended)
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install/macos
```

### 2. Verify Flutter Installation

```bash
flutter doctor
flutter doctor -v
```

### 3. Clone/Navigate to Project

```bash
cd /path/to/bible-path-macos
```

### 4. Get Dependencies

```bash
flutter pub get
```

### 5. Generate Code (for freezed/json_serializable)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Run on macOS

```bash
# Debug mode (with hot reload)
flutter run -d macos

# Release mode
flutter run -d macos --release

# Profile mode
flutter run -d macos --profile
```

### 7. Build for Distribution

```bash
# Build release bundle
flutter build macos --release

# The app will be at: build/macos/Build/Products/Release/Bible Path.app

# For notarization/distribution:
# 1. Open build/macos/Runner.xcworkspace in Xcode
# 2. Select "Product" > "Archive"
# 3. Follow Apple's notarization process
```

## Project Structure

```
bible-path-macos/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── app.dart                       # App router & providers
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Light/dark themes
│   │   ├── models/
│   │   │   └── user_preferences.dart      # Hive models (freezed)
│   │   └── services/
│   │       ├── storage_service.dart       # SharedPreferences + Hive
│   │       └── notification_service.dart  # Local notifications
│   ├── features/
│   │   ├── bible/
│   │   │   ├── bible_repository.dart      # Bible data & search
│   │   │   └── bible_screen.dart          # Bible reading UI
│   │   ├── chat/
│   │   │   ├── chat_repository.dart       # AI chat (unlimited!)
│   │   │   └── chat_screen.dart           # Chat UI
│   │   ├── daily_plan/
│   │   │   ├── daily_plan_repository.dart # Daily plans & streaks
│   │   │   └── daily_plan_screen.dart     # Daily plan UI
│   │   ├── prayer/
│   │   │   ├── prayer_repository.dart     # Prayer wall
│   │   │   └── prayer_screen.dart         # Prayer UI
│   │   ├── study/
│   │   │   ├── study_repository.dart      # Study plans
│   │   │   └── study_screen.dart          # Study UI
│   │   ├── home/
│   │   │   └── home_screen.dart           # Dashboard
│   │   ├── profile/
│   │   │   └── profile_screen.dart        # User profile & stats
│   │   └── settings/
│   │       └── settings_screen.dart       # All settings
│   └── shared/
│       └── widgets/
│           ├── app_scaffold.dart          # Main layout with sidebar
│           ├── custom_title_bar.dart      # Native macOS title bar
│           ├── feature_card.dart          # Dashboard cards
│           ├── verse_of_day_widget.dart   # Daily verse display
│           ├── streak_widget.dart         # Streak counter
│           └── bible_book_card.dart       # Bible book list item
├── macos/
│   ├── Runner/
│   │   ├── Info.plist                     # App configuration
│   │   ├── AppDelegate.swift              # App delegate
│   │   ├── MainFlutterWindow.swift        # Custom window
│   │   ├── DebugProfile.entitlements      # Debug entitlements
│   │   └── Release.entitlements           # Release entitlements
│   ├── CMakeLists.txt                     # CMake build config
│   └── Podfile                            # CocoaPods dependencies
├── assets/
│   ├── bible/                             # Bible JSON files
│   ├── images/                            # App images
│   ├── audio/                             # Audio files
│   └── fonts/                             # Custom fonts
├── pubspec.yaml                           # Dependencies
└── README.md                              # This file
```

## Adding Bible Data

Place public domain Bible JSON files in `assets/bible/`:

```
assets/bible/
├── asv.json      # American Standard Version (included)
├── kjv.json      # King James Version
└── web.json      # World English Bible
```

JSON format:
```json
{
  "Genesis": {
    "1": {
      "1": "In the beginning God created the heavens and the earth.",
      "2": "And the earth was without form, and void..."
    },
    "2": { ... }
  },
  "Exodus": { ... }
}
```

## Key Differences from Android App

| Feature | Android App | macOS Version |
|---------|-------------|---------------|
| License Check | Google Play LVL | **None** |
| Purchases | Google Play Billing | **None** |
| Subscriptions | RevenueCat | **None - All Pro** |
| AI Chat Limit | 10/day free | **Unlimited** |
| Analytics | Firebase | **None** |
| Crash Reports | Crashlytics | **None** |
| Attribution | Adjust | **None** |
| Social Login | Facebook | **None** |
| Backend | Firebase | **Local Only** |

## Architecture Notes

- **No Backend Required** - All data stored locally (Hive + SharedPreferences)
- **No API Keys** - No external services needed
- **Offline-First** - Works completely offline
- **Privacy-Focused** - No tracking, no analytics, no user data collection
- **Native macOS Feel** - Custom title bar with traffic lights, sidebar navigation

## Customization

### Change App Name/ID
Edit `macos/Runner/Info.plist`:
- `CFBundleDisplayName` - Display name
- `CFBundleIdentifier` - Bundle ID (e.g., `com.yourname.biblepath`)

### Add App Icon
Replace `macos/Runner/Assets.xcassets/AppIcon.appiconset/` with your icons.

### Modify Colors
Edit `lib/core/theme/app_theme.dart` - change `primaryColor`, `accentColor`, etc.

## Building for Distribution

### 1. Configure Signing (Xcode)
```bash
open macos/Runner.xcworkspace
```
- Select Runner target
- Signing & Capabilities → Add your Apple Developer Team
- Enable "App Sandbox" with required permissions

### 2. Build Release
```bash
flutter build macos --release
```

### 3. Notarize (Required for distribution outside Mac App Store)
```bash
# Create DMG
create-dmg \
  --volname "Bible Path Installer" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "Bible Path.app" 200 190 \
  --hide-extension "Bible Path.app" \
  --app-drop-link 600 185 \
  "Bible Path.dmg" \
  "build/macos/Build/Products/Release/"

# Notarize
xcrun notarytool submit "Bible Path.dmg" \
  --apple-id "your@apple.id" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple
xcrun stapler staple "Bible Path.dmg"
```

## Troubleshooting

### "Flutter not found"
```bash
export PATH="$PATH:`pwd`/flutter/bin"
# Or add to ~/.zshrc / ~/.bash_profile
```

### "CocoaPods not installed"
```bash
sudo gem install cocoapods
cd macos && pod install
```

### "Build failed - sandbox violation"
Check `macos/Runner/DebugProfile.entitlements` and `Release.entitlements` for required permissions.

### "Assets not loading"
Run `flutter pub get` and ensure assets are declared in `pubspec.yaml`.

## License

This project is a reverse-engineered reimplementation for educational purposes.
Original "Bible Path" app is copyright Codeway / Vision Wizard.

This macOS version:
- Contains NO original code from the Android app
- Uses ONLY public domain Bible texts (ASV, KJV, WEB)
- Implements ALL features from scratch in Flutter
- Removes ALL license validation and payment systems

## Disclaimer

This is a fan-made reimplementation for personal/educational use.
Support the original developers if you enjoy their work.