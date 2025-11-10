import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'timetracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create tags table
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        startTime TEXT NOT NULL,
        endTime TEXT,
        elapsedSeconds INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        categoryId INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // Create task_tags junction table for many-to-many relationship
    await db.execute('''
      CREATE TABLE task_tags (
        taskId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        PRIMARY KEY (taskId, tagId),
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_tasks_startTime ON tasks(startTime)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
    await db.execute('CREATE INDEX idx_tasks_categoryId ON tasks(categoryId)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here when schema changes
    // For now, we're on version 1, so no migrations needed
    if (oldVersion < newVersion) {
      // Example migration logic for future versions:
      // if (oldVersion < 2) {
      //   await db.execute('ALTER TABLE tasks ADD COLUMN newColumn TEXT');
      // }
    }
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Delete the database (useful for testing)
  Future<void> deleteDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'timetracker.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
