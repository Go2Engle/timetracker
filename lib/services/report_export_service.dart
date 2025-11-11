import 'dart:io';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../repositories/task_repository.dart';
import '../repositories/category_repository.dart';

class ReportExportService {
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  /// Export tasks to CSV file
  /// Returns the file path on success, throws exception on error
  Future<String> exportToCSV(List<Task> tasks, int totalSeconds, String filePath) async {
    try {
      // Generate CSV content
      final csvContent = await _generateCSVContent(tasks, totalSeconds);
      
      // Write file
      final file = File(filePath);
      await file.writeAsString(csvContent);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to export report: $e');
    }
  }

  /// Generate CSV content from tasks
  Future<String> _generateCSVContent(List<Task> tasks, int totalSeconds) async {
    final buffer = StringBuffer();
    
    // Write header
    buffer.writeln('Title,Description,Start Time,End Time,Elapsed Time (HH:MM:SS),Status,Category,Tags');
    
    // Write each task
    for (final task in tasks) {
      // Fetch category name if task has a category
      String categoryName = '';
      if (task.categoryId != null) {
        final category = await _categoryRepository.getCategoryById(task.categoryId!);
        categoryName = category?.name ?? '';
      }
      
      // Fetch tags for task
      final tags = task.id != null ? await _taskRepository.getTagsForTask(task.id!) : <Tag>[];
      final tagNames = tags.map((tag) => tag.name).join(',');
      
      // Format task data
      final title = _escapeCsvField(task.title);
      final description = _escapeCsvField(task.description ?? '');
      final startTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(task.startTime);
      final endTime = task.endTime != null 
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(task.endTime!)
          : '';
      final elapsedTime = _formatDuration(task.elapsedSeconds);
      final status = task.status.toValue();
      final category = _escapeCsvField(categoryName);
      final tagsField = _escapeCsvField(tagNames);
      
      buffer.writeln('$title,$description,$startTime,$endTime,$elapsedTime,$status,$category,$tagsField');
    }
    
    // Write total row
    final totalTime = _formatDuration(totalSeconds);
    buffer.writeln('TOTAL,,,,,,$totalTime,');
    
    return buffer.toString();
  }

  /// Escape CSV field according to RFC 4180
  /// Wraps field in quotes if it contains comma, quote, or newline
  /// Escapes embedded quotes by doubling them
  String _escapeCsvField(String field) {
    if (field.isEmpty) return '';
    
    // Check if field needs escaping
    if (field.contains(',') || field.contains('"') || field.contains('\n') || field.contains('\r')) {
      // Escape quotes by doubling them
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    
    return field;
  }

  /// Format duration in seconds to HH:MM:SS
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${secs.toString().padLeft(2, '0')}';
  }
}
