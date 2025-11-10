import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../services/database_service.dart';

class TaskRepository {
  final DatabaseService _dbService = DatabaseService();

  // Create a new task
  Future<int> createTask(Task task) async {
    final db = await _dbService.database;
    final id = await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'startTime DESC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by date range
  Future<List<Task>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'startTime BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'startTime DESC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks for a specific date (all tasks that started on that day)
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getTasksByDateRange(startOfDay, endOfDay);
  }

  // Update a task
  Future<int> updateTask(Task task) async {
    final db = await _dbService.database;
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    
    return await db.update(
      'tasks',
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    final db = await _dbService.database;
    
    // Delete task-tag relationships first (cascade will handle this, but being explicit)
    await db.delete(
      'task_tags',
      where: 'taskId = ?',
      whereArgs: [id],
    );
    
    // Delete the task
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add tag to task
  Future<void> addTagToTask(int taskId, int tagId) async {
    final db = await _dbService.database;
    await db.insert(
      'task_tags',
      {'taskId': taskId, 'tagId': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Remove tag from task
  Future<void> removeTagFromTask(int taskId, int tagId) async {
    final db = await _dbService.database;
    await db.delete(
      'task_tags',
      where: 'taskId = ? AND tagId = ?',
      whereArgs: [taskId, tagId],
    );
  }

  // Get all tags for a task
  Future<List<Tag>> getTagsForTask(int taskId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT tags.* FROM tags
      INNER JOIN task_tags ON tags.id = task_tags.tagId
      WHERE task_tags.taskId = ?
      ORDER BY tags.name
    ''', [taskId]);

    return List.generate(maps.length, (i) => Tag.fromMap(maps[i]));
  }

  // Set tags for a task (replaces all existing tags)
  Future<void> setTagsForTask(int taskId, List<int> tagIds) async {
    final db = await _dbService.database;
    
    // Remove all existing tags for this task
    await db.delete(
      'task_tags',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    
    // Add new tags
    for (final tagId in tagIds) {
      await db.insert(
        'task_tags',
        {'taskId': taskId, 'tagId': tagId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Get running tasks
  Future<List<Task>> getRunningTasks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: ['running'],
      orderBy: 'startTime DESC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status.toValue()],
      orderBy: 'startTime DESC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by filters (tags and/or category)
  Future<List<Task>> getTasksByFilters({
    List<int>? tagIds,
    int? categoryId,
  }) async {
    final db = await _dbService.database;
    
    // If no filters provided, return all tasks
    if ((tagIds == null || tagIds.isEmpty) && categoryId == null) {
      return getAllTasks();
    }
    
    // Build query based on filters
    if (tagIds != null && tagIds.isNotEmpty) {
      // Need to filter by tags (AND logic - task must have ALL selected tags)
      // Use SQL to find tasks that have all the specified tags
      final tagPlaceholders = List.filled(tagIds.length, '?').join(',');
      
      String query = '''
        SELECT DISTINCT tasks.* FROM tasks
        INNER JOIN task_tags ON tasks.id = task_tags.taskId
        WHERE task_tags.tagId IN ($tagPlaceholders)
      ''';
      
      List<dynamic> whereArgs = [...tagIds];
      
      // Add category filter if provided
      if (categoryId != null) {
        query += ' AND tasks.categoryId = ?';
        whereArgs.add(categoryId);
      }
      
      // Group by task and ensure all tags are present (AND logic)
      query += '''
        GROUP BY tasks.id
        HAVING COUNT(DISTINCT task_tags.tagId) = ?
        ORDER BY tasks.startTime DESC
      ''';
      whereArgs.add(tagIds.length);
      
      final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } else {
      // Only category filter
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'categoryId = ?',
        whereArgs: [categoryId],
        orderBy: 'startTime DESC',
      );
      
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    }
  }
}
