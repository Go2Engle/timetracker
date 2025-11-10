import 'package:sqflite/sqflite.dart';
import '../models/tag.dart';
import '../services/database_service.dart';

class TagRepository {
  final DatabaseService _dbService = DatabaseService();

  // Create a new tag
  Future<int> createTag(Tag tag) async {
    final db = await _dbService.database;
    try {
      final id = await db.insert(
        'tags',
        tag.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return id;
    } catch (e) {
      // If duplicate name, throw custom error
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Tag with name "${tag.name}" already exists');
      }
      rethrow;
    }
  }

  // Get or create tag by name (useful for tag input)
  Future<Tag> getOrCreateTag(String name) async {
    final existing = await getTagByName(name);
    if (existing != null) return existing;

    final newTag = Tag(name: name);
    final id = await createTag(newTag);
    return newTag.copyWith(id: id);
  }

  // Get tag by ID
  Future<Tag?> getTagById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Tag.fromMap(maps.first);
  }

  // Get tag by name
  Future<Tag?> getTagByName(String name) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isEmpty) return null;
    return Tag.fromMap(maps.first);
  }

  // Get all tags
  Future<List<Tag>> getAllTags() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Tag.fromMap(maps[i]));
  }

  // Update a tag
  Future<int> updateTag(Tag tag) async {
    final db = await _dbService.database;
    try {
      return await db.update(
        'tags',
        tag.toMap(),
        where: 'id = ?',
        whereArgs: [tag.id],
      );
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Tag with name "${tag.name}" already exists');
      }
      rethrow;
    }
  }

  // Delete a tag
  Future<int> deleteTag(int id) async {
    final db = await _dbService.database;
    // This will cascade delete task_tags relationships
    return await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get tags used by tasks (tags that have at least one task association)
  Future<List<Tag>> getUsedTags() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT tags.* FROM tags
      INNER JOIN task_tags ON tags.id = task_tags.tagId
      ORDER BY tags.name ASC
    ''');

    return List.generate(maps.length, (i) => Tag.fromMap(maps[i]));
  }

  // Get all tags for a specific task
  Future<List<Tag>> getTagsForTask(int taskId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT tags.* FROM tags
      INNER JOIN task_tags ON tags.id = task_tags.tagId
      WHERE task_tags.taskId = ?
      ORDER BY tags.name ASC
    ''', [taskId]);

    return List.generate(maps.length, (i) => Tag.fromMap(maps[i]));
  }

  // Get count of tasks using this tag
  Future<int> getTagUsageCount(int tagId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM task_tags WHERE tagId = ?',
      [tagId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get all tags with usage counts
  Future<List<Map<String, dynamic>>> getAllTagsWithCount() async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT t.*, COUNT(tt.taskId) as taskCount
      FROM tags t
      LEFT JOIN task_tags tt ON tt.tagId = t.id
      GROUP BY t.id
      ORDER BY t.name ASC
    ''');
    return maps;
  }
}