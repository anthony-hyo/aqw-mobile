# AQW Pocket

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/Rust-stable-orange.svg)](https://www.rust-lang.org/)
[![ActionScript](https://img.shields.io/badge/ActionScript-3.0-orange.svg)](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/)
[![Adobe AIR](https://img.shields.io/badge/Adobe%20AIR-51.1-red.svg)](https://airsdk.harman.com/)


AdventureQuest Worlds still runs on Flash. Mobile players have no official option, Puffin works but costs money. AQW Pocket is a free, community-built alternative that runs the game natively on Android.

> **Disclaimer:** This is an unofficial community project, not affiliated with or endorsed by Artix Entertainment. AdventureQuest Worlds and all related assets are the property of Artix Entertainment. Use at your own risk.

---

## How It Works

1. The build process always uses the latest game client.
2. A set of patches are applied to the ActionScript bytecode to make the client compatible with mobile/AIR constraints.
3. A lightweight ActionScript loader wraps the patched game and handles initialization.
4. Everything is packaged into an Android APK using the Adobe AIR SDK. The entire build process runs openly on GitHub Actions, what you see in the code is exactly what gets built.

## Features

- Native Android client via Adobe AIR
- **Joystick** and **combat buttons**, reposition, reset, or hide via the top left menu
- In-game update notifications, checks GitHub for new releases automatically

<img width="500" height="auto" alt="image" src="https://github.com/user-attachments/assets/65fe7ec8-d406-44d7-abc8-018cc6399deb" />

## Download

Grab the latest APK from the [Releases](../../releases/latest) tab.
Pick **armv7** for older devices or **armv8** for anything recent (2017+).

---

## Building

### Requirements

- [Rust](https://www.rust-lang.org/tools/install)
- [D compiler (DMD)](https://dlang.org/download.html)
- [RABCDAsm](https://github.com/CyberShadow/RABCDAsm)
- [Adobe AIR SDK](https://airsdk.harman.com/) (51.1+)
- Java (for `keytool` / `adt`)

### Steps

```bash
# Clone the repo
git clone https://github.com/anthony-hyo/aqw-mobile.git
cd aqw-mobile

# Build and patch Game.swf
cargo run --release

# Copy patched game into loader
cp assets/Game.swf loader/gamefiles/Game.swf

# Compile the loader
amxmlc -output loader/Loader.swf loader/src/Main.as

# Generate a keystore (first time only)
keytool -genkeypair -alias myalias -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore keystore.jks -storepass yourpass -keypass yourpass \
  -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=US"

# Package the APK
adt -package -target apk-captive-runtime -arch armv8 \
  -storetype JKS -keystore keystore.jks -storepass yourpass -keypass yourpass \
  AQWPocket.apk loader/app.xml \
  -C loader Loader.swf gamefiles/Game.swf
```

Or trigger it manually from the [Actions](../../actions) tab, the APK will be published to the [Releases](../../releases/latest) page automatically.

---

## Contributing

Community contributions are welcome. If you want to improve patches, fix compatibility issues, or help support more devices, feel free to open a pull request or issue.

---

## License

This project is licensed under the MIT License.
