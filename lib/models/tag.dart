class Tag {
  final int? id;
  final String name;
  final DateTime createdAt;

  Tag({
    this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Tag object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Tag object from Map (database row)
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy of Tag with modified fields
  Tag copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Tag(id: $id, name: $name)';
  }
}
