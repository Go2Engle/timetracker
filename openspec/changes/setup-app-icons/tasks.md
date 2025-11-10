# Implementation Tasks: Setup App Icons

## Android Icons
- [x] Copy all mipmap folders from `assets/IconKitchen-Output/android/res/` to `android/app/src/main/res/`
  - [x] Copy `mipmap-hdpi/` folder (contains ic_launcher.png, ic_launcher_background.png, ic_launcher_foreground.png, ic_launcher_monochrome.png)
  - [x] Copy `mipmap-mdpi/` folder (same structure, lower resolution)
  - [x] Copy `mipmap-xhdpi/` folder
  - [x] Copy `mipmap-xxhdpi/` folder
  - [x] Copy `mipmap-xxxhdpi/` folder
  - [x] Copy `mipmap-anydpi-v26/` folder (contains ic_launcher.xml and ic_launcher_round.xml for adaptive icons)
- [x] Verify `android/app/src/main/AndroidManifest.xml` references `@mipmap/ic_launcher` (should already be correct)

## iOS Icons
- [x] Copy all icon PNG files from `assets/IconKitchen-Output/ios/` to `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Includes: AppIcon@2x.png, AppIcon@3x.png, AppIcon~ipad.png, AppIcon-20@2x.png, etc. (all 20 PNG files)
- [x] Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` with `assets/IconKitchen-Output/ios/Contents.json`
- [x] Remove old placeholder icon files from `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (Icon-App-*.png files)

## Web Icons
- [x] Copy web icons from `assets/IconKitchen-Output/web/` to `web/` directory
  - [x] Copy `favicon.ico` to `web/favicon.ico`
  - [x] Copy `apple-touch-icon.png` to `web/icons/apple-touch-icon.png`
  - [x] Copy `icon-192.png` to `web/icons/Icon-192.png` (match existing naming)
  - [x] Copy `icon-512.png` to `web/icons/Icon-512.png`
  - [x] Copy `icon-192-maskable.png` to `web/icons/Icon-maskable-192.png`
  - [x] Copy `icon-512-maskable.png` to `web/icons/Icon-maskable-512.png`
- [x] Update `web/index.html` favicon reference to use `favicon.ico` instead of `favicon.png`
  - Change `<link rel="icon" type="image/png" href="favicon.png"/>` to `<link rel="icon" href="favicon.ico" sizes="any">`
- [x] Update `web/index.html` apple-touch-icon reference
  - Change `<link rel="apple-touch-icon" href="icons/Icon-192.png">` to `<link rel="apple-touch-icon" href="icons/apple-touch-icon.png">`
- [x] Update `web/manifest.json` icon paths (already correct, just verify they match)

## Validation
- [x] Run `flutter clean` to clear build cache
- [x] Build Android app and verify custom icon appears: `flutter build apk --debug` or test on connected device
- [x] Build iOS app (if macOS available) and verify custom icon in simulator/device
- [x] Build web app and verify favicon and PWA icons: `flutter build web` and inspect output
- [x] Check for any build warnings related to missing or malformed icons

## Cleanup
- [x] Remove old placeholder icon files that are no longer referenced
- [x] Optionally: Add `.DS_Store` files in IconKitchen-Output to .gitignore if not already excluded
