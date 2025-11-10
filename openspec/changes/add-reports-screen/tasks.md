# Implementation Tasks

## Task Checklist

- [x] **Add repository filtering method**
  - Add `getTasksByFilters(List<int>? tagIds, int? categoryId)` method to `TaskRepository`
  - Implement SQL query with JOIN on `task_tags` table for tag filtering
  - Support AND logic for multiple tags (task must have ALL selected tags)
  - Add WHERE clause for `categoryId` filtering
  - Test with various tag/category combinations
  - Validate: Write unit test covering all filter scenarios

- [x] **Create ReportExportService**
  - Create `lib/services/report_export_service.dart`
  - Implement `exportToCSV(List<Task> tasks, int totalSeconds)` method
  - Generate CSV with headers: Title, Description, Start Time, End Time, Elapsed Time, Status, Category, Tags
  - Format dates as `YYYY-MM-DD HH:MM:SS`
  - Format elapsed time as `HH:MM:SS`
  - Handle CSV escaping for commas and quotes (RFC 4180)
  - Add summary row with total time
  - Use `path_provider` to get appropriate directory (Downloads on Android, Documents on iOS)
  - Generate filename with timestamp: `timetracker_report_YYYYMMDD_HHMMSS.csv`
  - Return file path or throw exception on error
  - Validate: Test CSV generation with sample data and verify format

- [x] **Create Reports screen UI**
  - Create `lib/screens/reports_screen.dart`
  - Create StatefulWidget with state for selected tags, category, and filtered tasks
  - Add app bar with title "Reports"
  - Implement filter section UI:
    - Multi-select tag chips (wrap layout)
    - Single-select category dropdown or radio buttons
    - Clear filters button
  - Display total elapsed time prominently at top (HH:MM:SS format)
  - Display filtered task list with: title, category badge, tag chips, elapsed time, start date
  - Support scrolling with fixed header (total time and filters)
  - Add empty state message for no results
  - Make task items tappable to navigate to TaskDetailScreen
  - Validate: Manual testing of filter UI interactions

- [x] **Implement filtering logic in Reports screen**
  - Create methods to fetch all tags and categories on screen init
  - Implement `_applyFilters()` method to query tasks using `getTasksByFilters()`
  - Calculate total elapsed seconds from filtered tasks
  - Update UI when filters change (tag selected/deselected, category changed)
  - Handle empty filter state (show all tasks)
  - Show loading indicator during data fetch
  - Validate: Test all filter combinations and verify correct task lists

- [x] **Add CSV export functionality to Reports screen**
  - Add FloatingActionButton with export icon
  - Implement `_exportReport()` method calling `ReportExportService`
  - Include current filtered tasks and total time
  - Show SnackBar with success message including file path
  - Show SnackBar with error message on failure
  - Handle permissions (request if needed on Android)
  - Test on both Android and iOS if possible
  - Validate: Export and open CSV file in spreadsheet app

- [x] **Add Reports tab to bottom navigation**
  - Update `lib/main.dart` HomeScreen to add third navigation destination
  - Add "Reports" NavigationDestination with appropriate icon (e.g., `Icons.assessment` or `Icons.bar_chart`)
  - Add ReportsScreen to `_screens` list
  - Ensure proper tab highlighting and navigation state
  - Validate: Navigate between all three tabs and verify state preservation

- [x] **Add share/permissions dependencies if needed**
  - Check if `path_provider` is sufficient for file access
  - If needed for better UX, add `share_plus` package for sharing CSV
  - If needed for Android scoped storage, add permissions in `android/app/src/main/AndroidManifest.xml`
  - Update `pubspec.yaml` with any new dependencies
  - Run `flutter pub get`
  - Validate: Check permissions work on Android 10+ devices

- [x] **Test edge cases and error scenarios**
  - Test with no tasks in database
  - Test with tasks having no tags or category
  - Test with very long elapsed times (100+ hours)
  - Test CSV export with special characters in task titles/descriptions
  - Test filter persistence when navigating away and back
  - Test with many tags (50+) for UI layout
  - Test with insufficient storage for export
  - Validate: Document any issues found and fix before completion

- [x] **Update documentation**
  - Update README.md with Reports feature description
  - Add usage instructions for filtering and CSV export
  - Document CSV file format and location
  - Validate: Review documentation for clarity

## Dependencies Between Tasks
- Tasks 1-2 can be completed independently first (repository and export service)
- Tasks 3-4 depend on Task 1 (repository filtering method)
- Task 5 depends on Task 2 (export service) and Task 4 (filtering logic)
- Task 6 depends on Task 3 (Reports screen exists)
- Task 7 can be done anytime before final testing
- Task 8 depends on all previous tasks being complete
- Task 9 is final documentation step

## Validation Strategy
Each task includes a "Validate" step. All validations must pass before marking the change as complete:
- Unit tests for repository and service methods
- Manual UI testing on physical Android device
- CSV file verification in external spreadsheet app
- Edge case testing documented
- Code review of all new files

## Estimated Complexity
- Repository method: Simple (existing patterns)
- Export service: Medium (CSV formatting, file handling)
- Reports screen UI: Medium (new screen, filter UI)
- Filter logic: Simple (straightforward query integration)
- CSV export integration: Simple (service already built)
- Navigation update: Simple (existing pattern)
- Dependencies/permissions: Simple (likely no new deps needed)
- Testing: Medium (many edge cases)
- Documentation: Simple

Total estimated effort: 8-12 hours for full implementation and testing.
