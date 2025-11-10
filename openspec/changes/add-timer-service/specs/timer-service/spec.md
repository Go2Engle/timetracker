## ADDED Requirements

### Requirement: Timer State Management
The system SHALL maintain timer state for each active task, including:
- Task ID
- Elapsed seconds (total accumulated time)
- Current status (running, paused, stopped)
- Start timestamp for current session
- Last update timestamp

#### Scenario: Start timer for new task
- **WHEN** a timer is started for a task with no previous elapsed time
- **THEN** the timer SHALL begin at 0 seconds
- **AND** the task status SHALL be updated to "running" in the database
- **AND** the timer SHALL increment every second

#### Scenario: Start timer for existing task with elapsed time
- **WHEN** a timer is started for a task with existing elapsed time
- **THEN** the timer SHALL continue from the previous elapsed time
- **AND** the accumulated time SHALL be preserved

### Requirement: Timer Operations
The system SHALL provide the following timer operations:
- Start timer (begin timing for a task)
- Pause timer (suspend timing, preserve elapsed time)
- Resume timer (continue timing from paused state)
- Stop timer (end timing, finalize elapsed time)

#### Scenario: Pause running timer
- **WHEN** a running timer is paused
- **THEN** the timer SHALL stop incrementing
- **AND** the current elapsed time SHALL be preserved
- **AND** the task status SHALL be updated to "paused"

#### Scenario: Resume paused timer
- **WHEN** a paused timer is resumed
- **THEN** the timer SHALL continue incrementing from the paused time
- **AND** the task status SHALL be updated to "running"

#### Scenario: Stop timer
- **WHEN** a timer is stopped
- **THEN** the final elapsed time SHALL be saved to the database
- **AND** the task status SHALL be updated to "stopped"
- **AND** the timer SHALL be removed from active timers

### Requirement: Multiple Concurrent Timers
The system SHALL support multiple timers running simultaneously for different tasks.

#### Scenario: Start multiple timers
- **WHEN** timers are started for multiple tasks
- **THEN** each timer SHALL run independently
- **AND** each timer SHALL track its own elapsed time
- **AND** each timer SHALL update at 1-second intervals

#### Scenario: Prevent duplicate timers
- **WHEN** a timer is started for a task that already has a running timer
- **THEN** the system SHALL not create a duplicate timer
- **AND** the existing timer SHALL continue running

### Requirement: Real-Time Updates
The system SHALL broadcast timer updates to listeners via a stream.

#### Scenario: Subscribe to timer updates
- **WHEN** a listener subscribes to timer updates
- **THEN** the listener SHALL receive updates for all active timers
- **AND** updates SHALL be delivered every second for running timers
- **AND** updates SHALL include task ID, elapsed seconds, and status

#### Scenario: Timer state changes broadcast
- **WHEN** a timer state changes (start, pause, resume, stop)
- **THEN** an immediate update SHALL be broadcast to all listeners
- **AND** the update SHALL reflect the new state

### Requirement: Automatic Persistence
The system SHALL automatically save timer state to the database at regular intervals.

#### Scenario: Periodic auto-save
- **WHEN** a timer is running
- **THEN** the elapsed time SHALL be saved to the database every 5 seconds
- **AND** the save operation SHALL not interrupt timer accuracy

#### Scenario: Save on state transition
- **WHEN** a timer state changes (pause, stop)
- **THEN** the current elapsed time SHALL be immediately saved to the database
- **AND** the task status SHALL be updated

### Requirement: State Restoration
The system SHALL restore running timers when the app restarts.

#### Scenario: App restart with running tasks
- **WHEN** the app is restarted
- **AND** there are tasks in "running" status in the database
- **THEN** timers SHALL be restored for those tasks
- **AND** elapsed time SHALL be calculated from the last saved state
- **AND** timers SHALL resume incrementing

#### Scenario: Handle time gap after restart
- **WHEN** a running task is restored after app restart
- **THEN** the system SHALL account for time elapsed while the app was closed
- **AND** add the gap time to the total elapsed seconds

### Requirement: Timer Accuracy
The system SHALL maintain accurate time tracking within a 1-second tolerance.

#### Scenario: Continuous timer accuracy
- **WHEN** a timer runs for an extended period
- **THEN** the elapsed time SHALL accurately reflect wall-clock time
- **AND** drift SHALL not exceed 1 second per hour

#### Scenario: Pause/resume accuracy
- **WHEN** a timer is paused and resumed multiple times
- **THEN** only the time when the timer was running SHALL be counted
- **AND** paused time SHALL be excluded from elapsed time

### Requirement: Time Formatting
The system SHALL provide utilities to format elapsed time for display.

#### Scenario: Format time as HH:MM:SS
- **WHEN** elapsed seconds are formatted
- **THEN** the output SHALL be in HH:MM:SS format
- **AND** hours SHALL display even if 0
- **AND** values SHALL be zero-padded (e.g., 01:05:09)

#### Scenario: Format time for human reading
- **WHEN** elapsed time is formatted for display
- **THEN** short durations (< 1 hour) SHALL display as "MM:SS"
- **AND** long durations (≥ 1 hour) SHALL display as "HH:MM:SS"
