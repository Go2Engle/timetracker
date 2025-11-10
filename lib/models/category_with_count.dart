import 'category.dart';

class CategoryWithCount {
  final Category category;
  final int taskCount;

  CategoryWithCount({
    required this.category,
    required this.taskCount,
  });

  factory CategoryWithCount.fromMap(Map<String, dynamic> map) {
    return CategoryWithCount(
      category: Category.fromMap(map),
      taskCount: (map['taskCount'] as int?) ?? 0,
    );
  }
}
