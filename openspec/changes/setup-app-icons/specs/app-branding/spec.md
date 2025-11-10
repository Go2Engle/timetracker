# App Branding Specification Deltas

## ADDED Requirements

### Requirement: Platform-Specific App Icons
The application SHALL display custom branded icons on all supported platforms (Android, iOS, web) using platform-appropriate formats and configurations.

#### Scenario: Android adaptive icon display
- **WHEN** the app is installed on an Android device
- **THEN** the launcher SHALL display a custom adaptive icon with background, foreground, and monochrome layers
- **AND** the icon SHALL appear in the app drawer, recent apps, and notifications

#### Scenario: iOS app icon display
- **WHEN** the app is installed on an iOS device
- **THEN** the home screen SHALL display a custom app icon at the correct size for the device (iPhone, iPad, CarPlay)
- **AND** the icon SHALL appear in the app switcher and Settings

#### Scenario: Web PWA icon display
- **WHEN** the app is accessed in a web browser
- **THEN** the browser tab SHALL display a custom favicon
- **AND** when installed as a PWA, the home screen SHALL display custom icons at 192x192 and 512x512 sizes
- **AND** maskable icons SHALL be provided for adaptive icon support on Android PWAs

### Requirement: Icon Asset Organization
The application project SHALL maintain icon assets in platform-specific directories following Flutter and platform conventions.

#### Scenario: Android icon assets location
- **WHEN** building for Android
- **THEN** icon assets SHALL be located in `android/app/src/main/res/mipmap-*` directories
- **AND** adaptive icon XML descriptors SHALL be in `mipmap-anydpi-v26` folder

#### Scenario: iOS icon assets location
- **WHEN** building for iOS
- **THEN** icon assets SHALL be located in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **AND** a `Contents.json` file SHALL define the icon set metadata

#### Scenario: Web icon assets location
- **WHEN** building for web
- **THEN** icon assets SHALL be located in the `web/` and `web/icons/` directories
- **AND** the `manifest.json` file SHALL reference all PWA icon sizes
- **AND** the `index.html` file SHALL link to the favicon and apple-touch-icon
