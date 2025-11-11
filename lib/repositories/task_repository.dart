import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../models/category.dart';
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

  /// Get tasks grouped by category
  /// Returns a Map where keys are Category objects (or null for uncategorized)
  /// and values are Lists of Tasks
  Future<Map<Category?, List<Task>>> getTasksGroupedByCategory() async {
    final db = await _dbService.database;
    
    // Get all tasks with their category info
    final query = '''
      SELECT tasks.*, categories.id as cat_id, categories.name as cat_name, 
             categories.color as cat_color, categories.createdAt as cat_createdAt
      FROM tasks
      LEFT JOIN categories ON tasks.categoryId = categories.id
      ORDER BY categories.name ASC, tasks.startTime DESC
    ''';
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    
    final Map<Category?, List<Task>> grouped = {};
    
    for (final map in maps) {
      final task = Task.fromMap(map);
      
      Category? category;
      if (map['cat_id'] != null) {
        category = Category(
          id: map['cat_id'] as int?,
          name: map['cat_name'] as String,
          color: map['cat_color'] as String,
          createdAt: DateTime.parse(map['cat_createdAt'] as String),
        );
      }
      
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(task);
    }
    
    return grouped;
  }

  /// Get time totals for each category
  /// Returns a List of Maps containing category, totalSeconds, and taskCount
  Future<List<Map<String, dynamic>>> getCategoryTimeTotals() async {
    final db = await _dbService.database;
    
    final query = '''
      SELECT 
        categories.id as cat_id,
        categories.name as cat_name,
        categories.color as cat_color,
        categories.createdAt as cat_createdAt,
        SUM(tasks.elapsedSeconds) as totalSeconds,
        COUNT(tasks.id) as taskCount
      FROM categories
      LEFT JOIN tasks ON tasks.categoryId = categories.id
      GROUP BY categories.id
      ORDER BY totalSeconds DESC
    ''';
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    
    final List<Map<String, dynamic>> results = [];
    
    for (final map in maps) {
      final category = Category(
        id: map['cat_id'] as int?,
        name: map['cat_name'] as String,
        color: map['cat_color'] as String,
        createdAt: DateTime.parse(map['cat_createdAt'] as String),
      );
      
      results.add({
        'category': category,
        'totalSeconds': map['totalSeconds'] as int? ?? 0,
        'taskCount': map['taskCount'] as int? ?? 0,
      });
    }
    
    // Add uncategorized tasks
    final uncategorizedQuery = '''
      SELECT 
        SUM(elapsedSeconds) as totalSeconds,
        COUNT(id) as taskCount
      FROM tasks
      WHERE categoryId IS NULL
    ''';
    
    final uncategorizedMaps = await db.rawQuery(uncategorizedQuery);
    if (uncategorizedMaps.isNotEmpty) {
      final totalSeconds = uncategorizedMaps.first['totalSeconds'] as int? ?? 0;
      final taskCount = uncategorizedMaps.first['taskCount'] as int? ?? 0;
      
      if (taskCount > 0) {
        results.add({
          'category': null,
          'totalSeconds': totalSeconds,
          'taskCount': taskCount,
        });
      }
    }
    
    return results;
  }
}

