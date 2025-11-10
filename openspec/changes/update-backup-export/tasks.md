# Tasks: update-backup-export

## Implementation Checklist

### Setup & Dependencies
- [x] Add `file_picker: ^8.0.0` to `pubspec.yaml` dependencies
- [x] Run `flutter pub get` to install new dependency
- [x] Verify `file_picker` package works on test device

### Create BackupService
- [x] Create `lib/services/backup_service.dart`
- [x] Implement `BackupService` class with `DatabaseService` dependency injection
- [x] Add `createBackup(String destinationPath)` method - copy database to destination
- [x] Add `restoreBackup(String backupFilePath)` method - copy backup to database location
- [x] Add `validateBackupFile(String filePath)` method - validate SQLite file and schema
- [x] Add getter for database path from `DatabaseService`
- [x] Add proper error handling for all file operations
- [x] Add database close/reopen logic around file operations

### Update Settings Screen UI
- [x] Remove the "Export to CSV" `ListTile` from `lib/screens/settings_screen.dart`
- [x] Update "Backup Database" `ListTile` onTap to call backup flow
- [x] Update "Restore from Backup" `ListTile` onTap to call restore flow
- [x] Add loading state management (disable buttons during operations)
- [x] Add success/error SnackBar messages

### Implement Backup Flow
- [x] Create `_handleBackup()` method in `SettingsScreen`
- [x] Integrate `FilePicker.platform.getDirectoryPath()` to let user choose save location
- [x] Generate default filename with timestamp (e.g., `timetracker_backup_20251110_HHmmss.db`)
- [x] Handle user cancellation (null return) gracefully
- [x] Call `BackupService.createBackup()` with selected path
- [x] Show loading indicator during backup
- [x] Display success message with file path
- [x] Display error message if backup fails
- [x] Re-enable UI after operation completes

### Implement Restore Flow
- [x] Create `_handleRestore()` method in `SettingsScreen`
- [x] Check for running tasks using `TaskRepository.getRunningTasks()`
- [x] Show warning dialog if tasks are running (block restore)
- [x] Show confirmation dialog warning about data replacement
- [x] Handle user cancellation at confirmation dialog
- [x] Integrate `FilePicker.platform.pickFiles()` for file selection
- [x] Handle user cancellation at file picker (null return)
- [x] Call `BackupService.validateBackupFile()` on selected file
- [x] Display error if validation fails
- [x] Call `BackupService.restoreBackup()` with selected file
- [x] Show loading indicator during restore
- [x] Display success message after restore
- [x] Display error message if restore fails
- [x] Re-enable UI after operation completes

### Documentation
- [x] Add comments to `BackupService` explaining validation logic
- [x] Document file picker usage in code comments
- [x] Verify CSV export still works correctly in Reports screen

### Validation & Polish
- [x] Run `dart format` on all modified files
- [x] Run `flutter analyze` and fix any issues
- [x] Verify all requirements from spec are implemented
- [x] Perform manual testing on Android device
- [x] Verify error messages are user-friendly and helpful
- [x] Test backup with directory picker to various locations
- [x] Test restore with file picker from various locations
- [x] Test cancellation at each user interaction point
- [x] Test restore blocking when tasks are running

## Notes
- Database is closed before file operations to avoid locks
- File picker cancellation returns `null` - handled gracefully
- Backup filename format: `timetracker_backup_YYYYMMDD_HHmmss.db`
- Restore is an atomic operation - fails completely or succeeds completely
- CSV export removed from Settings, remains in Reports screen
- On Android/iOS: `getDirectoryPath()` for backup, `pickFiles()` with `FileType.any` for restore
- Backup allows user to choose any accessible directory (Downloads, Google Drive, etc.)
