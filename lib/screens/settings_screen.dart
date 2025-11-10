import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/category_management_section.dart';
import '../widgets/tag_management_section.dart';
import '../services/backup_service.dart';
import '../repositories/task_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final TaskRepository _taskRepository = TaskRepository();
  bool _isBackupLoading = false;
  bool _isRestoreLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          const CategoryManagementSection(),
          const TagManagementSection(),
          const Divider(height: 32),

          // Backup & Export Section
          _buildSectionHeader(context, 'Backup & Export'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Database'),
            subtitle: const Text('Export your data to a backup file'),
            trailing: _isBackupLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            enabled: !_isBackupLoading && !_isRestoreLoading,
            onTap: _handleBackup,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore from Backup'),
            subtitle: const Text('Import data from a backup file'),
            trailing: _isRestoreLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            enabled: !_isBackupLoading && !_isRestoreLoading,
            onTap: _handleRestore,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Handle backup database operation
  Future<void> _handleBackup() async {
    setState(() {
      _isBackupLoading = true;
    });

    try {
      // Generate filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'timetracker_backup_$timestamp.db';

      // Let user choose directory to save backup
      final directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Location',
      );

      // User cancelled
      if (directoryPath == null) {
        setState(() {
          _isBackupLoading = false;
        });
        return;
      }

      // Create backup file path
      final backupPath = '$directoryPath/$fileName';

      // Create backup
      await _backupService.createBackup(backupPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup created successfully:\n$fileName\n\nSaved to: $directoryPath',
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackupLoading = false;
        });
      }
    }
  }

  /// Handle restore from backup operation
  Future<void> _handleRestore() async {
    try {
      // Check if any tasks are currently running
      final runningTasks = await _taskRepository.getRunningTasks();
      if (runningTasks.isNotEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Active Tasks Running'),
              content: const Text(
                'Active tasks are running. Please stop all tasks before restoring from backup.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Show confirmation dialog
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore from Backup'),
            content: const Text(
              'This will replace all current data. This action cannot be undone. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        // User cancelled confirmation
        if (confirmed != true) {
          return;
        }
      }

      setState(() {
        _isRestoreLoading = true;
      });

      // Open file picker to select backup file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.any,
        allowMultiple: false,
      );

      // User cancelled file picker
      if (result == null || result.files.isEmpty) {
        setState(() {
          _isRestoreLoading = false;
        });
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        throw Exception('Could not access selected file');
      }

      // Validate backup file
      final isValid = await _backupService.validateBackupFile(filePath);
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid backup file. Please select a valid timetracker backup.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          _isRestoreLoading = false;
        });
        return;
      }

      // Restore from backup
      await _backupService.restoreBackup(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database restored successfully from backup'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore backup: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoreLoading = false;
        });
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
