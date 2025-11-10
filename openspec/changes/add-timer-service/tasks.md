# Implementation Tasks

## 1. Time Formatting Utilities
- [x] 1.1 Create TimeFormatter utility class
- [x] 1.2 Implement formatDuration for HH:MM:SS display
- [x] 1.3 Implement formatElapsedTime for human-readable format
- [x] 1.4 Add unit tests for time formatting

## 2. Timer Service Core
- [x] 2.1 Create TimerService class with singleton pattern
- [x] 2.2 Define TimerState data class (taskId, elapsedSeconds, isRunning, isPaused)
- [x] 2.3 Implement internal timer map to track multiple concurrent timers
- [x] 2.4 Create periodic timer (1-second intervals) for active timers
- [x] 2.5 Implement stream controller for broadcasting timer updates

## 3. Timer Operations
- [x] 3.1 Implement startTimer(taskId) method
- [x] 3.2 Implement pauseTimer(taskId) method
- [x] 3.3 Implement resumeTimer(taskId) method
- [x] 3.4 Implement stopTimer(taskId) method
- [x] 3.5 Implement getTimerState(taskId) method
- [x] 3.6 Implement getAllActiveTimers() method

## 4. Database Integration
- [x] 4.1 Add updateTaskElapsedTime method to TaskRepository
- [x] 4.2 Auto-save elapsed time every 5 seconds for running timers
- [x] 4.3 Update task status in database on state transitions
- [x] 4.4 Load running tasks on service initialization

## 5. State Management
- [x] 5.1 Implement state restoration on app restart
- [x] 5.2 Handle app lifecycle (pause/resume)
- [x] 5.3 Ensure timer accuracy across state changes
- [x] 5.4 Prevent duplicate timers for same task

**Implementation Notes:**
- Timer state restoration now calculates elapsed time from last database update
- Uses `updatedAt` timestamp to track when timer was last active
- On app restart, calculates time difference and adds to elapsedSeconds
- Auto-save updates `updatedAt` every 5 seconds for accurate restoration
- **Limitation:** Notifications stop when app is killed (requires native foreground service)

## 6. Testing
- [x] 6.1 Write unit tests for timer state management
- [x] 6.2 Write unit tests for time calculations
- [x] 6.3 Test concurrent timer functionality
- [x] 6.4 Test persistence and restoration
- [x] 6.5 Manual testing with actual timing verification
- [x] 6.6 Test timer accuracy across app restarts
- [x] 6.7 Verify timestamp-based restoration logic

## 7. Implementation Complete
- ✅ All core timer functionality implemented
- ✅ Accurate time tracking with timestamp-based restoration
- ✅ Multiple concurrent timers working perfectly
- ✅ Auto-save every 5 seconds
- ✅ Real-time updates via streams
- ✅ Database persistence and restoration
- ✅ Integration with notification service
- ✅ Timer accuracy maintained across app lifecycle
- 📝 Future enhancement documented: Native foreground service for killed-app scenarios

