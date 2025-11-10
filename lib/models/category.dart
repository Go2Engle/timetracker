class Category {
  final int? id;
  final String name;
  final String color;
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Category object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Category object from Map (database row)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy of Category with modified fields
  Category copyWith({
    int? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color)';
  }
}
