## ADDED Requirements

### Requirement: Persistent Notification Display
The system SHALL display a persistent notification for each running or paused task showing:
- Task title
- Current elapsed time (formatted as HH:MM:SS or MM:SS)
- Task status indicator (running/paused)
- Action buttons (pause/resume and stop)

#### Scenario: Show notification when task starts
- **WHEN** a task timer is started
- **THEN** a persistent notification SHALL appear in the notification shade
- **AND** the notification SHALL display the task title
- **AND** the notification SHALL show "00:00" as initial timer value
- **AND** the notification SHALL include action buttons

#### Scenario: Notification for paused task
- **WHEN** a task is paused
- **THEN** the notification SHALL remain visible
- **AND** the notification SHALL show "Paused" indicator
- **AND** the pause button SHALL change to a resume button

### Requirement: Real-Time Notification Updates
The system SHALL update notification content in real-time as the timer progresses.

#### Scenario: Update timer display every second
- **WHEN** a task timer is running
- **THEN** the notification SHALL update the elapsed time display every second
- **AND** the update SHALL reflect the current timer value
- **AND** updates SHALL not cause notification to re-appear or make sound

#### Scenario: Silent notification updates
- **WHEN** a notification is updated with new timer value
- **THEN** the update SHALL be silent (no sound or vibration)
- **AND** the notification SHALL not move to the top of the shade
- **AND** the notification SHALL remain in its current position

### Requirement: Notification Actions
The system SHALL provide interactive action buttons within the notification.

#### Scenario: Pause button action
- **WHEN** the user taps the pause button in the notification
- **THEN** the timer SHALL pause
- **AND** the notification SHALL update to show "Paused" state
- **AND** the pause button SHALL change to a resume button

#### Scenario: Resume button action
- **WHEN** the user taps the resume button in the notification
- **THEN** the timer SHALL resume
- **AND** the notification SHALL update to show "Running" state
- **AND** the resume button SHALL change to a pause button

#### Scenario: Stop button action
- **WHEN** the user taps the stop button in the notification
- **THEN** the timer SHALL stop and finalize elapsed time
- **AND** the notification SHALL be removed
- **AND** the task SHALL be saved with final elapsed time

### Requirement: Multiple Concurrent Notifications
The system SHALL support displaying multiple notifications simultaneously for concurrent tasks.

#### Scenario: Show multiple task notifications
- **WHEN** multiple tasks are running concurrently
- **THEN** each task SHALL have its own separate notification
- **AND** each notification SHALL update independently
- **AND** each notification SHALL have its own action buttons

#### Scenario: Unique notification IDs
- **WHEN** a notification is created for a task
- **THEN** the notification SHALL use the task ID as the notification ID
- **AND** the notification ID SHALL prevent duplicates for the same task

### Requirement: Notification Tap Action
The system SHALL open the app when the user taps the notification body.

#### Scenario: Open app from notification
- **WHEN** the user taps the notification content (not action buttons)
- **THEN** the app SHALL open
- **AND** the app SHALL navigate to the main screen or task detail
- **AND** the notification SHALL remain visible

### Requirement: Notification Persistence
The system SHALL keep notifications visible as long as the task is running or paused.

#### Scenario: Non-dismissible notification for running task
- **WHEN** a task is running
- **THEN** the notification SHALL be marked as ongoing
- **AND** the user SHALL not be able to dismiss the notification by swiping

#### Scenario: Remove notification on stop
- **WHEN** a task is stopped
- **THEN** the notification SHALL be automatically removed
- **AND** no notification residue SHALL remain

### Requirement: Background Execution
The system SHALL continue displaying and updating notifications when the app is in the background.

#### Scenario: Notification updates while app backgrounded
- **WHEN** the app is in the background
- **AND** a task timer is running
- **THEN** the notification SHALL continue updating every second
- **AND** the timer SHALL continue running accurately

#### Scenario: Foreground service for Android
- **WHEN** a task timer is running on Android
- **THEN** the app SHALL use a foreground service
- **AND** the foreground service SHALL prevent the system from killing the process
- **AND** the service SHALL be properly managed (start/stop with timers)

### Requirement: Android Permissions
The system SHALL request and handle necessary Android permissions.

#### Scenario: Request notification permission (Android 13+)
- **WHEN** the app is launched on Android 13 or higher
- **THEN** the app SHALL request POST_NOTIFICATIONS permission
- **AND** if denied, notifications SHALL not be shown
- **AND** the user SHALL be informed about the limitation

#### Scenario: Notification without permission
- **WHEN** notification permission is denied
- **THEN** timers SHALL still function correctly
- **AND** the app SHALL display timer state within the app UI
- **AND** no errors SHALL be thrown

### Requirement: Notification Channel Configuration
The system SHALL configure proper notification channels for Android.

#### Scenario: Create notification channel
- **WHEN** the notification service is initialized
- **THEN** a notification channel SHALL be created for timer notifications
- **AND** the channel SHALL be named "Task Timers"
- **AND** the channel importance SHALL be set to DEFAULT (no sound by default)

#### Scenario: Channel settings respect user preferences
- **WHEN** the user modifies notification channel settings
- **THEN** the app SHALL respect those settings
- **AND** notification behavior SHALL follow user preferences
