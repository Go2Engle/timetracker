import 'package:flutter_test/flutter_test.dart';
import 'package:timetracker/models/task.dart';
import 'package:timetracker/models/category.dart';
import 'package:timetracker/repositories/task_repository.dart';
import 'package:timetracker/repositories/category_repository.dart';
import 'package:timetracker/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late TaskRepository taskRepo;
  late CategoryRepository categoryRepo;
  late DatabaseService dbService;

  setUp(() async {
    dbService = DatabaseService();
    taskRepo = TaskRepository();
    categoryRepo = CategoryRepository();
    
    // Delete existing database to start fresh
    await dbService.deleteDatabase();
  });

  tearDown(() async {
    await dbService.deleteDatabase();
  });

  group('Task Grouping Repository Methods', () {
    test('getTasksGroupedByCategory groups tasks correctly', () async {
      // Create categories
      final workCategory = Category(name: 'Work', color: '#FF0000');
      final personalCategory = Category(name: 'Personal', color: '#00FF00');
      
      final workId = await categoryRepo.createCategory(workCategory);
      final personalId = await categoryRepo.createCategory(personalCategory);

      // Create tasks
      final task1 = Task(
        title: 'Task 1',
        startTime: DateTime.now(),
        categoryId: workId,
        elapsedSeconds: 3600,
      );
      final task2 = Task(
        title: 'Task 2',
        startTime: DateTime.now(),
        categoryId: workId,
        elapsedSeconds: 1800,
      );
      final task3 = Task(
        title: 'Task 3',
        startTime: DateTime.now(),
        categoryId: personalId,
        elapsedSeconds: 900,
      );
      final task4 = Task(
        title: 'Task 4 Uncategorized',
        startTime: DateTime.now(),
        elapsedSeconds: 600,
      );

      await taskRepo.createTask(task1);
      await taskRepo.createTask(task2);
      await taskRepo.createTask(task3);
      await taskRepo.createTask(task4);

      // Test grouping
      final grouped = await taskRepo.getTasksGroupedByCategory();

      expect(grouped.length, 3); // Work, Personal, Uncategorized
      
      // Find the work category group
      final workGroup = grouped.entries.firstWhere(
        (entry) => entry.key?.name == 'Work'
      );
      expect(workGroup.value.length, 2);

      // Find the personal category group
      final personalGroup = grouped.entries.firstWhere(
        (entry) => entry.key?.name == 'Personal'
      );
      expect(personalGroup.value.length, 1);

      // Find the uncategorized group
      final uncategorizedGroup = grouped.entries.firstWhere(
        (entry) => entry.key == null
      );
      expect(uncategorizedGroup.value.length, 1);
    });

    test('getCategoryTimeTotals calculates totals correctly', () async {
      // Create categories
      final workCategory = Category(name: 'Work', color: '#FF0000');
      final personalCategory = Category(name: 'Personal', color: '#00FF00');
      
      final workId = await categoryRepo.createCategory(workCategory);
      final personalId = await categoryRepo.createCategory(personalCategory);

      // Create tasks
      final task1 = Task(
        title: 'Task 1',
        startTime: DateTime.now(),
        categoryId: workId,
        elapsedSeconds: 3600,
      );
      final task2 = Task(
        title: 'Task 2',
        startTime: DateTime.now(),
        categoryId: workId,
        elapsedSeconds: 1800,
      );
      final task3 = Task(
        title: 'Task 3',
        startTime: DateTime.now(),
        categoryId: personalId,
        elapsedSeconds: 900,
      );
      final task4 = Task(
        title: 'Task 4 Uncategorized',
        startTime: DateTime.now(),
        elapsedSeconds: 600,
      );

      await taskRepo.createTask(task1);
      await taskRepo.createTask(task2);
      await taskRepo.createTask(task3);
      await taskRepo.createTask(task4);

      // Test totals
      final totals = await taskRepo.getCategoryTimeTotals();

      expect(totals.length, 3); // Work, Personal, Uncategorized

      // Work should have highest total (3600 + 1800 = 5400)
      final workTotal = totals.firstWhere(
        (t) => (t['category'] as Category?)?.name == 'Work'
      );
      expect(workTotal['totalSeconds'], 5400);
      expect(workTotal['taskCount'], 2);

      // Personal should have 900 seconds
      final personalTotal = totals.firstWhere(
        (t) => (t['category'] as Category?)?.name == 'Personal'
      );
      expect(personalTotal['totalSeconds'], 900);
      expect(personalTotal['taskCount'], 1);

      // Uncategorized should have 600 seconds
      final uncategorizedTotal = totals.firstWhere(
        (t) => t['category'] == null
      );
      expect(uncategorizedTotal['totalSeconds'], 600);
      expect(uncategorizedTotal['taskCount'], 1);
    });

    test('getCategoryTimeTotals excludes empty categories when no tasks', () async {
      // Create category with no tasks
      final emptyCategory = Category(name: 'Empty', color: '#FF0000');
      await categoryRepo.createCategory(emptyCategory);

      final totals = await taskRepo.getCategoryTimeTotals();

      // Should only include the empty category with 0 totals
      expect(totals.length, 1);
      expect(totals.first['taskCount'], 0);
      expect(totals.first['totalSeconds'], 0);
    });
  });
}
