# Background Timer Implementation - Testing Guide

## What Changed

The app now uses an Android Foreground Service to keep timers running even when the app is in the background or killed. This resolves the issue where timers would pause after a few minutes in the background.

## How It Works

### Architecture
1. **Dart Timer (Flutter)**: Updates UI when app is in foreground
2. **Native Foreground Service (Android)**: Keeps timers running in background
3. **Synchronization**: Both layers stay in sync via method channels

### Key Components
- `TimerForegroundService.kt` - Native Android service that runs independently
- `ForegroundTimerService.dart` - Flutter wrapper for method channel communication
- `TimerService.dart` - Updated to sync with foreground service on Android

## Testing Instructions

### 1. Build and Install
```bash
flutter build apk --release
# or
flutter run --release
```

### 2. Test Background Timer Persistence

**Test Case 1: App Backgrounded**
1. Start a timer
2. Press home button to send app to background
3. Wait 2-3 minutes
4. Open app again
5. ✅ Timer should continue from correct time (not paused)
6. ✅ Notification should show updated time

**Test Case 2: App Killed**
1. Start a timer
2. Swipe app away from recent apps (kill it completely)
3. Wait 2-3 minutes
4. Open app again from launcher
5. ✅ Timer should resume from correct time
6. ✅ Notification should have been updating while app was killed

**Test Case 3: Multiple Timers**
1. Start 2-3 different timers
2. Send app to background
3. Wait several minutes
4. Return to app
5. ✅ All timers should show correct elapsed time
6. ✅ All notifications should be present and updated

**Test Case 4: Pause/Resume in Background**
1. Start a timer
2. Pause it
3. Send app to background
4. Wait 2-3 minutes
5. Return to app
6. ✅ Paused timer should not have advanced
7. Resume timer and background app again
8. ✅ Timer should now continue in background

**Test Case 5: Stop Timer**
1. Start a timer
2. Send app to background
3. Return and stop the timer
4. ✅ Foreground service notification should disappear when no timers running
5. ✅ Individual task notification should be removed

### 3. Check Notifications

**Service Notification**
- Should show "TimeTracker" with count of running/paused timers
- Should be persistent (can't be swiped away) when timers are running
- Should auto-dismiss when all timers stop

**Task Notifications**
- Should update every second showing current elapsed time
- Should show "Running" or "Paused" status
- Should persist even when app is killed

### 4. Battery Impact Test

1. Start a timer
2. Send app to background for extended period (30+ minutes)
3. Check battery usage in Android Settings
4. ✅ Should be minimal battery drain (foreground service is lightweight)

## Expected Behavior

### When App is in Foreground
- Flutter `Timer.periodic` updates UI every second
- Foreground service also runs and updates notifications
- Both stay in sync via 5-second sync interval

### When App is in Background
- Flutter timer pauses (normal Android behavior)
- Foreground service continues running
- Notifications update every second from native service
- Timer state saved to SharedPreferences

### When App Resumes
- Flutter reads latest timer states from database
- Syncs with foreground service to get current elapsed time
- UI updates with accurate time
- Both layers continue in sync

## Troubleshooting

### Timers Still Pausing
- Check battery optimization is OFF for TimeTracker
- Verify foreground service is running: look for persistent notification
- Check Android logs: `adb logcat | grep TimeTracker`

### Service Not Starting
- Verify POST_NOTIFICATIONS permission granted
- Check Android version >= 8.0 (Oreo)
- Look for errors in: `adb logcat | grep TimerForegroundService`

### Notifications Not Updating
- Ensure notification channel "Task Timers" is enabled
- Check notification permissions in Android Settings
- Verify foreground service has proper permissions in manifest

## Known Limitations

1. **Android Only**: iOS handles background tasks differently (uses background refresh)
2. **Service Type**: Uses `dataSync` type - appropriate for time tracking
3. **Update Frequency**: Notifications update every 1 second (may be throttled by Android on some devices)

## Rollback

If issues occur, you can disable the foreground service by commenting out the `Platform.isAndroid` checks in `timer_service.dart`. The app will fall back to the previous behavior where timers pause in background but resume accurately when app is reopened.
