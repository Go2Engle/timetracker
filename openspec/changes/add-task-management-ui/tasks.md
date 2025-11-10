# Implementation Tasks

## 1. Add Task Dialog
- [x] 1.1 Create AddTaskDialog widget with form
- [x] 1.2 Add title field with validation
- [x] 1.3 Add description field (optional, multi-line)
- [x] 1.4 Load and display categories in dropdown
- [x] 1.5 Load and display tags as FilterChips
- [x] 1.6 Add category creation button and dialog
- [x] 1.7 Implement color picker for categories (16 colors)
- [x] 1.8 Add tag creation button and dialog
- [x] 1.9 Submit handler to return task data
- [x] 1.10 Integrate dialog into main screen FAB

## 2. Task Creation Flow
- [x] 2.1 Update _createTestTask to show dialog
- [x] 2.2 Create task with user-provided data
- [x] 2.3 Associate selected tags with task
- [x] 2.4 Auto-start timer after task creation
- [x] 2.5 Refresh task list after creation

## 3. Task Detail Screen
- [x] 3.1 Create TaskDetailScreen widget
- [x] 3.2 Load task, category, and tags data
- [x] 3.3 Display task title as headline
- [x] 3.4 Show status badge with color coding
- [x] 3.5 Display description section
- [x] 3.6 Display category with color dot
- [x] 3.7 Display tags as chips
- [x] 3.8 Create time information card
- [x] 3.9 Format timestamps (relative and absolute)
- [x] 3.10 Add edit button in app bar
- [x] 3.11 Add delete button in app bar
- [x] 3.12 Implement delete confirmation dialog
- [x] 3.13 Stop timer before deletion if running
- [x] 3.14 Navigate back after deletion

## 4. Edit Task Dialog
- [x] 4.1 Create EditTaskDialog widget
- [x] 4.2 Pre-fill form with existing task data
- [x] 4.3 Load current category and tags
- [x] 4.4 Track original tag IDs for comparison
- [x] 4.5 Implement category creation during edit
- [x] 4.6 Implement tag creation during edit
- [x] 4.7 Update task in database
- [x] 4.8 Remove deselected tags
- [x] 4.9 Add newly selected tags
- [x] 4.10 Return success indicator
- [x] 4.11 Refresh detail screen after edit

## 5. Task Navigation
- [x] 5.1 Make _ActiveTaskCard clickable
- [x] 5.2 Make _TaskCard clickable
- [x] 5.3 Navigate to TaskDetailScreen on tap
- [x] 5.4 Add onTap callback to task cards
- [x] 5.5 Pass _loadTasks as refresh callback
- [x] 5.6 Call refresh callback after navigation
- [x] 5.7 Auto-refresh on delete
- [x] 5.8 Auto-refresh on edit

## 6. Repository Enhancements
- [x] 6.1 Add getTagsForTask method to TagRepository
- [x] 6.2 Implement SQL join query for task tags
- [x] 6.3 Test tag association queries

## 7. UI Polish
- [x] 7.1 Fix calendar view overflow (12 pixels)
- [x] 7.2 Fix calendar view overflow (2 pixels)
- [x] 7.3 Replace ListTile with custom Row layout
- [x] 7.4 Add proper constraints to trailing Column
- [x] 7.5 Update deprecated withOpacity calls
- [x] 7.6 Update deprecated value parameter in DropdownButtonFormField
- [x] 7.7 Fix color comparison in color picker
- [x] 7.8 Use materialTapTargetSize shrinkWrap for Chips

## 8. Testing
- [x] 8.1 Test task creation form validation
- [x] 8.2 Test category creation inline
- [x] 8.3 Test tag creation inline
- [x] 8.4 Test task detail navigation
- [x] 8.5 Test task editing
- [x] 8.6 Test task deletion
- [x] 8.7 Test auto-timer start on creation
- [x] 8.8 Test auto-refresh after navigation
- [x] 8.9 Test calendar overflow fixes
- [x] 8.10 Manual testing on Android device
