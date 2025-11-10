import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class CategoryRepository {
  final DatabaseService _dbService = DatabaseService();

  // Create a new category
  Future<int> createCategory(Category category) async {
    final db = await _dbService.database;
    try {
      final id = await db.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return id;
    } catch (e) {
      // If duplicate name, throw custom error
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Category with name "${category.name}" already exists');
      }
      rethrow;
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  // Get category by name
  Future<Category?> getCategoryByName(String name) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // Update a category
  Future<int> updateCategory(Category category) async {
    final db = await _dbService.database;
    try {
      return await db.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Category with name "${category.name}" already exists');
      }
      rethrow;
    }
  }

  // Delete a category
  Future<int> deleteCategory(int id) async {
    final db = await _dbService.database;
    // This will set categoryId to NULL in tasks due to ON DELETE SET NULL
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get count of tasks using this category
  Future<int> getCategoryUsageCount(int categoryId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE categoryId = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get all categories with usage counts
  Future<List<Map<String, dynamic>>> getAllCategoriesWithCount() async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT c.*, COUNT(t.id) as taskCount
      FROM categories c
      LEFT JOIN tasks t ON t.categoryId = c.id
      GROUP BY c.id
      ORDER BY c.name ASC
    ''');
    return maps;
  }
}
