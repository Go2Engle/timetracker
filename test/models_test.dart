import 'package:flutter_test/flutter_test.dart';
import 'package:timetracker/models/task.dart';
import 'package:timetracker/models/category.dart';
import 'package:timetracker/models/tag.dart';

void main() {
  group('Task Model Tests', () {
    test('Task toMap and fromMap serialization', () {
      final now = DateTime.now();
      final task = Task(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        startTime: now,
        elapsedSeconds: 120,
        status: TaskStatus.running,
        categoryId: 5,
        createdAt: now,
        updatedAt: now,
      );

      final map = task.toMap();
      final deserializedTask = Task.fromMap(map);

      expect(deserializedTask.id, task.id);
      expect(deserializedTask.title, task.title);
      expect(deserializedTask.description, task.description);
      expect(deserializedTask.startTime.toIso8601String(), 
             task.startTime.toIso8601String());
      expect(deserializedTask.elapsedSeconds, task.elapsedSeconds);
      expect(deserializedTask.status, task.status);
      expect(deserializedTask.categoryId, task.categoryId);
    });

    test('Task defaults to stopped status with 0 elapsed seconds', () {
      final task = Task(
        title: 'New Task',
        startTime: DateTime.now(),
      );

      expect(task.status, TaskStatus.stopped);
      expect(task.elapsedSeconds, 0);
      expect(task.description, null);
      expect(task.categoryId, null);
    });

    test('Task copyWith creates modified copy', () {
      final task = Task(
        id: 1,
        title: 'Original',
        startTime: DateTime.now(),
      );

      final modified = task.copyWith(
        title: 'Modified',
        status: TaskStatus.running,
      );

      expect(modified.id, task.id);
      expect(modified.title, 'Modified');
      expect(modified.status, TaskStatus.running);
      expect(modified.startTime, task.startTime);
    });
  });

  group('Category Model Tests', () {
    test('Category toMap and fromMap serialization', () {
      final category = Category(
        id: 1,
        name: 'Work',
        color: '#FF5733',
      );

      final map = category.toMap();
      final deserialized = Category.fromMap(map);

      expect(deserialized.id, category.id);
      expect(deserialized.name, category.name);
      expect(deserialized.color, category.color);
    });
  });

  group('Tag Model Tests', () {
    test('Tag toMap and fromMap serialization', () {
      final tag = Tag(
        id: 1,
        name: 'urgent',
      );

      final map = tag.toMap();
      final deserialized = Tag.fromMap(map);

      expect(deserialized.id, tag.id);
      expect(deserialized.name, tag.name);
    });
  });

  group('TaskStatus Enum Tests', () {
    test('TaskStatus toValue and fromValue', () {
      expect(TaskStatus.running.toValue(), 'running');
      expect(TaskStatus.paused.toValue(), 'paused');
      expect(TaskStatus.stopped.toValue(), 'stopped');

      expect(TaskStatus.fromValue('running'), TaskStatus.running);
      expect(TaskStatus.fromValue('paused'), TaskStatus.paused);
      expect(TaskStatus.fromValue('stopped'), TaskStatus.stopped);
    });

    test('TaskStatus fromValue with invalid value defaults to stopped', () {
      expect(TaskStatus.fromValue('invalid'), TaskStatus.stopped);
    });
  });
}
