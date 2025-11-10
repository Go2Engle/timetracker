# Reports Screen Design

## Architecture Decisions

### UI Structure
The Reports screen will follow the existing navigation pattern with three main sections:
1. **Filter Panel**: Top section with chips/selectors for tags and category
2. **Results Display**: Middle section showing filtered tasks and total time
3. **Export Button**: Bottom floating action button for CSV export

### Data Flow
```
ReportsScreen
  ├─> TaskRepository (filtering logic)
  ├─> TagRepository (available tags)
  ├─> CategoryRepository (available categories)
  └─> ReportExportService (CSV generation)
```

### Filtering Logic
- **Tags**: Multi-select (AND logic - task must have ALL selected tags)
- **Category**: Single select (task's categoryId must match)
- **Combination**: Tags AND category filters applied together
- **Empty filters**: Show all tasks when no filters applied

### Data Aggregation
Time totals calculated by:
1. Query filtered tasks from repository
2. Sum `elapsedSeconds` field across all matching tasks
3. Convert total seconds to hours:minutes:seconds format
4. Display prominently at top of results

### CSV Export Implementation

**File Format:**
```csv
Title,Description,Start Time,End Time,Elapsed Time (HH:MM:SS),Status,Category,Tags
Task 1,Description,2025-11-10 09:00:00,2025-11-10 10:30:00,01:30:00,stopped,Work,"tag1,tag2"
...
TOTAL,,,,,,,05:45:30
```

**Export Location:**
- Android: Downloads folder via `getExternalStorageDirectory()` or shared storage
- iOS: Files app directory via `getApplicationDocumentsDirectory()`
- Filename: `timetracker_report_YYYYMMDD_HHMMSS.csv`

**Technical Approach:**
- Create `ReportExportService` in `/lib/services/`
- Use `path_provider` package (already in dependencies)
- For Android API 29+, use scoped storage with `MediaStore` API or `share` package
- Provide user feedback with SnackBar showing export path

### Repository Enhancements
Need to add filtering method to `TaskRepository`:

```dart
Future<List<Task>> getTasksByFilters({
  List<int>? tagIds,
  int? categoryId,
}) async {
  // SQL query with JOIN on task_tags table for tag filtering
  // WHERE clause for categoryId
  // Returns all tasks matching ALL criteria
}
```

### State Management
Use StatefulWidget with setState for:
- Selected tags (Set<int>)
- Selected category (int?)
- Filtered tasks (List<Task>)
- Total elapsed seconds (int)

Alternatively, if app already uses Provider/Riverpod, create a `ReportFilterProvider`.

### Performance Considerations
- Query optimization: Use indexed columns (categoryId, taskId in task_tags)
- Lazy loading: Only fetch tasks when filters change
- CSV generation: Perform in isolate if dataset is large (>1000 tasks)

## Alternative Approaches Considered

### Date Range Filtering
**Considered:** Adding date range picker for filtering
**Decision:** Defer to future iteration - Calendar screen already provides date-based viewing
**Rationale:** Keep initial implementation simple; users can manually filter exports by date in spreadsheet

### OR vs AND Logic for Tags
**Considered:** Allow user to choose AND/OR logic for multiple tags
**Decision:** Use AND logic only
**Rationale:** AND logic is more common use case ("show me work tasks tagged with both 'meeting' and 'client'")

### Export Formats
**Considered:** JSON, Excel, PDF
**Decision:** CSV only
**Rationale:** CSV is universal, simple to generate, and sufficient for most analysis needs

## Open Questions
None at this time.
