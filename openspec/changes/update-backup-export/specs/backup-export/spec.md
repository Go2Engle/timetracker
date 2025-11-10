# Capability: backup-export

Database backup and restore functionality for the time tracking application.

## ADDED Requirements

### Requirement: Users can create database backups
**Priority**: High  
**Type**: Functional

The application SHALL allow users to create a complete backup of their time tracking database to a location of their choice using the system file picker.

#### Scenario: User creates backup via Settings
**Given** the user is on the Settings screen  
**When** they tap "Backup Database"  
**Then** the system file picker opens in save mode  
**And** the default filename includes "timetracker_backup" with current date (e.g., "timetracker_backup_20251110.db")  
**And** the user can select any available storage location (Google Drive, iCloud, local storage)  
**When** the user confirms the save location  
**Then** the database file is copied to the selected location  
**And** a success message is displayed  
**And** the file path is shown in the success message

#### Scenario: User cancels backup operation
**Given** the user is on the Settings screen  
**When** they tap "Backup Database"  
**And** the file picker opens  
**When** the user cancels or backs out of the file picker  
**Then** no backup is created  
**And** no error message is shown  
**And** the user returns to the Settings screen

#### Scenario: Backup fails due to write error
**Given** the user is on the Settings screen  
**When** they tap "Backup Database"  
**And** select a destination where write permissions are denied  
**Then** an error message is displayed: "Failed to create backup: [error details]"  
**And** no partial backup file is left at the destination

---

### Requirement: Users can restore from database backups
**Priority**: High  
**Type**: Functional

The application SHALL allow users to restore their time tracking database from a previously created backup file using the system file picker.

#### Scenario: User restores from backup successfully
**Given** the user is on the Settings screen  
**And** there are no tasks currently running  
**When** they tap "Restore from Backup"  
**Then** a confirmation dialog appears warning "This will replace all current data. Continue?"  
**When** the user confirms  
**Then** the system file picker opens in file selection mode  
**When** the user selects a valid backup file  
**Then** the backup file is validated as a SQLite database  
**And** the current database is replaced with the backup  
**And** a success message is displayed  
**And** the app's data reflects the restored state

#### Scenario: User restores with active tasks running
**Given** the user is on the Settings screen  
**And** one or more tasks are currently running  
**When** they tap "Restore from Backup"  
**Then** a warning dialog appears: "Active tasks are running. Please stop all tasks before restoring from backup."  
**And** the restore operation is blocked  
**And** the user can tap "OK" to dismiss the dialog

#### Scenario: User cancels restore operation
**Given** the user is on the Settings screen  
**When** they tap "Restore from Backup"  
**And** the confirmation dialog appears  
**When** the user taps "Cancel"  
**Then** no restore occurs  
**And** the current database remains unchanged  

**Or when** the user confirms but cancels the file picker  
**Then** no restore occurs  
**And** the current database remains unchanged

#### Scenario: User attempts to restore invalid backup file
**Given** the user is on the Settings screen  
**When** they tap "Restore from Backup"  
**And** confirm the warning dialog  
**And** select a file that is not a valid SQLite database  
**Then** an error message is displayed: "Invalid backup file. Please select a valid timetracker backup."  
**And** the current database remains unchanged

#### Scenario: User attempts to restore corrupted backup file
**Given** the user is on the Settings screen  
**When** they tap "Restore from Backup"  
**And** confirm the warning dialog  
**And** select a SQLite database file with corrupted or incompatible schema  
**Then** an error message is displayed: "Backup file is corrupted or incompatible."  
**And** the current database remains unchanged

---

### Requirement: Backup and restore operations provide user feedback
**Priority**: High  
**Type**: Functional

All backup and restore operations SHALL provide clear feedback to the user about progress and results.

#### Scenario: Backup operation shows progress
**Given** the user initiates a backup  
**When** the backup is in progress  
**Then** a loading indicator is displayed  
**And** the "Backup Database" button is disabled to prevent concurrent operations  
**When** the backup completes  
**Then** the loading indicator disappears  
**And** the button is re-enabled

#### Scenario: Restore operation shows progress
**Given** the user initiates a restore  
**When** the restore is in progress  
**Then** a loading indicator is displayed  
**And** the "Restore from Backup" button is disabled to prevent concurrent operations  
**When** the restore completes  
**Then** the loading indicator disappears  
**And** the button is re-enabled

---

### Requirement: Backup files use consistent naming convention
**Priority**: Medium  
**Type**: Functional

Backup files SHALL use a consistent naming pattern to help users identify and organize their backups.

#### Scenario: Default backup filename includes timestamp
**Given** the user initiates a backup  
**When** the file picker opens  
**Then** the suggested filename is "timetracker_backup_YYYYMMDD.db"  
**And** YYYYMMDD represents the current date (e.g., "20251110")  
**And** the user can modify the filename before saving

---

## REMOVED Requirements

### Requirement: CSV export available in Settings screen
**Reason**: CSV export functionality is now consolidated in the Reports screen where it's more contextually appropriate. The Reports screen already has CSV export with full filtering and date range options.

#### Scenario: CSV export removed from Settings
**Given** the user is on the Settings screen  
**Then** there is no "Export to CSV" option in the Backup & Export section  
**And** CSV export remains available in the Reports screen

---

## Implementation Notes

### File Picker Integration
- Use `file_picker` package (version ^8.0.0 or compatible)
- `FilePicker.platform.saveFile()` for backup (save mode)
- `FilePicker.platform.pickFiles()` for restore (file selection mode)
- Handle `null` return values (user cancellation) gracefully

### Database Operations
- Database connection must be closed before file copy operations
- Database connection must be reopened after operations complete
- Use file copy operations that are atomic (all-or-nothing)
- Original database should remain intact if restore fails

### Validation
- Validate backup file by attempting to open it as SQLite database
- Check for required tables: `tasks`, `categories`, `tags`, `task_tags`
- Schema version validation (if applicable)

### Error Messages
- Keep error messages user-friendly but informative
- Include actionable guidance where possible
- Log detailed errors for debugging

### Platform Compatibility
- Test on both Android and iOS
- Ensure file picker works with cloud storage (Google Drive, iCloud)
- Handle platform-specific file system constraints
