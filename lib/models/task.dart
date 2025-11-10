enum TaskStatus {
  running,
  paused,
  stopped;

  String toValue() => name;

  static TaskStatus fromValue(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TaskStatus.stopped,
    );
  }
}

class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final int elapsedSeconds;
  final TaskStatus status;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.elapsedSeconds = 0,
    this.status = TaskStatus.stopped,
    this.categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Task object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'elapsedSeconds': elapsedSeconds,
      'status': status.toValue(),
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Task object from Map (database row)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null 
          ? DateTime.parse(map['endTime'] as String) 
          : null,
      elapsedSeconds: map['elapsedSeconds'] as int? ?? 0,
      status: TaskStatus.fromValue(map['status'] as String),
      categoryId: map['categoryId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Create a copy of Task with modified fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    int? elapsedSeconds,
    TaskStatus? status,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, elapsedSeconds: $elapsedSeconds)';
  }
}
