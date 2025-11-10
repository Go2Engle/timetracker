# Design: Settings Screen Architecture

## Overview
This document captures architectural decisions for the settings screen and category/tag management features.

## UI Structure

### Settings Screen Layout
```
SettingsScreen (Scaffold)
├── AppBar
│   └── Title: "Settings"
├── Body (ListView)
│   ├── CategoryManagementSection (ExpansionTile)
│   │   ├── Header: "Categories (X)" 
│   │   ├── Add button
│   │   └── Category list
│   ├── TagManagementSection (ExpansionTile)
│   │   ├── Header: "Tags (X)"
│   │   ├── Add button
│   │   └── Tag list
│   └── [Future sections: Backup, Export, Theme, etc.]
```

### Entry Point
- Settings icon (⚙️) in app bar of main HomeScreen
- **NOT** in bottom navigation (reserve for primary tasks/calendar/timer)
- Material page route transition

## Data Flow

### Loading Categories/Tags with Usage Counts
```
SettingsScreen
  └─> CategoryRepository.getAllCategoriesWithCount()
      └─> SQL: SELECT c.*, COUNT(t.id) as taskCount
              FROM categories c
              LEFT JOIN tasks t ON t.categoryId = c.id
              GROUP BY c.id
              ORDER BY c.name
```

### Deletion Validation Flow
```
User taps delete
  └─> Check usage count (already loaded)
      ├─> If count > 0: Show error dialog
      └─> If count == 0:
          ├─> Show confirmation dialog
          └─> On confirm:
              ├─> Call repository.delete()
              └─> Refresh list
```

## Repository Methods

### CategoryRepository Additions
```dart
// Get count of tasks using this category
Future<int> getCategoryUsageCount(int categoryId) async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM tasks WHERE categoryId = ?',
    [categoryId],
  );
  return Sqflite.firstIntValue(result) ?? 0;
}

// Get all categories with usage counts
Future<List<CategoryWithCount>> getAllCategoriesWithCount() async {
  final db = await database;
  final maps = await db.rawQuery('''
    SELECT c.*, COUNT(t.id) as taskCount
    FROM categories c
    LEFT JOIN tasks t ON t.categoryId = c.id
    GROUP BY c.id
    ORDER BY c.name
  ''');
  return maps.map((map) => CategoryWithCount.fromMap(map)).toList();
}
```

### TagRepository Additions
```dart
// Get count of tasks using this tag
Future<int> getTagUsageCount(int tagId) async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM task_tags WHERE tagId = ?',
    [tagId],
  );
  return Sqflite.firstIntValue(result) ?? 0;
}

// Get all tags with usage counts
Future<List<TagWithCount>> getAllTagsWithCount() async {
  final db = await database;
  final maps = await db.rawQuery('''
    SELECT t.*, COUNT(tt.taskId) as taskCount
    FROM tags t
    LEFT JOIN task_tags tt ON tt.tagId = t.id
    GROUP BY t.id
    ORDER BY t.name
  ''');
  return maps.map((map) => TagWithCount.fromMap(map)).toList();
}
```

### New Model Classes
```dart
class CategoryWithCount {
  final Category category;
  final int taskCount;
  
  CategoryWithCount({
    required this.category,
    required this.taskCount,
  });
}

class TagWithCount {
  final Tag tag;
  final int taskCount;
  
  TagWithCount({
    required this.tag,
    required this.taskCount,
  });
}
```

## UI Components

### Category List Tile Design
```
┌─────────────────────────────────────────┐
│ ● Blue  Work (5 tasks)          ✏️  🗑️  │ <- Delete disabled if count > 0
└─────────────────────────────────────────┘
```

### Tag List Tile Design
```
┌─────────────────────────────────────────┐
│ #urgent (3 tasks)               ✏️  🗑️  │ <- Delete disabled if count > 0
└─────────────────────────────────────────┘
```

### Dialog States

**Add Category Dialog:**
- TextField: "Category name"
- ColorPicker: 4x4 grid of 16 colors (reuse from add_task_dialog)
- Actions: Cancel, Create

**Edit Category Dialog:**
- TextField: Pre-filled with current name
- ColorPicker: Pre-selected with current color
- Actions: Cancel, Save

**Confirmation Dialog:**
- Title: "Delete Category?"
- Body: "This action cannot be undone."
- Actions: Cancel, Delete (red destructive button)

**Error Dialog:**
- Title: "Cannot Delete"
- Body: "This category is used by X tasks. Remove it from those tasks first."
- Action: OK

## State Management

### Screen State
Each management section maintains its own state:
- `List<CategoryWithCount> _categories`
- `List<TagWithCount> _tags`
- `bool _isLoading`

### Refresh Strategy
- Load on screen init
- Reload after create/update/delete
- Use `setState()` to trigger rebuild

No streams needed - user-initiated actions only.

## Error Handling

### Database Errors
- Catch and show SnackBar with error message
- Log to console for debugging
- Don't crash - graceful degradation

### Concurrent Modifications
- If deletion fails (item in use despite count check), show error
- Edge case: Task created between count check and deletion
- Solution: Database constraints prevent orphaning

### Network Errors
- N/A - fully local app (no network calls)

## Accessibility

- All buttons have semantic labels
- Color is not the only indicator (category names shown)
- Dialogs are keyboard navigable
- Error messages are screen-reader friendly

## Performance Considerations

### Query Optimization
- LEFT JOIN with GROUP BY is efficient for small datasets
- Add index on tasks.categoryId if performance degrades (future)
- Add index on task_tags.tagId if performance degrades (future)

### Expected Scale
- Categories: ~5-20 typical
- Tags: ~10-50 typical
- Tasks: ~100-1000 typical

No pagination needed at this scale.

## Future Extensions

### Planned Settings Sections
1. **Backup & Restore**
   - Export database to JSON
   - Import from JSON
   - Auto-backup schedule

2. **Export Options**
   - CSV export of tasks
   - Date range filtering
   - Include/exclude tags/categories

3. **Theme Settings**
   - Light/dark mode toggle
   - Accent color picker
   - Font size adjustment

4. **Notification Preferences**
   - Enable/disable notifications
   - Notification sound
   - Vibration settings

5. **Data Sync** (if cloud added later)
   - Account management
   - Sync frequency
   - Conflict resolution strategy

## Alternatives Considered

### Alternative 1: Dedicated Category/Tag Screens
- Pro: More screen real estate
- Con: Deeper navigation hierarchy
- **Decision:** Rejected - ExpansionTiles keep related settings together

### Alternative 2: Allow Cascade Delete
- Pro: Easier cleanup
- Con: Risk of accidental data loss
- **Decision:** Rejected - Safety first, user must manually remove associations

### Alternative 3: Settings in Bottom Navigation
- Pro: More prominent
- Con: Takes space from core features (tasks/calendar/timers)
- **Decision:** Rejected - Settings is secondary, app bar placement is sufficient

## Open Questions
None - all decisions finalized in proposal phase.
