# Change: Add Timer Service

## Status
**COMPLETED**

## Why
Tasks need to accurately track elapsed time while running or paused. A timer service will provide real-time updates, handle state transitions (start/pause/stop), and persist elapsed time to the database. This is essential for the app's core time tracking functionality and will integrate with the notification system.

## What Changes
- Add TimerService to manage active task timers
- Implement start, pause, resume, and stop operations
- Provide real-time timer updates via streams
- Persist elapsed time to database automatically
- Support multiple concurrent timers
- Handle app lifecycle (background/foreground transitions)
- Add elapsed time formatting utilities
- **Accurate timer restoration** using timestamp-based calculations

## Impact
- Affected specs: **timer-service** (new capability)
- Affected code:
  - New: `lib/services/timer_service.dart`
  - New: `lib/utils/time_formatter.dart`
  - Modified: `lib/repositories/task_repository.dart` (add update elapsed time method)
  - New: `docs/foreground-service-implementation.md` (future enhancement guide)
- Depends on: task-storage capability
- No breaking changes
- Foundation for notification controls
