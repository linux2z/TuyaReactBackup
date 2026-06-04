# ElenzaApp - Project & Agent State Document

## 1. Project Overview
ElenzaApp is a React Native mobile application integrating the Tuya Smart SDK to manage IoT devices. The application features custom native Kotlin bridge modules to interface with Tuya's Android SDK for Device Pairing (BLE/Wi-Fi), Authentication, Telemetry, OTA updates, and Device Control.

## 2. Current Architecture Status
- **Framework**: React Native `0.73.6`
- **Native Android**: Kotlin-based custom modules communicating via React Context.
- **Tuya SDK Integration**: Android Tuya SDK integrated via AAR and Maven.
- **State Management**: Zustand / React Context (depending on UI implementation).

## 3. Implementation Status
### What Has Been Completed
- Project directory consolidation (resolved `%20` URL-encoding path issues).
- Complete setup of isolated JDK 17 and Android SDK environment.
- Resolution of deep Gradle dependency conflicts (AndroidX core pinning).
- Resolution of React Native bridge incompatibility (screens/gesture-handler versions).
- Successful compilation of all custom Kotlin bridge modules.
- Generation of the functional `app-debug.apk`.

### What is Fully Working
- Android compilation pipeline (`assembleDebug`).
- React Native bundler compatibility setup.
- Custom Native Bridge compilation.

### What is Partially Working
- **Tuya SDK**: Native modules are successfully compiled and linked to JS, but await real-world runtime testing on a physical device.

## 4. Module & Feature Status
- **Android Build Status**: SUCCESS (Debug APK is fully compiling).
- **iOS Bridge Status**: PENDING (Current sprint focused entirely on Android stability).
- **BLE Pairing Status**: Native `TuyaPairingModule.kt` is compiled and linked. Needs runtime device validation.
- **Telemetry Status**: Native `TuyaTelemetryModule.kt` is compiled and linked. Needs runtime validation.
- **OTA Implementation Status**: Native `TuyaOtaModule.kt` is compiled and linked.
- **Authentication Flow Status**: Native `TuyaAuthModule.kt` is compiled and linked.
- **SDK Initialization Status**: Initialized via the Android lifecycle / Native Bridges. Needs runtime AppKey validation.

## 5. Folder Structure & Paths
- **`E:\folex\TuyaApp`**: Unified Project Root.
- **`E:\folex\TuyaApp\android`**: Native Android environment.
- **`E:\folex\TuyaApp\src`**: React Native UI code.
- **`E:\folex\TuyaApp\jdk17`**: Project-specific Java 17 Development Kit.
- **`E:\folex\TuyaApp\Android_SDK_extracted`**: Isolated Android SDK (if used) or fallback.

### Critical Exact Paths
- **Generated APK**: `E:\folex\TuyaApp\android\app\build\outputs\apk\debug\app-debug.apk`
- **Telemetry Module**: `E:\folex\TuyaApp\android\app\src\main\java\com\elenza\app\tuya\TuyaTelemetryModule.kt`
- **Pairing Module**: `E:\folex\TuyaApp\android\app\src\main\java\com\elenza\app\tuya\TuyaPairingModule.kt`
- **Auth Module**: `E:\folex\TuyaApp\android\app\src\main\java\com\elenza\app\tuya\TuyaAuthModule.kt`
- **OTA Module**: `E:\folex\TuyaApp\android\app\src\main\java\com\elenza\app\tuya\TuyaOtaModule.kt`
- **Control Module**: `E:\folex\TuyaApp\android\app\src\main\java\com\elenza\app\tuya\TuyaControlModule.kt`

## 6. Environment & Build Requirements
- **OS**: Windows
- **Java**: JDK 17 (Strictly required to avoid Java 8/11 Daemon mismatches).
- **Android SDK**: API 34.
- **Compile SDK**: 34
- **AGP (Android Gradle Plugin)**: 8.1.1
- **Gradle Version**: 8.3
- **React Native**: 0.73.6

### Critical Dependency Versions
- `react-native-screens`: `3.29.0` (Pinned for RN 0.73 compatibility).
- `react-native-gesture-handler`: `2.14.1` (Pinned for RN 0.73 compatibility).
- `androidx.core:core`: `1.12.0` (Forced via resolutionStrategy).

### Build Instructions (PowerShell)
To compile safely and avoid Zombie Daemons or Port Locking:
```powershell
taskkill /F /IM java.exe /T
cd E:\folex\TuyaApp\android
.\gradlew.bat clean assembleDebug --no-daemon -Dorg.gradle.java.home="E:\folex\TuyaApp\jdk17\jdk-17.0.19+10"
```

## 7. Known Issues & Fixes Applied
- **Fix Applied**: URL encoding (`%20`) in the root path was breaking Metro and Gradle. The project was successfully migrated to `E:\folex\TuyaApp`.
- **Fix Applied**: Gradle Daemon port locking (`java.net.BindException`). Resolved by killing all Java processes and combining `clean` and `assembleDebug` into a single `--no-daemon` execution.
- **Fix Applied**: Missing `local.properties` caused SDK resolution failures. This file is now auto-generated.
- **Pending Task**: Real device USB installation and runtime JS-to-Native bridge testing.

## 8. Production Preparation
- **Tuya AppKey/AppSecret**: Must be correctly configured in `AndroidManifest.xml` and validated on Tuya IoT Platform.
- **SHA256 / Signing**: The release keystore SHA256 must match the one uploaded to the Tuya Developer Console, otherwise Tuya SDK initialization will throw an `ILLEGAL_CLIENT_ID` error.
- **Proguard**: Rules must be verified to prevent obfuscation of Tuya SDK reflection classes.
