# Battery Optimization Setup

## Overview
TimeTracker uses a foreground service to keep timers running accurately in the background. However, Android's battery optimization settings can interfere with this functionality, causing timers to pause or stop unexpectedly.

## Why Disable Battery Optimization?

Battery optimization is an Android feature that restricts background app activity to save battery. While this is generally good, it can negatively impact TimeTracker by:

- Pausing timers when the app is backgrounded
- Stopping the foreground service after extended periods
- Causing inaccurate time tracking
- Preventing notifications from updating in real-time

**Disabling battery optimization for TimeTracker ensures:**
- ✅ Timers continue running accurately in the background
- ✅ Foreground service remains active
- ✅ Notifications update in real-time
- ✅ Reliable time tracking even when the screen is locked

## How to Disable Battery Optimization

### Using the In-App Settings

1. Open TimeTracker
2. Navigate to **Settings** (gear icon)
3. Tap **Battery Optimization** under "System Settings"
4. If the status shows "Battery Optimization: Enabled":
   - Tap the **Open Settings** button
   - Look for TimeTracker in the list
   - Select **Don't optimize** or **Not optimized**
   - Return to the app to verify the status has changed

### Manual Steps (Alternative)

If the in-app method doesn't work on your device:

1. Open Android **Settings**
2. Navigate to **Apps** or **Applications**
3. Find and tap **TimeTracker**
4. Tap **Battery** or **Battery usage**
5. Tap **Battery optimization**
6. Select **All apps** from the dropdown
7. Find **TimeTracker** and tap it
8. Select **Don't optimize**
9. Tap **Done**

## Checking the Status

The Battery Optimization screen will show:
- ✅ **Green check icon** - Battery optimization is disabled (good!)
- ⚠️ **Orange warning icon** - Battery optimization is enabled (needs attention)

The status automatically updates when you return from settings.

## Device-Specific Notes

Different Android manufacturers may have slightly different settings paths:

- **Samsung**: Settings → Apps → TimeTracker → Battery → Optimize battery usage → All apps → TimeTracker → Turn off
- **OnePlus/Oppo**: Settings → Battery → Battery optimization → TimeTracker → Don't optimize
- **Xiaomi/MIUI**: Settings → Apps → Manage apps → TimeTracker → Battery saver → No restrictions
- **Huawei**: Settings → Apps → Apps → TimeTracker → Battery → App launch → Manage manually

## Platform Availability

This feature is only available on Android devices running API level 23 (Marshmallow) or higher. On iOS, battery optimization for background tasks is handled differently and does not require user configuration.

## Troubleshooting

### Timers Still Pausing
If timers continue to pause even after disabling battery optimization:
1. Verify the status shows "Disabled" in the Battery Optimization screen
2. Check if your device has additional battery-saving features (e.g., "Doze mode", "App standby")
3. Ensure TimeTracker is not in any battery restriction lists
4. Try restarting your device

### Settings Won't Open
If the "Open Settings" button doesn't work:
1. Follow the manual steps above
2. Check that you have the latest version of Android
3. Ensure your device supports battery optimization management

### Status Doesn't Update
If the status doesn't update after changing settings:
1. Return to the Battery Optimization screen
2. Pull down to refresh (or close and reopen the screen)
3. The status is checked automatically when the screen gains focus

## Technical Details

Battery optimization affects Android's Doze mode and App Standby features. When enabled, these features can:
- Restrict network access
- Defer background sync
- Prevent wake locks
- Limit CPU usage
- Reduce background execution frequency

For apps that need continuous background operation (like time tracking), disabling optimization is recommended.

## Related Documentation

- [Background Timer Implementation](BACKGROUND_TIMER_IMPLEMENTATION.md)
- [Foreground Service Implementation](docs/foreground-service-implementation.md)
