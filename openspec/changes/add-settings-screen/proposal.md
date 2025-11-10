# Change: Add Settings Screen with Category and Tag Management

## Status
**PROPOSED**

## Why
Users need a centralized place to manage their categories and tags. Currently, categories and tags can only be created inline during task creation/editing, but there's no way to view, edit, or delete them. Additionally, we want to create a settings structure that can be extended in the future for features like backup, export/import, and other configuration options.

**Pain Points:**
- No way to see all categories and tags at once
- Cannot delete unused categories or tags
- No place for future configuration options (backup, export/import, themes)
- Orphaned categories/tags accumulate over time

## What Changes
- Add a Settings screen accessible from navigation
- Implement category management section with list, add, edit, and delete
- Implement tag management section with list, add, edit, and delete
- Add usage count display to show which categories/tags are in use
- Prevent deletion of categories/tags that are currently applied to tasks
- Create extensible settings structure for future configuration options
- Add repository methods to count task usage for categories and tags

**Scope:**
- ✅ Settings screen UI with sections
- ✅ Category CRUD operations
- ✅ Tag CRUD operations
- ✅ Usage validation before deletion
- ✅ Material 3 design patterns
- ❌ Backup/export features (future work)
- ❌ Theme settings (future work)
- ❌ Account/sync settings (future work)

## Impact
- Affected specs: **settings-management** (new capability)
- Affected code:
  - New: `lib/screens/settings_screen.dart`
  - New: `lib/widgets/category_management_section.dart`
  - New: `lib/widgets/tag_management_section.dart`
  - New: `lib/widgets/edit_category_dialog.dart`
  - New: `lib/widgets/edit_tag_dialog.dart`
  - Modified: `lib/repositories/category_repository.dart` (add usage count methods)
  - Modified: `lib/repositories/tag_repository.dart` (add usage count methods)
  - Modified: `lib/main.dart` (add settings navigation)
- Dependencies: Existing task-storage, category, and tag infrastructure
- No breaking changes
- Foundation for future settings (backup, export, themes)

## Technical Decisions

### Settings Screen Architecture
- Single screen with expandable sections (categories, tags, future options)
- Material 3 ExpansionTile or similar for section organization
- Floating action button for adding new items in each section
- Settings icon in app bar of main screen

### Usage Validation Strategy
- Query database for task count before allowing deletion
- Show error dialog if category/tag is in use
- Display usage count in the list (e.g., "Work (5 tasks)")
- Allow editing name/color even if in use

### Edit vs Delete
- **Edit:** Always allowed - updates name or color
- **Delete:** Only allowed if usage count is zero
- Color changes propagate to UI immediately (no migration needed)

### Navigation Pattern
- Settings accessible from main screen app bar
- Material page route to SettingsScreen
- Each management section self-contained

## Questions & Decisions

**Q: Should we allow deletion of categories/tags with cascade delete of task associations?**
A: No. We prevent deletion if in use. Users must manually remove from tasks first. This prevents accidental data loss.

**Q: Should we allow bulk operations (delete all unused)?**
A: Not in MVP. Can be added later if users request it.

**Q: Should categories/tags be editable (rename, recolor)?**
A: Yes. Name and color editing is allowed even if in use. Changes apply to all tasks using them.

**Q: How do we handle the settings icon placement?**
A: Add to app bar of HomeScreen (main tasks screen), not in bottom navigation.

## Migration
No database schema changes required. Existing delete methods in repositories already handle cascading properly, we just need to add usage count queries.

## Rollback Plan
All changes are additive:
1. Remove settings icon from app bar
2. Remove settings screen and management widgets
3. Remove usage count methods from repositories
4. No data migration needed

## Future Extensions
This change sets up infrastructure for:
- Database backup/restore
- CSV export/import
- Theme customization
- Notification preferences
- Data sync settings (if cloud sync is added later)
