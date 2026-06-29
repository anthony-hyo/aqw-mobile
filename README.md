# AQW Pocket 

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/Rust-stable-orange.svg)](https://www.rust-lang.org/)
[![ActionScript](https://img.shields.io/badge/ActionScript-3.0-orange.svg)](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/)
[![Adobe AIR](https://img.shields.io/badge/Adobe%20AIR-51.3-red.svg)](https://airsdk.harman.com/)

### Join our Discord  <a href="https://discord.gg/EXS5qM35ff" target="_blank"><img src="https://img.shields.io/discord/1477853380855468219?label=Discord&logo=discord"></a>

AdventureQuest Worlds Mobile, AQW Pocket is a free, community-built alternative that runs the game natively on Android and Desktop.

> **Disclaimer:** This is an unofficial community project, not affiliated with or endorsed by Artix Entertainment. AdventureQuest Worlds and all related assets are the property of Artix Entertainment. Use at your own risk.

---

## Download

Grab the latest release from the [Releases](../../releases/latest) tab.

### Android

Pick **armv8** for most modern devices or **armv7** for older 32-bit devices.

* **armv8**: recommended for most phones and tablets
* **armv8-direct**: alternative renderer if the recommended build has issues
* **armv8-gpu**: legacy fallback, not recommended unless needed
* **armv7**: older 32-bit Android devices
* **x86 / x64**: ChromeOS or Android emulators

### Desktop

Desktop builds may be available for:

* Windows
* Linux
* macOS

Use the build matching your operating system and architecture.

**Only download from this repository. Builds from other sources may be modified.**

## Features

* Native Adobe AIR client for Android and desktop
* Mobile controls with **Joystick**, **skills bar**, and **adjustable UI**
* Reposition, reset, or hide mobile UI elements from the top-left menu
* In-game update notifications through GitHub releases
* Shared client codebase across supported platforms
* Automated builds through GitHub Actions

- **Joystick**, **skills bar** and **UI**, reposition, reset, or hide via the top left menu
- In-game update notifications, checks GitHub for new releases automatically

<img width="auto" height="auto" alt="image" src="https://github.com/user-attachments/assets/a2fca19f-5c63-4857-b3dc-b6b87a94c848" />

## How It Works

- The build process always uses the latest game client.
- A set of patches are applied to the ActionScript bytecode to make the client compatible with mobile/AIR constraints.
- An ActionScript loader wraps the patched game and handles initialization.
- Everything is packaged into an Android APK/Desktop using the Adobe AIR SDK. The entire build process runs openly on GitHub Actions, what you see in the code is exactly what gets built.
- Private patches are included to prevent abuse (e.g., botting) but are fully audited in the compiled SWF.
- - Users can audit the SWF to:
- - - Review game logic
- - - Verify input handling
- - - Ensure no malicious code is present

**⚠️ While the SWF is readable, we still recommend using a secondary account if you are cautious. Only download APKs from official GitHub releases or build from source.**

## Security & Account Safety
- Login occurs directly with Artix Entertainment servers, passwords are not stored by the client.
- The client does not include cheats or automation.
- Use a secondary account first if you are concerned about safety.
- Only download APKs from this repository or build from source.
- Avoid reusing passwords from other accounts.

## Notes
- **GrapheneOS:** Keep "Disable DCL via memory" off; Adobe AIR's JIT requires it, same as browsers/JS engines. Not a bug.

---

## Contributing

Community contributions are welcome. If you want to improve patches, fix compatibility issues, or help support more devices, feel free to open a pull request or issue.

---

## License

This project is licensed under the MIT License.
