# Specification: Task Grouping

## ADDED Requirements

### Requirement: Task List Screen Grouping
The task list screen SHALL provide visual grouping of tasks by category/project.

**Rationale**: Users tracking time for multiple customers need to quickly see which tasks belong to which customer without scanning individual task labels.

#### Scenario: View tasks grouped by category
**Given** the user has tasks assigned to different categories (e.g., "Customer A", "Customer B", "Personal")
**When** the user views the task list screen
**Then** tasks are visually grouped under category section headers
**And** each group shows the category name and color indicator
**And** tasks without a category appear in an "Uncategorized" section
**And** each section displays the count of tasks in that category

#### Scenario: Toggle between grouped and ungrouped views
**Given** the user is viewing the task list
**When** the user taps a "Group by Category" toggle or menu option
**Then** the view switches between grouped (by category) and ungrouped (flat list) layouts
**And** the user's preference is persisted across app sessions

### Requirement: Category Visual Indicators
All screens SHALL display category information with consistent visual indicators.

**Rationale**: Color coding helps users quickly identify task categories across different views without reading text labels.

#### Scenario: Display category color badge on task cards
**Given** a task is assigned to a category
**When** the task is displayed in any list or card view
**Then** a colored badge or indicator matching the category's color is shown
**And** the badge is positioned consistently across all screens
**And** hovering/tapping the badge shows the full category name (if truncated)

#### Scenario: Show category in task details
**Given** the user views task details
**When** the task has an assigned category
**Then** the category name is displayed with its color indicator
**And** tapping the category navigates to a filtered view of all tasks in that category

### Requirement: Calendar Category Filtering
The calendar screen SHALL support filtering tasks by category.

**Rationale**: Users need to review historical tasks for specific customers/projects to generate invoices or reports.

#### Scenario: Filter calendar tasks by category
**Given** the user has selected a date in the calendar
**When** the user selects a category from a filter dropdown
**Then** only tasks belonging to that category are displayed for the selected date
**And** the filter persists when navigating to different dates
**And** the user can clear the filter to see all tasks again

#### Scenario: Visual indication of filtered state
**Given** the user has applied a category filter
**When** viewing the calendar
**Then** a visual indicator shows the active filter (e.g., chip/badge with category name and color)
**And** the indicator includes a clear/remove action
**And** tapping the indicator allows changing the selected category

### Requirement: Reports Category Grouping
The reports screen SHALL display time totals grouped by category.

**Rationale**: Users need to see aggregated time spent per customer/project for billing or productivity analysis.

#### Scenario: View time totals by category
**Given** the user has tasks with various categories
**When** the user views the reports screen
**Then** a summary section displays total time per category
**And** each category shows its name, color, total duration, and task count
**And** categories are sorted by total time (descending) by default
**And** tapping a category filters the detailed task list to show only that category's tasks

#### Scenario: Combine category grouping with existing filters
**Given** the user has applied tag filters or date range filters
**When** viewing category-grouped totals in reports
**Then** the grouping reflects only the filtered tasks
**And** empty categories (with no matching tasks) are hidden
**And** the "Uncategorized" group appears if any filtered tasks lack a category

### Requirement: Improved Category Labeling
UI labels for categories SHALL use terminology that clearly indicates usage for customers, projects, or clients.

**Rationale**: The generic term "Category" doesn't convey that it can be used for customer/project tracking.

#### Scenario: Clear labels in task creation/editing
**Given** the user is creating or editing a task
**When** viewing the category selection field
**Then** the field label reads "Project/Client" or "Category"
**And** placeholder text suggests example values (e.g., "Select customer or project")

#### Scenario: Consistent terminology across screens
**Given** the user navigates between different screens
**When** category-related UI elements are displayed
**Then** labels consistently use "Project/Client" or the configured terminology
**And** help text or tooltips explain that categories can represent customers, clients, or projects

## MODIFIED Requirements

### Requirement: Task List Display (Enhancement)
The existing task list display SHALL be enhanced to optionally group tasks by category while maintaining backward compatibility with the ungrouped view.

**Rationale**: Extends the current task list functionality without breaking existing behavior.

#### Scenario: Maintain existing ungrouped view as default
**Given** a user opens the app for the first time or hasn't set a grouping preference
**When** viewing the task list
**Then** tasks are displayed in the traditional ungrouped format (by start time)
**And** all existing sorting and filtering behavior remains unchanged

### Requirement: Reports Filtering (Enhancement)
The existing reports category filter SHALL be enhanced with quick-select category chips and grouped time displays.

**Rationale**: Current reports have category filtering, but it needs better visual presentation of results.

#### Scenario: Enhanced category filter presentation
**Given** the user is on the reports screen
**When** categories are available
**Then** the category filter shows a dropdown (existing) plus quick-select chips showing top categories by time
**And** selecting a chip immediately filters to that category
**And** the filtered results show category-specific metrics prominently
