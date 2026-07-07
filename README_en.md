# BlankApp

A fullscreen blank-screen and screenshot display app for Android, iOS, and HarmonyOS.

[中文](./README.md)

## Features

- Fullscreen immersive mode with system UI hidden
- Tap to cycle through pages: blank white → 3DMark screenshots (x3) → GeekBench screenshot
- Proximity sensor integration: screen turns black when the sensor is covered (anti-accidental-touch / power saving)
- Platform channel `blank_app/device` for native-side communication:
  - `proximityChanged` — reports proximity sensor state
  - `nextPage` — advances to the next page
  - `enableProximityScreenOff` / `disableProximityScreenOff` — toggles proximity-based screen-off

## Platform Support

| Platform   | Status                            |
|------------|-----------------------------------|
| Android    | Supported                         |
| iOS        | Supported                         |
| HarmonyOS  | Supported                         |
| Windows    | UI works (no native sensor)       |
| macOS      | UI works (no native sensor)       |
| Linux      | UI works (no native sensor)       |

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.11.5 (Dart ≥ 3.11.5)

### Run

```bash
# Install dependencies
flutter pub get

# Run (with a connected device or emulator)
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# HarmonyOS (requires Flutter-OHOS SDK)
# See docs/harmonyos.md for details
C:\Code\flutter-ohos\bin\flutter.bat build hap --release
```

### HarmonyOS Build

Building for HarmonyOS requires the [Flutter-OHOS SDK](https://gitcode.com/openharmony-sig/flutter_flutter.git) (`oh-3.41.9-dev` branch).

See [docs/harmonyos.md](docs/harmonyos.md) for detailed build instructions.

## Project Structure

```
blank_app/
├── lib/
│   └── main.dart          # App entry point
├── assets/
│   ├── branding/          # Branding assets
│   └── screens/           # Screenshot assets
├── android/               # Android platform
├── ios/                   # iOS platform
├── ohos/                  # HarmonyOS platform
├── docs/
│   └── harmonyos.md       # HarmonyOS build guide
└── pubspec.yaml           # Project configuration
```

## License

LGPL v2.1

