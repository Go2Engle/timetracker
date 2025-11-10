## MODIFIED Requirements

### Requirement: The system SHALL display a month-view calendar showing the current month with visual indicators for days containing tasks.
The system SHALL display a collapsible month-view calendar that shrinks when scrolling and can be expanded via drag gesture, while showing visual indicators for days containing tasks.

#### Scenario: Calendar collapses when scrolling down through tasks
- **WHEN** the user scrolls down in the calendar screen
- **THEN** the calendar SHALL smoothly animate to a collapsed/minimized state
- **AND** the collapsed calendar SHALL remain visible at the top of the screen
- **AND** the task list SHALL be fully accessible and scrollable
- **AND** the selected date indicator SHALL remain visible in the collapsed state

#### Scenario: Calendar expands when user drags down
- **WHEN** the calendar is in collapsed state
- **AND** the user performs a drag-down gesture on the collapsed calendar or scrolls to the top
- **THEN** the calendar SHALL smoothly animate back to full size
- **AND** the calendar month view SHALL be fully interactive
- **AND** all date indicators and markers SHALL be visible

#### Scenario: Calendar maintains state during collapse/expand
- **WHEN** the calendar transitions between collapsed and expanded states
- **THEN** the selected date SHALL remain selected
- **AND** the focused month SHALL not change
- **AND** the task list SHALL continue showing tasks for the selected date
- **AND** transitions SHALL be smooth without layout jumps

#### Scenario: Original calendar display on screen load
- **WHEN** the calendar screen is opened
- **THEN** the calendar SHALL be displayed in full expanded state
- **AND** the current month SHALL be displayed
- **AND** today's date SHALL be highlighted
- **AND** days with tasks SHALL show visual indicators

#### Scenario: Calendar shows task indicators in both states
- **WHEN** a day has one or more tasks
- **THEN** a visual marker SHALL appear on that day in both expanded and collapsed states
- **AND** the marker SHALL distinguish that day from empty days
- **AND** the marker style MAY indicate the number of tasks (optional enhancement)

## ADDED Requirements

### Requirement: The calendar SHALL provide visual feedback for scroll-based collapse/expand interactions.
The system SHALL provide clear visual cues during calendar collapse and expand animations to help users understand the interaction.

#### Scenario: Smooth animation during collapse
- **WHEN** the user scrolls down triggering calendar collapse
- **THEN** the calendar height SHALL animate smoothly over a duration of 200-300ms
- **AND** calendar content SHALL scale or fade appropriately during transition
- **AND** the animation SHALL not cause performance issues or jank
- **AND** the collapse SHALL feel natural and responsive

#### Scenario: Smooth animation during expansion
- **WHEN** the user triggers calendar expansion via drag or scroll to top
- **THEN** the calendar height SHALL animate smoothly over a duration of 200-300ms
- **AND** calendar content SHALL scale or fade appropriately during transition
- **AND** the fully expanded calendar SHALL be fully interactive
- **AND** month navigation controls SHALL be accessible

### Requirement: The collapsed calendar SHALL display minimal but useful information.
When collapsed, the calendar SHALL show essential information to maintain context without taking excessive screen space.

#### Scenario: Collapsed calendar shows selected date
- **WHEN** the calendar is in collapsed state
- **THEN** the selected date SHALL be clearly visible
- **AND** the month and year SHALL be displayed
- **AND** visual indicators for days with tasks MAY be shown in condensed form
- **AND** the collapsed height SHALL be approximately 60-80dp to maximize task list space

#### Scenario: Collapsed calendar remains interactive
- **WHEN** the calendar is in collapsed state
- **THEN** users SHALL be able to tap to expand the calendar
- **AND** users SHALL be able to drag down to expand the calendar
- **AND** scroll-to-top gesture SHALL expand the calendar
- **AND** visual cues SHALL indicate the calendar can be expanded
