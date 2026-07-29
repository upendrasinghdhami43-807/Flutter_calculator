# SuperCalc Device Testing and Deployment

This guide shows how to run and install SuperCalc on an Android phone and on Xubuntu Linux. Run every command from the project root unless the command states otherwise.

```bash
cd /home/upendra-singh-dhami/Flutter_projects/flutter_calce
```

## Verify the Flutter Environment

Before building for either platform, confirm that Flutter and the required platform toolchains are ready.

```bash
flutter doctor -v
flutter pub get
flutter analyze
flutter test
```

Resolve any item marked with an `X` by `flutter doctor` before continuing.

## Android Phone: USB Debug Build

### 1. Enable Developer Options on the Phone

1. Open **Settings** > **About phone**.
2. Tap **Build number** seven times.
3. Return to Settings and open **Developer options**.
4. Enable **USB debugging**.
5. Connect the phone to the computer using a data-capable USB cable.
6. Accept the USB debugging authorization prompt on the phone.

### 2. Confirm That ADB Can See the Phone

Install Android Platform Tools if `adb` is not already available:

```bash
sudo apt update
sudo apt install adb
```

Check the connected device:

```bash
adb devices
flutter devices
```

The device should appear with the status `device`. If it shows `unauthorized`, unlock the phone and accept the authorization prompt. To reset the connection:

```bash
adb kill-server
adb start-server
adb devices
```

### 3. Run Directly on the Phone

Run the debug build on the only connected Android device:

```bash
flutter run
```

When multiple devices are connected, get their IDs and select the Android device:

```bash
flutter devices
flutter run -d DEVICE_ID
```

For a performance-optimized test build:

```bash
flutter run --profile -d DEVICE_ID
```

For a release-mode test build:

```bash
flutter run --release -d DEVICE_ID
```

Use `r` in the running Flutter terminal for hot reload, `R` for hot restart, and `q` to stop the app.

## Android APK Build and Installation

### Debug APK

Build an installable debug APK:

```bash
flutter build apk --debug
```

The output file is:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Install or update it on the connected phone:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Start the app from the phone launcher, or launch it from the terminal:

```bash
adb shell monkey -p com.example.flutter_calce -c android.intent.category.LAUNCHER 1
```

### Release APK

Build a smaller, optimized release APK:

```bash
flutter build apk --release
```

The output file is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install it:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

To uninstall the existing app completely before a clean installation:

```bash
adb uninstall com.example.flutter_calce
adb install build/app/outputs/flutter-apk/app-release.apk
```

The current project template signs release builds with the debug key, which is suitable for local device testing only. Configure a dedicated upload/release keystore before publishing a release outside your own devices.

### Google Play App Bundle

Google Play accepts an Android App Bundle instead of a standalone APK:

```bash
flutter build appbundle --release
```

The bundle is created at:

```text
build/app/outputs/bundle/release/app-release.aab
```

An `.aab` file cannot be installed with `adb install`; upload it to Google Play Console or use `bundletool` to create device-specific APKs.

## Android Emulator Alternative

If no physical phone is available, first install Android Studio and create an Android Virtual Device (AVD) through **Tools** > **Device Manager**. Then use:

```bash
flutter emulators
flutter emulators --launch EMULATOR_ID
flutter devices
flutter run -d EMULATOR_DEVICE_ID
```

## Xubuntu Linux Setup and Deployment

### 1. Install Native Build Dependencies

Install the Linux desktop dependencies expected by Flutter's GTK runner:

```bash
sudo apt update
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

Enable Linux desktop support and confirm the local machine is available as a target:

```bash
flutter config --enable-linux-desktop
flutter doctor -v
flutter devices
```

### 2. Run a Debug Build on Xubuntu

Use Flutter directly during development:

```bash
flutter run -d linux
```

### 3. Build and Run the Release Bundle

Create the release bundle:

```bash
flutter build linux --release
```

Run the executable from the complete bundle directory. Do not copy out only the executable because it needs the neighboring `data/` and `lib/` directories.

```bash
cd build/linux/x64/release/bundle
./flutter_calce
```

### 4. Install Locally on Xubuntu

Copy the complete release bundle into `/opt` and create a desktop launcher:

```bash
flutter build linux --release
sudo rm -rf /opt/supercalc
sudo mkdir -p /opt/supercalc
sudo cp -a build/linux/x64/release/bundle/. /opt/supercalc/
sudo tee /usr/share/applications/supercalc.desktop > /dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=SuperCalc
Comment=Local-first engineering calculator
Exec=/opt/supercalc/flutter_calce
Terminal=false
Categories=Utility;Science;Education;
EOF
```

Start the installed app with:

```bash
/opt/supercalc/flutter_calce
```

The SuperCalc launcher should also appear in the Xubuntu application menu after the desktop database refreshes.

### 5. Package for Testers

For a simple archive to share with Xubuntu testers:

```bash
flutter build linux --release
cd build/linux/x64/release
tar -czf supercalc-linux-x64.tar.gz bundle
```

Testers can extract and run it with:

```bash
tar -xzf supercalc-linux-x64.tar.gz
cd bundle
./flutter_calce
```

## Troubleshooting

### Android

**`flutter doctor` reports missing Android SDK or licenses**

```bash
flutter doctor --android-licenses
flutter doctor -v
```

**The phone is not detected**

```bash
adb kill-server
adb start-server
adb devices
```

Use a data-capable cable, set the phone's USB mode to file transfer, and re-enable USB debugging if necessary.

**Android build fails because the NDK is missing**

Install the NDK version requested by the build output using Android Studio's **SDK Manager** > **SDK Tools**, then retry:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

**Release APK installation fails with a signature mismatch**

Remove the old app before installing the new signed variant:

```bash
adb uninstall com.example.flutter_calce
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Xubuntu Linux

**The Linux build cannot find GTK development headers**

```bash
sudo apt update
sudo apt install libgtk-3-dev pkg-config
flutter clean
flutter pub get
flutter build linux --release
```

**The release executable does not start after being copied**

Run it from the complete bundle. The executable needs the bundle's `lib/` and `data/` directories:

```bash
cd build/linux/x64/release/bundle
./flutter_calce
```

**Flutter cannot find the Linux desktop target**

```bash
flutter config --enable-linux-desktop
flutter doctor -v
flutter devices
```