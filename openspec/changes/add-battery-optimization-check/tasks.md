# Implementation Tasks

## Phase 1: Native Android Implementation
- [x] Add `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission to `AndroidManifest.xml`
- [x] Add battery optimization check methods to `MainActivity.kt`:
  - [x] `isBatteryOptimizationIgnored()` - Check if app is exempt from battery optimization
  - [x] `openBatteryOptimizationSettings()` - Open system settings for battery optimization
- [x] Update method channel handler in `MainActivity.kt` to expose battery optimization methods to Flutter
- [x] Test battery optimization check on Android device with API 23+
- [x] Test opening battery settings intent on Android device

## Phase 2: Flutter Service Layer
- [x] Create `lib/services/battery_optimization_service.dart`
- [x] Add `BatteryOptimizationService` class with methods:
  - [x] `checkBatteryOptimizationStatus()` - Returns bool indicating if optimization is disabled
  - [x] `requestBatteryOptimizationExemption()` - Opens system settings
  - [x] Platform-specific logic to handle Android vs iOS
- [x] Add error handling and fallbacks for unsupported platforms/API levels
- [x] Write unit tests for `BatteryOptimizationService`

## Phase 3: Battery Optimization Check Screen
- [x] Create `lib/screens/battery_optimization_screen.dart`
- [x] Build UI with:
  - [x] AppBar with "Battery Optimization" title
  - [x] Status card showing current optimization state (enabled/disabled)
  - [x] Icon and color coding (warning for enabled, success for disabled)
  - [x] Explanatory text about timer reliability
  - [x] "Open Settings" button (visible when optimization enabled)
- [x] Implement state management to update UI based on battery optimization status
- [x] Add `initState` to check battery optimization on screen load
- [x] Add `didChangeAppLifecycleState` listener to refresh status when returning from settings
- [x] Test screen layout on different screen sizes
- [x] Test status updates when toggling battery optimization

## Phase 4: Settings Screen Integration
- [x] Add "Battery Optimization" list tile to `SettingsScreen`
- [x] Position it in a new "System Settings" or "Advanced" section
- [x] Add appropriate icon (e.g., `Icons.battery_charging_full` or `Icons.settings_power`)
- [x] Add navigation to `BatteryOptimizationScreen` on tap
- [x] Consider adding a badge or indicator if optimization is enabled (optional enhancement)
- [x] Test navigation flow from Settings to Battery Optimization screen

## Phase 5: Platform Handling
- [x] Add conditional rendering to hide/show battery optimization option on iOS
- [x] Ensure `BatteryOptimizationService` returns appropriate values on iOS (always true or N/A)
- [x] Test app behavior on iOS simulator/device to confirm no crashes
- [x] Add debug logging for platform-specific behavior

## Phase 6: Documentation and Testing
- [x] Add user documentation explaining battery optimization importance
- [x] Update README.md or docs/ with battery optimization setup instructions
- [x] Create manual test checklist for battery optimization scenarios:
  - [x] Check status when optimization enabled
  - [x] Check status when optimization disabled
  - [x] Open settings and verify correct page opens
  - [x] Return from settings and verify status updates
  - [x] Test on multiple Android versions (API 23, 29, 33+)
- [x] Run full regression test suite to ensure no existing functionality broken
- [x] Test foreground service with battery optimization enabled vs disabled

## Phase 7: Validation and Polish
- [x] Run `dart format` on all modified/new Dart files
- [x] Run `dart analyze` and fix any linting issues
- [x] Review error handling for edge cases (device doesn't support intent, etc.)
- [x] Verify all UI text is clear and user-friendly
- [x] Take screenshots for documentation (optional)
- [x] Run `openspec validate add-battery-optimization-check --strict`

## Validation Checklist
- [x] Battery optimization status correctly detected on Android
- [x] Settings intent opens to correct page
- [x] UI updates when returning from settings
- [x] No crashes on iOS or unsupported Android versions
- [x] All tasks above completed and checked off
- [x] Code follows project conventions (formatting, naming, architecture)
- [x] Manual testing completed on connected Android device
