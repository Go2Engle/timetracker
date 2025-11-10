# Design: update-backup-export

## Technical Approach

### Architecture Overview
The backup/restore feature will be implemented as a new `BackupService` that coordinates between the `DatabaseService` and the system file picker. This keeps concerns separated:
- **DatabaseService**: Manages database connection and file location
- **BackupService**: Handles backup/restore logic, file copying, validation
- **SettingsScreen**: UI integration and user feedback

### Component Design

#### 1. BackupService
```dart
class BackupService {
  final DatabaseService _databaseService;
  
  Future<String> createBackup(String destinationPath);
  Future<void> restoreBackup(String backupFilePath);
  Future<bool> validateBackupFile(String filePath);
  String get databasePath;
}
```

**Responsibilities:**
- Copy database file to user-selected location for backup
- Copy user-selected backup file to database location for restore
- Validate backup file is a valid SQLite database
- Handle database closing/reopening during restore
- Provide appropriate error messages

#### 2. File Picker Integration
Use the `file_picker` package for cross-platform file selection:
- **Backup**: `FilePicker.platform.saveFile()` - lets user choose save location and name
- **Restore**: `FilePicker.platform.pickFiles()` - lets user select existing backup file

Platform behavior:
- **Android**: Native Android file picker (supports Google Drive, local storage, etc.)
- **iOS**: Native iOS file picker (supports iCloud, Files app locations)

#### 3. Settings Screen Updates
Remove the "Export to CSV" ListTile and update the existing backup/restore ListTiles to:
- Call `BackupService.createBackup()` with file picker destination
- Call `BackupService.restoreBackup()` with file picker selection
- Show loading indicators during operations
- Display success/error messages via SnackBar
- Confirm before restore (warn about data replacement)

### Data Flow

#### Backup Flow
1. User taps "Backup Database" in Settings
2. System file picker opens (saveFile mode)
3. User selects destination and filename
4. BackupService closes database connection
5. Database file copied to destination
6. Database connection reopened
7. Success message shown

#### Restore Flow
1. User taps "Restore from Backup" in Settings
2. Check if any tasks are running → warn user if so
3. Show confirmation dialog (data will be replaced)
4. System file picker opens (pickFiles mode)
5. User selects backup file
6. BackupService validates file is valid SQLite database
7. Database connection closed
8. Backup file copied to database location (overwrites existing)
9. Database connection reopened
10. Success message shown

### Error Handling

**Backup Errors:**
- User cancels file picker → no action, no error
- Cannot access database file → error message
- Cannot write to destination → error message (permission issue)
- File copy fails → error message

**Restore Errors:**
- User cancels file picker → no action, no error
- Invalid backup file → error message "Invalid backup file"
- Cannot read backup file → error message (permission issue)
- Database validation fails → error message "Corrupted backup file"
- File copy fails → error message, existing database remains intact

### Security & Data Integrity

1. **Validation**: Before restore, open backup file as SQLite database and verify schema
2. **Atomic Operations**: Use file copy operations that fail completely or succeed completely
3. **Backup Before Restore**: Optionally create automatic backup before restore (future enhancement)
4. **No Encryption**: Database stored unencrypted (matches current behavior)

### Platform Considerations

**Android:**
- Database stored in app's documents directory
- File picker provides access to external storage, Google Drive, etc.
- No special permissions needed with `file_picker` package

**iOS:**
- Database stored in app's documents directory
- File picker provides access to Files app, iCloud Drive, etc.
- No special permissions needed with `file_picker` package

### Dependencies

**New Dependency:**
```yaml
dependencies:
  file_picker: ^8.0.0
```

**Existing Dependencies Used:**
- `sqflite` - for database validation
- `path_provider` - for database path access
- `dart:io` - for file operations

### Testing Strategy

**Unit Tests:**
- `BackupService.createBackup()` with mock file system
- `BackupService.restoreBackup()` with valid/invalid files
- `BackupService.validateBackupFile()` with various file types

**Integration Tests:**
- Full backup → restore workflow
- Restore with active tasks (should warn/block)
- Error scenarios (invalid files, permission errors)

**Manual Testing:**
- Backup to Google Drive on Android
- Restore from Google Drive
- Backup to iCloud on iOS (if available)
- Cancel file picker operations
- Attempt restore with corrupted file

### Implementation Notes

1. Database must be closed before file copy operations to avoid locks
2. File picker cancellation returns `null` - handle gracefully
3. Use `.db` extension for backup files by default
4. Consider adding timestamp to default backup filename (e.g., `timetracker_backup_20251110.db`)
5. Settings screen backup/restore operations should disable buttons during operation to prevent concurrent actions
