# Spec: UI Consistency

## MODIFIED Requirements

### Requirement: Tasks screen modern styling
The Tasks screen (TaskListScreen) SHALL apply modern Material Design 3 patterns consistent with the Reports screen, including gradient backgrounds for active tasks, outlined borders for stopped tasks, icon-enhanced section headers, and centered empty states.

**ID:** `ui-consistency-tasks-modern`  
**Priority:** High  
**Category:** User Interface

#### Scenario: Active task cards display with gradient backgrounds
**Given** a user has one or more active (running or paused) tasks  
**When** they view the Tasks screen  
**Then** active task cards SHALL display with:
- Gradient background using `primaryContainer` color
- Rounded corners (16px border radius)
- Box shadow with 8px blur and 2px vertical offset
- Bold elapsed time in `displaySmall` or `headlineMedium` font
- Status badge showing "Running" (green tint) or "Paused" (orange tint)
- Icon buttons for play/pause and stop actions

#### Scenario: Stopped task cards use outlined border styling
**Given** a user has completed or stopped tasks  
**When** they view the "Recent Tasks" section  
**Then** task cards SHALL display with:
- Zero elevation
- 1px border using `outlineVariant` color
- 16px border radius
- Elapsed time in colored container badge (top-right position)
- Consistent 16px padding
- Start button as icon on the right

#### Scenario: Section headers include contextual icons
**Given** the Tasks screen displays multiple sections  
**When** a user views the screen  
**Then** section headers SHALL include:
- Icon on the left (play_circle for active, history for recent)
- Bold text in `titleMedium` font
- Primary color for both icon and text
- 16px padding around the header

#### Scenario: Empty state displays centered with icon and text
**Given** a user has no tasks in the system  
**When** they view the Tasks screen  
**Then** an empty state SHALL display:
- Centered vertically and horizontally
- Large icon (64px) using `onSurfaceVariant` color with 50% opacity
- Title text in `titleMedium` font
- Optional subtitle text in `bodyMedium` font
- Appropriate spacing between elements (16px vertical)

---

### Requirement: Calendar screen modern styling
The Calendar screen SHALL apply modern Material Design 3 patterns consistent with the Reports and Tasks screens, including gradient backgrounds for the daily summary, outlined borders for task history cards, refined status chips, and centered empty states.

**ID:** `ui-consistency-calendar-modern`  
**Priority:** High  
**Category:** User Interface

#### Scenario: Daily summary displays with gradient background
**Given** a user selects a date in the calendar  
**When** the daily summary bar appears below the calendar  
**Then** the summary container SHALL display:
- Gradient background using `primaryContainer` color
- 20px border radius
- Box shadow with 8px blur and 2px vertical offset
- 24px padding all sides
- Calendar icon next to the date
- Task count and total time on the right
- Text using `onPrimaryContainer` color

#### Scenario: Task history cards match Reports card styling
**Given** a user selects a date with one or more tasks  
**When** viewing the task list for that date  
**Then** each task card SHALL display:
- Zero elevation
- 1px border using `outlineVariant` color  
- 16px border radius
- Elapsed time in colored container badge (top-right)
- Schedule icon next to start time
- Status chip with appropriate color (green/orange/grey)
- 16px padding all sides
- 12px bottom margin between cards

#### Scenario: Calendar empty state uses centered icon pattern
**Given** a user selects a date with no tasks  
**When** viewing the task list for that date  
**Then** an empty state SHALL display:
- Centered vertically and horizontally
- Large icon (64px, `event_busy` or `inbox_outlined`)
- Title "No tasks on this day" in `titleMedium`
- Subtitle "Start tracking to see tasks here" in `bodyMedium`
- Icons and text using `onSurfaceVariant` color with appropriate opacity

#### Scenario: Task list includes section header
**Given** a user selects a date with tasks  
**When** viewing the task list  
**Then** a section header SHALL appear:
- Label text showing "TASKS" or "TASKS FOR [DATE]"
- Styled as `labelLarge` with letter spacing
- Using `onSurfaceVariant` color
- 16px horizontal padding
- Positioned above the task list

---

### Requirement: Cross-screen visual consistency
The Tasks, Calendar, and Reports screens SHALL share common visual patterns including card styling (16px radius, outlined borders or gradients), empty states (centered icon + text), section headers (icon + bold text), and spacing rhythm (16px margins, 12px card gaps) to create a cohesive user experience across the application.

**ID:** `ui-consistency-cross-screen`  
**Priority:** High  
**Category:** User Interface

#### Scenario: Cards across all screens use consistent styling
**Given** a user navigates between Tasks, Calendar, and Reports screens  
**When** they view task cards on any screen  
**Then** all cards SHALL share:
- 16px border radius
- Either gradient background (for emphasis) or outlined 1px border
- 16px internal padding
- Zero elevation for outlined cards
- Consistent shadow pattern for gradient cards

#### Scenario: Empty states follow the same pattern
**Given** a screen has no data to display  
**When** a user views the empty state  
**Then** it SHALL consistently show:
- Centered layout (vertical and horizontal)
- Large icon at 64px size
- Primary message in `titleMedium`
- Optional secondary message in `bodyMedium`
- Icon color using `onSurfaceVariant` with 50% opacity

#### Scenario: Section headers use consistent styling
**Given** any screen displays multiple sections of content  
**When** a user views section headers  
**Then** headers SHALL consistently include:
- Contextual icon (20px) on the left
- Bold text in `titleMedium` or `labelLarge` (uppercase with letter spacing)
- Primary or `onSurfaceVariant` color based on emphasis
- 8px spacing between icon and text
- 16px padding around the header

#### Scenario: Spacing follows standard rhythm
**Given** any UI component across all screens  
**When** rendered in the app  
**Then** spacing SHALL follow:
- 16px screen margins (horizontal)
- 16px card padding (internal)
- 12px card margins (bottom, when stacked)
- 8px, 12px, or 16px vertical rhythm based on hierarchy
- Consistent gap sizes for icon-text pairs (4px small, 8px standard)

---

## ADDED Requirements

None. This change only modifies existing UI patterns without adding new functional requirements.

---

## REMOVED Requirements

None. All existing functionality is preserved; only visual styling changes.
