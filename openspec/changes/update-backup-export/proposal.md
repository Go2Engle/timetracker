# Change Proposal: update-backup-export

## Status
Pending Approval

## Summary
Update the Settings screen's "Backup & Export" section to remove CSV export functionality (now available in the Reports view) and implement full database backup and restore capabilities using the system file picker.

## Motivation
Currently, the Settings screen has placeholder implementations for backup and restore, and includes a CSV export option that duplicates functionality already available in the Reports screen. Users need a simple, reliable way to:
- Create complete database backups to protect their time tracking data
- Restore from backups in case of device change or data loss
- Save backups to locations of their choice (Google Drive, local storage, etc.) using the native file picker

This change consolidates export features logically: CSV exports for reporting purposes remain in the Reports screen, while full database backup/restore lives in Settings for data management.

## Goals
- Remove CSV export from Settings screen (keep in Reports screen only)
- Implement database backup functionality using system file picker for save location
- Implement database restore functionality using system file picker for file selection
- Provide clear user feedback during backup/restore operations
- Ensure data integrity during backup and restore operations

## Non-Goals
- Cloud sync or automatic backup scheduling (future enhancement)
- Multiple backup formats (SQLite database only for now)
- Backup encryption (future enhancement)
- Incremental or differential backups (full database backup only)

## Affected Capabilities
- **backup-export** (NEW): Database backup and restore functionality

## Dependencies
- Requires `file_picker` Flutter package (new dependency)
- Existing `database_service.dart` for database access
- Existing `settings_screen.dart` for UI integration

## Risks & Mitigations
- **Risk**: User could restore corrupted or incompatible database backup
  - **Mitigation**: Validate database file before restore, show clear error messages
- **Risk**: Active tasks might be lost if database is replaced during restore
  - **Mitigation**: Check for running tasks and warn user before proceeding
- **Risk**: File picker permissions on different platforms
  - **Mitigation**: Use well-tested `file_picker` package with platform-specific handling

## References
- Current settings screen: `lib/screens/settings_screen.dart`
- Database service: `lib/services/database_service.dart`
- CSV export in reports: `lib/screens/reports_screen.dart`
