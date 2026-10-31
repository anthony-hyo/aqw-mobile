# AQW Pocket on iPhone (sideload)

iOS doesn't allow Adobe AIR apps to run ActionScript they download, and AQW downloads maps and items as SWFs with code. This build uses AIR's **interpreter mode**, which runs that code through an interpreter instead, so those downloads have a chance to work. It is untested: expect it to be slower than Android, and it may still fail.

## 1. Build the IPA (free, no Mac needed)

1. Fork this repo on GitHub (it must include `.github/workflows/build-ios-sideload.yml`, `ios/` and `loader/iOS-app.xml`).
2. In your fork, open **Actions**, enable workflows, pick **Build iOS (sideload)**, and press **Run workflow**. Leave the defaults.
3. When it finishes (about 10 minutes), download the **AQWPocket-ios** artifact from the run page and unzip it to get the `.ipa`.

Game files come from the Android release APK, so you don't need the private patches repo.

## 2. Install on your iPhone

The IPA is signed with a throwaway certificate, so it must be re-signed with your Apple ID when you install it:

- **Sideloadly** (Windows/Mac): plug in the iPhone, drop in the IPA, enter your Apple ID.
- **AltStore / SideStore**: open the IPA from Files inside the app.
- **xtool** (Linux, or Windows via WSL): after `xtool setup` (needs `Xcode.xip` from Apple's developer site and your Apple ID), plug in the iPhone and run `xtool install AQWPocket-....ipa`.

With a free Apple ID the app expires after 7 days and must be refreshed. Turn on **Developer Mode** on the iPhone (Settings → Privacy & Security) and trust your Apple ID under Settings → General → VPN & Device Management.

## If the build fails at "Build IPA"

Adobe's packager may reject the throwaway certificate. Use a real one instead: add the repo secrets `IOS_CERT_P12_BASE64`, `IOS_CERT_PASS` and `IOS_PROVISION_BASE64` (from an Apple Developer account, App ID `com.aqw.pocket`) and run it again.
