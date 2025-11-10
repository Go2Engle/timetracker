import 'tag.dart';

class TagWithCount {
  final Tag tag;
  final int taskCount;

  TagWithCount({
    required this.tag,
    required this.taskCount,
  });

  factory TagWithCount.fromMap(Map<String, dynamic> map) {
    return TagWithCount(
      tag: Tag.fromMap(map),
      taskCount: (map['taskCount'] as int?) ?? 0,
    );
  }
}
