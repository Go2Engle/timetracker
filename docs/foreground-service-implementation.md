# Foreground Service for Background Timers

## Current Limitation
When the app is completely killed (swiped away from recent apps), the timer stops and notifications disappear. The timer resumes accurately when the app is reopened (using the last saved timestamp), but it doesn't continue running in the background.

## Why This Happens
- Flutter apps stop running when killed by the OS
- Notifications require the Flutter app to be alive to update
- The 1-second tick timer stops when the app is terminated

## Solution: Android Foreground Service

To keep timers running when the app is killed, we need to implement a native Android Foreground Service.

### What is a Foreground Service?
A foreground service is an Android component that:
- Runs independently of the Flutter app lifecycle
- Shows a persistent notification (required by Android)
- Continues running even when the app is killed
- Can update notifications from native code

### Implementation Steps (Future Work)

#### 1. Create Native Android Service
File: `android/app/src/main/kotlin/.../TimerForegroundService.kt`

```kotlin
class TimerForegroundService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val timerRunnable = object : Runnable {
        override fun run() {
            // Update timer every second
            updateTimerNotifications()
            handler.postDelayed(this, 1000)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Create foreground notification
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        
        // Start timer loop
        handler.post(timerRunnable)
        
        return START_STICKY
    }
    
    private fun updateTimerNotifications() {
        // Query database for running tasks
        // Calculate elapsed time
        // Update notifications
    }
}
```

#### 2. Declare Service in AndroidManifest.xml
```xml
<service
    android:name=".TimerForegroundService"
    android:foregroundServiceType="dataSync"
    android:exported="false" />
```

#### 3. Add Flutter Method Channel
File: `lib/services/foreground_timer_service.dart`

```dart
class ForegroundTimerService {
  static const platform = MethodChannel('com.timetracker/timer_service');
  
  Future<void> startForegroundService() async {
    await platform.invokeMethod('startForegroundService');
  }
  
  Future<void> stopForegroundService() async {
    await platform.invokeMethod('stopForegroundService');
  }
}
```

#### 4. Integrate with TimerService
- Start foreground service when first timer starts
- Stop foreground service when all timers stop
- Sync state between Flutter and native service

### Alternative: WorkManager
Another approach is to use WorkManager for periodic background tasks:
- Simpler than foreground service
- Less battery drain
- Updates less frequently (15-minute minimum intervals)
- Good enough for time tracking use cases

### Recommended Approach
1. **Phase 1** (Current): Timer accuracy on app restart ✅
   - Store timestamps in database
   - Calculate elapsed time on restart
   - Good enough for most use cases

2. **Phase 2** (Future): Foreground Service
   - Implement only if users complain about killed apps
   - More complex but provides continuous updates
   - Required for mission-critical timing

3. **Phase 3** (Optional): iOS Background Modes
   - Similar implementation needed for iOS
   - Uses Background Tasks framework
   - Stricter limitations than Android

## Testing the Current Implementation
1. Start a timer
2. Force-kill the app (swipe from recent apps)
3. Wait 30 seconds
4. Reopen app
5. ✅ Timer should show accurate elapsed time (including time while app was closed)
6. ❌ Notification did not continue (expected limitation)

## User Impact
- **Low**: Most users keep app in background (paused, not killed)
- **Medium**: Users who force-kill apps will see timer stop but resume accurately
- **High**: Users who need continuous notifications (rare for time tracking)

## Recommendation
Current implementation is sufficient for MVP. Implement foreground service only if:
- Users request it
- Analytics show frequent app kills
- Competitor analysis shows it's a key differentiator
