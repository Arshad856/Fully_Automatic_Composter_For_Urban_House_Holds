# Fully Automatic Composter — Mobile App (Flutter • Android / iOS)

## Overview
This directory contains the **Flutter-based mobile application** for the *Fully Automatic Organic Waste Composter* system.  
The app functions as the **Human–Machine Interface (HMI)**, enabling users to remotely **monitor sensor data** and **control actuators** of the composting machine.

The mobile application integrates with the **ESP32-S3 firmware** indirectly via **Firebase Realtime Database**, which acts as the central communication layer between the embedded system and the mobile client.

---

## Key Features
- Real-time monitoring of composting parameters:
  - Temperature
  - Humidity
  - Soil moisture
  - Fill / level status
- Remote actuator control:
  - Doors
  - Exhaust fans
  - Water valves
  - Heater
  - Motors
- Chamber-wise system visualization
- Firebase-backed real-time synchronization
- Clean and responsive Flutter UI
- Android-ready with iOS compatibility through Flutter

> Authentication, notifications, and advanced analytics depend on Firebase configuration and are marked as _To be configured_ if not explicitly implemented in the code.

---

## Technology Stack

| Layer | Technology |
|-----|-----------|
| Framework | Flutter |
| Language | Dart |
| Backend | Firebase Realtime Database |
| Communication Model | Firebase RTDB (ESP32-S3 ↔ Mobile App) |
| Supported Platforms | Android / iOS |

---

## Project Structure

| Path | Description |
|-----|-------------|
| `mobile-app/` | Mobile application root directory |
| `mobile-app/Mobile_App_Code/` | Flutter project root |
| `mobile-app/Mobile_App_Code/pubspec.yaml` | Flutter dependencies & metadata |
| `mobile-app/Mobile_App_Code/lib/` | Dart source code |
| `mobile-app/Mobile_App_Code/lib/main.dart` | Application entry point |
| `mobile-app/Mobile_App_Code/android/` | Android platform configuration |
| `mobile-app/Mobile_App_Code/ios/` | iOS platform configuration |
| `mobile-app/Mobile_App_Code/assets/` | UI assets (images, icons, fonts) |
| `mobile-app/Mobile_App_Code/test/` | Unit and widget tests |

---

## Setup & Installation

### Prerequisites
- Flutter SDK (stable channel recommended)
- Android Studio (Android builds)
- Xcode (iOS builds)
- Firebase project with Realtime Database enabled

### Flutter Installation
Install Flutter by following the official guide:  
https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter doctor
```

## Dependency Installation

Navigate to the Flutter project root:

```bash
cd mobile-app/Mobile_App_Code
flutter clean
flutter pub get
```
## Configuration

### Firebase Setup

| Component | Description |
|---------|-------------|
| Firebase Project | Create a new Firebase project |
| Realtime Database | Enable RTDB and configure rules |
| Android Config | Place `google-services.json` inside `android/app/` |
| iOS Config | Add `GoogleService-Info.plist` to the iOS Runner |
| Initialization | Firebase initialization inside `main.dart` |

> _To be configured_: Confirm Firebase initialization logic and dependencies in `pubspec.yaml`.

---

### Environment Variables
_To be configured_

If environment-based configuration is used (e.g., `.env` files), document required variables such as:
- Firebase Database URL
- API endpoints (if any)

---

### API Endpoints
_To be configured_

The app primarily relies on Firebase Realtime Database.  
REST or WebSocket APIs should be documented here if added in the future.

---

## Build & Run Instructions

### Debug Mode
```bash
flutter run
```
List connected devices:

```bash
flutter devices
```
## Release Build

### Android APK
```bash
flutter build apk --release
```
### Android App Bundle
```bash
flutter build appbundle --release
```
### iOS Release
```bash
flutter build ios --release
```
## App–Firmware Interaction

### Communication Architecture

- **ESP32-S3 → Firebase RTDB**  
  Publishes sensor telemetry and system states.

- **Mobile App → Firebase RTDB**  
  Writes actuator commands and configuration parameters.

- **ESP32-S3 ← Firebase RTDB**  
  Listens for command updates and executes actions.

No direct Bluetooth, Wi-Fi socket, or serial communication is used.  
All interaction is **cloud-mediated through Firebase**.

---

## Firebase Node Mapping

### Actuator Control Nodes

| RTDB Path | Function |
|----------|----------|
| `Actuator_Control/Chamber_1st/Door` | Door control |
| `Actuator_Control/Chamber_2nd/Door` | Door control |
| `Actuator_Control/Chamber_2nd/Exhaust` | Exhaust fan |
| `Actuator_Control/Chamber_2nd/Valve` | Water valve |
| `Actuator_Control/Chamber_3rd/Door` | Door control |
| `Actuator_Control/Chamber_3rd/Exhaust` | Exhaust fan |
| `Actuator_Control/Chamber_3rd/Heater` | Heater |
| `Actuator_Control/Chamber_3rd/Valve` | Water valve |
| `Actuator_Control/Chamber_4th/Door` | Door control |
| `Actuator_Control/Chamber_4th/Exhaust` | Exhaust fan |

### Actuator State Encoding

- `2` → ON / Open / In  
- `1` → OFF / Close  
- `0` → IDLE  
- `3` → Out  

### Sensor Data Nodes

| Measurement | RTDB Path Pattern |
|------------|------------------|
| Temperature | `dhtx/Temperature` |
| Humidity | `dhtx/Humidity` |
| Soil Moisture | `dsx_temperature` |
| Fill Level | `distanceX` |

`x` / `X` corresponds to the chamber number.

---

## Screenshots
_To be added_

```text
docs/screenshots/dashboard.png
docs/screenshots/chamber_view.png
docs/screenshots/control_panel.png
```
## Troubleshooting

| Issue | Possible Cause | Solution |
|-----|---------------|----------|
| No data displayed | RTDB path mismatch | Verify node names with firmware |
| Firebase permission denied | Incorrect DB rules | Update Firebase security rules |
| Build errors | Cached artifacts | Run `flutter clean` |
| Android install fails | Gradle / signing issue | Check SDK & signing config |
| iOS build error | Pod / signing issue | Run `pod install` and verify signing |

---

## Contribution Guidelines

- Fork the repository  
- Create a feature branch from `main`  
- Commit clean and scoped changes  
- Run static checks:
  ```bash
  flutter analyze
  dart format .

## License

_To be configured_

Add a `LICENSE` file at the repository root and update this section accordingly.

