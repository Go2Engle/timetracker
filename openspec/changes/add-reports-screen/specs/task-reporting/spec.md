# Task Reporting Specification

## ADDED Requirements

### Requirement: Filter tasks by tags and categories
The system SHALL allow users to filter their task history by selecting one or more tags and/or a single category to view a subset of all tasks.

#### Scenario: Filter by single tag
**Given** the user has tasks with various tags  
**And** the user is on the Reports screen  
**When** the user selects a single tag (e.g., "Meeting")  
**Then** only tasks tagged with "Meeting" are displayed  
**And** the total elapsed time reflects only the filtered tasks

#### Scenario: Filter by multiple tags (AND logic)
**Given** the user has tasks with multiple tags  
**And** the user is on the Reports screen  
**When** the user selects multiple tags (e.g., "Work" and "Client")  
**Then** only tasks tagged with BOTH "Work" AND "Client" are displayed  
**And** tasks with only one of the selected tags are excluded

#### Scenario: Filter by category
**Given** the user has tasks assigned to different categories  
**And** the user is on the Reports screen  
**When** the user selects a category (e.g., "Development")  
**Then** only tasks assigned to the "Development" category are displayed  
**And** tasks without a category or with a different category are excluded

#### Scenario: Filter by tags and category combined
**Given** the user has tasks with tags and categories  
**And** the user is on the Reports screen  
**When** the user selects tags "Meeting" and category "Work"  
**Then** only tasks that have the "Meeting" tag AND belong to the "Work" category are displayed  
**And** the filters are applied with AND logic (both conditions must be met)

#### Scenario: Clear filters
**Given** the user has applied one or more filters  
**And** filtered results are displayed  
**When** the user removes all selected tags and category  
**Then** all tasks are displayed  
**And** the total elapsed time reflects all tasks

#### Scenario: No tasks match filter criteria
**Given** the user has tasks in the database  
**And** the user is on the Reports screen  
**When** the user selects filter criteria that no tasks match  
**Then** an empty state message is displayed (e.g., "No tasks match the selected filters")  
**And** the total elapsed time shows 00:00:00

---

### Requirement: Display aggregated time totals for filtered tasks
The system SHALL display the total hours, minutes, and seconds for all tasks that match the currently applied filters.

#### Scenario: Show total time with no filters
**Given** the user has multiple completed tasks  
**And** no filters are applied  
**When** the user views the Reports screen  
**Then** the total elapsed time is the sum of all tasks' `elapsedSeconds`  
**And** the time is displayed in HH:MM:SS format

#### Scenario: Show total time with filters applied
**Given** the user has applied tag and/or category filters  
**And** 3 tasks match the filters with elapsed times of 1800s, 3600s, and 7200s  
**When** the results are displayed  
**Then** the total elapsed time shows 03:30:00 (12600 seconds total)

#### Scenario: Total time updates when filters change
**Given** the user has filters applied with a total time of 05:00:00  
**When** the user adds another tag to the filter  
**Then** the task list updates to show only tasks matching all filters  
**And** the total elapsed time recalculates based on the new filtered set

#### Scenario: Total time format for long durations
**Given** filtered tasks have a combined total of 125,400 seconds (34 hours, 50 minutes)  
**When** the total time is displayed  
**Then** it shows 34:50:00 (hours are not limited to 24-hour format)

---

### Requirement: Export filtered task data to CSV file
The system SHALL enable users to export the currently filtered task list along with totals to a CSV file for external analysis.

#### Scenario: Export with filters applied
**Given** the user has applied filters showing 5 tasks  
**And** the user is on the Reports screen  
**When** the user taps the "Export to CSV" button  
**Then** a CSV file is generated containing the 5 filtered tasks  
**And** each row includes: title, description, start time, end time, elapsed time, status, category name, and tag names  
**And** a summary row at the end shows the total elapsed time  
**And** the file is saved to the device's Downloads or Documents folder  
**And** a success message displays the file path/name

#### Scenario: Export all tasks (no filters)
**Given** no filters are applied  
**And** the Reports screen shows all tasks  
**When** the user taps the "Export to CSV" button  
**Then** a CSV file is generated containing all tasks in the database  
**And** the summary row shows the total time across all tasks

#### Scenario: Export file naming convention
**Given** the user exports a report on November 10, 2025 at 14:30:45  
**When** the CSV file is created  
**Then** the filename is `timetracker_report_20251110_143045.csv`  
**And** the timestamp reflects the exact moment of export

#### Scenario: CSV file format
**Given** a task with title "Team Meeting", description "Weekly sync", tags "Work,Meeting", category "Management", elapsed time 3661 seconds (01:01:01)  
**When** exported to CSV  
**Then** the row format is: `Team Meeting,Weekly sync,2025-11-10 09:00:00,2025-11-10 10:01:01,01:01:01,stopped,Management,"Work,Meeting"`  
**And** the header row is: `Title,Description,Start Time,End Time,Elapsed Time (HH:MM:SS),Status,Category,Tags`

#### Scenario: CSV handles special characters
**Given** a task with title containing a comma "Project A, Phase 1" and description with quotes  
**When** exported to CSV  
**Then** fields with commas are wrapped in double quotes  
**And** embedded quotes are escaped per CSV RFC 4180 standard

#### Scenario: Export feedback on success
**Given** the user exports a report  
**When** the file is successfully created  
**Then** a SnackBar or Toast message displays "Report exported to [path/filename]"  
**And** the message dismisses after 5 seconds or when tapped

#### Scenario: Export error handling
**Given** the user attempts to export a report  
**When** file creation fails (e.g., insufficient storage, permissions denied)  
**Then** an error message displays "Failed to export report: [reason]"  
**And** no partial file is created

#### Scenario: Export empty results
**Given** filters are applied with no matching tasks  
**When** the user taps "Export to CSV"  
**Then** a CSV file is created with headers only  
**And** the total row shows 00:00:00  
**And** a success message confirms the export

---

### Requirement: Reports screen navigation
The system SHALL provide access to the Reports screen from the bottom navigation bar.

#### Scenario: Navigate to Reports screen
**Given** the user is on the Tasks or Calendar screen  
**When** the user taps the "Reports" tab in the bottom navigation bar  
**Then** the Reports screen is displayed  
**And** the "Reports" tab is highlighted as active

#### Scenario: Reports tab position
**Given** the bottom navigation bar has Tasks, Calendar, and Reports tabs  
**Then** the Reports tab is positioned as the third (rightmost) tab  
**And** uses an appropriate icon (e.g., chart, analytics, or report icon)

#### Scenario: Preserve navigation state
**Given** the user has applied filters on the Reports screen  
**When** the user navigates to another tab and returns to Reports  
**Then** the previously applied filters are still active  
**And** the filtered results are still displayed

---

### Requirement: Filter UI presentation
The filter selection interface SHALL allow users to easily select and visualize their active filters.

#### Scenario: Display available tags for filtering
**Given** the database contains tags "Work", "Personal", "Meeting", "Exercise"  
**And** the user is on the Reports screen  
**When** the tag filter section is displayed  
**Then** all available tags are shown as selectable chips or checkboxes  
**And** tags are sorted alphabetically

#### Scenario: Display available categories for filtering
**Given** the database contains categories "Development", "Design", "Management"  
**And** the user is on the Reports screen  
**When** the category filter section is displayed  
**Then** all available categories are shown as a dropdown or radio group  
**And** an option to clear the category selection exists

#### Scenario: Visual indication of active filters
**Given** the user has selected tags "Work" and "Meeting"  
**And** selected category "Development"  
**When** viewing the filter section  
**Then** selected tags are visually highlighted (e.g., filled chips vs outlined)  
**And** the selected category is visually indicated as active  
**And** a count or badge shows "2 tags, 1 category" or similar summary

#### Scenario: No tags or categories exist
**Given** the database has no tags or categories defined  
**When** the user views the Reports screen  
**Then** a message indicates "No tags or categories available to filter"  
**And** all tasks are displayed by default  
**And** the total time is still calculated

---

### Requirement: Filtered task list display
The filtered task results SHALL be presented in a clear, scannable format showing key task details.

#### Scenario: Display filtered task list
**Given** filters are applied resulting in 10 matching tasks  
**When** the results are displayed  
**Then** each task shows: title, category, tags, elapsed time, and start date  
**And** tasks are sorted by start time (most recent first) by default

#### Scenario: Task list scrolling
**Given** the filtered results contain more tasks than fit on screen  
**When** the user scrolls the task list  
**Then** the filter section and total time remain fixed at the top  
**And** only the task list scrolls

#### Scenario: Tap task to view details
**Given** a filtered task list is displayed  
**When** the user taps on a task  
**Then** the task detail screen opens (existing functionality)  
**And** the user can navigate back to the Reports screen with filters preserved
