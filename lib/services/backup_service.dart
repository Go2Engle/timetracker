import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

/// Service for creating and restoring database backups
class BackupService {
  final DatabaseService _databaseService;

  BackupService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  /// Get the path to the current database file
  Future<String> getDatabasePath() async {
    final db = await _databaseService.database;
    return db.path;
  }

  /// Create a backup of the database to the specified destination path
  ///
  /// The database connection is temporarily closed during the copy operation
  /// to avoid file locking issues.
  ///
  /// Returns the destination path on success.
  /// Throws an exception if the backup fails.
  Future<String> createBackup(String destinationPath) async {
    try {
      // Get the current database path
      final sourcePath = await getDatabasePath();
      final sourceFile = File(sourcePath);

      // Verify source file exists
      if (!await sourceFile.exists()) {
        throw Exception('Database file not found');
      }

      // Close database connection before copying
      await _databaseService.close();

      try {
        // Copy database file to destination
        await sourceFile.copy(destinationPath);
        return destinationPath;
      } finally {
        // Reopen database connection
        await _databaseService.database;
      }
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Restore the database from a backup file
  ///
  /// The backup file is validated before restoration to ensure it's a valid
  /// SQLite database with the expected schema.
  ///
  /// The database connection is closed, the backup is copied to the database
  /// location, and the connection is reopened.
  ///
  /// Throws an exception if validation or restoration fails.
  Future<void> restoreBackup(String backupFilePath) async {
    try {
      // Validate the backup file before proceeding
      final isValid = await validateBackupFile(backupFilePath);
      if (!isValid) {
        throw Exception('Invalid backup file');
      }

      // Get the current database path
      final databasePath = await getDatabasePath();

      // Close database connection before replacing file
      await _databaseService.close();

      try {
        // Copy backup file to database location (overwrites existing)
        final backupFile = File(backupFilePath);
        await backupFile.copy(databasePath);
      } finally {
        // Reopen database connection
        await _databaseService.database;
      }
    } catch (e) {
      // Ensure database is reopened even if restore fails
      try {
        await _databaseService.database;
      } catch (_) {
        // Ignore errors when reopening after failure
      }
      throw Exception('Failed to restore backup: $e');
    }
  }

  /// Validate that a file is a valid timetracker database backup
  ///
  /// Checks that:
  /// - The file exists and can be read
  /// - The file is a valid SQLite database
  /// - The database contains the expected tables
  ///
  /// Returns true if the file is a valid backup, false otherwise.
  Future<bool> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Try to open as SQLite database
      Database? db;
      try {
        db = await openDatabase(filePath, readOnly: true);

        // Verify required tables exist
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('tasks', 'categories', 'tags', 'task_tags')",
        );

        // Should have all 4 required tables
        if (tables.length != 4) {
          return false;
        }

        return true;
      } finally {
        await db?.close();
      }
    } catch (e) {
      // If any error occurs during validation, file is not valid
      return false;
    }
  }
}
