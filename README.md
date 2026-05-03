# AQW Pocket 

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/Rust-stable-orange.svg)](https://www.rust-lang.org/)
[![ActionScript](https://img.shields.io/badge/ActionScript-3.0-orange.svg)](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/)
[![Adobe AIR](https://img.shields.io/badge/Adobe%20AIR-51.3-red.svg)](https://airsdk.harman.com/)

### Join our Discord [discord.gg/EXS5qM35ff](https://discord.gg/EXS5qM35ff)

AdventureQuest Worlds Mobile, AQW Pocket is a free, community-built alternative that runs the game natively on Android.

> **Disclaimer:** This is an unofficial community project, not affiliated with or endorsed by Artix Entertainment. AdventureQuest Worlds and all related assets are the property of Artix Entertainment. Use at your own risk.

---

## Download

Grab the latest APK from the [Releases](../../releases/latest) tab.
Pick **armv8** for anything recent (2017+) or **armv7** for older devices.

**Only download from this repository. APKs from other sources may be modified.**

## Features

- **Joystick**, **skills bar** and **UI**, reposition, reset, or hide via the top left menu
- In-game update notifications, checks GitHub for new releases automatically

<img width="500" height="auto" alt="image" src="https://github.com/user-attachments/assets/65fe7ec8-d406-44d7-abc8-018cc6399deb" />

## How It Works

- The build process always uses the latest game client.
- A set of patches are applied to the ActionScript bytecode to make the client compatible with mobile/AIR constraints.
- An ActionScript loader wraps the patched game and handles initialization.
- Everything is packaged into an Android APK using the Adobe AIR SDK. The entire build process runs openly on GitHub Actions, what you see in the code is exactly what gets built.
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

---

## Contributing

Community contributions are welcome. If you want to improve patches, fix compatibility issues, or help support more devices, feel free to open a pull request or issue.

---

## License

This project is licensed under the MIT License.
