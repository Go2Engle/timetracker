# Change: Add Persistent Notifications

## Status
**COMPLETED** (Simplified implementation without action buttons)

## Why
Users need to see active task timers without opening the app. Persistent notifications provide at-a-glance timer visibility directly from the notification shade. This is critical for a time tracking app where tasks run in the background.

## What Changes
- Add persistent notification support for running tasks
- Display task title, status (Running/Paused), and live timer in notification
- Tap notification to open app to active tasks screen
- Support multiple notifications for concurrent tasks
- Update notifications in real-time as timers tick (every second)
- Auto-cancel notifications when tasks stop
- Add proper Android configuration for notifications

**Note:** Initial implementation included action buttons (pause/resume/stop) but these were removed due to complexity. Tap to open app provides sufficient access to timer controls.

## Impact
- Affected specs: **task-notifications** (new capability)
- Affected code:
  - New: `lib/services/notification_service.dart`
  - Modified: `lib/services/timer_service.dart` (integrate notifications)
  - Modified: `android/app/src/main/AndroidManifest.xml` (add permissions)
  - Modified: `android/app/build.gradle.kts` (core library desugaring)
  - Modified: `pubspec.yaml` (add flutter_local_notifications)
  - Modified: `lib/main.dart` (initialize notification service)
- Depends on: timer-service capability
- No breaking changes
- Android-focused initially (iOS support can be added later)
